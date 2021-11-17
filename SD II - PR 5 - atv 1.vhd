library ieee;
use ieee.numeric_bit.all;

entity signExtend is
    port (
        i: in bit_vector(31 downto 0);
        o: out bit_vector(63 downto 0)
    );
end entity signExtend;

architecture atv1 of signExtend is
    
    signal o_aux : bit_vector(63 downto 0);
    signal i_aux : bit_vector(4 downto 0);
    
    begin
    
    
    o_aux <= 
    			bit_vector(resize(signed(i(23 downto  5)), 64)) when (i_aux = "10110") else
                bit_vector(resize(signed(i(25 downto  0)), 64)) when (i_aux = "00010") else
                bit_vector(resize(signed(i(20 downto 12)), 64))when (i_aux = "11111") else
                bit_vector(to_signed(0, 64)) ;
    			
    o <= o_aux;
    i_aux <= i(31 downto 27);
    
end architecture;
