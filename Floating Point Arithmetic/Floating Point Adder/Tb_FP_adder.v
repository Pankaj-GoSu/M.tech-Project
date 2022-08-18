`timescale 1ns/1ps
module Tb_FP_adder;

 

reg clk;
reg add;
reg [31:0] number1;
reg [31:0] number2;
wire [31:0] result;
wire ready;

 

FP_Adder_32 UUT (clk, add, number1, number2, result, ready);

 

initial begin
clk = 0; 
forever
#5 clk = ~clk;
end

 

initial begin
add=0;
number1=0;
number2=0;

 

#1000;
add = 1;
number1= 32'b01001000100100100011010000101110;    //  299425.4375
number2= 32'b01001001011100010001011011000011 ;    //987500.234
#1000 add=0;
#1000 add=1;
number1= 32'b11001110010110000011011101001100;//-906875678.2358
number2= 32'b01001101011101100110011001001101;//258368723.235
//number1= 32'b01000010000011001110000000000000;//35.21875
//number2= 32'b01000001101010011101011100001010;//21.23
// result of addition   0b0100010111110100  , 0x45F4  ,  5.953
#100;
add = 0;

 

#1000 $stop;

 

end

 


endmodule