`timescale 1ns / 100ps

module vscputb();

localparam [ 1 : 0 ] INSTR_add = 2'd0 ;
localparam [ 1 : 0 ] INSTR_and = 2'd1 ;
localparam [ 1 : 0 ] INSTR_jmp = 2'd2 ;
localparam [ 1 : 0 ] INSTR_inc = 2'd3 ;

localparam A_WIDTH = 6 ; localparam D_WIDTH = 8 ;
reg clk ; reg reset ; reg start ; reg write_en ;
reg [A_WIDTH-1:0] addr ; reg [D_WIDTH-1:0] data ;
wire status ;
vscpu vscpu ( .clock (clk) , .reset ( reset ) , .start ( start ) ,
             . write ( write_en ) , .addr ( addr ) , .data ( data ) ) ;
				 
initial begin
  clk = 0 ;
  forever begin
	 #1 clk = 1 ;
    #1 clk = 0 ;
  end
end

task do_reset ;
begin
  @(negedge clk ) ;  reset = 1 ;
  @(negedge clk ) ;  reset = 0 ;
end
endtask

task do_start ;
begin
  @(negedge clk ) ; start = 1 ;
  @(negedge clk ) ; start = 0 ;
end
endtask

task do_program ;
	input [A_WIDTH-1:0] ADDRESS;
	input [D_WIDTH-1:0] DATA;
begin
   @(negedge clk ) ; write_en = 1 ;
	addr = ADDRESS; data = DATA;
	@(negedge clk ) ; write_en = 0 ;
end
endtask

initial begin
  reset = 0 ;  start = 0 ; write_en = 0 ;
  addr = 0 ;  data = 0 ;
  do_reset ; // acc=0
  do_program ( 1 , {INSTR_add , 2'b0 , 4'b0101 }) ; // LABEL1 acc += mem [ 5 ]
  do_program ( 2 , {INSTR_and , 2'b0 , 4'b0110 }) ; // acc &= mem [ 6 ]
  do_program ( 3 , {INSTR_inc , 2'b0 , 4'b0000 }) ; // acc += 1
  do_program ( 4 , {INSTR_jmp , 2'b0 , 4'b0001 }) ; // jmp to LABEL1
  do_program ( 5 , 8'h27 ) ; // mem[ 5 ]
  do_program ( 6 , 8'h39 ) ; // mem[ 6 ]
  do_start ;
  #100 $finish ;
end
endmodule

`timescale 1ns / 100ps

module vscpu #(
	parameter VSCPU_A_WIDTH = 6 ,  parameter VSCPU_D_WIDTH = 8 ,
	parameter MEMSIZE = ((1<<VSCPU_A_WIDTH)-1) , // 64
	parameter PC_STARTS_AT = 6'b000001 )

