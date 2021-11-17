----------- entity fulladder ------------

entity fulladder is
    port (
        a, b, cin : in bit;
        s, cout : out bit
    );
end entity fulladder;

------------arch fulladder---------------
	--- foi usada a solucao do livro design principles and practices pag 475
    
architecture somador of fulladder is

	begin
    	s <= (a xor b) xor cin;
    	cout <= (a and b) or (cin and a) or (cin and b);
end architecture somador;

-----------------------------------------------------------------------------------

--------------- bibliotecas -------------

library ieee;
use ieee.numeric_bit.all;

---------------entity alu1bit------------

entity alu1bit is 
    port (
    	a, b, less, cin : in bit;
        result, cout, set, overflow : out bit;
        ainvert, binvert : in bit;
        operation : in bit_vector (1 downto 0)
    );
end entity;

-------------arch alu1bit--------------

architecture atv1 of alu1bit is 
	
    component fulladder is 
		port(
    		a, b, cin : in bit;
        	s, cout : out bit
    	);
	end component;
    
    ----------sinais que recebem a entrada
    
    signal a_aux : bit;
    signal b_aux : bit;
    
    ----------sinais que recebem a saida
    
    signal result_aux : bit;
    signal cout_aux : bit;
    
	begin
    
    	--------- setar a_aux
        
        a_aux <= 
        		a xor ainvert;
                
        --------- setar b_aux 
                
        b_aux <= 
        		b xor binvert;
    	
        ---------- port map
        
    	soma : fulladder port map (a_aux, b_aux, cin, result_aux, cout_aux);
        
        --------- setar as saidas
        
        cout <= cout_aux;
        set <= result_aux;
        overflow <= (cout_aux xor cin);
        
        --------- setar o resultado 
        
        result <= 
        			(a_aux and b_aux) when operation = "00" else 
                    (a_aux or b_aux) when operation = "01" else
                    result_aux when operation = "10" else
                    b when operation = "11";

end atv1;

--------------------------------------------------------------------------------------
------------bibliotecas-------------

library ieee;
use ieee.numeric_bit.all;
-------------entity alu--------------

entity alu is
    generic (
        size : natural := 64
    );
    port (
        A, B : in bit_vector(size-1 downto 0); 
        F : out bit_vector(size-1 downto 0); 
        S : in bit_vector(3 downto 0); 
        Z : out bit; 
        Ov : out bit;
        Co : out bit 
    );
end entity alu;

--------------arch alu-----------------

architecture atv2 of alu is
    
    
    component alu1bit is
        port(
            a, b, less, cin: in bit;
            result, cout, set, overflow: out bit;
            ainvert, binvert: in bit;
            operation : in bit_vector(1 downto 0)
        );
    end component alu1bit;
	
      
   signal cincout: bit_vector(size-1 downto 0);
   signal set_aux : bit_vector (size-1 downto 0);
   signal F_aux : bit_vector(size-1 downto 0);
   signal less_aux : bit := '0';
    
	begin


    less_aux <= set_aux(size-1);
    F <= F_aux;
    Co <= cincout(size-1);
    Z <= '1' when (signed(F_aux) = 0) else '0';
    
    primeiroPort : alu1bit port map (A(0), B(0),less_aux, S(2), F_aux(0), cincout(0), set_aux(0), open, S(3), S(2), S(1 downto 0));
    
    genereating: for k in 1 to size-2 generate 
    	segundoPort : alu1bit port map (A(k), B(k), '0', cincout(k-1), F_aux(k), cincout(k), set_aux(k), open, S(3), S(2), S(1 downto 0));
    end generate;
   
    ultimoPort : alu1bit port map (A(size-1), B(size-1), '0', cincout(size-2), F_aux(size-1), cincout(size-1), set_aux(size-1), Ov, S(3), S(2), S(1 downto 0));
    
    

end architecture atv2;
