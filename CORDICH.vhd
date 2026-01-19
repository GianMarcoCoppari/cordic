LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.CONFIG.ALL;
USE WORK.CONFIGCORDIC.ALL;


ENTITY CORDICH IS
    GENERIC (
        BLOCKS : INTEGER      := M_BLOCKS;
        MODE   : CORDICMODE_T := M_ROTATING
    );
    PORT (
        CLK      : IN  STD_LOGIC;
        RST      : IN  STD_LOGIC;
        
        STATEIN  : IN  CORDICSTATE_T;
        STATEOUT : OUT CORDICSTATE_T
    );
END ENTITY CORDICH;


ARCHITECTURE RTL OF CORDICH IS 
    TYPE CORDICHPIPELINE_T IS ARRAY (0 TO M_HINDEX'LENGTH) OF CORDICSTATE_T;
    SIGNAL STAGES    : CORDICHPIPELINE_T;
    SIGNAL STAGESREG : CORDICHPIPELINE_T;
    
    SIGNAL XSCALED : STD_LOGIC_VECTOR(2 * M_BLOCKSIZE * BLOCKS - 1 DOWNTO 0);
    SIGNAL YSCALED : STD_LOGIC_VECTOR(2 * M_BLOCKSIZE * BLOCKS - 1 DOWNTO 0);
    
    
BEGIN 
    REGSTAGES : PROCESS (CLK, RST) BEGIN 
        IF RST = '1' THEN 
            STAGESREG <= (OTHERS => ((OTHERS => '0'), (OTHERS => '0'), (OTHERS => '0')));
            
        ELSE 
            IF RISING_EDGE(CLK) THEN 
                STAGESREG <= STAGES;
                
            END IF;
        END IF;
    END PROCESS REGSTAGES;
    
    
    REGOUT : PROCESS (CLK, RST) BEGIN 
        IF RST = '1' THEN 
            STATEOUT <= ((OTHERS => '0'), (OTHERS => '0'), (OTHERS => '0'));
            
        ELSE 
            IF RISING_EDGE(CLK) THEN 
                STATEOUT <= (XSCALED((M_BLOCKS + M_BLOCKSIZE) * M_BLOCKSIZE - 1 DOWNTO M_BFRAC * M_BLOCKSIZE), 
                             YSCALED((M_BLOCKS + M_BLOCKSIZE) * M_BLOCKSIZE - 1 DOWNTO M_BFRAC * M_BLOCKSIZE), 
                             STAGESREG(STAGESREG'HIGH).Z);
                
            END IF;
        END IF; 
    END PROCESS REGOUT;
    -- COMPONENT PER I-ESIMO STAGE
    STAGES(0) <= STATEIN;
    GENSTAGES : FOR I IN 0 TO M_HINDEX'LENGTH - 1 GENERATE
        INSTCORDICSTAGE : ENTITY WORK.CORDICSTAGEH(RTL) 
            GENERIC MAP (BLOCKS => BLOCKS, MODE => MODE, ITER => I) 
            PORT MAP (
                CLK      => CLK, 
                RST      => RST, 
                
                STATEIN  => STAGESREG(I), 
                PHI      => M_ATANHLUT(M_HINDEX(I) - 1), 
                
                STATEOUT => STAGES(I + 1)
            );
    END GENERATE GENSTAGES;
    
    SCALEX : ENTITY WORK.MULTIPLIER(RTL) 
        GENERIC MAP ( BLOCKS => BLOCKS ) 
        PORT MAP (
            CLK => CLK, 
            RST => RST, 
            
            A => STAGESREG(STAGESREG'HIGH).X, 
            B => M_KY, 
            
            P => XSCALED
        );
        
    
    SCALEY : ENTITY WORK.MULTIPLIER(RTL) 
        GENERIC MAP ( BLOCKS => BLOCKS ) 
        PORT MAP (
            CLK => CLK, 
            RST => RST, 
            
            A => STAGESREG(STAGESREG'HIGH).Y, 
            B => M_KY, 
            
            P => YSCALED
        );
        
        
END ARCHITECTURE RTL;