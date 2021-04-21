//THIS DESIGN IS IMPLEMENTED ON THE INTEL TERASIC DE10-LITE FPGA.
//THIS MODULE WAS SOURCED FROM https://www.ece.ucdavis.edu/~bbaas/180/tutorials/vga/
//AND MODIFIED TO FIT THIS PARTICULAR APPLICATION.
//--------------------------------------------------------------------------
//				vga_controller module				
//--------------------------------------------------------------------------
// This module sends signals to the on-board VGA device to communicate desired output.
//--------------------------------------------------------------------------
module vga_controller #(
   parameter h_pixels   = 640,   // horizontal display
   parameter h_fp       = 16,    // horizontal Front Porch
   parameter h_pulse    = 96,    // horizontal sync pulse
   parameter h_bp       = 48,    // horizontal back porch
   parameter h_pol      = 1'b0,  // horizontal sync polarity (1 = positive, 0 = negative)
   parameter v_pixels   = 480,   // vertical display
   parameter v_fp       = 10,    // vertical front porch
   parameter v_pulse    = 2,     // vertical pulse
   parameter v_bp       = 33,    // vertical back porch
   parameter v_pol      = 1'b0   // vertical sync polarity (1 = positive, 0 = negative)
	)
	( 
	input pixel_clk,           // Pixel clock
   input reset_n,             // Active low synchronous reset
	input [15:0]data_x,			//Accelerometer data (x-direction)
	input [15:0]data_y,			//Accelerometer data (y-direction)
   output reg h_sync,         // horizontal sync signal
   output reg v_sync,         // vertical sync signal
   output reg disp_ena,       // display enable (0 = all colors must be blank)
   output reg [31:0] column,  // horizontal pixel coordinate
   output reg [31:0] row,     // vertical pixel coordinate
   output [3:0]  red,    		// 4-bit color output
	output [3:0]  green,  		// 4-bit color output
	output [3:0]  blue,   		// 4-bit color output
	output [31:0]		sq_x_l,	//Square position (left-edge)
	output [31:0]		sq_x_r,	//Square position (right-edge)
	output [31:0]		sq_y_t,	//Square position (top-edge)
	output [31:0]		sq_y_b	//Square position (bottom-edge)
	);

   // Get total number of row and column pixel clocks
   localparam h_period = h_pulse + h_bp + h_pixels + h_fp;
   localparam v_period = v_pulse + v_bp + v_pixels + v_fp;

   // Full range counters
   reg [$clog2(h_period)-1:0] h_count;
   reg [$clog2(v_period)-1:0] v_count;

   //////////// Square Position Buffer //////////	
	reg [11:0]	sq_x_l_buffer	=	12'd310;
	reg [11:0]	sq_x_r_buffer	=	12'd330;
	reg [11:0]	sq_y_t_buffer	=	12'd230;
	reg [11:0]	sq_y_b_buffer	=	12'd250;	

	//////////// Accelerometer Data Buffer //////////
	reg [15:0] 	data_x_buffer = 16'hFFFF;
	reg [15:0]	data_y_buffer = 16'hFFFF;	
	
	//////////// Formatted Accelerometer Data //////////
	wire [11:0]data_x_trim;
	wire [11:0]data_y_trim;
	
   //////////// Net Assignments //////////
	assign data_x_trim = data_x_buffer[15:4];
	assign data_y_trim = data_y_buffer[15:4];
	assign sq_x_l = {20'd0,sq_x_l_buffer};
	assign sq_x_r = {20'd0,sq_x_r_buffer};
	assign sq_y_t = {20'd0,sq_y_t_buffer};
	assign sq_y_b = {20'd0,sq_y_b_buffer};


//============================================================================
// Buffering input data
//============================================================================	
always @(posedge pixel_clk) begin
	data_x_buffer <= data_x;
	data_y_buffer <= data_y;
end
//============================================================================
// Calculating square position according to input data
//============================================================================
always @(posedge pixel_clk) begin
	if (reset_n == 1'b0) begin
      sq_x_l_buffer	<=	12'd310;
		sq_x_r_buffer	<=	12'd330;
		sq_y_t_buffer	<=	12'd230;
		sq_y_b_buffer	<=	12'd250;	
	end
 else begin
		if (data_x_trim[11]==1) begin
			sq_x_l_buffer <= 12'd310 + ((~data_x_trim) << 4);
			sq_x_r_buffer <= 12'd330 + ((~data_x_trim) << 4);
		end
		else
		begin
			sq_x_l_buffer <= 12'd310 - ((data_x_trim) << 4) - 12'd1;
			sq_x_r_buffer <= 12'd330 - ((data_x_trim) << 4) - 12'd1;
		end
		if (data_y_trim[11]==1) begin
			sq_y_t_buffer <= 12'd230 + ((~data_y_trim) << 4);
			sq_y_b_buffer <= 12'd250 + ((~data_y_trim) << 4);
		end
		else
		begin
			sq_y_t_buffer <= 12'd230 - ((data_y_trim) << 4) - 12'd1;
			sq_y_b_buffer <= 12'd250 - ((data_y_trim) << 4) - 12'd1;
		end
	end
end
//============================================================================
// Synchronization signals generation
//============================================================================
always @(posedge pixel_clk) begin
	// Perform reset operations if needed
	if (reset_n == 1'b0) begin
		h_count  <= 0;
		v_count  <= 0;
		h_sync   <= ~ h_pol;
		v_sync   <= ~ v_pol;
		disp_ena <= 1'b0;
		column   <= 0;
		row      <= 0;
	end else begin

		// Pixel Counters
		if (h_count < h_period - 1) begin
			h_count <= h_count + 1;
		end else begin
			h_count <= 0;
			if (v_count < v_period - 1) begin
				v_count <= v_count + 1;
			end else begin
				v_count <= 0;
			end
		end

		// Horizontal Sync Signal
		if ( (h_count < h_pixels + h_fp) || (h_count > h_pixels + h_fp + h_pulse) ) begin
			h_sync <= ~ h_pol;
		end else begin
			h_sync <= h_pol;
		end

		// Vertical Sync Signal
		if ( (v_count < v_pixels + v_fp) || (v_count > v_pixels + v_fp + v_pulse) ) begin
			v_sync <= ~ v_pol;
		end else begin
			v_sync <= v_pol;
		end

		// Update Pixel Coordinates
		if (h_count < h_pixels) begin
			column <= h_count;
		end

		if (v_count < v_pixels) begin
			row <= v_count;
		end

		// Set display enable output
		if (h_count < h_pixels && v_count < v_pixels) begin
			disp_ena <= 1'b1;
		end else begin
			disp_ena <= 1'b0;
		end
	end
end

endmodule
