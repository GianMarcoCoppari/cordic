LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE WORK.CONFIG.ALL;


ENTITY MULTIPLIER IS
    GENERIC (
        BLOCKS : INTEGER := M_BLOCKS
    );
    
    PORT (
        CLK : IN STD_LOGIC;
        RST : IN STD_LOGIC;
        
        A : IN STD_LOGIC_VECTOR(M_BLOCKSIZE * BLOCKS - 1 DOWNTO 0);
        B : IN STD_LOGIC_VECTOR(M_BLOCKSIZE * BLOCKS - 1 DOWNTO 0);
        
        P : OUT STD_LOGIC_VECTOR(2 * M_BLOCKSIZE * BLOCKS - 1 DOWNTO 0)
    );
END ENTITY MULTIPLIER;


ARCHITECTURE RTL OF MULTIPLIER IS 
    -- Wires (Combinatoral Outputs)
    SIGNAL AEXT : STD_LOGIC_VECTOR(2 * M_BLOCKSIZE * BLOCKS - 1 DOWNTO 0);
    SIGNAL BEXT : STD_LOGIC_VECTOR(2 * M_BLOCKSIZE * BLOCKS - 1 DOWNTO 0);
    
    TYPE PARTIALSUMS_T IS ARRAY (0 TO BEXT'LENGTH - 1) OF STD_LOGIC_VECTOR(BEXT'RANGE);
    SIGNAL PARTIALSUMS : PARTIALSUMS_T;
    
    TYPE CUMULATIVESUM_T IS ARRAY (0 TO BEXT'LENGTH) OF STD_LOGIC_VECTOR(BEXT'RANGE);
    SIGNAL CUMULATIVESUM : CUMULATIVESUM_T;
    
    
    -- Registers (Synchronized Inputs)
    SIGNAL AREG : STD_LOGIC_VECTOR(A'RANGE);
    SIGNAL BREG : STD_LOGIC_VECTOR(B'RANGE);
    
    SIGNAL AEXTREG : STD_LOGIC_VECTOR(AEXT'RANGE);
    SIGNAL BEXTREG : STD_LOGIC_VECTOR(BEXT'RANGE);
    
    SIGNAL PARTIALSUMSREG   : PARTIALSUMS_T;
    SIGNAL CUMULATIVESUMREG : CUMULATIVESUM_T;
    
    
BEGIN 
    -- Top-Level Module
    -- Gestisce Direttamente la Pipeline dei Dati
    -- Registra Input per Sincronizzazione
    
    REGIN : PROCESS (CLK, RST) BEGIN 
        IF RISING_EDGE(CLK) THEN 
            IF RST = '1' THEN 
                -- Reset to Default Values Here...
                AREG <= (OTHERS => '0');
                BREG <= (OTHERS => '0');
                
            ELSE 
                -- Combinatorial Logic Here...
                -- Assign Registers Here...
                AREG <= A;
                BREG <= B;
                
            END IF;
        END IF;
    END PROCESS REGIN;
    
    REGEXT : PROCESS (CLK, RST) BEGIN 
        IF RISING_EDGE(CLK) THEN 
            IF RST = '1' THEN 
                -- Reset to Default Values Here...
                AEXTREG <= (OTHERS => '0');
                BEXTREG <= (OTHERS => '0');
                
            ELSE 
                -- Combinatorial Logic Here...
                -- Assign Registers Here...
                AEXTREG <= AEXT;
                BEXTREG <= BEXT;
                
            END IF;
        END IF;
    END PROCESS REGEXT;
    
    REGPARTIALS : PROCESS (CLK, RST) BEGIN 
        IF RISING_EDGE(CLK) THEN 
            IF RST = '1' THEN 
                -- Reset to Default Values
                PARTIALSUMSREG <= (OTHERS => (OTHERS => '0'));
                
            ELSE    
                -- Combinatorial Logic Here...
                -- Assign Registers Here...
                PARTIALSUMSREG <= PARTIALSUMS;
                
            END IF;
        END IF;
    END PROCESS REGPARTIALS;
    
    
    CUMULATIVESUM(0) <= (OTHERS => '0');
    REGCUMULATIVE : PROCESS (CLK, RST) BEGIN 
        IF RISING_EDGE(CLK) THEN 
            IF RST = '1' THEN 
                -- Reset to Default Values Here...
                CUMULATIVESUMREG <= (OTHERS => (OTHERS => '0'));
                
            ELSE 
                -- Combinatorial Logic Here...
                -- Assign Registers Here...
                CUMULATIVESUMREG <= CUMULATIVESUM;
            
            END IF;
        END IF;
    END PROCESS REGCUMULATIVE;
    
    
    REGOUT : PROCESS (CLK, RST) BEGIN 
        IF RISING_EDGE(CLK) THEN 
            IF RST = '1' THEN 
                -- Reset to Default Values Here...
                P <= (OTHERS => '0');
                
            ELSE    
                -- Combinatorial Logic Here...
                -- Assign Registers Here...
                P <= CUMULATIVESUMREG(CUMULATIVESUMREG'HIGH);
            
            END IF;
        END IF;    
    END PROCESS REGOUT;
    
    
    -- Sub-Components
    -- 1) Sign Extension of AREG, BREG
    SGNEXTA : ENTITY WORK.SGNEXTENSION(RTL) 
        GENERIC MAP (
            BLOCKS => BLOCKS
        ) 
        PORT MAP (
            CLK => CLK, 
            RST => RST,
            
            X   => A,
            Y   => AEXT
        );
        
    SGNEXTB : ENTITY WORK.SGNEXTENSION(RTL) 
        GENERIC MAP (
            BLOCKS => BLOCKS
        ) 
        PORT MAP (
            CLK => CLK, 
            RST => RST,
            
            X => B,
            Y => BEXT
        );


    -- 2) Partial Sum Generation
    GENPARTIALSUMS : FOR I IN 0 TO BEXT'LENGTH - 1 GENERATE 
        PARTIAL : ENTITY WORK.PARTIALSUM(RTL) 
            GENERIC MAP (
                BLOCKS => 2 * BLOCKS,
                INDEX  => I
            ) 
            PORT MAP (
                CLK => CLK, 
                RST => RST,
                
                A => AEXTREG, 
                B => BEXTREG,
                
                PSUM => PARTIALSUMS(I)
            );
    END GENERATE GENPARTIALSUMS;


    -- 3) Compute Cumulative Sum
    GENCUMULATIVESUM : FOR I IN 0 TO BEXT'LENGTH - 1 GENERATE
        CUMULATIVE : ENTITY WORK.CCLA(RTL) 
            GENERIC MAP (
                BLOCKS => 2 * BLOCKS
            ) 
            PORT MAP (
                CLK  => CLK, 
                RST  => RST, 
                
                A    => PARTIALSUMSREG(I),
                B    => CUMULATIVESUMREG(I),
                CIN  => '0',
                
                SUM  => CUMULATIVESUM(I + 1),
                COUT => OPEN, 
                OVF  => OPEN
            );
    END GENERATE GENCUMULATIVESUM;
END ARCHITECTURE RTL;