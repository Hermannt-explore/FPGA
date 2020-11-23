//THIS MODULE IS TESTED ON THE ALTERA DE-10LITE FPGA (50MHz CLOCK)
`timescale 1 ns / 1 ps

module tb();

reg clk;
reg sresetn;
reg MISO;
reg start_cmd;
reg [31:0]n_clks;
reg [31:0] tx_data;

wire SS_N;
wire MOSI;
wire SCLK;
wire spi_drv_rdy;
wire [31:0]rx_miso;


spi_drv check (.clk(clk), .sresetn(sresetn), .SS_N(SS_N), .MISO(MISO), .MOSI(MOSI), .SCLK(SCLK), .start_cmd(start_cmd), .spi_drv_rdy(spi_drv_rdy), .n_clks(n_clks), .tx_data(tx_data), .rx_miso(rx_miso));

//Produce 50Mhz clk
always
begin
	clk = 1'd1;
	#10;
	clk = 1'd0;
	#10;
end


initial
begin

sresetn = 0;
start_cmd = 1'd0;
n_clks = 6'b000100;
tx_data = 32'b1100;
MISO = 1'dx;

#400;

sresetn = 1;

#2000;
start_cmd = 1'd1;
#1000;
MISO = 1'd1;
start_cmd = 1'd0;
//tx_data = 32'b1010;
#2000;
MISO = 1'd0;
#2000;
MISO = 1'd1;
#2000;
MISO = 1'd0;
#2000;
MISO = 1'dx;
#2000;
//#2000
//start_cmd = 1'd1;
//#1000;
//MISO = 1'd1;
//start_cmd = 1'd0;
//#2000;
//MISO = 1'd1;
//#2000;
//MISO = 1'd1;
//#2000;
//MISO = 1'd0;
//#2000;
//MISO = 1'dx;

//start_cmd = 1'd0;

end

endmodule