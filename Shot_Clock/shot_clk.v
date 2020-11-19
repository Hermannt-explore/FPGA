module Lab4(clk, rst, pause, s0, disp0, disp1);
input clk, rst, pause, s0;
output [6:0] disp0, disp1;				//Drives the displays.
reg [31:0] count = 32'd0;				//Counts every clock cycle.
reg [4:0] sec = 5'd0;					//Counts number of seconds passed.
reg state = 1'd1;							//Keeps track of state (play=1/pause=0).
reg detect = 1'd0;						//Helps detect push of play/pause button.
reg dfault = 2'd0;						//Helps control behaviour on initial run of design.
parameter full_sec = 32'd50000000;	//How many 50Mhz clock cycles in a second.
wire [4:0] c_out;							//Holds current count down number.
wire [3:0] num_0;							//Drives disp0 with one's place part of c_cout.
wire [3:0] num_1;							//Drives disp1 with ten's place part of c_cout.
wire [4:0] start_num;					//Holds value of start time.

/*assign start time according to sw0*/
assign start_num = s0 ? 5'd24 : 5'd30;
/*Logic for clock*/
always @(posedge clk or negedge rst or negedge pause)
begin
	if (rst == 0)		//If reset, reset state, times, and pause/play detection.
	begin	
		count <= 32'd0;
		sec <= 5'd0;
		state <= 1'd1;
		detect <= 1'd0;
	end	
	else 
	begin
		if (pause == 0)		//If pause button is pushed down, set detect to 1.
		begin
			detect <= (dfault == 2'd0) ? 1'd0 : 1'd1;
		end
		else
		begin
			if ((detect == 1'd1) && (dfault != 2'd0))		//If paused button was released from a push down, change states (pause/play).
			begin
				detect <= 1'd0;			//Set detect back to 0.
				state <= ~state;			//Change state.
				if (state == 1'd1)		//If state is play, count. Else, don't count.
				begin
					/*Count*/
					count <= count + 32'd1;
					if (count >= full_sec - 32'd1)	//If 1 second is reached, increment sec.
					begin
						count <= 32'd0;
						sec <= sec + 5'd1;
						if (sec >= start_num - 5'd1)	//If sec is equal to start time.
							sec <= start_num;				//Hold sec's value as start time.
						/*Control behaviour at initial run*/
						if (dfault <= 2'd0)				
							dfault <= dfault + 2'd1;
							detect <= 1'd0;
					end
				end				
			end
			else			//If paused button was not released from a push down, do not change state.
			begin
				if (state == 1'd1)	//If state is play, count. Else, don't count.
				begin
					count <= count + 32'd1;
					if (count >= full_sec - 32'd1)	//If 1 second is reached, increment sec.
					begin
						count <= 32'd0;
						sec <= sec + 5'd1;
						if (sec >= start_num - 5'd1)	//If sec is equal to start time.
							sec <= start_num;				//Hold sec's value as start time.
						/*Control behaviour at initial run*/
						if (dfault <= 2'd0)
							dfault <= dfault + 2'd1;
							detect <= 1'd0;
					end
				end
			end
		end
	end
end	


/*assign count down numer*/
assign c_out = start_num - sec;

/*Seperate ten's place from one's place*/
assign num_0 = c_out % 5'd10;
assign num_1 = c_out / 5'd10;

/*Drive each displey according to num_0 and num_1*/

	/*Boolean function for disp0. */
	assign disp0[0] = (~num_0[3]&~num_0[2]&~num_0[1]&num_0[0]) | (~num_0[3]&num_0[2]&~num_0[1]&~num_0[0]);
	assign disp0[1] = (~num_0[3]&num_0[2]&~num_0[1]&num_0[0]) | (~num_0[3]&num_0[2]&num_0[1]&~num_0[0]);
	assign disp0[2] = (~num_0[3]&~num_0[2]&num_0[1]&~num_0[0]);
	assign disp0[3] = (~num_0[3]&~num_0[2]&~num_0[1]&num_0[0]) | (~num_0[3]&num_0[2]&~num_0[1]&~num_0[0]) | (~num_0[3]&num_0[2]&num_0[1]&num_0[0]);
	assign disp0[4] = (~num_0[3]&~num_0[2]&~num_0[1]&num_0[0]) | (~num_0[3]&~num_0[2]&num_0[1]&num_0[0]) | (~num_0[3]&num_0[2]&~num_0[1]&~num_0[0]) | (~num_0[3]&num_0[2]&~num_0[1]&num_0[0]) | (~num_0[3]&num_0[2]&num_0[1]&num_0[0]) | (num_0[3]&~num_0[2]&~num_0[1]&num_0[0]);
	assign disp0[5] = (~num_0[3]&~num_0[2]&~num_0[1]&num_0[0]) | (~num_0[3]&~num_0[2]&num_0[1]&~num_0[0]) | (~num_0[3]&~num_0[2]&num_0[1]&num_0[0]) | (~num_0[3]&num_0[2]&num_0[1]&num_0[0]);
	assign disp0[6] = (~num_0[3]&~num_0[2]&~num_0[1]&~num_0[0]) | (~num_0[3]&~num_0[2]&~num_0[1]&num_0[0]) | (~num_0[3]&num_0[2]&num_0[1]&num_0[0]);
	
	/*Boolean function for disp1. */
	assign disp1[0] = (~num_1[3]&~num_1[2]&~num_1[1]&num_1[0]) | (~num_1[3]&num_1[2]&~num_1[1]&~num_1[0]);
	assign disp1[1] = (~num_1[3]&num_1[2]&~num_1[1]&num_1[0]) | (~num_1[3]&num_1[2]&num_1[1]&~num_1[0]);
	assign disp1[2] = (~num_1[3]&~num_1[2]&num_1[1]&~num_1[0]);
	assign disp1[3] = (~num_1[3]&~num_1[2]&~num_1[1]&num_1[0]) | (~num_1[3]&num_1[2]&~num_1[1]&~num_1[0]) | (~num_1[3]&num_1[2]&num_1[1]&num_1[0]);
	assign disp1[4] = (~num_1[3]&~num_1[2]&~num_1[1]&num_1[0]) | (~num_1[3]&~num_1[2]&num_1[1]&num_1[0]) | (~num_1[3]&num_1[2]&~num_1[1]&~num_1[0]) | (~num_1[3]&num_1[2]&~num_1[1]&num_1[0]) | (~num_1[3]&num_1[2]&num_1[1]&num_1[0]) | (num_1[3]&~num_1[2]&~num_1[1]&num_1[0]);
	assign disp1[5] = (~num_1[3]&~num_1[2]&~num_1[1]&num_1[0]) | (~num_1[3]&~num_1[2]&num_1[1]&~num_1[0]) | (~num_1[3]&~num_1[2]&num_1[1]&num_1[0]) | (~num_1[3]&num_1[2]&num_1[1]&num_1[0]);
	assign disp1[6] = (~num_1[3]&~num_1[2]&~num_1[1]&~num_1[0]) | (~num_1[3]&~num_1[2]&~num_1[1]&num_1[0]) | (~num_1[3]&num_1[2]&num_1[1]&num_1[0]);


endmodule