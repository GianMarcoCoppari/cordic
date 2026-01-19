LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


ENTITY CCLA IS
    GENERIC (
        BLOCKSIZE : INTEGER := 4;
        BLOCKS    : INTEGER := 2
    );
    PORT (
        CLK  : IN STD_LOGIC;
        RST  : IN STD_LOGIC;
        
        A    : IN STD_LOGIC_VECTOR(BLOCKSIZE * BLOCKS - 1 DOWNTO 0);
        B    : IN STD_LOGIC_VECTOR(BLOCKSIZE * BLOCKS - 1 DOWNTO 0);
        CIN  : IN STD_LOGIC;
        
        SUM  : OUT STD_LOGIC_VECTOR(BLOCKSIZE * BLOCKS - 1 DOWNTO 0);
        COUT : OUT STD_LOGIC;
        OVF  : OUT STD_LOGIC
    );
END ENTITY CCLA;


ARCHITECTURE RTL OF CCLA IS 
    SIGNAL S : STD_LOGIC_VECTOR(BLOCKSIZE * BLOCKS - 1 DOWNTO 0);
    SIGNAL C : STD_LOGIC_VECTOR(BLOCKS DOWNTO 0);
    SIGNAL O : STD_LOGIC_VECTOR(BLOCKS - 1 DOWNTO 0);
    
    SIGNAL CREG : STD_LOGIC_VECTOR(BLOCKS DOWNTO 0);
    
    
BEGIN 
    C(0) <= CIN;
    REGC : PROCESS (CLK, RST) BEGIN 
        IF RST = '1' THEN 
            CREG <= (OTHERS => '0');
            
        ELSE 
            IF RISING_EDGE(CLK) THEN 
                CREG <= C;
                
            END IF; -- RISING EDGE
        END IF; -- RESET
    END PROCESS REGC;
    
    
    REGOUT : PROCESS (CLK, RST) BEGIN 
        IF RST = '1' THEN 
            SUM  <= (OTHERS => '0');
            COUT <= '0';
            OVF  <= '0';
            
        ELSE 
            IF RISING_EDGE(CLK) THEN 
                SUM  <= S;
                COUT <= C(C'HIGH);
                OVF  <= O(O'HIGH);
            END IF; -- RISING EDGE
        END IF; -- RESET
    END PROCESS REGOUT;
    
    
    -- Sub Components
    GENCLA : FOR I IN 0 TO BLOCKS - 1 GENERATE 
        INSTCLA : ENTITY WORK.CLA4(RTL) 
            PORT MAP (
                CLK  => CLK, 
                RST  => RST, 
                
                A    => A((I + 1) * BLOCKSIZE - 1 DOWNTO I * BLOCKSIZE), 
                B    => B((I + 1) * BLOCKSIZE - 1 DOWNTO I * BLOCKSIZE), 
                CIN  => CREG(I), 
                
                SUM  => S((I + 1) * BLOCKSIZE - 1 DOWNTO I * BLOCKSIZE), 
                COUT => C(I + 1),
                OVF  => O(I)
            );
    END GENERATE GENCLA;
    
END ARCHITECTURE RTL;