LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE WORK.CONFIG.ALL;


ENTITY SGNEXTENSION IS
    GENERIC (
        BLOCKS : INTEGER := M_BLOCKS
    );
    PORT (
        CLK : IN STD_LOGIC;
        RST : IN STD_LOGIC;
        
        X   : IN STD_LOGIC_VECTOR(M_BLOCKSIZE * BLOCKS - 1 DOWNTO 0);
        Y   : OUT STD_LOGIC_VECTOR(2 * M_BLOCKSIZE * BLOCKS - 1 DOWNTO 0)
    );
END ENTITY SGNEXTENSION;


ARCHITECTURE RTL OF SGNEXTENSION IS 

BEGIN 
    -- NO Top-Level Module
    -- Non Gestisce Pipeline Direttamente
    -- Non Registra Input
    
    COMPUTE : PROCESS (CLK, RST) 
        VARIABLE SGN : STD_LOGIC := '0';
        
    BEGIN 
        IF RISING_EDGE(CLK) THEN 
            IF RST = '1' THEN
                -- Reset to Default Values Here...
                Y <= (OTHERS => '0');
                
            ELSE
                -- Combinatorial Logic Here...
                -- Assign Register Here...
                SGN := X(X'HIGH);
                
                
                Y(Y'HIGH DOWNTO M_BLOCKSIZE * BLOCKS) <= (OTHERS => SGN);
                Y(M_BLOCKSIZE * BLOCKS - 1 DOWNTO 0) <= X;
            END IF;     
        END IF;
    END PROCESS COMPUTE;

END ARCHITECTURE RTL;