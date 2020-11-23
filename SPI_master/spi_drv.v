module spi_drv (clk, sresetn, SS_N, MISO, MOSI, SCLK, start_cmd, spi_drv_rdy, n_clks, tx_data, rx_miso);


parameter CLK_DIVIDE = 32'd100;							//Used to Divide host clock, to create the desired SPI clock frequency. In this case SPI clock will be 0.5Mhz. Because Host clock is 50MHz.
parameter SPI_MAXLEN = 32;									//represents the maximum length of data transfered.

//Base clock inputs
input clk;														//Base clock from ASIC or FPGA
input sresetn;													//Reset trigger for SPI clock. Goes low when reset is activated.

//SPI pins
output SS_N;													//Goes low when SPI communication is happenning. Stays high otherwise.
input MISO;														//Port for receiving data
output MOSI;													//Port for sending data
output SCLK;													//SPI clock

//Command interface 
input	start_cmd;    											// Start SPI transfer
output	spi_drv_rdy;   									// Ready to begin a transfer
input	[$clog2(SPI_MAXLEN):0] n_clks;    			   // Number of bits (SCLK pulses) for the SPI transaction
input  [SPI_MAXLEN-1:0] tx_data;      					// Data to be transmitted out on MOSI
output [SPI_MAXLEN-1:0] rx_miso;      					// Data read in from MISO

