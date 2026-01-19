-- Utility Package for VHDL Designs


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


-- TODO: RENDERE PRIVATE COSTANTI CHE NON DEVO USARE ESPLICITAMENTE NEI MODULI
-- TODO: Modulare Configuration Files per Ogni Modulo Indipendente
PACKAGE CONFIG IS
    -- Costanti di Parametrizzazione Default Progetto
    -- Formato Numerico
    CONSTANT M_BLOCKSIZE : INTEGER := 4;
    CONSTANT M_BLOCKS    : INTEGER := 9; -- N. di Blocchi di Default, Fixed Point 
    CONSTANT M_BFRAC     : INTEGER := 7; -- N. di Blocchi per la Parte Frazionaria
    
    CONSTANT PERIOD : TIME := 10 ns;
    
    
    -- Tipi e Costanti per il Calcolo della Spline
    TYPE SUM_T IS RECORD 
        LHS : STD_LOGIC_VECTOR(M_BLOCKSIZE * M_BLOCKS - 1 DOWNTO 0);
        RHS : STD_LOGIC_VECTOR(M_BLOCKSIZE * M_BLOCKS - 1 DOWNTO 0);
        CIN : STD_LOGIC;
    END RECORD SUM_T;
    
END PACKAGE CONFIG;

PACKAGE BODY CONFIG IS 
END PACKAGE BODY CONFIG;