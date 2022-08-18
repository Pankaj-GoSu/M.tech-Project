

module FP_Multi_32(num1,num2,product);

input [31:0] num1,num2;
output [31:0] product;

wire [7:0] num1_exponent,num2_exponent,exponent,product_exponent ;
wire [22:0] num1_mantissa,num2_mantissa,product_mantissa ;
wire num1_sign,num2_sign,product_sign ;

wire [47:0] prod_mantissa;
wire [7:0] prod_exponent;

assign num1_exponent = num1[30:23];
assign num1_mantissa = num1[22:0];
assign num1_sign = num1[31];

assign num2_exponent = num2[30:23];
assign num2_mantissa = num2[22:0];
assign num2_sign = num2[31];

assign product_sign = num1_sign ^ num2_sign;

assign exponent = num1_exponent + num2_exponent;
assign prod_exponent = exponent - 8'd127;
 

assign prod_mantissa = {1'b1, num1_mantissa} * {1'b1, num2_mantissa};

assign product_mantissa = prod_mantissa[47] ? prod_mantissa[46:24] + prod_mantissa[23] : prod_mantissa[45:23] + prod_mantissa[22];
// assign prod2_mantissa = prod_mantissa[47:24] + {23'b0, 1'b0};
// assign product_mantissa = prod2_mantissa[22:0];
assign product_exponent = prod_mantissa[47] ? prod_exponent + 8'd1 : prod_exponent;

assign product = {product_sign, product_exponent, product_mantissa};

initial begin
     $monitor("%b",prod_mantissa);
end




endmodule