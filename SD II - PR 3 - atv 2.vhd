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
-----------------------banco de registradores----------------------

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

			  ------arch -----------
              
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
        
--         process_final : process (clock, reset)
        
--         	begin 
--             	if (clock'event and clock = '1') then 
--                 	if (regWrite = '0') then 
--                     	-- load_var <= (others=>'1');
--                     elsif (regWrite ='1' and (to_integer(unsigned (wr)) /= regn -1 )) then
--                     	in_var(to_integer(unsigned(wr))) <= d;
--                       --  load_var(to_integer(unsigned(in_address))) <= '1';
--                     end if;
-- 				end if;
-- 		end process process_final;
        
        q1 <= out_var(to_integer(unsigned(out_address1)));
        q2 <= out_var(to_integer(unsigned(out_address2)));
end atv2;