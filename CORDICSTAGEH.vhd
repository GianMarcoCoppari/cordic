LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.CONFIG.ALL;
USE WORK.CONFIGCORDIC.ALL;


ENTITY CORDICSTAGEH IS 
    GENERIC (
        BLOCKS : INTEGER      := M_BLOCKS;
        MODE   : CORDICMODE_T := M_ROTATING;
        ITER   : INTEGER      := 0
    );
    
    PORT (
        CLK      : IN  STD_LOGIC;
        RST      : IN  STD_LOGIC;
        
        STATEIN  : IN  CORDICSTATE_T;
        PHI      : IN  STD_LOGIC_VECTOR(M_BLOCKSIZE * BLOCKS - 1 DOWNTO 0);
        
        STATEOUT : OUT CORDICSTATE_T
    );
END ENTITY CORDICSTAGEH;


ARCHITECTURE RTL OF CORDICSTAGEH IS 
    SIGNAL XSHIFTED : STD_LOGIC_VECTOR(M_BLOCKSIZE * M_BLOCKS - 1 DOWNTO 0);
    SIGNAL YSHIFTED : STD_LOGIC_VECTOR(M_BLOCKSIZE * M_BLOCKS - 1 DOWNTO 0);

    TYPE EVOLUTIONEQS_T IS ARRAY (0 TO 2) OF SUM_T;
    SIGNAL EVOLUTIONEQS : EVOLUTIONEQS_T;
    
    TYPE CORDICRESULT_T IS ARRAY (0 TO 2) OF STD_LOGIC_VECTOR(M_BLOCKSIZE * BLOCKS - 1 DOWNTO 0);
    SIGNAL TEMP : CORDICRESULT_T;
    
    
BEGIN 
    COMPUTE : PROCESS (CLK, RST) BEGIN 
        IF RST = '1' THEN 
            EVOLUTIONEQS <= (OTHERS => ((OTHERS => '0'), (OTHERS => '0'), '0'));
            
        ELSE 
            IF RISING_EDGE(CLK) THEN 
                CASE MODE IS 
                    WHEN M_ROTATING  => 
                        IF STATEIN.Z(STATEIN.Z'HIGH) = '0' THEN 
                            -- ANGOLO RSIDUO POSITIVO
                            -- ROTAZIONE ANTIORARIA (ETA = 1), 
                            -- SOTTRAGGO L'ANGOLO DI ROTAZIONE DAL RESIDUO
                            EVOLUTIONEQS(0) <= (STATEIN.X, YSHIFTED, '0');
                            EVOLUTIONEQS(1) <= (STATEIN.Y, XSHIFTED, '0');
                            EVOLUTIONEQS(2) <= (STATEIN.Z, NOT(PHI), '1');
                            
                        ELSE 
                            -- ANGOLO RESIDUO NEGATIVO
                            -- ROTAZIONE ORARIA (ETA = -1)
                            -- SOMMO L'ANGOLO DI ROTAZIONE AL RESIDUO
                            EVOLUTIONEQS(0) <= (STATEIN.X, NOT(YSHIFTED), '1');
                            EVOLUTIONEQS(1) <= (STATEIN.Y, NOT(XSHIFTED), '1');
                            EVOLUTIONEQS(2) <= (STATEIN.Z,           PHI, '0');
                            
                        END IF; -- ROTATION DIRECTION
                        
                    WHEN M_VECTORING => 
                        IF STATEIN.Y(STATEIN.Y'HIGH) = '0' THEN 
                            -- SECONDA COMPONENTE DEL VETTORE POSITIVA
                            -- ROTAZIONE ORARIA
                            -- SOMMO ANGOLO AL RESIDUO
                            EVOLUTIONEQS(0) <= (STATEIN.X, NOT(YSHIFTED), '1');
                            EVOLUTIONEQS(1) <= (STATEIN.Y, NOT(XSHIFTED), '1');
                            EVOLUTIONEQS(2) <= (STATEIN.Z,           PHI, '0');
                            
                        ELSE 
                            -- SECONDA COMPONENTE DEL VETTORE NEGATIVA
                            -- ROTAZIONE ANTIORARIA
                            -- SOTTRAGGO L'ANGOLO AL RESIDUO
                            EVOLUTIONEQS(0) <= (STATEIN.X, YSHIFTED, '0');
                            EVOLUTIONEQS(1) <= (STATEIN.Y, XSHIFTED, '0');
                            EVOLUTIONEQS(2) <= (STATEIN.Z, NOT(PHI), '1');
                        
                        END IF;
                    
                    WHEN OTHERS      => -- NULL
                END CASE; -- MODE
            END IF; -- RISING EDGE
        END IF; -- RST
    END PROCESS COMPUTE;
    
    
    REGOUT : PROCESS (CLK, RST) BEGIN 
        IF RST = '1' THEN 
            STATEOUT <= ((OTHERS => '0'), (OTHERS => '0'), (OTHERS => '0'));
            
        ELSE 
            IF RISING_EDGE(CLK) THEN 
                STATEOUT <= (TEMP(0), TEMP(1), TEMP(2));
                
            END IF; -- RISING EDGE
        END IF; -- RST
    END PROCESS REGOUT;
    
    
    -- COMPONENTI PER IL CALCOLO DEGLI SHIFT
    SHIFTX : ENTITY WORK.RIGHTSHIFTER(RTL) 
        GENERIC MAP ( BLOCKS => BLOCKS, I => M_HINDEX(ITER) ) 
        PORT MAP (
            CLK => CLK, 
            RST => RST, 
            
            X => STATEIN.X, 
            Y => XSHIFTED
        );
        
    SHIFTY : ENTITY WORK.RIGHTSHIFTER(RTL) 
        GENERIC MAP ( BLOCKS => BLOCKS, I => M_HINDEX(ITER) ) 
        PORT MAP (
            CLK => CLK, 
            RST => RST, 
            
            X => STATEIN.Y, 
            Y => YSHIFTED
        );
        
    -- COMPONENTI PER I SOMMATORI: CALCOLO DELLE EQUAZIONI DI EVOLUZIONE
    GENEVOLUTIONEQS : FOR I IN 0 TO 2 GENERATE
        INSTADDER : ENTITY WORK.CCLA(RTL) 
            GENERIC MAP ( BLOCKS => BLOCKS ) 
            PORT MAP (
                CLK  => CLK, 
                RST  => RST, 
                
                A    => EVOLUTIONEQS(I).LHS, 
                B    => EVOLUTIONEQS(I).RHS, 
                CIN  => EVOLUTIONEQS(I).CIN, 
                
                SUM  => TEMP(I), 
                COUT => OPEN, 
                OVF  => OPEN
            );
    END GENERATE GENEVOLUTIONEQS;
END ARCHITECTURE RTL;