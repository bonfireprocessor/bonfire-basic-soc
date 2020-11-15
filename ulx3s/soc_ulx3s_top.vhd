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
       RamFileName : string := "c:/Users/thoma/development/bonfire/bonfire-software/monitor/ULX3S_monitor.hex";
       BRANCH_PREDICTOR : boolean := true;
       USE_BONFIRE_CORE : boolean := false;
       BYPASS_CLOCKGEN  : boolean := false;
	     CacheSizeWords : natural := 16384 / 4; 
       BurstSize : natural := 8;
       sdram_column_bits : natural :=9
     );
     port(
          sysclk  : in  std_logic;       
          resetn : in std_logic;

          -- UART0 signals:
          uart0_txd : out std_logic;
          uart0_rxd : in  std_logic :='1';

          -- SPI NOR Flash
          flash_csn   : out std_logic;
          --flash_clk  : out std_logic;
          flash_mosi : out std_logic;
          flash_miso : in  std_logic;
          flash_holdn :  out std_logic;
          flash_wpn : out std_logic;

          -- SD Card
          sd_clk : out std_logic;
          sd_mosi : out std_logic; -- sd_cmd
          sd_miso : in std_logic; -- sd_d[0]
          sd_cs : out std_logic; -- sd_d[3]

          -- ADC (MAX11123)
          adc_csn : out std_logic;
          adc_mosi : out std_logic;
          adc_miso : in std_logic;
          adc_sclk : out std_logic;


            -- SDRAM signals
          sdram_clk      : out   STD_LOGIC;
          sdram_cke      : out   STD_LOGIC;
          sdram_csn      : out   STD_LOGIC;
          sdram_rasn     : out   STD_LOGIC;
          sdram_casn     : out   STD_LOGIC;
          sdram_wen      : out   STD_LOGIC;
          sdram_dqm      : out   STD_LOGIC_VECTOR( 1 downto 0);
          sdram_a        : out   STD_LOGIC_VECTOR(12 downto 0);
          sdram_ba       : out   STD_LOGIC_VECTOR( 1 downto 0);
          sdram_d        : inout STD_LOGIC_VECTOR(15 downto 0);

          led : out std_logic_vector(7 downto 0);
		  -- I2C RTC 
		  gpdi_sda : inout std_logic;
		  gpdi_scl : inout std_logic
		  
    );

end entity;

architecture Behavioral of soc_ulx3s_top is

