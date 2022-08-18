library ieee;
use ieee.std_logic_1164.all;
package assign_logic_pack is 
    function assign_logic(  constant cond : Boolean;  constant trueval : std_logic;  constant falseval : std_logic)  return std_logic; 
    function assign_logic(  constant cond : Boolean;  constant trueval : std_logic_vector;  constant falseval : std_logic_vector)  return std_logic_vector; 
end package; 




package body assign_logic_pack is 
    function assign_logic(  constant cond : Boolean;  constant trueval : std_logic;  constant falseval : std_logic)  return std_logic is 
    begin
        if ( cond ) then 
             return trueval;
        else 
             return falseval;
        end if;
    end;
    function assign_logic(  constant cond : Boolean;  constant trueval : std_logic_vector;  constant falseval : std_logic_vector)  return std_logic_vector is 
    begin
        if ( cond ) then 
             return trueval;
        else 
             return falseval;
        end if;
    end;
end; 


library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use work.assign_logic_pack.all;


entity vscpu is 
generic (
        VSCPU_A_WIDTH : INTEGER := 6 ;
        VSCPU_D_WIDTH : INTEGER := 8 ;
        MEMSIZE : INTEGER := 63 ;
        PC_STARTS_AT : std_logic_vector( 5 downto 0) := "000001" 
       
    );
     port (
        clock :  in std_logic;
        reset :  in std_logic;
        start :  in std_logic;
        write :  in std_logic;
        addr :  in std_logic_vector( ( VSCPU_A_WIDTH - 1  )  downto 0  );
        data :  in std_logic_vector( ( VSCPU_D_WIDTH - 1  )  downto 0  );
        status :  out std_logic
    );
end entity; 


