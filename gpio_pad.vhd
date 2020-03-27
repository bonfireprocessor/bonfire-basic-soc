----------------------------------------------------------------------------------

-- Create Date:    23:34:41 12/06/2017

-- Module Name:    gpio_pad - Behavioral

-- Description:

-- The Bonfire Processor Project, (c) 2016-2020 Thomas Hornschuh
-- IO Buffer "wrapper" for Xilinx FPGAs
--
-- License: See LICENSE or LICENSE.txt File in git project root.
--
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity gpio_pad is
    Port ( I : in  STD_LOGIC;
           O : out  STD_LOGIC;
           T : in  STD_LOGIC;
           IO : inout  STD_LOGIC);
end gpio_pad;

architecture Behavioral of gpio_pad is

begin

  -- Instantiate Xilinx primitive
  pad : IOBUF

     port map (
        O => O,     -- Buffer output
        IO => IO,   -- Buffer inout port (connect directly to top-level port)
        I => I,     -- Buffer input
        T => T      -- 3-state enable input, high=input, low=output
     );

end Behavioral;
