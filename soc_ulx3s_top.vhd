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


entity soc_ulx3s_top is
  generic (
       RamFileName : string := "c:/Users/thoma/development/bonfire/bonfire-software/test/hw_hello.hex";
       BRANCH_PREDICTOR : boolean := true
     );
     port(
          sysclk  : in  std_logic;       
          resetn : in std_logic;

          -- UART0 signals:
          uart0_txd : out std_logic;
          uart0_rxd : in  std_logic :='1';

          led : out std_logic_vector(7 downto 0)
    );

end entity;

architecture Behavioral of soc_ulx3s_top is



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
      gpio_o : out std_logic_vector(NUM_GPIO-1 downto 0);
      gpio_i : in  std_logic_vector(NUM_GPIO-1 downto 0);
      gpio_t : out std_logic_vector(NUM_GPIO-1 downto 0)
    );
 end component bonfire_basic_soc_top;


signal reset,res1,res2  : std_logic;
signal clk_locked : std_logic;

signal gpio_o         : std_logic_vector(LED'range);
signal gpio_i         : std_logic_vector(LED'range);
signal gpio_t         : std_logic_vector(LED'range);


begin

  bonfire_basic_soc_top_i :  bonfire_basic_soc_top
      generic map (
        RamFileName      => RamFileName,
        mode             => "H",
        BRAM_ADR_WIDTH   => 12,  -- TODO: Switch tis back to 11 for the FireAnt board
        LANED_RAM        => true,
        Swapbytes        => false,
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
        NUM_GPIO         => LED'length

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
        gpio_o => gpio_o,
        gpio_i => gpio_i,
        gpio_t => gpio_t
      );


    
      LED(7) <= not resetn; -- to check polarity of reset button.
      LED(6 downto 0) <=  gpio_o(6 downto 0);

      process(sysclk) begin
         if rising_edge(sysclk) then
            res1 <= not resetn;
            res2 <= res1;
            reset <= res2;
         end if;
      end process;

end architecture;
