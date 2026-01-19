LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE WORK.CONFIG.ALL;


ENTITY RIGHTSHIFTER IS
    GENERIC (
        BLOCKS : INTEGER := M_BLOCKS;
        I      : INTEGER := 0
    );
    PORT (
        CLK : IN  STD_LOGIC;
        RST : IN  STD_LOGIC;
        
        X   : IN  STD_LOGIC_VECTOR(M_BLOCKSIZE * BLOCKS - 1 DOWNTO 0);
        Y   : OUT STD_LOGIC_VECTOR(M_BLOCKSIZE * BLOCKS - 1 DOWNTO 0)
    );
END ENTITY RIGHTSHIFTER;

ARCHITECTURE RTL OF RIGHTSHIFTER IS 

BEGIN 
    COMPUTE : PROCESS (CLK, RST) 
        VARIABLE SGN : STD_LOGIC := '0';
        
    BEGIN 
        IF RST = '1' THEN 
            Y <= (OTHERS => '0');
            
        ELSE 
            IF RISING_EDGE(CLK) THEN 
                SGN := X(X'HIGH);
                
                IF I = 0 THEN 
                    -- No Shift
                    Y <= X;
                    
                ELSE
                    Y(Y'HIGH DOWNTO Y'HIGH - I + 1) <= (OTHERS => SGN);
                    Y(Y'HIGH - I DOWNTO 0) <= X(X'HIGH DOWNTO I);
                    
                END IF;
            END IF;
        END IF;
    END PROCESS COMPUTE;
END ARCHITECTURE RTL;