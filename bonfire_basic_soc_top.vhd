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
use IEEE.NUMERIC_STD.ALL;


entity bonfire_basic_soc_top is
generic (
     USE_BONFIRE_CORE : boolean := false; -- Use bonfire-core instead of bonfire-cpu, experimental
     RamFileName : string:="";    -- :="compiled_code/monitor.hex";
     mode : string := "H";       -- only used when UseBRAMPrimitives is false
     BRAM_ADR_WIDTH : natural := 13;
     LANED_RAM : boolean := false; -- Implement RAM in Byte Lanes
     Swapbytes : boolean := true; -- SWAP Bytes in RAM word in low bRAMyte first order to use data2mem
     ExtRAM : boolean := false; 
     ENABLE_UART1    : boolean := true;
     ENABLE_SPI      : boolean := true;  
     NUM_SPI : natural := 1; 
     BurstSize : natural := 8;
     CacheSizeWords : natural := 512; -- 2KB Instruction Cache
     ENABLE_DCACHE : boolean := false;
     DCacheSizeWords : natural := 512;
     M_EXTENSION : boolean := true;
     BRANCH_PREDICTOR : boolean := true;
     REG_RAM_STYLE : string := "block";
     NUM_GPIO   : natural := 8;
     DEVICE_FAMILY : string :=  ""
   
   );
   port(
        sysclk  : in  std_logic;
        I_RESET   : in  std_logic;
        -- UART0 signals:
        uart0_txd : out std_logic;
        uart0_rxd : in  std_logic :='1';
        -- UART1 signals:
        uart1_txd : out std_logic;
        uart1_rxd : in  std_logic :='1';
        -- SPI
        spi_cs        : out   std_logic_vector(NUM_SPI-1 downto 0);
        spi_clk       : out   std_logic_vector(NUM_SPI-1 downto 0);
        spi_mosi      : out   std_logic_vector(NUM_SPI-1 downto 0);
        spi_miso      : in    std_logic_vector(NUM_SPI-1 downto 0);
         -- GPIO
        gpio_o : out std_logic_vector(NUM_GPIO-1 downto 0);
        gpio_i : in  std_logic_vector(NUM_GPIO-1 downto 0);
        gpio_t : out std_logic_vector(NUM_GPIO-1 downto 0);

        -- External memory bus
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
end bonfire_basic_soc_top;

architecture Behavioral of bonfire_basic_soc_top is


constant reset_adr : std_logic_vector(31 downto 0) :=X"0C000000";
constant TOTAL_GPIO : natural := NUM_GPIO;
constant ram_size : natural := 2**BRAM_ADR_WIDTH;


signal clk : std_logic;       -- logical CPU clock
signal reset : std_logic;

signal irq_i : std_logic_vector(7 downto 0);



component bonfire_basic_soc is
  generic (
    ENABLE_EXT_RAM  : boolean := false;
    ENABLE_UART1    : boolean := false;
    ENABLE_SPI      : boolean := false;
    ENABLE_DCACHE   : boolean := false;
    BRAM_ADR_WIDTH  : natural := 13;
    BurstSize       : natural := 8;
    CacheSizeWords  : natural := 512;
    DCacheSizeWords : natural := 512;
    BRAM_ADR_BASE : std_logic_vector(7 downto 0) := X"0C";
    REG_RAM_STYLE   : string;
    M_EXTENSION  : boolean := true;
    BRANCH_PREDICTOR : boolean := true;
    NUM_GPIO        : natural := 8;
    NUM_SPI : natural := 1;
    DEVICE_FAMILY   : string
  );
  port (
    clk_i          : in  std_logic;
    reset_i        : in  std_logic;
    bram_dba_i     : in  std_logic_vector(31 downto 0);
    bram_dba_o     : out std_logic_vector(31 downto 0);
    bram_adra_o    : out std_logic_vector(BRAM_ADR_WIDTH-1 downto 0);
    bram_ena_o     : out STD_LOGIC;
    bram_wrena_o   : out STD_LOGIC_VECTOR (3 downto 0);
    bram_dbb_i     : in  std_logic_vector(31 downto 0);
    bram_adrb_o    : out std_logic_vector(BRAM_ADR_WIDTH-1 downto 0);
    bram_enb_o     : out STD_LOGIC;
    wbm_cyc_o      : out std_logic;
    wbm_stb_o      : out std_logic;
    wbm_we_o       : out std_logic;
    wbm_cti_o      : out std_logic_vector(2 downto 0);
    wbm_bte_o      : out std_logic_vector(1 downto 0);
    wbm_sel_o      : out std_logic_vector(3 downto 0);
    wbm_ack_i      : in  std_logic;
    wbm_adr_o      : out std_logic_vector(25 downto 2);
    wbm_dat_i      : in  std_logic_vector(31 downto 0);
    wbm_dat_o      : out std_logic_vector(31 downto 0);
    uart0_txd : out std_logic;
    uart0_rxd      : in  std_logic;
    uart1_txd : out std_logic;
    uart1_rxd      : in  std_logic;
    spi_cs        : out   std_logic_vector(NUM_SPI-1 downto 0);
    spi_clk       : out   std_logic_vector(NUM_SPI-1 downto 0);
    spi_mosi      : out   std_logic_vector(NUM_SPI-1 downto 0);
    spi_miso      : in    std_logic_vector(NUM_SPI-1 downto 0);

    gpio_o         : out std_logic_vector(NUM_GPIO-1 downto 0);
    gpio_i         : in  std_logic_vector(NUM_GPIO-1 downto 0);
    gpio_t         : out std_logic_vector(NUM_GPIO-1 downto 0)
  );
end component;

component bonfire_core_basic_soc
generic (
  ENABLE_EXT_RAM  : boolean := false;
  ENABLE_UART1    : boolean := false;
  ENABLE_SPI      : boolean := false;
  ENABLE_DCACHE   : boolean := false;
  ENABLE_GPIO     : boolean := true;
  UART_FIFO_DEPTH : natural := 6;
  BRAM_ADR_WIDTH  : natural := 12;
  NUM_GPIO        : natural := 8;
  DCacheSizeWords : natural := 0;
  NUM_SPI : natural := 1;
  DEVICE_FAMILY   : string
);
port (
  clk_i          : in  std_logic;
  reset_i        : in  std_logic;
  bram_dba_i     : in  std_logic_vector(31 downto 0);
  bram_dba_o     : out std_logic_vector(31 downto 0);
  bram_adra_o    : out std_logic_vector(BRAM_ADR_WIDTH-1 downto 0);
  bram_ena_o     : out STD_LOGIC;
  bram_wrena_o   : out STD_LOGIC_VECTOR (3 downto 0);
  bram_dbb_i     : in  std_logic_vector(31 downto 0);
  bram_adrb_o    : out std_logic_vector(BRAM_ADR_WIDTH-1 downto 0);
  bram_enb_o     : out STD_LOGIC;
  wbm_cyc_o      : out std_logic;
  wbm_stb_o      : out std_logic;
  wbm_we_o       : out std_logic;
  wbm_cti_o      : out std_logic_vector(2 downto 0);
  wbm_bte_o      : out std_logic_vector(1 downto 0);
  wbm_sel_o      : out std_logic_vector(3 downto 0);
  wbm_ack_i      : in  std_logic;
  wbm_adr_o      : out std_logic_vector(25 downto 2);
  wbm_dat_i      : in  std_logic_vector(31 downto 0);
  wbm_dat_o      : out std_logic_vector(31 downto 0);
  uart0_txd      : out std_logic;
  uart0_rxd      : in  std_logic;
  uart1_txd      : out std_logic;
  uart1_rxd      : in  std_logic;
  spi_cs        : out   std_logic_vector(NUM_SPI-1 downto 0);
  spi_clk       : out   std_logic_vector(NUM_SPI-1 downto 0);
  spi_mosi      : out   std_logic_vector(NUM_SPI-1 downto 0);
  spi_miso      : in    std_logic_vector(NUM_SPI-1 downto 0);
  gpio_o         : out std_logic_vector(NUM_GPIO-1 downto 0);
  gpio_i         : in  std_logic_vector(NUM_GPIO-1 downto 0);
  gpio_t         : out std_logic_vector(NUM_GPIO-1 downto 0)
);
end component bonfire_core_basic_soc;



signal bram_dba_i     : std_logic_vector(31 downto 0);
signal bram_dba_o     : std_logic_vector(31 downto 0);
signal bram_adra_o    : std_logic_vector(BRAM_ADR_WIDTH-1 downto 0);
signal bram_ena_o     : STD_LOGIC;
signal bram_wrena_o   : STD_LOGIC_VECTOR (3 downto 0);
signal bram_dbb_i     : std_logic_vector(31 downto 0);
signal bram_adrb_o    : std_logic_vector(BRAM_ADR_WIDTH-1 downto 0);
signal bram_enb_o     : STD_LOGIC;


begin

  clk <= sysclk;
  reset <= I_RESET;


   assert TOTAL_GPIO <= 32
     report "Total number of gpio ports cannot exceed 32"
     severity failure;

   -- Assignment of IOBs for GPIO



use_bonfire_cpu: if not USE_BONFIRE_CORE generate
   

   bonfire_basic_soc_i : bonfire_basic_soc
   generic map (
     ENABLE_EXT_RAM  => ExtRAM,
     ENABLE_UART1    => ENABLE_UART1,
     ENABLE_SPI      => ENABLE_SPI,
     ENABLE_DCACHE   => ENABLE_DCACHE,
     BRAM_ADR_WIDTH  => BRAM_ADR_WIDTH,
     BurstSize       => BurstSize,
     CacheSizeWords  => CacheSizeWords,
     DCacheSizeWords => DCacheSizeWords,
     M_EXTENSION     => M_EXTENSION,
     BRANCH_PREDICTOR => BRANCH_PREDICTOR,
     REG_RAM_STYLE   => REG_RAM_STYLE,
     NUM_GPIO        => NUM_GPIO,
     NUM_SPI         => NUM_SPI, 
     DEVICE_FAMILY   => DEVICE_FAMILY,
     BRAM_ADR_BASE   =>  X"C0"
   )
   port map (
     clk_i          => clk,
     reset_i        => reset,
     bram_dba_i     => bram_dba_i,
     bram_dba_o     => bram_dba_o,
     bram_adra_o    => bram_adra_o,
     bram_ena_o     => bram_ena_o,
     bram_wrena_o   => bram_wrena_o,
     bram_dbb_i     => bram_dbb_i,
     bram_adrb_o    => bram_adrb_o,
     bram_enb_o     => bram_enb_o,
     wbm_cyc_o      => wbm_cyc_o,
     wbm_stb_o      => wbm_stb_o,
     wbm_we_o       => wbm_we_o,
     wbm_cti_o      => wbm_cti_o,
     wbm_bte_o      => wbm_bte_o,
     wbm_sel_o      => wbm_sel_o,
     wbm_ack_i      => wbm_ack_i,
     wbm_adr_o      => wbm_adr_o,
     wbm_dat_i      => wbm_dat_i,
     wbm_dat_o      => wbm_dat_o,
     uart0_txd      => uart0_txd,
     uart0_rxd      => uart0_rxd,
     uart1_txd      => uart1_txd,
     uart1_rxd      => uart1_rxd,
     spi_cs   => spi_cs,
     spi_clk  => spi_clk,
     spi_mosi => spi_mosi,
     spi_miso => spi_miso,
     gpio_o         => gpio_o,
     gpio_i         => gpio_i,
     gpio_t         => gpio_t
   );
end generate;

g_use_bonfire_core: if USE_BONFIRE_CORE generate
   bonfire_basic_soc_i : bonfire_core_basic_soc
   generic map (
     ENABLE_EXT_RAM  => ExtRAM,
     ENABLE_UART1    => ENABLE_UART1,
     ENABLE_SPI      => ENABLE_SPI,
     ENABLE_DCACHE   => ENABLE_DCACHE,
     BRAM_ADR_WIDTH =>  BRAM_ADR_WIDTH,

     NUM_GPIO        => NUM_GPIO,
     NUM_SPI         => NUM_SPI, 
     DEVICE_FAMILY   => DEVICE_FAMILY
   )
   port map (
     clk_i          => clk,
     reset_i        => reset,
     bram_dba_i     => bram_dba_i,
     bram_dba_o     => bram_dba_o,
     bram_adra_o    => bram_adra_o,
     bram_ena_o     => bram_ena_o,
     bram_wrena_o   => bram_wrena_o,
     bram_dbb_i     => bram_dbb_i,
     bram_adrb_o    => bram_adrb_o,
     bram_enb_o     => bram_enb_o,
     wbm_cyc_o      => wbm_cyc_o,
     wbm_stb_o      => wbm_stb_o,
     wbm_we_o       => wbm_we_o,
     wbm_cti_o      => wbm_cti_o,
     wbm_bte_o      => wbm_bte_o,
     wbm_sel_o      => wbm_sel_o,
     wbm_ack_i      => wbm_ack_i,
     wbm_adr_o      => wbm_adr_o,
     wbm_dat_i      => wbm_dat_i,
     wbm_dat_o      => wbm_dat_o,
     uart0_txd      => uart0_txd,
     uart0_rxd      => uart0_rxd,
     uart1_txd      => uart1_txd,
     uart1_rxd      => uart1_rxd,
     spi_cs   => spi_cs,
     spi_clk  => spi_clk,
     spi_mosi => spi_mosi,
     spi_miso => spi_miso,
     gpio_o         => gpio_o,
     gpio_i         => gpio_i,
     gpio_t         => gpio_t
   );
end generate;

  ram_nl:  if not LANED_RAM generate
     ram: entity work.MainMemory
          generic map (
             ADDR_WIDTH =>BRAM_ADR_WIDTH,
             RamFileName => RamFileName,
             mode => mode,
             Swapbytes => Swapbytes,
             EnableSecondPort => true
          )

        PORT MAP(
           DBOut =>   bram_dba_i,
           DBIn =>    bram_dba_o,
           AdrBus =>  bram_adra_o,
           ENA =>     bram_ena_o,
           WREN =>    bram_wrena_o,
           CLK =>     clk,
           CLKB =>    clk,
           ENB =>     bram_enb_o,
           AdrBusB => bram_adrb_o,
           DBOutB =>  bram_dbb_i
        );
  end generate;

  ram_l:  if LANED_RAM generate
     ram: entity work.main_memory_laned
          generic map (
             ADDR_WIDTH =>BRAM_ADR_WIDTH,
             RamFileName => RamFileName,
             mode => mode,
             EnableSecondPort => true
          )

        PORT MAP(
           DBOut =>   bram_dba_i,
           DBIn =>    bram_dba_o,
           AdrBus =>  bram_adra_o,
           ENA =>     bram_ena_o,
           WREN =>    bram_wrena_o,
           CLK =>     clk,
           CLKB =>    clk,
           ENB =>     bram_enb_o,
           AdrBusB => bram_adrb_o,
           DBOutB =>  bram_dbb_i
        );
  end generate;




end Behavioral;