(  input clock , input reset ,  input start ,
	input write ,  input [VSCPU_A_WIDTH-1:0] addr ,
	input [VSCPU_D_WIDTH-1:0] data ,  output reg status ) ;
	
	localparam [ 1 : 0 ] INSTR_add = 2'd0 ;  localparam [ 1 : 0 ] INSTR_and = 2'd1 ;
	localparam [ 1 : 0 ] INSTR_jmp = 2'd2 ;  localparam [ 1 : 0 ] INSTR_inc = 2'd3 ;
	localparam [ 5 : 0 ] ST_FETCH1 = 6'd1 ;  localparam [ 5 : 0 ] ST_FETCH2 = 6'd2 ;
	localparam [ 5 : 0 ] ST_FETCH3 = 6'd3 ;  localparam [ 5 : 0 ] ST_ADD1 = 6'd4 ;
	localparam [ 5 : 0 ] ST_ADD2 = 6'd5 ;  localparam [ 5 : 0 ] ST_AND1 = 6'd6 ;
	localparam [ 5 : 0 ] ST_AND2 = 6'd7 ;  localparam [ 5 : 0 ] ST_JMP1 = 6'd8 ;
	localparam [ 5 : 0 ] ST_INC1 = 6'd9 ;  localparam [ 5 : 0 ] ST_HALT = 6'd63 ;
	
	reg [VSCPU_D_WIDTH-1:0] mem [ 0 : MEMSIZE-1];
	
	reg read ;  wire [VSCPU_D_WIDTH-1:0] data_rd ;
	wire [VSCPU_A_WIDTH-1:0] address ;  reg [ 7 : 0 ] AC_ff ; // Accumulator
	reg [VSCPU_A_WIDTH-1:0] AR_ff ; // Address register
	reg [VSCPU_A_WIDTH-1:0] PC_ff ; // Program counter
	reg [VSCPU_D_WIDTH-1:0] DR_ff ; // Data register
	reg [ 1 : 0 ] IR_ff ; // Instruction register
	reg [ 7 : 0 ] AC_ns ; // Next state values
	reg [VSCPU_A_WIDTH-1:0] AR_ns ; //
	reg [VSCPU_A_WIDTH-1:0] PC_ns ; //
	reg [VSCPU_D_WIDTH-1:0] DR_ns ; //
	reg [ 1 : 0 ] IR_ns ; //
   reg [ 5 : 0 ] stvar_ff ;  reg [ 5 : 0 ] stvar_ns ;
	
	
	assign address = (ST_HALT == stvar_ff ) ? addr : AR_ff ;
	
	integer i ;
	always @ (posedge clock ) begin
		if ( reset ) begin
			for ( i = 0 ; i<MEMSIZE-1; i=i+1)
				mem[ i ] <= 0 ;
		end else
				if ( write & !read ) begin
					mem[ address ] <= data ;
				end
	end
	assign data_rd = ( read & ! write ) ? mem[ address ] : 8'bZ ;
	
	always @(posedge clock ) begin
		if ( reset == 1'b1 ) begin
			stvar_ff <= ST_HALT;
		end
		else	if ( start == 1'b1 ) begin
			stvar_ff <= ST_FETCH1;
		end else 
			stvar_ff <= stvar_ns ;
	end
	
	always @(posedge clock ) begin
		if ( reset == 1'b1 ) begin
			AC_ff <= 0 ;
			PC_ff <= PC_STARTS_AT;
			AR_ff <= 0 ;
			IR_ff <= 0 ;
			DR_ff <= 0 ;
		end else begin
			AC_ff <= AC_ns ; PC_ff <= PC_ns ;
			AR_ff <= AR_ns ; IR_ff <= IR_ns ;
			DR_ff <= DR_ns ;
		end
	end
	
	always @( * ) begin
		stvar_ns = stvar_ff ;
		case ( stvar_ff )
			ST_HALT: stvar_ns = ST_HALT;
			ST_FETCH1: stvar_ns = ST_FETCH2;
			ST_FETCH2: stvar_ns = ST_FETCH3;
			ST_FETCH3: begin
				case ( IR_ff )
					INSTR_add : stvar_ns = ST_ADD1;
					INSTR_and : stvar_ns = ST_AND1;
					INSTR_jmp : stvar_ns = ST_JMP1 ;
					INSTR_inc : stvar_ns = ST_INC1 ;
				endcase
			end
			ST_ADD1: stvar_ns = ST_ADD2;
			ST_AND1: stvar_ns = ST_AND2;
			ST_JMP1 : stvar_ns = ST_FETCH1;
			ST_INC1 : stvar_ns = ST_FETCH1;
			ST_ADD2 : stvar_ns = ST_FETCH1;
			ST_AND2 : stvar_ns = ST_FETCH1;
		endcase
	end
	
	always @( * ) begin
		if ( ( stvar_ff==ST_FETCH2) || ( stvar_ff==ST_ADD1) ||
			 ( stvar_ff==ST_AND1) )
			read = 1 ;
		else read = 0 ;
	end
	
	always @( * ) begin
		AR_ns = AR_ff ; PC_ns = PC_ff ;
		DR_ns = DR_ff ;    IR_ns = IR_ff ; AC_ns = AC_ff ;
		case ( stvar_ff )
			ST_FETCH1: AR_ns = PC_ff ;
			ST_FETCH2: begin
				PC_ns = PC_ff + 1 ; DR_ns = data_rd ;
				IR_ns = DR_ns [VSCPU_D_WIDTH-1: VSCPU_D_WIDTH-2];
				AR_ns = DR_ns [VSCPU_D_WIDTH-3 : 0 ] ;
			end
			ST_FETCH3: ;
			ST_ADD1: DR_ns = data_rd ;
			ST_ADD2: AC_ns = AC_ff + DR_ff ;
			ST_AND1: DR_ns = data_rd ;
			ST_AND2: AC_ns = AC_ff & DR_ff ; 
			ST_JMP1 : PC_ns = DR_ff[VSCPU_D_WIDTH-3 : 0 ] ;
			ST_INC1 : AC_ns = AC_ff + 1 ;
				default : ;
		endcase
	end
	
	always @(posedge clock ) begin
		if ( stvar_ff==ST_FETCH1)
			$display ( " -----> AC = 0x%x" , AC_ff ) ;
	end
	
	always @( clock ) begin
		$display ( "CS: %g clk =%x rst =%x start =%x write =%x pc=%x cstate =%x " 
							,$time , clock , reset , start , write ,  PC_ff , stvar_ff ,
							"ac=%x ir=%x dr=%x ar=%x data_rd =%x read =%x address =%x" ,
							AC_ff , IR_ff , DR_ff , AR_ff , data_rd , read , address ) ;
	end
endmodule
