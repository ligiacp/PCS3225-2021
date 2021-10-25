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

architecture atv1 of reg is
	signal internal: bit_vector (wordSize-1 downto 0);
    
    begin 
    
    parametrizavel : process (clock, reset, load)
   	begin
    	if reset = '1' then
        	internal <= (others => '0');
		elsif (clock'event and clock = '1' and load ='1') then
        	internal <= d;
        end if;
	end process;
    q <= internal;       	
   
end atv1;