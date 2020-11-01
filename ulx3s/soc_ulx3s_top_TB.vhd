library ecp5u;
use ecp5u.components.all;
library ieee;
use ieee.std_logic_1164.all;
library vital2000;
use vital2000.VITAL_Timing.all;

	-- Add your library and packages declaration here ...

entity soc_ulx3s_top_tb is
end soc_ulx3s_top_tb;

architecture TB_ARCHITECTURE of soc_ulx3s_top_tb is
	-- Component declaration of the tested unit
	
	port(
		sysclk : in STD_LOGIC;
		resetn : in STD_LOGIC;
		uart0_txd : out STD_LOGIC;
		uart0_rxd : in STD_LOGIC;
		led : out STD_LOGIC_VECTOR(7 downto 0) );
	end component;							 
	
	constant ClockPeriod : time :=  ( 1000.0 / real(25) ) * 1 ns;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal sysclk : STD_LOGIC := '0';
	signal resetn : STD_LOGIC;
	signal uart0_rxd : STD_LOGIC := '1';
	-- Observed signals - signals mapped to the output ports of tested entity
	signal uart0_txd : STD_LOGIC;
	signal led : STD_LOGIC_VECTOR(7 downto 0);

	-- Add your code here ...

begin

	-- Unit Under Test port map
	UUT : soc_ulx3s_top
		port map (
			sysclk => sysclk,
			resetn => resetn,
			uart0_txd => uart0_txd,
			uart0_rxd => uart0_rxd,
			led => led
		);

	-- Add your stimulus here ...
	
	sysclk <= not sysclk after ClockPeriod / 2;
	
	stimuli : process
    begin
      
        wait for ClockPeriod;
        resetn <= '0';
        wait for ClockPeriod * 3;
        resetn <= '1';
        --print("Start simulation"); 
    
       -- wait until uart0_stop;
--        print("");
--        print("UART0 Test captured bytes: " & str(total_count(0)) & " framing errors: " & str(framing_errors(0)));
--
--        TbSimEnded <= '1';
        wait;
    end process;

end TB_ARCHITECTURE;

--configuration TESTBENCH_FOR_soc_ulx3s_top of soc_ulx3s_top_tb is
--	for TB_ARCHITECTURE
--		for UUT : soc_ulx3s_top
--			use entity work.soc_ulx3s_top(structure);
--		end for;
--	end for;
--end TESTBENCH_FOR_soc_ulx3s_top;
--
