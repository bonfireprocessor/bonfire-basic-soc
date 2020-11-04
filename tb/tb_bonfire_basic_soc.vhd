
----------------------------------------------------------------------------------
-- Testbench automatically generated online
-- at http://vhdl.lapinoo.net
-- Generation date : 30.4.2018 16:33:09 GMT

-- The Bonfire Processor Project, (c) 2016,2017 Thomas Hornschuh

--
-- License: See LICENSE or LICENSE.txt File in git project root.
--
--
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

LIBRARY std;
USE std.textio.all;

use work.txt_util.all;


entity tb_bonfire_basic_soc is
generic(
         USE_BONFIRE_CORE : boolean := true; -- Use bonfire-core instead of bonfire-cpu, experimental
         RamFileName : string :="/home/thomas/development/bonfire/bonfire-software/monitor/BASIC_12_monitor.hex";
         BRAM_ADR_WIDTH : natural := 13;
         mode : string := "H";       -- only used when UseBRAMPrimitives is false
         LANED_RAM : boolean := true; -- Implement RAM in Byte Lanes
         ENABLE_UART1 : boolean := false;
         ENABLE_SPI   : boolean := true;
         Swapbytes : boolean := false; -- SWAP Bytes in RAM word in low byte first order to use data2mem
         ExtRAM : boolean := false; -- "Simulate" External RAM as Bock RAM
         BurstSize : natural := 8;
         CacheSizeWords : natural := 0;
         ENABLE_DCACHE : boolean := false;
         DCacheSizeWords : natural := 512;
         M_EXTENSION : boolean :=true;
         BRANCH_PREDICTOR : boolean := true;
         REG_RAM_STYLE : string := "block";
         NUM_GPIO   : natural := 8;
         DEVICE_FAMILY : string :=  "";
         UART_BAUDRATE : natural := 38400;
         CLK_FREQ_MHZ : natural := 12
       );


end tb_bonfire_basic_soc;

architecture tb of tb_bonfire_basic_soc is

    component bonfire_basic_soc_top
    generic (
         USE_BONFIRE_CORE : boolean := true;
         RamFileName : string:="";
         mode : string := "H";
         BRAM_ADR_WIDTH : natural := 13;
         LANED_RAM : boolean := true;
         ENABLE_UART1 : boolean := true;
         ENABLE_SPI   : boolean := true;
         Swapbytes : boolean := true;
         ExtRAM : boolean := false;
         BurstSize : natural := 8;
         CacheSizeWords : natural := 512;
         ENABLE_DCACHE : boolean := false;
         DCacheSizeWords : natural := 512;
         M_EXTENSION : boolean := true;
         BRANCH_PREDICTOR : boolean := true;
         REG_RAM_STYLE : string := "block";
         NUM_GPIO   : natural := 8;
         DEVICE_FAMILY : string :=  ""

       );

        port (sysclk         : in std_logic;
              I_RESET        : in std_logic;
              uart0_txd      : out std_logic;
              uart0_rxd      : in std_logic;
              uart1_txd      : out std_logic;
              uart1_rxd      : in std_logic;
              flash_spi_cs   : out std_logic;
              flash_spi_clk  : out std_logic;
              flash_spi_mosi : out std_logic;
              flash_spi_miso : in std_logic;
              gpio_o : out std_logic_vector(NUM_GPIO-1 downto 0);
              gpio_i : in  std_logic_vector(NUM_GPIO-1 downto 0);
              gpio_t : out std_logic_vector(NUM_GPIO-1 downto 0);
              wbm_cyc_o      : out std_logic;
              wbm_stb_o      : out std_logic;
              wbm_we_o       : out std_logic;
              wbm_cti_o      : out std_logic_vector(2 downto 0);
              wbm_bte_o      : out std_logic_vector(1 downto 0);
              wbm_sel_o      : out std_logic_vector(3 downto 0);
              wbm_ack_i      : in  std_logic;
              wbm_adr_o      : out std_logic_vector(25 downto 2);
              wbm_dat_i      : in  std_logic_vector(31 downto 0);
              wbm_dat_o      : out std_logic_vector(31 downto 0)
         );

    end component;


    component gpio_pad
    port (
      I  : in  STD_LOGIC;
      O  : out STD_LOGIC;
      T  : in  STD_LOGIC;
      IO : inout STD_LOGIC
    );
    end component gpio_pad;


    signal sysclk         : std_logic;
    signal I_RESET        : std_logic :='0';
    signal uart0_txd      : std_logic;
    signal uart0_rxd      : std_logic :='1';
    signal uart1_txd      : std_logic;
    signal uart1_rxd      : std_logic := '1';
    signal flash_spi_cs   : std_logic;
    signal flash_spi_clk  : std_logic;
    signal flash_spi_mosi : std_logic;
    signal flash_spi_miso : std_logic;

    signal gpio_io           : std_logic_vector (num_gpio-1 downto 0);

    signal gpio_o         : std_logic_vector(NUM_GPIO-1 downto 0);
    signal gpio_i         : std_logic_vector(NUM_GPIO-1 downto 0);
    signal gpio_t         : std_logic_vector(NUM_GPIO-1 downto 0);


    constant ClockPeriod : time :=  ( 1000.0 / real(CLK_FREQ_MHZ) ) * 1 ns;

    signal TbClock : std_logic := '0';
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



