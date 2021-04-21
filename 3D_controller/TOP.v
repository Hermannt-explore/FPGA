//THIS DESIGN IS EMPLEMETED ON THE INTEL TERASIC DE10-LITE FPGA
//--------------------------------------------------------------------------
//				Top level module				
//--------------------------------------------------------------------------
// This module instantiates the accelerometer and VGA modules.
//	This module facilitates access to the accelerometer and VGA devices for other modules.
//--------------------------------------------------------------------------

module TOP(
	
	//////////// CLOCK //////////
   input 		          		MAX10_CLK1_50,
	
   //////////// BUTTONS //////////
   input 		     [1:0]		KEY,
	
	//////////// VGA SIGNALS //////////
   output  [3:0]    VGA_R,
   output  [3:0]    VGA_G,
   output  [3:0]    VGA_B,
   output           VGA_HS,
   output           VGA_VS,

   //////////// ACCELEROMETER PORTS //////////
   output		          		GSENSOR_CS_N,
   input 		     [2:1]		GSENSOR_INT,
   output		          		GSENSOR_SCLK,
   inout 		          		GSENSOR_SDI,
   inout 		          		GSENSOR_SDO
	
	);

	//////////// DATA FROM ACCELEROMETER //////////
   wire 		     [15:0]		data_x;
	wire 		     [15:0]		data_y;	

//	--Instantiate accelerometer module
	accel my_accel (.MAX10_CLK1_50(MAX10_CLK1_50), .KEY(KEY), .GSENSOR_CS_N(GSENSOR_CS_N), .GSENSOR_INT(GSENSOR_INT), .GSENSOR_SCLK(GSENSOR_SCLK), .GSENSOR_SDI(GSENSOR_SDI), .GSENSOR_SDO(GSENSOR_SDO), .data_x(data_x), .data_y(data_y));
	
//	--Instantiate vga module
	VGA my_vga (.MAX10_CLK1_50(MAX10_CLK1_50), .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B), .VGA_HS(VGA_HS), .VGA_VS(VGA_VS), .KEY(KEY), .data_x(data_x), .data_y(data_y));

	
endmodule