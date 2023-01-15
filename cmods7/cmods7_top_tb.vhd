
library ieee;
use ieee.std_logic_1164.all;

LIBRARY std;
USE std.textio.all;

use work.txt_util.all;


	

entity cmods7_top_tb is
end cmods7_top_tb;

architecture TB_ARCHITECTURE of cmods7_top_tb is

	component 
	-- Component declaration of the tested unit
		generic (
			RamFileName : string :="/home/thomas/development/bonfire/bonfire-software/monitor/sim_hello.hex"
		);
		port(
			I_RESET : in STD_LOGIC;
			CLK12MHZ : in STD_LOGIC;
			uart0_txd : out STD_LOGIC;
			uart0_rxd : in STD_LOGIC;
			led : out STD_LOGIC_VECTOR(3 downto 0) );
	end component;							 
	
	constant ClockPeriod : time :=  ( 1000.0 / real(12) ) * 1 ns;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal sysclk : STD_LOGIC := '0';
	signal resetn : STD_LOGIC;
	signal uart0_rxd : STD_LOGIC := '1';
	-- Observed signals - signals mapped to the output ports of tested entity
	signal uart0_txd : STD_LOGIC;
	signal led : STD_LOGIC_VECTOR(7 downto 0);

	
    signal TbSimEnded : std_logic := '0';


	-- UART Capture Module
    constant bit_time : time := ( 1_000_000.0 / real(UART_BAUDRATE) ) * 1 us;
    subtype t_uartnum is natural range 0 to 1;
    type t_uart_kpi is array (t_uartnum) of natural;

    signal total_count : t_uart_kpi;
    signal framing_errors : t_uart_kpi;
    signal uart0_stop : boolean;

    COMPONENT tb_uart_capture_tx
    GENERIC (
      baudrate : natural;
      bit_time : time;
      SEND_LOG_NAME : string ;
      echo_output : boolean ;
      stop_mark : std_logic_vector(7 downto 0) -- Stop marker byte
     );
    PORT(
        txd : IN std_logic;
        stop : OUT boolean;
        framing_errors : OUT natural;
        total_count : OUT natural
        );
    END COMPONENT;

	-- Add your code here ...

begin

	-- Unit Under Test port map
	UUT : cmod_s7_top
		port map (
			CLK12MHZ => sysclk,
			I_RESET => reset,
			uart0_txd => uart0_txd,
			uart0_rxd => uart0_rxd,
			led => led
		);



	capture_tx_0 :  tb_uart_capture_tx
	GENERIC MAP (
		baudrate => natural(UART_BAUDRATE),
		bit_time => bit_time,
		SEND_LOG_NAME => "send0.log",
		echo_output => True,
		stop_mark => X"1A"
	)
	PORT MAP(
		 txd => uart0_txd,
		 stop => uart0_stop ,
		 framing_errors => framing_errors(0),
		 total_count =>total_count(0)
	 );	


	
	sysclk <= not sysclk after ClockPeriod / 2;
	
	stimuli : process
    begin
      
        wait for ClockPeriod;
        reset <= '1';
        wait for ClockPeriod * 3;
        reset <= '0';
        print("Start simulation"); 
    
        wait until uart0_stop;
        print("");
        print("UART0 Test captured bytes: " & str(total_count(0)) & " framing errors: " & str(framing_errors(0)));

        TbSimEnded <= '1';
        wait;
    end process;

end TB_ARCHITECTURE;


