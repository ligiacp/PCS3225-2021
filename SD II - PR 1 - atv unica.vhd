library ieee;
use ieee.numeric_bit.all;

entity contador_9 is
    port (
      clock, reset:   in bit;
      conta:          in bit;
      soma:        out bit_vector(8 downto 0)
    );
end entity;

architecture arch_counter of contador_9 is
    signal internal: bit_vector(8 downto 0);
begin
    process(clock, reset)
    begin
        if reset = '1' then
                internal <= (others=>'0');
        elsif (rising_edge(clock)) then                
            if conta = '1' then		
                internal <= bit_vector(unsigned(internal) + "000000001");
            end if;
        end if;
    end process;
    
    soma <= internal;
end architecture arch_counter;


entity register16 is
    port(
        clock, reset: in  bit;
        load:         in  bit;
        parallel_in:  in  bit_vector(15 downto 0);
        parallel_out: out bit_vector(15 downto 0)
    );
end entity;

architecture arch_reg of register16 is
    signal internal: bit_vector(15 downto 0);
    begin
        process(clock, reset)
        begin
            if reset = '1' then -- reset assincrono
                internal <= (others => '0'); -- "000000"
            elsif (clock'event and clock = '1') then
                if load = '1' then
                    internal <= parallel_in;
                end if;
            end if; 
        end process;
        parallel_out <= internal;
end architecture;

entity register9 is
    port(
        clock, reset: in  bit;
        load:         in  bit;
        parallel_in:  in  bit_vector(8 downto 0);
        parallel_out: out bit_vector(8 downto 0)
    );
end entity;

architecture arch_reg of register9 is
    signal internal: bit_vector(8 downto 0);
    begin
        process(clock, reset)
        begin
            if reset = '1' then -- reset assincrono
                internal <= (others => '0'); -- "000000"
            elsif (clock'event and clock = '1') then
                if load = '1' then
                    internal <= parallel_in;
                end if;
            end if; 
        end process;
        parallel_out <= internal;
end architecture;

---------- Unidade de Controle ---------

entity UC is
    port(
        -- Sinais de controle global
        clock, reset_usuario: in bit;
        -- Entrada de controle
        iniciar: in bit;
        -- Sinais de status
        diferente, b_maior_a, zero: in bit;
        b_maior_a_uc, b_menor_a_uc: out bit;
        -- Sinais de controle 
        load_reg_A, load_reg_B, load_reg_Ma, load_reg_Mb, load_mmc, conta_UC: out bit;
        -- Saida de controle
        fim: out bit;
        reset_uc: out bit
    );
end entity;

architecture arch_UC of UC is

    type state is (espera, inicial, a_igl_b, e_b_maior_a, e_b_menor_a, fim_op, reset);
    signal next_state, current_state: state;

    begin
        process(clock, reset_usuario)
        begin
            if reset_usuario = '1' then	-- reset assincrono
                current_state <= espera;		
            elsif (clock'event and clock = '1') then	
                current_state <= next_state;
            end if;
        end process;

    -- Logica de proximo estado
    next_state <= inicial when (current_state = espera) and (iniciar = '1') else
                  espera  when (current_state = espera) and (iniciar = '0') else
                      
                  a_igl_b     when (current_state = inicial) and (zero = '1') else
                  a_igl_b     when (current_state = inicial) and (diferente = '0') else
                  e_b_maior_a when (current_state = inicial) and (diferente = '1') and (b_maior_a = '1') else
                  e_b_menor_a when (current_state = inicial) and (diferente = '1') and (b_maior_a = '0') else

                  inicial when (current_state = e_b_maior_a) else
                  inicial when (current_state = e_b_menor_a) else
                  
                  fim_op when (current_state = a_igl_b) else
                  reset when (current_state = fim_op) else
                  espera when (current_state = reset);

    -- Decodifica o estado para gerar sinais de controle
    load_reg_A  <= '1' when (current_state = espera) else '0'; 
    load_reg_B  <= '1' when (current_state = espera) else '0';
    load_reg_Ma <= '1' when (current_state = e_b_maior_a) else '0'; 
    load_reg_Mb <= '1' when (current_state = e_b_menor_a) else '0';

    conta_uc <= '1' when (current_state = e_b_menor_a or current_state = e_b_maior_a) else '0';

    fim      <= '1' when (current_state = fim_op) else '0';
    load_mmc <= '1' when (current_state = a_igl_b) else '0';
    

    reset_uc <= '1' when (current_state = reset) else '0';
    
end architecture;

---------- Fluxo de Dados ------------
library ieee;
use ieee.numeric_bit.all;

entity FD is
    port(
        -- Sinais de controle global
        clock, reset: in bit;
        -- Sinais de controle da UC
        load_reg_A, load_reg_B, load_reg_Ma, load_reg_Mb, b_menor_a_uc, b_maior_a_uc, load_mmc: in bit;
        -- Sinais de status
        diferente: out bit; 
        zero: out bit; 
        -- Entrada de dados
        a_en, b_en: in bit_vector(7 downto 0);
        -- Entrada de controle 
        iniciar: in bit;
        conta: in bit;
        -- Saida de dados
        b_maior_a: out bit;
        mmc: out bit_vector(15 downto 0);
        nSomas: out bit_vector(8 downto 0)
        -- saidaA, saidaB, saidaMa, saidaMb: out bit_vector(15 downto 0)
    );
end entity;

architecture arch_FD of FD is
    component register16 is
        port(
            clock, reset: in  bit;
            load:         in  bit;
            parallel_in:  in  bit_vector(15 downto 0);
            parallel_out: out bit_vector(15 downto 0)
        );
    end component;

    component register9 is
        port(
            clock, reset: in  bit;
            load:         in  bit;
            parallel_in:  in  bit_vector(8 downto 0);
            parallel_out: out bit_vector(8 downto 0)
        );
    end component;
    
    component contador_9 is
        port (
        clock, reset:   in bit;
        conta:          in bit;
        soma:        out bit_vector(8 downto 0)
        );
    end component;

    signal a, b: bit_vector(15 downto 0);
    signal Ma_in, Mb_in: bit_vector(15 downto 0); -- Fio que liga o MUX ao REG
    signal internal_mmc: bit_vector(15 downto 0); -- Fio que liga a saída MMC
    signal out_A, out_B: bit_vector(15 downto 0);
    signal A_16, B_16: bit_vector(15 downto 0);
    signal Ma, Mb: bit_vector(15 downto 0);
    signal internal_soma: bit_vector(8 downto 0);
    signal internal_load_Ma, internal_load_Mb: bit;

    begin 
        internal_load_Ma <= load_reg_A or load_reg_Ma;
        internal_load_Mb <= load_reg_B or load_reg_Mb;
        A_16 <= "00000000" & a_en;
        B_16 <= "00000000" & b_en;

        
        cont: contador_9
        port map (clock, reset, conta, internal_soma);
        
        regA: register16
        port map (clock, reset, load_reg_A, A_16, out_A);
        
        regB: register16
        port map (clock, reset, load_reg_B, B_16, out_B);
        
        regMa: register16
        port map (clock, reset, internal_load_Ma, Ma_in, Ma);
        
        regMb: register16
        port map (clock, reset, internal_load_Mb, Mb_in, Mb);
        
        regCMD: register16
        port map (clock, reset, load_mmc, internal_mmc, mmc);

        regSom: register9
        port map (clock, reset, load_mmc, internal_soma, nSomas);
        
        Ma_in <= A_16 when (load_reg_A = '1') else   
        bit_vector((unsigned(Ma) + unsigned(out_A)));
        
        Mb_in <= B_16 when (load_reg_B = '1') else   
        bit_vector((unsigned(Mb) + unsigned(out_B)));
        
        internal_mmc <= "0000000000000000" when (out_A = "0000000000000000") or (out_B = "0000000000000000") else Ma;

        -- Sinais de condicao para UC
        zero      <= '1' when (out_A = "0000000000000000") or (out_B = "0000000000000000") else '0';
        diferente <= '1' when (Ma /= Mb) else '0';
        b_maior_a <= '1' when (Mb > Ma) else '0';
end architecture;

entity mmc is
    port(
        reset, clock: in bit; -- Entrada de controle global
        inicia:       in bit; -- Entrada de controle
        A, B:         in bit_vector(7 downto 0); -- Entrada de dados
        fim:         out bit; -- Saida de controle
        nSomas:      out bit_vector(8 downto 0);
        MMC:         out bit_vector(15 downto 0)-- Saida de dados
    );
end entity;

architecture arch_MMC of mmc is
    component UC is
        port(
            -- Sinais de controle global
            clock, reset_usuario: in bit;
            -- Entrada de controle
            iniciar: in bit;
            -- Sinais de status
            diferente, b_maior_a, zero: in bit;
            b_maior_a_uc, b_menor_a_uc: out bit;
            -- Sinais de controle 
            load_reg_A, load_reg_B, load_reg_Ma, load_reg_Mb, load_mmc, conta_UC: out bit;
            -- Saida de controle
            fim: out bit;
            reset_uc: out bit
        );
    end component;

    component FD is
        port(
            -- Sinais de controle global
            clock, reset: in bit;
            -- Sinais de controle da UC
            load_reg_A, load_reg_B, load_reg_Ma, load_reg_Mb, b_menor_a_uc, b_maior_a_uc, load_mmc: in bit;
            -- Sinais de status
            diferente: out bit; 
            zero: out bit; 
            -- Entrada de dados
            a_en, b_en: in bit_vector(7 downto 0);
            -- Entrada de controle 
            iniciar: in bit;
            conta: in bit;
            -- Saida de dados
            b_maior_a: out bit;
            mmc: out bit_vector(15 downto 0);
            nSomas: out bit_vector(8 downto 0)
            -- saidaA, saidaB, saidaMa, saidaMb: out bit_vector(15 downto 0)
        );
    end component;

    signal s_reset_geral, s_load_reg_A, s_load_reg_B, s_load_reg_Ma, s_load_reg_Mb, s_b_maior_a, s_b_maior_a_uc, s_b_menor_a_uc, s_zero, s_load_mmc, s_diferente, s_conta, s_reset_uc: bit; 
    signal clock_n: bit;

    begin
        clock_n <= not(clock);
        s_reset_geral <= reset or s_reset_uc;
        
        xUC: UC
        port map(   clock,
                    reset,
                    inicia,
                    s_diferente,
                    s_b_maior_a,
                    s_zero,
                    s_b_maior_a_uc,
                    s_b_menor_a_uc,
                    s_load_reg_A,
                    s_load_reg_B,
                    s_load_reg_Ma,
                    s_load_reg_Mb,
                    s_load_mmc,
                    s_conta,
                    fim,
                    s_reset_uc);

        xFD: FD
        port map(   clock_n,
                    s_reset_geral,
                    s_load_reg_A,
                    s_load_reg_B,
                    s_load_reg_Ma,
                    s_load_reg_Mb,
                    s_b_menor_a_uc,
                    s_b_maior_a_uc,
                    s_load_mmc,
                    s_diferente,
                    s_zero,                    
                    A, B,
                    inicia,
                    s_conta,
                    s_b_maior_a,
                    MMC,
                    nSomas);
end architecture;