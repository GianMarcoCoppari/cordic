-- Synchronized CLA4
-- Gian Marco Coppari
-- 2025/11/26


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;


ENTITY CLA4 IS 
    PORT (
        CLK  : IN STD_LOGIC;
        RST  : IN STD_LOGIC;
        
        A    : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        B    : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        CIN  : IN STD_LOGIC;
        
        SUM  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        COUT : OUT STD_LOGIC;
        OVF  : OUT STD_LOGIC
    );
END ENTITY CLA4;


ARCHITECTURE RTL OF CLA4 IS 
    SIGNAL C : STD_LOGIC_VECTOR(4 DOWNTO 0); -- COMBINATORIAL
    
    SIGNAL P : STD_LOGIC_VECTOR(3 DOWNTO 0); -- COMBINATORIAL
    SIGNAL G : STD_LOGIC_VECTOR(3 DOWNTO 0); -- COMBINATORIAL
    
    SIGNAL PREG : STD_LOGIC_VECTOR(3 DOWNTO 0);
    
BEGIN 
    
    COMPUTEPG : PROCESS (CLK, RST) BEGIN 
        IF RST = '1' THEN 
            -- Asynchronous Reset Logic Here...
            G <= (OTHERS => '0');
            P <= (OTHERS => '0');
            
        ELSE 
            IF RISING_EDGE(CLK) THEN 
                -- 1) Compute Propagate & Generate Functions, Fully Parallel
                P <= A XOR B;
                G <= A AND B;
                
            END IF; -- Rising Edge
        END IF; -- Reset
    END PROCESS COMPUTEPG;
    
    COMPUTECARRY : PROCESS (CLK, RST) BEGIN 
        IF RST = '1' THEN 
            C <= (OTHERS => '0');            

        ELSE 
            IF RISING_EDGE(CLK) THEN 
                -- 2a) Compute Input Carry, Fully Parallel
                C(0) <= CIN;
                C(1) <= G(0) OR (P(0) AND CIN);
                C(2) <= G(1) OR (P(1) AND G(0)) OR (P(1) AND P(0) AND CIN);
                C(3) <= G(2) OR (P(2) AND G(1)) OR (P(2) AND P(1) AND G(0)) OR (P(2) AND P(1) AND P(0) AND CIN);
                C(4) <= G(3) OR (P(3) AND G(2)) OR (P(3) AND P(2) AND G(1)) OR (P(3) AND P(2) AND P(1) AND G(0)) OR (P(3) AND P(2) AND P(1) AND P(0) AND CIN);
                
            END IF;
        END IF;
    END PROCESS COMPUTECARRY;
    
    STAGEP : PROCESS (CLK, RST) BEGIN 
        IF RST = '1' THEN 
            PREG <= (OTHERS => '0');
            
        ELSE 
            IF RISING_EDGE(CLK) THEN 
                -- 2b) Stage P Signal to Update SUM Only Once
                PREG <= P;
                
            END IF;
        END IF;
    END PROCESS STAGEP;
    
    REGOUT : PROCESS (CLK, RST) BEGIN 
        IF RST = '1' THEN 
            SUM  <= (OTHERS => '0');
            COUT <= '0';
            OVF  <= '0';
            
        ELSE 
            IF RISING_EDGE(CLK) THEN 
                -- 3) Assign Outputs
                SUM  <= PREG XOR C(C'HIGH - 1 DOWNTO 0);
                COUT <= C(C'HIGH);
                OVF  <= C(C'HIGH) XOR C(C'HIGH - 1);
                
            END IF;
        END IF;
    END PROCESS REGOUT;

END ARCHITECTURE RTL;