constant num_spi : natural := 3;

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
      NUM_SPI : natural := 1; 
      USE_BONFIRE_CORE : boolean := true;
      BurstSize        : natural := 8;
      CacheSizeWords   : natural := 512;
      ENABLE_DCACHE    : boolean := false;
      DCacheSizeWords  : natural := 512;
      M_EXTENSION      : boolean := true;
      BRANCH_PREDICTOR : boolean := true;
      REG_RAM_STYLE    : string := "block";
      NUM_GPIO         : natural := 8;
      DEVICE_FAMILY    : string := ""    
    );
    port (
      sysclk         : in  std_logic;
      I_RESET        : in  std_logic;
      uart0_txd      : out std_logic;
      uart0_rxd      : in  std_logic :='1';
      uart1_txd      : out std_logic;
      uart1_rxd      : in  std_logic :='1';
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
 end component bonfire_basic_soc_top;
 
	component clock_gen
		port (CLKI: in  std_logic; CLKOP: out  std_logic);
	end component;

	COMPONENT USRMCLK
	PORT(
		USRMCLKI : IN STD_ULOGIC;
		USRMCLKTS : IN STD_ULOGIC
	);
	END COMPONENT;
	attribute syn_noprune: boolean ;
	attribute syn_noprune of USRMCLK: component is true;
	
	component gpio_pad is
      Port ( i : in  STD_LOGIC;
             o : out  STD_LOGIC;
             t : in  STD_LOGIC;
             io : inout  STD_LOGIC);
   end component;


signal reset,res1,res2  : std_logic;
signal clk_locked : std_logic;
signal clk : std_logic;

-- SPI
signal spi_cs   : std_logic_vector(NUM_SPI-1 downto 0);
signal spi_clk  :  std_logic_vector(NUM_SPI-1 downto 0);
signal spi_mosi :  std_logic_vector(NUM_SPI-1 downto 0);
signal spi_miso :  std_logic_vector(NUM_SPI-1 downto 0);

signal flash_clk : std_logic;
--signal flash_csn_local : std_logic;


constant gpio_len : natural := LED'length + 2;

signal gpio_o         : std_logic_vector(gpio_len-1 downto 0);
signal gpio_i         : std_logic_vector(gpio_len-1 downto 0);
signal gpio_t         : std_logic_vector(gpio_len-1 downto 0);

-- Common bus to DRAM controller
signal mem_cyc,mem_stb,mem_we,mem_ack : std_logic;
signal mem_sel :  std_logic_vector(3 downto 0);
signal mem_dat_rd,mem_dat_wr : std_logic_vector(31 downto 0);
signal mem_adr : std_logic_vector(25 downto 2);
signal mem_cti : std_logic_vector(2 downto 0);


begin

  -- SPI(0)
  flash_holdn <= '1';
  flash_wpn <= '1';
  flash_csn <= spi_cs(0);
  flash_mosi <= spi_mosi(0);
  spi_miso(0) <= flash_miso;
   -- See Lattice TN1260 Figure 7: MCLK Connection 
  u1: USRMCLK port map (
		USRMCLKI => spi_clk(0),
    USRMCLKTS => spi_cs(0)); -- CS active low will also disable Tristate status
    
  -- SPI(1)
  sd_clk <= spi_clk(1);
  sd_mosi <= spi_mosi(1);
  sd_cs <= spi_cs(1);
  spi_miso(1) <= sd_miso;

  --SPI(2)
  adc_csn <= spi_cs(2);
  adc_mosi <= spi_mosi(2);
  adc_sclk <= spi_clk(2);
  spi_miso(2) <= adc_miso;

  cgen: case BYPASS_CLOCKGEN generate
    when FALSE =>
      pll : clock_gen port map (CLKI=>sysclk, CLKOP=>clk);
    when TRUE =>
      clk <= sysclk;
      
  end generate;    
  
 


  bonfire_basic_soc_top_i :  bonfire_basic_soc_top
      generic map (
        DEVICE_FAMILY    => "ECP5",
        RamFileName      => RamFileName,
        mode             => "H",
        BRAM_ADR_WIDTH   => 13,  
        LANED_RAM        => true,
        Swapbytes        => false,
        ExtRAM           => true,
        ENABLE_UART1     => false,
        ENABLE_SPI       => true,
        NUM_SPI          => num_spi,
        USE_BONFIRE_CORE => false,
        BurstSize        => BurstSize,
        CacheSizeWords   => CacheSizeWords,
        ENABLE_DCACHE    => true,
        DCacheSizeWords  => 2048,
        M_EXTENSION      => true,
        BRANCH_PREDICTOR => BRANCH_PREDICTOR,
        -- REG_RAM_STYLE    => REG_RAM_STYLE,
        NUM_GPIO         => gpio_len
      )
      port map (
        sysclk         => clk,
        I_RESET        => reset,
        uart0_txd      => uart0_txd,
        uart0_rxd      => uart0_rxd,
        uart1_txd      => open,
        uart1_rxd      => '1',
        spi_cs   => spi_cs, --(0 downto 0),
        spi_clk  => spi_clk, --(0 downto 0),
        spi_mosi => spi_mosi, --(0 downto 0),
        spi_miso => spi_miso, --(0 downto 0),

        gpio_o => gpio_o,
        gpio_i => gpio_i,
        gpio_t => gpio_t,

        wbm_cyc_o      => mem_cyc,
        wbm_stb_o      => mem_stb,
        wbm_we_o       => mem_we,
        wbm_cti_o      => mem_cti,
        wbm_bte_o      => open,
        wbm_sel_o      => mem_sel,
        wbm_ack_i      => mem_ack,
        wbm_adr_o      => mem_adr,
        wbm_dat_i      => mem_dat_rd,
        wbm_dat_o      => mem_dat_wr
      );


    
      --LED(7) <= not resetn; -- to check polarity of reset button.
      LED(7 downto 0) <=  gpio_o(7 downto 0);
      gpio_i(7 downto 0) <= gpio_o(7 downto 0);
	  
      scl : gpio_pad 
        port map(
          i => gpio_o(8),
          o => gpio_i(8),
          t => gpio_t(8),
          io => gpdi_scl

        );

        sda : gpio_pad 
        port map(
          i => gpio_o(9),
          o => gpio_i(9),
          t => gpio_t(9),
          io => gpdi_sda

        );  

      DRAM: entity work.wbs_sdram_interface
      generic map (
        wbs_adr_high => mem_adr'high,
        wbs_burst_length => BurstSize,
        sdram_column_bits => sdram_column_bits,
		sdram_address_width => 13 + 2 + 9 -- Row + Bank + Col - see datasheet		
      )
      PORT MAP(
            clk_i =>clk ,
            rst_i => reset,

            wbs_cyc_i =>  mem_cyc,
            wbs_stb_i =>  mem_stb,
            wbs_we_i =>   mem_we,
            wbs_sel_i =>  mem_sel,
            wbs_ack_o =>  mem_ack,
            wbs_adr_i =>  mem_adr,
            wbs_dat_i =>  mem_dat_wr,
            wbs_dat_o =>  mem_dat_rd,
            wbs_cti_i =>  mem_cti,
      
            SDRAM_CLK => sdram_clk,
            SDRAM_CKE => sdram_cke,
            SDRAM_CS => sdram_csn,
            SDRAM_RAS => sdram_rasn,
            SDRAM_CAS => sdram_casn,
            SDRAM_WE => sdram_wen,
            SDRAM_DQM => sdram_dqm,
            SDRAM_ADDR => sdram_a,
            SDRAM_BA => sdram_ba,
            SDRAM_DATA => sdram_d
          );



      process(clk) begin
         if rising_edge(clk) then
            res1 <= not resetn;
            res2 <= res1;
            reset <= res2;
         end if;
      end process;

end architecture;