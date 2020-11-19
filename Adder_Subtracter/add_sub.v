module Lab3(num0, num1, s, disp0, disp1, disp3, disp5);
input  [3:0] num0, num1;
input  s;
output [6:0] disp0;
output [6:0] disp1;
output [6:0] disp3;
output [6:0] disp5;
wire [3:0] a1;
wire init_carry; 
wire cin[2:0];
wire cout;
wire [3:0] r;
wire [3:0] result;


/*check operator bit. if s=1, pass !num1 to a1 and set initial_carry=1. if s=0, pass num1 to a1 and set initial_carry=0*/
assign a1 = s ? ~num1  : num1;
assign init_carry = s ? 1'b1 : 1'b0;

/*Add the numbers*/
fullAdder add0 (.a0(num0[3]), .a1(a1[3]), .c_in(init_carry), .sum(r[3]), .c_out(cin[0]));
fullAdder add1 (.a0(num0[2]), .a1(a1[2]), .c_in(cin[0]), .sum(r[2]), .c_out(cin[1]));
fullAdder add2 (.a0(num0[1]), .a1(a1[1]), .c_in(cin[1]), .sum(r[1]), .c_out(cin[2]));
fullAdder add3 (.a0(num0[0]), .a1(a1[0]), .c_in(cin[2]), .sum(r[0]), .c_out(cout));

/*Assign result if s=0 pass r directly to result. If s=1 and cout=1, pass r to result. if s=1 and cout=0, pass !r to result.*/
assign result = s ? (cout ? r : ~r) : r;

/*Boolean function for disp0. If s=1 and cout=0, implicitly display result+1. Otherwise, display result.*/
assign disp0[0] = s ? ( cout ? (~result[0]&~result[1]&~result[2]&result[3]) | (~result[0]&result[1]&~result[2]&~result[3]) | (result[0]&~result[1]&result[2]&result[3]) | (result[0]&result[1]&~result[2]&result[3]) : (~result[0]&~result[1]&~result[2]&~result[3]) | (~result[0]&~result[1]&result[2]&result[3]) | (result[0]&~result[1]&result[2]&~result[3]) | (result[0]&result[1]&~result[2]&~result[3]) | (result[0]&result[1]&result[2]&result[3]) ) : (~result[0]&~result[1]&~result[2]&result[3]) | (~result[0]&result[1]&~result[2]&~result[3]) | (result[0]&~result[1]&result[2]&result[3]) | (result[0]&result[1]&~result[2]&result[3]);

assign disp0[1] = s ? ( cout ? (~result[0]&result[1]&~result[2]&result[3]) | (~result[0]&result[1]&result[2]&~result[3]) | (result[0]&result[1]&~result[2]&~result[3]) | (result[0]&~result[1]&result[2]&result[3]) | (result[0]&result[1]&result[2]&~result[3]) | (result[0]&result[1]&result[2]&result[3]) : (~result[0]&result[1]&~result[2]&~result[3]) | (~result[0]&result[1]&~result[2]&result[3]) | (result[0]&~result[1]&result[2]&~result[3]) | (result[0]&~result[1]&result[2]&result[3]) | (result[0]&result[1]&~result[2]&result[3]) | (result[0]&result[1]&result[2]&~result[3]) | (result[0]&result[1]&result[2]&result[3]) ) : (~result[0]&result[1]&~result[2]&result[3]) | (~result[0]&result[1]&result[2]&~result[3]) | (result[0]&result[1]&~result[2]&~result[3]) | (result[0]&~result[1]&result[2]&result[3]) | (result[0]&result[1]&result[2]&~result[3]) | (result[0]&result[1]&result[2]&result[3]);

assign disp0[2] = s ? ( cout ? (~result[0]&~result[1]&result[2]&~result[3]) | (result[0]&result[1]&~result[2]&~result[3]) | (result[0]&result[1]&result[2]&~result[3]) | (result[0]&result[1]&result[2]&result[3]) : (~result[0]&~result[1]&~result[2]&result[3]) | (result[0]&~result[1]&result[2]&result[3]) | (result[0]&result[1]&~result[2]&result[3]) | (result[0]&result[1]&result[2]&~result[3]) | (result[0]&result[1]&result[2]&result[3]) ) : (~result[0]&~result[1]&result[2]&~result[3]) | (result[0]&result[1]&~result[2]&~result[3]) | (result[0]&result[1]&result[2]&~result[3]) | (result[0]&result[1]&result[2]&result[3]);

assign disp0[3] = s ? ( cout ? (~result[0]&~result[1]&~result[2]&result[3]) | (~result[0]&result[1]&~result[2]&~result[3]) | (result[0]&~result[1]&result[2]&~result[3]) | (~result[0]&result[1]&result[2]&result[3]) | (result[0]&result[1]&result[2]&result[3]) : (~result[0]&~result[1]&~result[2]&~result[3]) | (~result[0]&~result[1]&result[2]&result[3]) | (~result[0]&result[1]&result[2]&~result[3]) | (result[0]&~result[1]&~result[2]&result[3]) | (result[0]&result[1]&result[2]&~result[3]) | (result[0]&result[1]&result[2]&result[3]) ) : (~result[0]&~result[1]&~result[2]&result[3]) | (~result[0]&result[1]&~result[2]&~result[3]) | (result[0]&~result[1]&result[2]&~result[3]) | (~result[0]&result[1]&result[2]&result[3]) | (result[0]&result[1]&result[2]&result[3]);

