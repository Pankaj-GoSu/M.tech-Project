module TB_FP_multi;
reg [31:0] num1,num2;
wire [31:0] product;

FP_Multi_32 dut (num1,num2,product);
  initial 
    begin
    //   num1 = 32'b10111110100110011001100110011010;
    //   num2 = 32'b01000011111110100010000000000000;
      num1 = 32'b10111110100110011001100110011010;
      num2 = 32'b01000011111110100010000000000000;
      #10;
      $display("%b, %b, %b", num1, num2, product);
      $finish ;
    end
endmodule
