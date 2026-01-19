-- Top-Level Module for ALU
-- Author:  Gian Marco Coppari
-- Date: 2025/11/21


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE WORK.CONFIG.ALL;
USE WORK.CONFIGCORDIC.ALL;
USE WORK.CONFIGALU.ALL;


ENTITY ALU IS 
    GENERIC (
        BLOCKS : INTEGER := M_BLOCKS
    );
    PORT (
        CLK : STD_LOGIC;
        RST : STD_LOGIC;
        
        A : IN STD_LOGIC_VECTOR(M_BLOCKSIZE * BLOCKS - 1 DOWNTO 0);
        B : IN STD_LOGIC_VECTOR(M_BLOCKSIZE * BLOCKS - 1 DOWNTO 0);
        
        OPCODE : IN STD_LOGIC_VECTOR(M_OPCODE_LENGTH - 1 DOWNTO 0);
        
        RESULT : OUT STD_LOGIC_VECTOR(M_BLOCKSIZE * BLOCKS - 1 DOWNTO 0)
        -- TODO: AGGIUNGERE EVENTUALI FLAG (ES. OVERFLOW DELLA SOMMA, RISULTATO NULLO, ...)
    );
END ENTITY ALU;


ARCHITECTURE RTL OF ALU IS 
    
    
    SIGNAL LHS, RHS : STD_LOGIC_VECTOR(B'RANGE);
    SIGNAL C : STD_LOGIC;
    
    
    -- Wires (Combinatorial Output)
    SIGNAL BMASK : STD_LOGIC_VECTOR(B'RANGE);
    SIGNAL S     : STD_LOGIC_VECTOR(B'RANGE);
    SIGNAL PROD  : STD_LOGIC_VECTOR(2 * M_BLOCKSIZE * BLOCKS - 1 DOWNTO 0);
    
    -- Registers (Synchronized Inputs)
    SIGNAL AREG, BREG : STD_LOGIC_VECTOR(B'RANGE);
    SIGNAL BMASKREG   : STD_LOGIC_VECTOR(B'RANGE);
    
    
BEGIN 
    -- Top-Level Module
    -- Gestisce Pipeline Dati
    -- Registra Input per Sincronizzazione
    
    REGIN : PROCESS (CLK, RST) BEGIN 
        IF RISING_EDGE(CLK) THEN 
            IF RST = '1' THEN 
                -- Reset to Default Values Here...
                AREG <= (OTHERS => '0');
                BREG <= (OTHERS => '0');
            ELSE 
                -- Assign Registers
                AREG <= A;
                BREG <= B;
            END IF;
        END IF;
    
    END PROCESS REGIN;
    
    REGMASK : PROCESS (CLK, RST) BEGIN 
        IF RISING_EDGE(CLK) THEN 
            IF RST = '1' THEN 
                -- Reset to Default Here...
                BMASKREG <= (OTHERS => '0');
                
            ELSE 
                -- Assign Registers Here...
                BMASKREG <= BMASK;
                
            END IF;
        END IF;
    END PROCESS REGMASK;
    
    COMPUTE : PROCESS (CLK, RST) BEGIN 
        IF RISING_EDGE(CLK) THEN 
            IF RST = '1' THEN 
                -- Reset to Default Values Here...
                BMASK <= (OTHERS => '0');
                
                LHS <= (OTHERS => '0');
                RHS <= (OTHERS => '0');
                C <= '0';
                
                
            ELSE
                -- Combinatorial Logic Here...
                -- Assigna Registers Here...
                
                -- 1) Operando B Calcolato in Base al Tipo di Operazione, Binaria o Unaria...
                IF OPCODE(6) = M_BINARY THEN 
                    BMASK <= BREG;
                    
                ELSE 
                    BMASK <= (OTHERS => '0');
                    
                END IF;
            
                -- Case Statement per Selezione Operazione
                CASE OPCODE IS
                    WHEN M_OPCODE_ADD =>
                        LHS <= AREG;
                        RHS <= BMASKREG;
                        C   <= '0';
                        
                    WHEN M_OPCODE_SUB =>
                        LHS <= AREG;
                        RHS <= NOT BMASKREG;
                        C   <= '1';
                        
                    WHEN M_OPCODE_MULT =>
                        LHS <= AREG;
                        RHS <= BMASKREG;
                        C <= '0';
                        
                    WHEN OTHERS =>
                END CASE;
            END IF;
        END IF;
    END PROCESS COMPUTE;
    
    REGOUT : PROCESS (CLK, RST) BEGIN 
        IF RISING_EDGE(CLK) THEN 
            IF RST = '1' THEN 
                RESULT <= (OTHERS => '0');
                
            ELSE
                CASE OPCODE IS 
                    WHEN M_OPCODE_ADD => 
                        RESULT <= S;
                    
                    WHEN M_OPCODE_MULT =>
                        RESULT <= PROD(55 DOWNTO 24);
                        
                    WHEN OTHERS =>
                END CASE;
            END IF;
        END IF;
    END PROCESS REGOUT;
    
    
    -- Istanze dei Componenti
    INSTADDSUB : ENTITY WORK.CCLA(RTL) 
        GENERIC MAP (
            BLOCKS => BLOCKS
        ) 
        PORT MAP (
            CLK  => CLK,
            RST  => RST,
            
            A    => LHS,
            B    => RHS,
            CIN  => C,
            
            SUM  => S,
            COUT => OPEN, 
            OVF  => OPEN
        );
        
    INSTMULT : ENTITY WORK.MULTIPLIER(RTL) 
        GENERIC MAP (
            BLOCKS => BLOCKS
        ) 
        PORT MAP (
            CLK => CLK, 
            RST => RST,
             
            A => LHS,
            B => RHS,
            
            P => PROD
        );
END ARCHITECTURE RTL;


