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


entity cmod_s7_top is
  generic (
       RamFileName : string:="";    -- :="compiled_code/monitor.hex"
       mode : string := "H";       -- only used when UseBRAMPrimitives is false
       BRAM_ADR_WIDTH  : natural := 13;
       Swapbytes : boolean := false -- SWAP Bytes in RAM word in low byte first order to use data2mem
  );
  port (
      I_RESET   : in  std_logic;
      CLK12MHZ  : in  std_logic;

      -- UART0 signals:
      uart0_txd : out std_logic;
      uart0_rxd : in  std_logic :='1';
      --LEDs
      led : inout std_logic_vector(3 downto 0);
      --QSPI FLASH
      qspi_cs : out std_logic;
      qspi_mosi : out std_logic;
      qspi_miso : in std_logic;
      --qspi_wpn  : out std_logic;
      qspi_holdn : out std_logic;
      qspi_sck : out std_logic
  );

end entity;

architecture Behavioral of cmod_s7_top is



  component bonfire_basic_soc_top
    generic (
         USE_BONFIRE_CORE : boolean := false;
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
         NUM_SPI : natural := 1;
         DEVICE_FAMILY : string :=  ""

       );

        port (sysclk         : in std_logic;
              I_RESET        : in std_logic;
              uart0_txd      : out std_logic;
              uart0_rxd      : in std_logic;
              uart1_txd      : out std_logic;
              uart1_rxd      : in std_logic;
              spi_cs        : out   std_logic_vector(NUM_SPI-1 downto 0);
              spi_clk       : out   std_logic_vector(NUM_SPI-1 downto 0);
              spi_mosi      : out   std_logic_vector(NUM_SPI-1 downto 0);
              spi_miso      : in    std_logic_vector(NUM_SPI-1 downto 0);
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


  component clkgen
  port
   (
    sysclk  : out std_logic;    
    reset   : in  std_logic;
    locked  : out    std_logic;
    clk12mhz: in     std_logic
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

signal sysclk : std_logic;

signal reset,res1  : std_logic;
signal clk_locked : std_logic;

signal gpio_o         : std_logic_vector(led'range);
signal gpio_i         : std_logic_vector(led'range);
signal gpio_t         : std_logic_vector(led'range);


begin


  qspi_holdn <= '1';
  --qspi_wpn <= '1';

  bonfire_basic_soc_top_i :  bonfire_basic_soc_top
      generic map (
        RamFileName      => RamFileName,
        mode             => mode,
        BRAM_ADR_WIDTH   => BRAM_ADR_WIDTH,
        -- LANED_RAM        => LANED_RAM,
        Swapbytes        => Swapbytes,
        -- ExtRAM           => ExtRAM,
        ENABLE_UART1     => false,
        ENABLE_SPI       => true,
        USE_BONFIRE_CORE => false,
        -- BurstSize        => BurstSize,
        -- CacheSizeWords   => CacheSizeWords,
        -- ENABLE_DCACHE    => ENABLE_DCACHE,
        -- DCacheSizeWords  => DCacheSizeWords,
        -- M_EXTENSION      => M_EXTENSION,
        -- BRANCH_PREDICTOR => BRANCH_PREDICTOR,
        -- REG_RAM_STYLE    => REG_RAM_STYLE,
        NUM_GPIO         => led'length,
        NUM_SPI          => 1

      )
      port map (
        sysclk         => sysclk,
        I_RESET        => reset,
        uart0_txd      => uart0_txd,
        uart0_rxd      => uart0_rxd,
        uart1_txd      => open,
        uart1_rxd      => '1',

        spi_cs(0)   => qspi_cs,
        spi_clk(0)  => qspi_sck,
        spi_mosi(0) => qspi_mosi,
        spi_miso(0) => qspi_miso,

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


      leds: for i in led'low to led'high generate
        led_pad : gpio_pad
        port map(
          i => gpio_o(i),
          o => gpio_i(i),
          t => gpio_t(i),
          io => led(i)
        );
       end generate;

     
    clkgen_inst : clkgen
     port map ( 
   
       sysclk => sysclk,
       reset => i_reset,
       locked => clk_locked,   
       clk12mhz => clk12mhz
     );

     --sysclk <= CLK12MHZ;

      reset <=  not clk_locked;


end architecture;
