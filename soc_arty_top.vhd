----------------------------------------------------------------------------------

-- Module Name:    bonfire_basic_soc - Behavioral

-- The Bonfire Processor Project, (c) 2016,2017 Thomas Hornschuh

--
-- License: See LICENSE or LICENSE.txt File in git project root.
--
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;


entity soc_arty_top is
  generic (
       RamFileName : string:="";    -- :="compiled_code/monitor.hex"
       mode : string := "H";       -- only used when UseBRAMPrimitives is false
       BRAM_ADR_WIDTH  : natural := 13;
       Swapbytes : boolean := false -- SWAP Bytes in RAM word in low byte first order to use data2mem
  );
  port (
  I_RESET   : in  std_logic;
  CLK100MHZ  : in  std_logic;

  -- UART0 signals:
  uart0_txd : out std_logic;
  uart0_rxd : in  std_logic :='1';
  gpio : inout std_logic_vector(3 downto 0)
  );

end entity;

architecture Behavioral of soc_arty_top is



  component bonfire_basic_soc_top
    generic (
      RamFileName      : string;
      mode             : string;
      BRAM_ADR_WIDTH   : natural := 13;
      LANED_RAM        : boolean := false;
      Swapbytes        : boolean := true;
      ExtRAM           : boolean := false;
      ENABLE_UART1     : boolean := true;
      ENABLE_SPI       : boolean := true;
      USE_BONFIRE_CORE : boolean := true;
      BurstSize        : natural := 8;
      CacheSizeWords   : natural := 512;
      ENABLE_DCACHE    : boolean := false;
      DCacheSizeWords  : natural := 512;
      M_EXTENSION      : boolean := true;
      BRANCH_PREDICTOR : boolean := true;
      REG_RAM_STYLE    : string := "block";
      NUM_GPIO         : natural := 8;
      DEVICE_FAMILY    : string := "ARTIX7";
      BYPASS_CLKGEN    : boolean := false
    );
    port (
      sysclk         : in  std_logic;
      I_RESET        : in  std_logic; -- active low
      uart0_txd      : out std_logic;
      uart0_rxd      : in  std_logic :='1';
      uart1_txd      : out std_logic;
      uart1_rxd      : in  std_logic :='1';
      flash_spi_cs   : out std_logic;
      flash_spi_clk  : out std_logic;
      flash_spi_mosi : out std_logic;
      flash_spi_miso : in  std_logic;
      GPIO           : inout STD_LOGIC_VECTOR(NUM_GPIO-1 downto 0)
    );
 end component bonfire_basic_soc_top;

 component clkgen_arty
 port (
   clkout : out STD_LOGIC;
 --  resetn  : in  STD_LOGIC;
   locked : out STD_LOGIC;
   sysclk : in  STD_LOGIC
 );
 end component clkgen_arty;

signal sysclk : std_logic;

signal reset,res1  : std_logic;
signal clk_locked : std_logic;


begin

  bonfire_basic_soc_top_i :  bonfire_basic_soc_top
      generic map (
        RamFileName      => RamFileName,
        mode             => mode,
        BRAM_ADR_WIDTH   => BRAM_ADR_WIDTH,
        -- LANED_RAM        => LANED_RAM,
        Swapbytes        => Swapbytes,
        -- ExtRAM           => ExtRAM,
        ENABLE_UART1     => false,
        ENABLE_SPI       => false,
        USE_BONFIRE_CORE => true,
        -- BurstSize        => BurstSize,
        -- CacheSizeWords   => CacheSizeWords,
        -- ENABLE_DCACHE    => ENABLE_DCACHE,
        -- DCacheSizeWords  => DCacheSizeWords,
        -- M_EXTENSION      => M_EXTENSION,
        -- BRANCH_PREDICTOR => BRANCH_PREDICTOR,
        -- REG_RAM_STYLE    => REG_RAM_STYLE,
        NUM_GPIO         => gpio'length

      )
      port map (
        sysclk         => sysclk,
        I_RESET        => reset, 
        uart0_txd      => uart0_txd,
        uart0_rxd      => uart0_rxd,
        uart1_txd      => open,
        uart1_rxd      => '1',
        flash_spi_cs   => open,
        flash_spi_clk  => open,
        flash_spi_mosi => open,
        flash_spi_miso => '0',
        GPIO           => gpio
      );


      clkgen_inst: clkgen_arty
        port map (
        -- Clock out ports
        clkout => sysclk,
        -- Status and control signals
        --resetn => I_RESET,
        locked => clk_locked,
        -- Clock in ports
        sysclk => CLK100MHZ
      );

      reset <= not clk_locked;

     
end architecture;
