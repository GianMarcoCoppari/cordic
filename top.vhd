library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.config.all;
use work.configcordic.all;
use work.configalu.all;


entity top is 
    port (
        clk_n : in std_logic;
        clk_p : in std_logic
    );
end entity top;


architecture behavioral of top is 
    -- Clocking Wizard
    component clk_wiz_0 is
        port (
            -- Clock in ports
            -- Clock out ports
            clk_out1  : out std_logic;
            
            -- Status and control signals
            reset     : in  std_logic;
            locked    : out std_logic;
            clk_in1_p : in  std_logic;
            clk_in1_n : in  std_logic
         );
    end component clk_wiz_0;
    
    -- Virtual In/Out Wizard
    component vio_0 is
        port (
            clk : in std_logic;
        
            probe_in0  : in  std_logic_vector(m_blocksize * m_blocks - 1 downto 0);
            probe_in1  : in  std_logic_vector(m_blocksize * m_blocks - 1 downto 0);
            probe_in2  : in  std_logic_vector(m_blocksize * m_blocks - 1 downto 0);
        
            probe_out0 : out std_logic_vector(m_blocksize * m_blocks - 1 downto 0);
            probe_out1 : out std_logic_vector(m_blocksize * m_blocks - 1 downto 0);
            probe_out2 : out std_logic_vector(m_blocksize * m_blocks - 1 downto 0);
            probe_out3 : out std_logic_vector(0 downto 0) 
        );
    end component vio_0;
    
    
    -- segnali interni
    constant mode : cordicmode_t := m_rotating;
    
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    
    signal probe_in0_tb : std_logic_vector(m_blocksize * m_blocks - 1 downto 0);
    signal probe_in1_tb : std_logic_vector(m_blocksize * m_blocks - 1 downto 0);
    signal probe_in2_tb : std_logic_vector(m_blocksize * m_blocks - 1 downto 0);
            
    signal statein  : cordicstate_t := ((others => '0'), (others => '0'), (others => '0'));
    signal stateout : cordicstate_t;
    
    
begin 
    -- Istanzio clk_wiz_0
    clock : clk_wiz_0 
        port map (
            clk_in1_n => clk_n, 
            clk_in1_p => clk_p, 
            reset     => '0',
            
            locked    => open, 
            clk_out1  => clk
            
        );
    
    
    -- Istanzio vio_0
    vio : vio_0 
        port map (
            clk => clk, 
            
            probe_in0     => stateout.x, 
            probe_in1     => stateout.y, 
            probe_in2     => stateout.z, 
            
            probe_out0    => statein.x, 
            probe_out1    => statein.y, 
            probe_out2    => statein.z, 
            probe_out3(0) => rst
        );


    dut : entity work.cordich(rtl) 
        generic map ( blocks => m_blocks, mode => mode ) 
        port map (
            clk      => clk, 
            rst      => rst,
            
            statein  => statein, -- (out1, out2, out3)
            stateout => stateout -- (in1, in2, in3)
        );
        
end architecture behavioral;