-- usei como base o código do professor bruno albertini do link https://balbertini.github.io/vhdl_mem-pt_BR.html
library IEEE;

use ieee.numeric_bit.all;
use std.textio.all;

entity rom_arquivo_generica is
	generic (
    	addressSize : natural := 5;
        wordSize : natural := 8;
        datFileName : string := "conteudo_rom_ativ_02_carga.dat"
	);
    port (
    	addr : in bit_vector(addressSize-1 downto 0);
        data : out bit_vector(wordSize-1 downto 0)
	);
end rom_arquivo_generica;

architecture atv3 of rom_arquivo_generica is 


	constant depth : natural := 2**addressSize;    
    type mem_t is array (0 to depth-1) of bit_vector (wordSize-1 downto 0); 
    signal posicao : integer := 0;
    
    impure function inicializa(nome_do_arquivo : in string) return mem_t is
        file     arquivo  : text open read_mode is nome_do_arquivo;
        variable linha    : line;
        variable temp_bv  : bit_vector(wordSize-1 downto 0);
        variable temp_mem : mem_t;
        begin
          for i in mem_t'range loop
            readline(arquivo, linha);
            read(linha, temp_bv);
            temp_mem(i) := temp_bv;
          end loop;
          return temp_mem;
        end;
      signal mem : mem_t := inicializa(datFileName);

	begin
    
    posicao <= to_integer(unsigned(addr));
    
    data <= mem(posicao);
    
    
end atv3;