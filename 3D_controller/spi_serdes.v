//THIS DESIGN IS IMPLEMENTED ON THE INTEL TERASIC DE10-LITE FPGA.
//THIS MODULE WAS SOURCED FROM https://www.ece.ucdavis.edu/~bbaas/180/tutorials/accelerometer.html
//AND MODIFIED TO FIT THIS PARTICULAR APPLICATION.
//--------------------------------------------------------------------------
//				Spi_serdes module				
//--------------------------------------------------------------------------
// This module implements the 4-wire spi communication between the rest of the design 
// and the accelerometer device.
//	This module outputs position data to the spi_control module (spi_control.v).
//--------------------------------------------------------------------------
module spi_serdes(
	  // Host side signals
	  input                       reset_n,
	  input                       spi_clk,
	  input                       spi_clk_out,
	  input       [15:0]          data_tx,
	  input                       start,
	  output                      done,
	  output reg  [7:0]           data_rx,
	  // SPI side signals
	  output                      SPI_SDI,
	  input                       SPI_SDO,
	  output                      SPI_CSN,
	  output                      SPI_CLK
 );

//=======================================================
//  REG/WIRE declarations
//=======================================================
//
// State Encodings
localparam  IDLE = 0; // Wait for start.
localparam WRITE = 1; // Write out data.
localparam  READ = 2; // Read data.
localparam STALL = 3; // Stall for 1 cycle while asserting "done"

reg [1:0]  state = IDLE;
reg [3:0]  count;
reg [15:0] data_tx_reg;
reg read;

wire spi_active;
assign spi_active = (state == READ || state == WRITE);

// Chip select
assign SPI_CSN = ~(spi_active || start);
// SPI CLK
assign SPI_CLK = spi_active ? spi_clk_out : 1'b1;
// SPI Data. Hold high if not writing.
assign SPI_SDI = (state == WRITE) ? data_tx_reg[count] : 1'b1;
// Signal to higher level module that transaction is complete.
assign done    = (state == STALL);

/* Theory of operation:
*
* - Wait in the idle state until the "start" signal is asserted.
* - Capture the contents of the TX input.
* - Capture the upper most bit of the TX input. If it is '1', this is a read
*       operation and expect to receive 8 bits from the secondary.
*
*       On the otherhand, if it is a '0', this is a read operation and thus
*       the first 8 bits of TX data is an address, and the lower 8 bits are
*       data.
*
* - Write out the first 8 bits. If reading, switch to the read state and
*       shift in 8 bits of read data. Otherwise, write out the last 8 bits.
*
* - Branch to a STALL state to assert the "done" signal before returning
*       to IDLE. Unfortunately necessary for timing at a higher level.
*/

always @(posedge spi_clk or negedge reset_n) begin
    if (reset_n == 1'b0) begin
        state <= IDLE;
    end else begin
        case (state)
            IDLE : begin
                count <= 4'hf;
                if (start) begin
                    read        <= data_tx[15];
                    data_tx_reg <= data_tx;
                    state       <= WRITE;
                end
            end

            WRITE : begin
                // Decrement event counter
                count <= count - 1;
                // If reading and we're writing the last bit
                // Stay here if performing a write. Otherwise, branch to the
                // READ state.
                if (read && (count == 8)) begin
                    state <= READ;
                end else if (count == 0) begin
                    state <= STALL;
                end
            end

            READ : begin
                // Decrement event counter
                count <= count - 1;
                // Shift in data
                data_rx <= {data_rx[6:0],SPI_SDO};
                if (count == 0) begin
                    state <= STALL;
                end
            end
            // One clock cycle idle state.
            STALL: state <= IDLE;
        endcase
    end
end

endmodule
