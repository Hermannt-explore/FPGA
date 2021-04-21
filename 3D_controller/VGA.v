//THIS DESIGN IS IMPLEMENTED ON THE INTEL TERASIC DE10-LITE FPGA.
//THIS MODULE WAS SOURCED FROM https://www.ece.ucdavis.edu/~bbaas/180/tutorials/vga/
//AND MODIFIED TO FIT THIS PARTICULAR APPLICATION.
//--------------------------------------------------------------------------
//				VGA module				
//--------------------------------------------------------------------------
// This module controls what will be printed on the screen and where.
//	This module outputs VGA synch and color data to the vga_controller module (vga_controller.v).
//--------------------------------------------------------------------------
module VGA (
   //////////// CLOCKS //////////
   input               MAX10_CLK1_50,
	
   //////////// ACCELEROMETER DATA //////////	
	input [15:0]data_x,
	input [15:0]data_y,
	
   //////////// VGA SIGNALS //////////
   output	[3:0]    VGA_R,
   output	[3:0]    VGA_G,
   output	[3:0]    VGA_B,
   output				VGA_HS,
   output          	VGA_VS,

   //////////// BUTTONS //////////
   input      [1:0]    KEY    // two board-level push buttons KEY1 - KEY0
);

//============================================================================
//  reg and wire declarations
//============================================================================

// vga buffer registers
reg  [3:0] vga_R, vga_G, vga_B;
reg vga_HS, vga_VS;

// Signals for drawing to the display. 
wire [31:0]    col, row;
wire [3:0]     red, green, blue;

// Timing signals - don't touch these.
wire           h_sync, v_sync;
wire           disp_ena;
wire           vga_clk;


wire	[31:0]		sq_x_l;
wire	[31:0]		sq_x_r;
wire	[31:0]		sq_y_t;
wire	[31:0]		sq_y_b;

//============================================================================
// Net Assignments
//============================================================================
assign VGA_R = vga_R;
assign VGA_G = vga_G;
assign VGA_B = vga_B;
assign VGA_HS = vga_HS;
assign VGA_VS = vga_VS;

// Register VGA output signals for timing purposes
always @(posedge vga_clk) begin
   if (disp_ena == 1'b1) begin
      if((col > sq_x_l && col < sq_x_r) && (row > sq_y_t && row < sq_y_b )) begin
			vga_R <= 4'hF;
			vga_B <= 4'hF;
			vga_G <= 4'hF;
		end
		else begin
			vga_R <= 4'h0;
			vga_B <= 4'h0;
			vga_G <= 4'h0;
		end
   end 
	else begin
      vga_R <= 4'h0;
      vga_B <= 4'h0;
      vga_G <= 4'h0;
   end
   vga_HS <= h_sync;
   vga_VS <= v_sync;
end

// Instantiate PLL to convert the 50 MHz clock to a 25 MHz clock for timing.
pll vgapll_inst (
    .inclk0    (MAX10_CLK1_50),
    .c0        (vga_clk)
    );

// Instantite VGA controller
vga_controller control (
   .pixel_clk  (vga_clk),
   .reset_n    (KEY[0]),
   .h_sync     (h_sync),
   .v_sync     (v_sync),
   .disp_ena   (disp_ena),
   .column     (col),
   .row        (row),
	.data_x		(data_x), 
	.data_y		(data_y),
	.sq_x_l		(sq_x_l),
	.sq_x_r		(sq_x_r),
	.sq_y_t		(sq_y_t),
	.sq_y_b		(sq_y_b)
   );

endmodule

