-- Testbench automatically generated online
-- at http://vhdl.lapinoo.net
-- Generation date : 30.4.2018 16:33:09 GMT

library ieee;
use ieee.std_logic_1164.all;

entity tb_bonfire_basic_soc is
generic(
         RamFileName : string :="/home/thomas/development/bonfire/bonfire-basic-soc/compiled_code/BASIC_monitor.hex";
         mode : string := "H";       -- only used when UseBRAMPrimitives is false
         Swapbytes : boolean := true; -- SWAP Bytes in RAM word in low byte first order to use data2mem
         ExtRAM : boolean := false; -- "Simulate" External RAM as Bock RAM
         BurstSize : natural := 8;
         CacheSizeWords : natural := 512; -- 2KB Instruction Cache
         EnableDCache : boolean := false;
         DCacheSizeWords : natural := 512;
         MUL_ARCH: string := "spartandsp";
         REG_RAM_STYLE : string := "block";
         NUM_GPIO   : natural := 8;
         DEVICE_FAMILY : string :=  ""

       );


end tb_bonfire_basic_soc;

architecture tb of tb_bonfire_basic_soc is

    component bonfire_basic_soc
    generic (
         RamFileName : string:="";    -- :="compiled_code/monitor.hex";
         mode : string := "H";       -- only used when UseBRAMPrimitives is false
         Swapbytes : boolean := true; -- SWAP Bytes in RAM word in low byte first order to use data2mem
         ExtRAM : boolean := false; -- "Simulate" External RAM as Bock RAM
         BurstSize : natural := 8;
         CacheSizeWords : natural := 512; -- 2KB Instruction Cache
         EnableDCache : boolean := false;
         DCacheSizeWords : natural := 512;
         MUL_ARCH: string := "spartandsp";
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
              GPIO           : inout std_logic_vector (NUM_GPIO-1 downto 0));
    end component;

    signal sysclk         : std_logic;
    signal I_RESET        : std_logic;
    signal uart0_txd      : std_logic;
    signal uart0_rxd      : std_logic :='1';
    signal uart1_txd      : std_logic;
    signal uart1_rxd      : std_logic := '1';
    signal flash_spi_cs   : std_logic;
    signal flash_spi_clk  : std_logic;
    signal flash_spi_mosi : std_logic;
    signal flash_spi_miso : std_logic;
    signal GPIO           : std_logic_vector (num_gpio-1 downto 0);

    constant TbPeriod : time := 10 ns;  -- 100 Mhz (for ARTY)
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : bonfire_basic_soc
    generic map (
      RamFileName => RamFileName,
         mode => mode,
         Swapbytes => SwapBytes,
         ExtRAM => ExtRAM,
         BurstSize => BurstSize,
         CacheSizeWords => CacheSizeWords,
         EnableDCache => EnableDCache,
         DCacheSizeWords => DCacheSizeWords,
         MUL_ARCH => MUL_ARCH,
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
              GPIO           => GPIO);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that sysclk is really your main clock signal
    sysclk <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        uart0_rxd <= '0';
        uart1_rxd <= '0';
        flash_spi_miso <= '0';

        -- Reset generation
        -- EDIT: Check that I_RESET is really your reset signal
        I_RESET <= '1';
        wait for 100 ns;
        I_RESET <= '0';
        wait for 100 ns;

        -- EDIT Add stimuli here
     

        -- Stop the clock and hence terminate the simulation
        --TbSimEnded <= '1';
        wait;
    end process;

end tb;


