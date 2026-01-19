LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE WORK.CONFIG.ALL;


ENTITY PARTIALSUM IS 
    GENERIC (
        BLOCKS : INTEGER := M_BLOCKS;
        INDEX  : INTEGER := 30
    );
    PORT (
        CLK  : IN  STD_LOGIC;
        RST  : IN  STD_LOGIC;
        
        A    : IN  STD_LOGIC_VECTOR(M_BLOCKSIZE * BLOCKS - 1 DOWNTO 0);
        B    : IN  STD_LOGIC_VECTOR(M_BLOCKSIZE * BLOCKS - 1 DOWNTO 0);
        
        PSUM : OUT STD_LOGIC_VECTOR(M_BLOCKSIZE * BLOCKS - 1 DOWNTO 0)
    );
END ENTITY PARTIALSUM;


ARCHITECTURE RTL OF PARTIALSUM IS

BEGIN 
    -- NO Top-Level Module
    -- Non Gestisce Direttamente la Pipeline
    -- Non Registra gli Input
    
    COMPUTE : PROCESS (CLK, RST) BEGIN 
        IF RISING_EDGE(CLK) THEN 
            IF RST = '1' THEN 
                -- Reset to Default Values Here...
                PSUM <= (OTHERS => '0');
                
            ELSE
                -- Combinatorial Logic Here...
                -- Assign Registers Here...
                
                IF INDEX = 0 THEN 
                    -- No Shift
                    IF B(INDEX) = '0' THEN 
                        -- Ma se B(0) = 0, Allora la stringa prodotta deve comunque essere 0
                        PSUM <= (OTHERS => '0');
                        
                    ELSE 
                        PSUM <= A;
                        
                    END IF;
                    
                ELSE    
                    -- Qui INDEX è positivo
                    IF B(INDEX) = '0' THEN 
                        PSUM <= (OTHERS => '0');
                        
                    ELSE     
                        PSUM(B'HIGH DOWNTO INDEX) <= A(A'HIGH - INDEX DOWNTO 0);
                        PSUM(INDEX - 1 DOWNTO 0)  <= (OTHERS => '0');
                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS COMPUTE;

END ARCHITECTURE RTL;