begin

    dut : bonfire_basic_soc_top
    generic map (
         USE_BONFIRE_CORE => USE_BONFIRE_CORE,
         RamFileName => RamFileName,
         mode => mode,
         BRAM_ADR_WIDTH => BRAM_ADR_WIDTH,
         Swapbytes => SwapBytes,
         LANED_RAM => LANED_RAM,
         ENABLE_UART1 => ENABLE_UART1,
         ENABLE_SPI => ENABLE_SPI,
         ExtRAM => ExtRAM,
         BurstSize => BurstSize,
         CacheSizeWords => CacheSizeWords,
         ENABLE_DCACHE => ENABLE_DCACHE,
         DCacheSizeWords => DCacheSizeWords,
         M_EXTENSION => M_EXTENSION,
         BRANCH_PREDICTOR=>BRANCH_PREDICTOR,
         REG_RAM_STYLE => REG_RAM_STYLE,
         NUM_GPIO  => NUM_GPIO,
         DEVICE_FAMILY => DEVICE_FAMILY
    )
    port map (sysclk         => sysclk,
              I_RESET        => I_RESET,
              uart0_txd      => uart0_txd,
              uart0_rxd      => uart0_rxd,
              uart1_txd      => uart1_txd,
              uart1_rxd      => uart1_rxd,
              flash_spi_cs   => flash_spi_cs,
              flash_spi_clk  => flash_spi_clk,
              flash_spi_mosi => flash_spi_mosi,
              flash_spi_miso => flash_spi_miso,
              gpio_o => gpio_o,
              gpio_i => gpio_i,
              gpio_t => gpio_t,

              wbm_cyc_o      => open,
              wbm_stb_o      => open,
              wbm_we_o       => open,
              wbm_cti_o      => open,
              wbm_bte_o      => open,
              wbm_sel_o      => open,
              wbm_ack_i      => '1',
              wbm_adr_o      => open,
              wbm_dat_i      => (others=>'X'),
              wbm_dat_o      => open
      );



    gpio_pads: for i in gpio_io'range generate
      pad : gpio_pad

      port map (
         O => gpio_i(i),   -- Buffer output
         IO => gpio_io(i),    -- Buffer inout port
         I => gpio_o(i),   -- Buffer input
         T => gpio_t(i)    -- 3-state enable input, high=input, low=output
      );

    end generate;


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

    -- process(total_count)
    -- begin
    --   report "Byte received over UART"  severity note;

    -- end process;

    process
    begin
      wait on gpio_io;
      print("IO Pads:" & str(gpio_io) & "(" & hstr(gpio_io) & ")");

    end process;


    -- Clock generation
    TbClock <= not TbClock after ClockPeriod / 2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that sysclk is really your main clock signal
    sysclk <= TbClock;

    -- SPI Loopback

    flash_spi_miso <= flash_spi_mosi;

    stimuli : process
    begin

        wait for ClockPeriod;
        I_RESET <= '1';
        wait for ClockPeriod * 3;
        I_RESET <= '0';
        print("Start simulation");

        wait until uart0_stop;
        print("");
        print("UART0 Test captured bytes: " & str(total_count(0)) & " framing errors: " & str(framing_errors(0)));

        TbSimEnded <= '1';
        wait;
    end process;

end tb;
