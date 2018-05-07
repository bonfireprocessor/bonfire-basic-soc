library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clkgen_arty is
  generic (
    CLK_PERIOD : time := 10.42 ns -- 96 Mhz
  );
  Port (
    clkout : out STD_LOGIC;
    reset : in STD_LOGIC;
    locked : out STD_LOGIC;
    sysclk : in STD_LOGIC
  );

end clkgen_arty;

architecture stub of clkgen_arty is

signal TbClock : std_logic := '0';

begin

   TbClock <= not TbClock after CLK_PERIOD/2 when reset /= '1' else '0';

   clkout <= tbClock;

   locked <= '1';

end;