//buffers (Mostly used to keep data stable)
reg SCLK_buffer = 1'd0;										//Buffer for SPI clock output.
reg [31:0] count = 32'd0;									//Counts each clock cycle of the host FPGA/ASIC.
reg [SPI_MAXLEN-1:0] rx_miso_buffer = {SPI_MAXLEN{1'b0}};			//Holds value of MISO data through a full SPI clock cycle.
reg mosi_buffer;												//Holds value of MOSI data through a full SPI clock cycle.
reg [31:0] tx_next= 32'd1;									//Determines which piece of data to send out next
reg [31:0] rx_next= 32'd1;									//Determines where to store next piece of data received
reg spi_drv_rdy_buffer = 1'd1;							//Goes low to inform host of SPI transaction start. Goes low inform host of SPI transaction completion 
reg [$clog2(SPI_MAXLEN):0]n_clks_buffer;				//Hold value of n_clks input throughout the transaction
reg [SPI_MAXLEN-1:0] tx_data_buffer;					//Holds value of data to be transfered throughout the transaction
reg transfer_complete = 1'd0;								//Goes high when transfer is complete. Stays low otherwise.
//reg ready = 1'd0;											//Intended to fascilitate timing after once transaction is complete.
reg data_valid = 1'd0;										//Goes high to indicate data on MISO is ready to be sampled and stored

//Produce SPI cock by dividing base clock
always @(posedge clk, negedge sresetn)		//On every positive edge of the base clock or when resetn goes low.
begin
	if (sresetn == 0)								//If reset is activated
	begin
		count <= 32'd0;							//Set clock count to zero (reset SPI clock).
	end
	else												//If reset is not activated
	begin
		count <= count + 32'd1;					//Increase count by one.
		if(count >= (CLK_DIVIDE))				//If count has reached the number of clocks required for one full cycle of SPI clock.
		count <= 32'd0;							//Reset count
	end
end
assign SCLK = (count >= (CLK_DIVIDE/2)) ? 1'd0 : 1'd1;	//Once count reaches half the number of clock cycles required for a full SPI clock cycle, Change the polarity of the SPI clock variable.

//Secure incoming data in buffers at every rising edge of the SPI clock or when the start command is received from the host.
always @ (posedge SCLK, posedge start_cmd)	
begin
	if(start_cmd == 1'd1)
	begin
		n_clks_buffer <= n_clks;
		tx_data_buffer <= tx_data;
		spi_drv_rdy_buffer <= 1'd0;		//inform the host of starting the SPI communication process.
	end
	else
	begin
		n_clks_buffer <= n_clks;
		tx_data_buffer <= tx_data_buffer;
		spi_drv_rdy_buffer <= transfer_complete ? 1'd1 : spi_drv_rdy_buffer;	//Inform the host of SPI communication status (0 for ongoing, 1 for completed)
	end	
end
assign spi_drv_rdy = transfer_complete ? /*(ready ? 1'd1 : 1'd0)*/ 1'd1 : spi_drv_rdy_buffer;	//spi_drv_rdy is high if the transaction complete. Low otherwise
assign SS_N = transfer_complete ? 1'd1 : spi_drv_rdy_buffer;	//spi_drv_rdy is high if the transaction complete. Low otherwise

//RECIEVE MISO DATA
always @(posedge SCLK, negedge spi_drv_rdy)					//Recieve data on positive edge of SPI clock or as soon as the SPI communication begins
begin	
	if(spi_drv_rdy == 0)												//If SPI communication begun
	begin		
		if(rx_next >= (n_clks_buffer+32'd1))					//If next piece of data to be received is out of the n_clks bounds, SPI communicatoin is complete
		begin
			rx_next <= 32'd1;
			rx_miso_buffer <= 32'd0;
			transfer_complete <= 1'd1;
//			ready <= 1'd0;
		end
		else																//If next piece of data to be received is in the n_clks bounds
		begin
			if(data_valid == 1)										//If data on the MISO port is valid, store next piece of data into the rx_miso_buffer
			begin
			rx_miso_buffer[n_clks_buffer-rx_next] <= MISO;
			rx_next <= rx_next + 32'd1;
			transfer_complete <= 1'd0;
//			ready <= 1'd0;
			end
			else															//If data on the MISO port is not valid, maintain the data in the rx_miso_buffer
			begin
				rx_next <= rx_next;
				rx_miso_buffer <= 32'd0;
				transfer_complete <= transfer_complete;
//				ready <= 1'd1;
			end
		end
	end
	else																	//If SPI communication is complete, reset buffers for next event
	begin
		rx_next <= 32'd1;
		rx_miso_buffer <= 32'd0;
		transfer_complete <= transfer_complete;
//		ready <= 1'd0;
	end		
end
assign rx_miso = transfer_complete ? rx_miso : rx_miso_buffer;	//Link rx_miso output to rx_miso_buffer

//PUT DATA ON MOSI PORT
always @ (negedge SCLK, negedge spi_drv_rdy)					//Send data on negative edge of SPI clock or as soon as the SPI communication begins
begin	
	if(SCLK == 0)														//If SPI clock is low
	begin	
		if(spi_drv_rdy == 1'd0)										//If SPI communication begun
			begin
				if (tx_next >= (n_clks_buffer+32'd1))			//If next piece of data to be sent is out of the n_clks bounds, SPI communicatoin is complete
				begin	
					mosi_buffer <= 32'dx;
					tx_next <= 32'd1;
					data_valid <= 1'd0;
				end
				else														//If next piece of data to be sent is in the n_clks bounds, SPI communicatoin begins
				begin
					mosi_buffer <= tx_data_buffer[n_clks_buffer-tx_next];			//put next piece of data on MOSI buffer
					tx_next <= tx_next + 32'd1;											//Increment tx_next for next piece of data
					data_valid <= 1'd1;														//Set data valid to 1. Because by now the data on the MISO port should be valid. Since SPI communication is synchronous
					
				end	
			end
		else																//If SPI communication is complete, reset buffers for next event
		begin
			mosi_buffer <= 32'dx;
			tx_next <= 32'd1;
			data_valid <= 1'd0;
		end
	end
	else 																	//If SPI clock is high, maintain buffers
	begin
		mosi_buffer <= mosi_buffer;
		tx_next <= tx_next;
		data_valid <= data_valid;
	end
	
end
assign MOSI = mosi_buffer;											//Link MOSI output to mosi_buffer


endmodule