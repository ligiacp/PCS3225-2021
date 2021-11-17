
----------- entity fulladder ------------

entity fulladder is 
	port(
    	a, b, cin : in bit;
        s, cout : out bit
    );
end entity;

------------arch fulladder---------------
	--- foi usada a solucao do livro design principles and practices pag 475
    
architecture somador of fulladder is 

	begin
    
    	s <= ((not cin) and (a xor b)) or (cin and (not (a xor b)));
        cout <= (a and b) or (cin and a) or (cin and b);
    
end somador;

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
                    less when operation = "11";

end atv1;

----------------------------------------------------------------------------------