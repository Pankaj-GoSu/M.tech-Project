module FP_Adder_32(clk,add,number1,number2,result,ready);
input clk;
input add;
input [31:0] number1;
input [31:0] number2;
output reg [31:0] result;
output reg ready;

localparam RDY=3'b000,START=3'b001,NEGPOS=3'b010,OP=3'b011,SHIFT=3'b100,WRITE=3'b101,RSLT=3'b110;
//integer exp=
reg [3:0] state = RDY;
reg [276:0] bigreg;
reg [276:0] smallreg;
reg [276:0] resultreg;
reg resultsign;
reg [7:0] resultshift;
reg [22:0] resultfrac;
reg [8:0] pos=0;

integer bigshift,k;
integer smallshift;
//reg [5:0] i;

always @ (posedge clk) 

case (state)
RDY:
	if (add) 
	begin
	bigreg <= {127'b0,1'b1,149'b0};
	smallreg <= {127'b0,1'b1,149'b0};
	pos <= 9'b0;
	//i <= 6'd39;
	ready <= 0;
	state <= START;
	end
START:  
	begin
	if (number1[31] != number2[31]) // one of the no is negative
	 if (number1[30:23] > number2[30:23]) // if exponent of no1 is greater
	   begin 
	     bigreg[148:126] <= number1[22:0];
	     bigshift <= number1[30:23] - 7'b1111111;
	     resultsign <= number1[31];
	     smallreg[148:126] <= number2[22:0];
	     smallshift <= number2[30:23] - 7'b1111111;
	   end
	 else if (number2[30:23] > number1[30:23])// if exponent of no2 is greater
	       begin 
	         bigreg[148:126] <= number2[22:0];
	         bigshift <= number2[30:23] - 7'b1111111;
	         resultsign <= number2[31];
	         smallreg[148:126] <= number1[22:0];
	         smallshift <= number1[30:23] - 7'b1111111;
	       end
	 else // when both exponent are equal
	   begin
	     if (number1[22:0] > number2[22:0])// if mantessa of no1 is greater when exponent are equal
	       begin 
	         bigreg[148:126] <= number1[22:0];
	         bigshift <= number1[30:23] - 7'b1111111;
	         resultsign <= number1[31];
	         smallreg[148:126] <= number2[22:0];
	         smallshift <= number2[30:23] - 7'b1111111;
	       end
	     else if (number2[22:0] > number1[22:0])// if mantessa of no2 is greater when exponent are equal
	       begin 
	         bigreg[148:126] <= number2[22:0];
	         bigshift <= number2[30:23] - 7'b1111111;
	         resultsign <= number2[31];
	         smallreg[148:126] <= number1[22:0];
	         smallshift <= number1[30:23] - 7'b1111111;
	       end
	      else result <= {2'b00,7'b1111111,23'b0};// if mantessa of both are equal. here exponent are also equal
	   end
	else // when both no are either positive or negative
	 begin 
	   bigreg[148:126] <= number1[22:0];
	   bigshift <= number1[30:23] - 7'b1111111;
	   resultsign <= number1[31];
	   smallreg[148:126] <= number2[22:0];
	   smallshift <= number2[30:23] - 7'b1111111;
	 end
	state <= NEGPOS;
	end
NEGPOS: 
	begin
	if (bigshift > 0) 
	 bigreg <= bigreg << bigshift;
	else bigreg <= bigreg >> ((~bigshift)+1);
	if (smallshift > 0) 
	  smallreg <= smallreg << smallshift;
	else smallreg <= smallreg >> ((~smallshift)+1);
	  state <= OP;
	end
OP:     
	begin
	if (number1[31] != number2[31]) 
	 resultreg = bigreg - smallreg;
	else 
	 resultreg = bigreg + smallreg;
	state <= SHIFT;
	end
SHIFT:
  begin
	 for(k=0;k<=276;k=k+1)
	    begin
	     if(resultreg[k]==1'b1)
	       pos=k;
	      end
	state<=WRITE;
	end
  
	//if (resultreg[i] == 1'b1 || i == 0) begin//
	//pos = i;
	//state <= WRITE;
	//end
	//else i <= i - 1'b1;
	  
WRITE:  
	begin
	resultshift <= pos - 22;//pos - 149+127
	if (pos >= 11)
	resultfrac <= resultreg[pos-1 -: 23];   
	state <= RSLT; 
	end
RSLT:   
	begin
	result <= {resultsign,resultshift,resultfrac};
	ready <= 1'b1;
	state <= RDY;
	if(add==1'b0) state<=RDY;
	else state<= RSLT;
	
	end
endcase

endmodule