architecture rtl of vscpu is 
		  
	 type state_type is (ST_FETCH1,ST_FETCH2,ST_FETCH3,ST_ADD1,ST_ADD2,ST_AND1,ST_AND2,ST_JMP1,ST_INC1,ST_HALT);
	 type state_type_inst is (INSTR_add,INSTR_and,INSTR_jmp,INSTR_inc);
	 
	 
    type vscpu_memory_type is      array  (  0  to ( MEMSIZE - 1  ) )  of std_logic_vector(( VSCPU_D_WIDTH - 1  )  downto 0) ;
    signal mem : vscpu_memory_type;
    signal read : std_logic;
    signal data_rd : std_logic_vector( ( VSCPU_D_WIDTH - 1  )  downto 0  );
    signal address : std_logic_vector( ( VSCPU_A_WIDTH - 1  )  downto 0  );
    signal AC_ff : std_logic_vector( 7  downto 0  );
    signal AR_ff : std_logic_vector( ( VSCPU_A_WIDTH - 1  )  downto 0  );
    signal PC_ff : std_logic_vector( ( VSCPU_A_WIDTH - 1  )  downto 0  );
    signal DR_ff : std_logic_vector( ( VSCPU_D_WIDTH - 1  )  downto 0  );
    signal IR_ff : state_type_inst;
    signal AC_ns : std_logic_vector( 7  downto 0  );
    signal AR_ns : std_logic_vector( ( VSCPU_A_WIDTH - 1  )  downto 0  );
    signal PC_ns : std_logic_vector( ( VSCPU_A_WIDTH - 1  )  downto 0  );
    signal DR_ns : std_logic_vector( ( VSCPU_D_WIDTH - 1  )  downto 0  );
    signal IR_ns : state_type_inst;
    signal stvar_ff : state_type ;
    signal stvar_ns : state_type ;
	 
    begin 
        address <= assign_logic((stvar_ff = ST_HALT) , addr, AR_ff );
		  
        process 
        begin
            wait until ( clock'EVENT and ( clock = '1' )  ) ;
            if ( reset = '1') then 
					 for j in 0 to ( MEMSIZE - 1 )  loop
						  mem(j) <= "00000000" ;
                end loop;
						
                    
            else 
                if ( write = '1' and   read = '0'  ) then 
                    mem(to_integer(unsigned(address))) <= data;
                end if;
            end if;
        end process;
        data_rd <= assign_logic( ( read = '1'and  write  = '0')   , mem(to_integer(unsigned(address))), "ZZZZZZZZ" );
        
		  
		  process 
        begin
            wait until ( clock'EVENT and ( clock = '1' )  ) ;
            if ( ( reset = '1' )  ) then 
                stvar_ff <= ST_HALT;
            else 
                if ( ( start = '1' )  ) then 
                    stvar_ff <= ST_FETCH1;
                else 
                    stvar_ff <= stvar_ns;
                end if;
            end if;
        end process;
        
		  
		  process 
        begin
            wait until ( clock'EVENT and ( clock = '1' )  ) ;
            if ( ( reset = '1' )  ) then 
                AC_ff <= "00000000" ;
                PC_ff <= PC_STARTS_AT;
                AR_ff <= "000000" ;
                IR_ff <= INSTR_add;
                DR_ff <= "00000000" ;
            else 
                AC_ff <= AC_ns;
                PC_ff <= PC_ns;
                AR_ff <= AR_ns;
                IR_ff <= IR_ns;
                DR_ff <= DR_ns;
            end if;
        end process;
        
		  
		  process(stvar_ff,IR_ff,AR_ff) 
        begin
				stvar_ns <= stvar_ff;
            case  ( stvar_ff ) is 
                when 
                    ST_HALT => 
                    stvar_ns <= ST_HALT;
                when 
                    ST_FETCH1 => 
                    stvar_ns <= ST_FETCH2;
                when 
                    ST_FETCH2 => 
                    stvar_ns <= ST_FETCH3;
                when 
                    ST_FETCH3 => 
                    case  ( IR_ff ) is 
                        when 
                            INSTR_add=> 
                            stvar_ns <= ST_ADD1;
                        when 
                            INSTR_and => 
                            stvar_ns <= ST_AND1;
                        when 
                            INSTR_jmp => 
                            stvar_ns <= ST_JMP1;
                        when 
                            INSTR_inc => 
                            stvar_ns <= ST_INC1;
                    end case;
                when 
                    ST_ADD1 => 
                    stvar_ns <= ST_ADD2;
                when 
                    ST_AND1 => 
                    stvar_ns <= ST_AND2;
                when 
                    ST_JMP1 => 
                    stvar_ns <= ST_FETCH1;
                when 
                    ST_INC1 => 
                    stvar_ns <= ST_FETCH1;
                when 
                    ST_ADD2 => 
                    stvar_ns <= ST_FETCH1;
                when 
                    ST_AND2 => 
                    stvar_ns <= ST_FETCH1;
					 when others =>
							stvar_ns <= stvar_ff;
							
            end case;
			
        end process;
        
		  
		  process(stvar_ff) 
        begin
            
            if  ( (stvar_ff = ST_FETCH2 ) or ( stvar_ff = ST_ADD1  )  or ( stvar_ff = ST_AND1 )  ) then 
                read <= '1' ;
            else 
                read <= '0' ;
            end if;
        end process;
		  
        process(stvar_ff,IR_ff,AR_ff,PC_ff,DR_ff,AC_ff,data_rd,DR_ns) 
        begin
           
            AR_ns <= AR_ff;
            PC_ns <= PC_ff;
            DR_ns <= DR_ff;
            IR_ns <= IR_ff;
            AC_ns <= AC_ff;
            case  ( stvar_ff ) is 
                when 
                    ST_FETCH1=> 
                    AR_ns <= PC_ff;
                when 
                    ST_FETCH2=> 
                    PC_ns <= std_logic_vector(to_unsigned(to_integer(unsigned(PC_ff))+1,PC_ns'length)) ;
                    DR_ns <= data_rd;
						  if (DR_ns(( VSCPU_D_WIDTH - 1  )  downto ( VSCPU_D_WIDTH - 2  ) ) = "00") then
								IR_ns <= INSTR_add;
						  elsif (DR_ns(( VSCPU_D_WIDTH - 1  )  downto ( VSCPU_D_WIDTH - 2  ) ) = "01") then
								IR_ns <= INSTR_and;
						  elsif (DR_ns(( VSCPU_D_WIDTH - 1  )  downto ( VSCPU_D_WIDTH - 2  ) ) = "10") then
								IR_ns <= INSTR_jmp;
						  elsif (DR_ns(( VSCPU_D_WIDTH - 1  )  downto ( VSCPU_D_WIDTH - 2  ) ) = "11") then
								IR_ns <= INSTR_inc;
						  end if;
                    AR_ns <= DR_ns(( VSCPU_D_WIDTH - 3  )  downto 0 );
                when 
                    ST_FETCH3 => 
                when 
                    ST_ADD1 => 
                    DR_ns <= data_rd;
                when 
                    ST_ADD2 => 
                    AC_ns <= std_logic_vector(to_unsigned(to_integer(unsigned(AC_ff))+to_integer(unsigned( DR_ff)),AC_ns'length)) ;
                when 
                    ST_AND1 => 
                    DR_ns <= data_rd;
                when 
                    ST_AND2 => 
                    AC_ns <= ( AC_ff and DR_ff ) ;
                when 
                    ST_JMP1 => 
                    PC_ns <= DR_ff(( VSCPU_D_WIDTH - 3  )  downto 0 );
                when 
                    ST_INC1 => 
                    AC_ns <= std_logic_vector(to_unsigned(to_integer(unsigned( AC_ff ))+1,AC_ns'length)) ;
                when 
                     others  => 
            end case;
        end process;
        
		  
		  process 
        begin
            wait until ( clock'EVENT and ( clock = '1' )  ) ;
            if ( (  stvar_ff = ST_FETCH1  )  ) then 
                report " -----> AC = " & integer'image(to_integer(unsigned(AC_ff)));
            end if;
        end process;
        
		  process(clock) 
        begin
            report "CS:" & time'image(now) & "clk =" & std_logic'image(clock) & "rst =" & std_logic'image(reset) &
							"start =" & std_logic'image(start) & "write =" & std_logic'image(write) & "pc=" & integer'image(to_integer(unsigned(PC_ff))) & 
							"cstate =" & state_type'image(stvar_ff) & "ac=" & integer'image(to_integer(unsigned(AC_ff))) & "ir="& state_type_inst'image(IR_ff)& 
							"dr="& integer'image(to_integer(unsigned(DR_ff))) & "ar="& integer'image(to_integer(unsigned(AR_ff)))& "data_rd ="& integer'image(to_integer(unsigned(data_rd))) & 
							"read ="& std_logic'image(read) & "address =" & integer'image(to_integer(unsigned(address)));
        end process;
    end; 

	 
	 ---------------------------------
---------------------------------

library ieee ; use ieee.std_logic_1164.all ;

entity vscputb is end entity ;
architecture stim of vscputb is 

  constant INSTR_add : std_logic_vector( 1 downto 0 ) := "00" ;
  constant INSTR_and : std_logic_vector( 1 downto 0 ) := "01" ;
  constant INSTR_jmp : std_logic_vector( 1 downto 0 ) := "10" ;
  constant INSTR_inc : std_logic_vector( 1 downto 0 ) := "11" ;

  constant A_WIDTH : integer := 6 ; 
  constant D_WIDTH : integer := 8 ;
  
  signal clk , reset , start , write_en : std_logic ;
  signal addr : std_logic_vector( A_WIDTH-1 downto 0 ) ; 
  signal data : std_logic_vector ( D_WIDTH-1 downto 0 ) ;
  signal status : std_logic ;

  procedure do_synch_active_high_half_pulse ( 
      signal formal_p_clk : in std_logic ; 
      signal formal_p_sig : out std_logic 
    ) is
  begin
    wait until formal_p_clk='0' ;  formal_p_sig <= '1' ;
    wait until formal_p_clk='1' ;  formal_p_sig <= '0' ;
  end procedure ;

  procedure do_program ( 
      signal formal_p_clk : in std_logic ; 
      signal formal_p_write_en : out std_logic ; 
      signal formal_p_addr_out , formal_p_data_out : out std_logic_vector ;
      formal_p_ADDRESS_in , formal_p_DATA_in : in std_logic_vector     
    ) is
  begin
    wait until formal_p_clk='0' ;  formal_p_write_en <= '1' ;
    formal_p_addr_out <= formal_p_ADDRESS_in ; 
    formal_p_data_out <= formal_p_DATA_in ;
    wait until formal_p_clk='1' ;  formal_p_write_en <='0' ;
  end procedure ;

begin

  dut_vscpu : entity work.vscpu( rtl)
      port map ( clock => clk , reset => reset , start => start ,
             write => write_en , addr => addr  , data => data ) ;
             
  process begin
    clk <= '0' ;
    for i in 0 to 99 loop 
      wait for 1 ns ; clk <= '1' ;  wait for 1 ns ; clk <= '0';
    end loop ;
    wait ;
  end process ;

  
  process begin
    reset <= '0' ;  start <= '0' ; write_en <= '0' ;
    addr <= "000000" ;  data <= "00000000" ;
    do_synch_active_high_half_pulse ( clk, reset ) ; -- acc=0
    do_program ( clk, write_en, addr, data, "000001" , INSTR_add & "00" & "0101"  ) ; 
    -- LABEL1 acc += mem [ 5 ]
    do_program ( clk, write_en, addr, data, "000010" , INSTR_and & "00" & "0110"  ) ; 
    -- acc &= mem [ 6 ]
    do_program ( clk, write_en, addr, data, "000011" , INSTR_inc & "00" & "0000"  ) ; 
    -- acc += 1
    do_program ( clk, write_en, addr, data, "000100" , INSTR_jmp & "00" & "0001"  ) ; 
    -- jmp to LABEL1
    do_program ( clk, write_en, addr, data, "000101" , X"27"  ) ; -- mem[ 5 ]
    do_program ( clk, write_en, addr, data, "000110" , X"39"  ) ; -- mem[ 6 ]
    do_synch_active_high_half_pulse ( clk, start ) ; 
    wait ;
  end process ;
end architecture ;

