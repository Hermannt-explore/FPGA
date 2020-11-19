module 7-seg_decoder(num,disp);
input [3:0]num;
output [6:0]disp;


/*Boolean function disp*/

//In minterm form, disp0 = ~num[0]~num[1]~num[2]num[3] + ~num[0]num[1]~num[2]~num[3]
//+ num[0]~num[1]num[2]num[3] + num[0]num[1]~num[2]num[3]
//Reduction:
//disp0 = ~num[0](~num[1]~num[2]num[3] + num[1]~num[2]~num[3])
//+ num[0]num[3](~num[1]num[2] + num[1]~num[2]) 
//
//      = ~num[0]~num[2] (~num[1]num[3] + num[1]~num[3]) 
//+ num[0]num[3](~num[1]num[2] + num[1]~num[2]) 
//
//      = ~num[0]~num[2] (~num[1]num[3] + num[1]~num[3]) 
//+ num[0](~num[1]num[2]num[3] + num[1]~num[2]num[3]) 
//
//      = ~num[0]~num[2] (~num[1]num[3] + num[1]~num[3]) 
//+ num[0]num[3](~num[1]num[2] + num[1]~num[2]) 
//
//disp0 = ~num[0]~num[2] (num[1] XOR num[3]) + num[0]num[3](num[1] XOR num[2])

assign disp[0] = ~num[0] & ~num[2] & (num[1] ^ num[3]) 
| num[0] & num[3] & (num[1] ^ num[2]);

assign disp[1] = num[1] & ~num[2] & (num[0] ^ num[3])
| num[2] & (num[0] & num[3] | num[1] & ~num[3]);

assign disp[2] = num[0] & num[1] & (~num[3] | num[2] & num[3]) 
| ~num[0] & ~num[1] & num[2] & ~num[3];

assign disp[3] = ~num[0] & ~num[2] & (num[1] ^ num[3]) 
| num[2] & (num[1] & num[3] | num[0] & ~num[1] & ~num[3]);

assign disp[4] = num[3] & (~num[1] & ~num[2] | ~num[0] & num[2]) 
| ~num[0] & num[1] & ~num[2];

assign disp[5] = ~num[0] & ~num[1] & (num[2] | ~num[2] & num[3])
| num[1] & num[3] & (num[0] ^ num[2]);

assign disp[6] = ~num[0] & ~num[1] & ~num[2] | num[1] 
& (~num[0] & num[2] & num[3] | num[0] & ~num[2] & ~num[3]);


endmodule