assign disp0[4] = s ? ( cout ? (~result[0]&~result[1]&~result[2]&result[3]) | (~result[0]&result[1]&~result[2]&~result[3]) | (~result[0]&~result[1]&result[2]&result[3]) | (~result[0]&result[1]&~result[2]&result[3]) | (result[0]&~result[1]&~result[2]&result[3]) | (~result[0]&result[1]&result[2]&result[3]) : (~result[0]&~result[1]&~result[2]&~result[3]) | (~result[0]&~result[1]&result[2]&~result[3]) | (~result[0]&result[1]&~result[2]&~result[3]) | (result[0]&~result[1]&~result[2]&~result[3]) | (~result[0]&~result[1]&result[2]&result[3]) | (~result[0]&result[1]&result[2]&~result[3]) | (result[0]&result[1]&result[2]&result[3]) ): (~result[0]&~result[1]&~result[2]&result[3]) | (~result[0]&result[1]&~result[2]&~result[3]) | (~result[0]&~result[1]&result[2]&result[3]) | (~result[0]&result[1]&~result[2]&result[3]) | (result[0]&~result[1]&~result[2]&result[3]) | (~result[0]&result[1]&result[2]&result[3]);

assign disp0[5] = s ? ( cout ? (~result[0]&~result[1]&~result[2]&result[3]) | (~result[0]&~result[1]&result[2]&~result[3]) | (~result[0]&~result[1]&result[2]&result[3]) | (~result[0]&result[1]&result[2]&result[3]) | (result[0]&result[1]&~result[2]&result[3]) : (~result[0]&~result[1]&~result[2]&~result[3]) | (~result[0]&~result[1]&~result[2]&result[3]) | (~result[0]&~result[1]&result[2]&~result[3]) | (~result[0]&result[1]&result[2]&~result[3]) | (result[0]&result[1]&~result[2]&~result[3]) | (result[0]&result[1]&result[2]&result[3]) ) : (~result[0]&~result[1]&~result[2]&result[3]) | (~result[0]&~result[1]&result[2]&~result[3]) | (~result[0]&~result[1]&result[2]&result[3]) | (~result[0]&result[1]&result[2]&result[3]) | (result[0]&result[1]&~result[2]&result[3]);

assign disp0[6] = s ? ( cout ? (~result[0]&~result[1]&~result[2]&~result[3]) | (~result[0]&~result[1]&~result[2]&result[3]) | (result[0]&result[1]&~result[2]&~result[3]) | (~result[0]&result[1]&result[2]&result[3]) : (~result[0]&~result[1]&~result[2]&~result[3]) | (~result[0]&result[1]&result[2]&~result[3]) | (result[0]&~result[1]&result[2]&result[3]) | (result[0]&result[1]&result[2]&result[3]) ) : (~result[0]&~result[1]&~result[2]&~result[3]) | (~result[0]&~result[1]&~result[2]&result[3]) | (result[0]&result[1]&~result[2]&~result[3]) | (~result[0]&result[1]&result[2]&result[3]);

/*Boolean function for disp1. If s=0 and cout=1, display "1". If s=1 and cout=0, display "-".Display nothing otherwise. */
assign disp1 = s ? (cout ? 7'b1111111 : 7'b0111111) : (cout ? 7'b1111001 : 7'b1111111);

/*Boolean function for disp3*/
assign disp3[0] = ~num1[0] & ~num1[2] & (num1[1] ^ num1[3]) 
| num1[0] & num1[3] & (num1[1] ^ num1[2]);

assign disp3[1] = num1[1] & ~num1[2] & (num1[0] ^ num1[3])
| num1[2] & (num1[0] & num1[3] | num1[1] & ~num1[3]);

assign disp3[2] = num1[0] & num1[1] & (~num1[3] | num1[2] & num1[3]) 
| ~num1[0] & ~num1[1] & num1[2] & ~num1[3];

assign disp3[3] = ~num1[0] & ~num1[2] & (num1[1] ^ num1[3]) 
| num1[2] & (num1[1] & num1[3] | num1[0] & ~num1[1] & ~num1[3]);

assign disp3[4] = num1[3] & (~num1[1] & ~num1[2] | ~num1[0] & num1[2]) 
| ~num1[0] & num1[1] & ~num1[2];

assign disp3[5] = ~num1[0] & ~num1[1] & (num1[2] | ~num1[2] & num1[3])
| num1[1] & num1[3] & (num1[0] ^ num1[2]);

assign disp3[6] = ~num1[0] & ~num1[1] & ~num1[2] | num1[1] 
& (~num1[0] & num1[2] & num1[3] | num1[0] & ~num1[2] & ~num1[3]);


/*Boolean function for disp5*/
assign disp5[0] = ~num0[0] & ~num0[2] & (num0[1] ^ num0[3]) 
| num0[0] & num0[3] & (num0[1] ^ num0[2]);

assign disp5[1] = num0[1] & ~num0[2] & (num0[0] ^ num0[3])
| num0[2] & (num0[0] & num0[3] | num0[1] & ~num0[3]);

assign disp5[2] = num0[0] & num0[1] & (~num0[3] | num0[2] & num0[3]) 
| ~num0[0] & ~num0[1] & num0[2] & ~num0[3];

assign disp5[3] = ~num0[0] & ~num0[2] & (num0[1] ^ num0[3]) 
| num0[2] & (num0[1] & num0[3] | num0[0] & ~num0[1] & ~num0[3]);

assign disp5[4] = num0[3] & (~num0[1] & ~num0[2] | ~num0[0] & num0[2]) 
| ~num0[0] & num0[1] & ~num0[2];

assign disp5[5] = ~num0[0] & ~num0[1] & (num0[2] | ~num0[2] & num0[3])
| num0[1] & num0[3] & (num0[0] ^ num0[2]);

assign disp5[6] = ~num0[0] & ~num0[1] & ~num0[2] | num0[1] 
& (~num0[0] & num0[2] & num0[3] | num0[0] & ~num0[2] & ~num0[3]);


endmodule