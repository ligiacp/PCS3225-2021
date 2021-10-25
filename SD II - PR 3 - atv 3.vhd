library IEEE;
use ieee.math_real.ceil;
use ieee.math_real.log2;
use ieee.numeric_bit.all;

---------------------registrador component -----------------------

entity reg is 
	generic (wordSize : natural := 4);
    port (
    	clock : in bit;
        reset : in bit;
        load: in bit;
        d : in bit_vector(wordSize-1 downto 0);
        q : out bit_vector(wordSize-1 downto 0)
    );
end reg;
			-----------arch-------
architecture atv1 of reg is
	signal internal: bit_vector (wordSize-1 downto 0);
    
    begin 
    
    parametrizavel : process (clock, reset, load)
   	begin
    	if reset = '1' then
        	internal <= (others => '0');
		elsif (clock'event and clock = '1' and load ='1') then
        	if (load ='1') then
        		internal <= d;
            end if;
        end if;
	end process;
    q <= internal;       	
   
end atv1;

---------------------- fim do registrador component----------------

library IEEE;
use ieee.math_real.ceil;
use ieee.math_real.log2;
use ieee.numeric_bit.all;


-----------------------banco de registradores component----------------------

entity regfile is 
	generic (
    	regn : natural := 32;
        wordSize : natural := 64
    );
    port (
    	clock : in bit;
        reset : in bit;
        regWrite : in bit;
        rr1, rr2, wr : in bit_vector(natural(ceil(log2(real(regn))))-1 downto 0);
        d : in bit_vector(wordSize-1 downto 0);
        q1, q2 : out bit_vector(wordSize-1 downto 0)
    );
end regfile;

			---------arch -----------
              
architecture atv2 of regfile is

	component reg is 
		generic (wordSize : natural := 4);
    	port (
    		clock : in bit;
        	reset : in bit;
        	load: in bit;
        	d : in bit_vector(wordSize-1 downto 0);
        	q : out bit_vector(wordSize-1 downto 0)
    	);
	end component;
    
    	----types-----
    
    type word_address is array (0 to regn) of bit_vector(wordSize-1 downto 0);
    type bit_address is array (0 to regn) of bit;
    
    	----signals-----
	
    signal in_address : bit_vector(natural(ceil(log2(real(regn))))-1 downto 0);
    signal out_address1 : bit_vector(natural(ceil(log2(real(regn))))-1 downto 0);
    signal out_address2 : bit_vector(natural(ceil(log2(real(regn))))-1 downto 0);
    
    signal in_var : word_address := (others=>(others=>'0'));
    signal out_var : word_address := (others=>(others=>'0'));
    
    signal load_var : bit_address;
    
    
	begin

		register_generate : for k in 0 to regn-1 generate
        	register_k : reg generic map(wordSize) port map (clock, reset, load_var(k), in_var(k), out_var(k));
            load_var(k) <=  '0' when (k = regn - 1)else 
            				'1' when (k = to_integer(unsigned(wr)) and regWrite = '1') else 
                            '0';
            in_var(k) <= d when (k = to_integer(unsigned(wr)) and regWrite = '1') else  (others =>'0');
        end generate register_generate;
        
               
        in_address <= wr;
        out_address1 <= rr1;
        out_address2 <= rr2;
        

        
        q1 <= out_var(to_integer(unsigned(out_address1)));
        q2 <= out_var(to_integer(unsigned(out_address2)));
end atv2;

----------------------------------fim de banco de registradores component ---------------

library IEEE;
use ieee.math_real.ceil;
use ieee.math_real.log2;
use ieee.numeric_bit.all;

----------------------------------somador 16 bits component--------------------------------------

entity somador16 is ---unsigned
	port(
    	a : in bit_vector(15 downto 0);
        b : in bit_vector(15 downto 0);
        saida : out bit_vector(15 downto 0) ------------talvez de problema de overflow
    );
end somador16;

			------------arch------------
     
architecture soma of somador16 is
    begin
    saida <= bit_vector(unsigned(a)+unsigned(b));
end soma;

-------------------------------------fim do somador 16 bits component -----------------------

library IEEE;
use ieee.math_real.ceil;
use ieee.math_real.log2;
use ieee.numeric_bit.all;

----------------------------------subtrator 16 bits component--------------------------------------

entity subtrator16 is ---unsigned
	port(
    	a : in bit_vector(15 downto 0);
        b : in bit_vector(15 downto 0);
        saida : out bit_vector(15 downto 0) ------------talvez de problema de overflow
    );
end subtrator16;

			------------arch------------
     
architecture subtracao of subtrator16 is
    begin
    saida <= bit_vector(unsigned(a)-unsigned(b));
end subtracao;

-------------------------------------fim do subtrator 16 bits component -----------------------

library IEEE;
use ieee.math_real.ceil;
use ieee.math_real.log2;
use ieee.numeric_bit.all;

---------------------------------------  calculadora ----------------------------

entity calc is 
	port(
    	clock : in bit;
        reset : in bit;
        instruction : in bit_vector(16 downto 0);
        q1 : out bit_vector(15 downto 0)
    );
end calc;
			-----------arch----------
architecture atv3 of calc is
	
    component regfile is 
		generic (
    		regn : natural := 32;
        	wordSize : natural := 64
    	);
    	port (
    		clock : in bit;
        	reset : in bit;
        	regWrite : in bit;
        	rr1, rr2, wr : in bit_vector(natural(ceil(log2(real(regn))))-1 downto 0);
        	d : in bit_vector(wordSize-1 downto 0);
        	q1, q2 : out bit_vector(wordSize-1 downto 0)
    	);
	end component;
    
    component somador16 is ---unsigned
		port(
    		a : in bit_vector(15 downto 0);
       		b : in bit_vector(15 downto 0);
        	saida : out bit_vector(15 downto 0) ------------talvez de problema de overflow
    	);
	end component;

	component subtrator16 is ---unsigned
		port(
    		a : in bit_vector(15 downto 0);
        	b : in bit_vector(15 downto 0);
        	saida : out bit_vector(15 downto 0) ------------talvez de problema de overflow
    	);
	end component;
   
   	---------signals 
   
   	signal resultado : bit_vector (15 downto 0);
    
    signal oper2: bit_vector(4 downto 0);
    signal oper1: bit_vector(4 downto 0);
    signal dest: bit_vector(4 downto 0);
    signal opcode : bit_vector(1 downto 0);
    
    signal data1 : bit_vector (15 downto 0);
    signal data2 : bit_vector (15 downto 0);
    
    --signal n_clk : bit := not clock;
    
	begin
    
	----separar as 'palavras'
    
        opcode <= instruction(16 downto 15); --2 bits
		oper2  <= instruction(14 downto 10); --5 bits
		oper1  <= instruction(9 downto 5); --5 bits
		dest   <= instruction(4 downto 0); --5 bits
        
	----opcode when else ou if
          
             
-- operacoes : process (clock, oper1, oper2, dest, opcode, resultado, data1, data2)
--         	begin 
--             if (clock'event and clock = '1') then 
--             	if    (opcode = "00") then --add
                
--                 	resultado <= bit_vector(unsigned(data2) + unsigned(data1));
                    
--                 elsif (opcode = "01") then --addI
                
--                      resultado <= bit_vector((signed(oper2)) + signed(unsigned(data1))); 
                     
--                 elsif (opcode = "10") then --sub
                                
--                 	resultado <= bit_vector((unsigned(data1) - unsigned(data2)));
                    
--                 elsif (opcode = "11") then --subI
                
--                 	resultado <= bit_vector((signed(unsigned(data1)) - signed(oper2))); 
                                
--                 end if;
--             end if;
--         end process;
            
        		resultado <= 	bit_vector((signed(unsigned(data1)) - signed(oper2))) when (opcode = "11") else
                				bit_vector((unsigned(data1) - unsigned(data2))) when (opcode = "10") else
                                bit_vector((signed(oper2)) + signed(unsigned(data1))) when (opcode = "01") else 
                                bit_vector(unsigned(data2) + unsigned(data1)) when (opcode = "00");
		
        
		regDest : regfile generic map (32,16) port map (clock, reset, '1', oper1, oper2, dest, resultado, data1, data2); 
        q1 <= data1;
        
end atv3;

--------------------------------------fim da calculadora --------------------------