----------------bibliotecas
library ieee;
use ieee.numeric_bit.all;

----------------entity
entity controlunit is
    port (
        -- To Datapath
        reg2loc : out bit;
        uncondBranch : out bit;
        branch : out bit;
        memRead : out bit;
        memToReg : out bit;
        aluOp : out bit_vector(1 downto 0);
        memWrite : out bit;
        aluSrc : out bit;
        regWrite : out bit;
        -- From Datapath
        opcode : in bit_vector(10 downto 0)
    );
end entity controlunit;

----------------arch
architecture atv4 of controlunit is
    type tipo_instrucao is (LDUR, STUR, CBZ, B, R_format);
    
    signal instrucao : tipo_instrucao;


begin

    instrucao <= 	LDUR        when (opcode = "11111000010") else
            		STUR        when (opcode = "11111000000") else
            		CBZ         when (opcode(10 downto 3) = "10110100") else
            		B           when (opcode(10 downto 5) = "000101") else
            		R_format;

   
        aluOp <=    "10" when (instrucao = R_format) else
                    "01" when (instrucao = B) else
                    "01" when (instrucao = CBZ ) else
                    "00" ;
                    
        reg2loc <=  '1' when (instrucao =  STUR ) else
        			'1' when (instrucao =  CBZ) else
                    '0' ;

    	regWrite <= '1' when (instrucao = R_format ) else
        			'1' when (instrucao =  LDUR) else
                    '0' ;
    
        uncondBranch <= '1' when (instrucao = B) else
                        '0' ;

    
        
    
        memRead <=  '1' when (instrucao = LDUR) else
                    '0' ;

   
        memToReg <= '1' when (instrucao = LDUR) else
                    '0' ;

    
        branch <=   '1' when (instrucao = CBZ) else
                    '0' ;


    
        memWrite <= '1' when (instrucao = STUR) else
                    '0' ;

  
        aluSrc <=   '1' when (instrucao = STUR) else
        			'1' when (instrucao = LDUR ) else        			
                    '0' ;

   
        
end atv4;