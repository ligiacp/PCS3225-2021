--usei como base o código do professor albertini em https://github.com/balbertini/hwProjects/blob/master/vhdl_modules/memory/ram.vhd

library IEEE;

use ieee.numeric_bit.all;

entity ram is 
	generic (
    	addressSize : natural := 5;
        wordSize : natural := 8
    );
    port (
    	ck, wr : in bit;
        addr : in bit_vector(addressSize-1 downto 0);
        data_i : in bit_vector(wordSize-1 downto 0);
        data_o : out bit_vector(wordSize-1 downto 0)
    );
end ram;

architecture atv4 of ram is 
	
    signal posicao : integer := 0;
	
	type mem_tipo is array (0 to 2**addressSize) of bit_vector(wordSize-1 downto 0);
    signal mem : mem_tipo;
    
	begin
    
    escrita : process (ck)
    	begin
    		if (ck = '1' and ck'event and wr = '1') then 
            	mem(posicao) <= data_i;
            end if;
	end process;
      
	
    posicao <= to_integer(unsigned(addr));
    data_o <= mem(posicao);
    

end atv4;