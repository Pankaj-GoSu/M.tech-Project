
`timescale 1ns/ 1ps


module Tb_Asynchronous_FIFO;

	
// Inputs
	reg read_clk;
	reg write_clk;
	reg reset;

// Outputs
	wire [15:0] data_out;
	wire r_empty;
	wire w_full;

	// Instantiate the Unit Under Test (UUT)
	Asynchronous_FIFO a1 (.read_clk(read_clk), .write_clk(write_clk), .reset(reset), .data_out(data_out), .r_empty(r_empty), .w_full(w_full));

	initial begin
		// Initialize Inputs
		read_clk = 0;
		write_clk = 0;
		reset = 1;
		#4 reset=0;
	end
		
		always begin
		#10 write_clk = ~write_clk;
		end
		always begin
		#100 read_clk = ~read_clk;
		end
        

      
endmodule

