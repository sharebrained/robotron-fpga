-----------------------------------------------------------------------
--
-- Copyright 2009-2011 ShareBrained Technology, Inc.
--
-- This file is part of robotron-fpga.
--
-- robotron-fpga is free software: you can redistribute
-- it and/or modify it under the terms of the GNU General
-- Public License as published by the Free Software
-- Foundation, either version 3 of the License, or (at your
-- option) any later version.
--
-- robotron-fpga is distributed in the hope that it will
-- be useful, but WITHOUT ANY WARRANTY; without even the
-- implied warranty of MERCHANTABILITY or FITNESS FOR A
-- PARTICULAR PURPOSE. See the GNU General Public License
-- for more details.
--
-- You should have received a copy of the GNU General
-- Public License along with robotron-fpga. If not, see
-- <http://www.gnu.org/licenses/>.
--
-----------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity robotron is
   port(
      CLK_50M_IN  : in     STD_LOGIC;
      RESET_IN    : in     STD_LOGIC;
      PB_IN       : in     STD_LOGIC_VECTOR (5 downto 0);
      HAND_IN     : in     STD_LOGIC;
      STROBE_IN   : in     STD_LOGIC;
      DAC_OUT     : out    STD_LOGIC_VECTOR (7 downto 0);
      STATUS_OUT  : out    STD_LOGIC_VECTOR (7 downto 0);
      PWM_OUT     : out    std_logic
   );
end robotron;

architecture Behavioral of robotron is
   
   signal CLKDIV        : std_logic_vector (23 downto 0);
   signal reset         : std_logic;
   signal clk_fast      : std_logic;
   signal clk_cpu       : std_logic;
   
   signal pb            : std_logic_vector(5 downto 0);
   signal hand          : std_logic;
   
   signal dac           : std_logic_vector(7 downto 0);
   
   component robotron_sound
      port(
         clk_fast    : in     STD_LOGIC;
         clk_cpu     : in     STD_LOGIC;
         reset       : in     STD_LOGIC;
         pb          : in     STD_LOGIC_VECTOR (5 downto 0);
         hand        : in     STD_LOGIC;
         dac         : out    STD_LOGIC_VECTOR (7 downto 0)
      );
   end component;
   
begin
   
   reset <= RESET_IN;
   clk_fast <= CLK_50M_IN;
   clk_cpu <= CLKDIV(5);
   
   sound: robotron_sound
      port map(
         clk_fast => clk_fast,
         clk_cpu => clk_cpu,
         reset => reset,
         pb => pb,
         hand => hand,
         dac => dac
      );
   
   process (STROBE_IN, PB_IN, HAND_IN)
   begin
      if (STROBE_IN = '1') then
         pb <= PB_IN;
         hand <= HAND_IN;
      else
         pb <= "111111";
         hand <= '1';
      end if;
   end process;
   
   process (clk_fast)
   begin
      if rising_edge(clk_fast) then
         if (reset = '1') then
            CLKDIV <= "000000000000000000000000";
         else
            CLKDIV <= CLKDIV + 1;
         end if;
      end if;   
   end process;
   
   process (clk_fast)
   begin
      if rising_edge(clk_fast) then
         if CLKDIV(7 downto 0) >= dac then
            PWM_OUT <= '1';
         else
            PWM_OUT <= '0';
         end if;
      end if;
   end process;
   
   STATUS_OUT <= CLKDIV(23) & RESET_IN & STROBE_IN & dac(4 downto 0);
   
   DAC_OUT <= dac;
   
end Behavioral;
