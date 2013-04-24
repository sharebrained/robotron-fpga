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

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity logic7442 is
    Port (  input    : in     std_logic_vector (3 downto 0);
            output   : out    std_logic_vector (9 downto 0)
            );
end logic7442;

architecture rtl of logic7442 is

begin
   
   logic7442 : process(input)
   begin
      case input is
      when "0000" =>
         output <= "1111111110";
      when "0001" =>
         output <= "1111111101";
      when "0010" =>
         output <= "1111111011";
      when "0011" =>
         output <= "1111110111";
      when "0100" =>
         output <= "1111101111";
      when "0101" =>
         output <= "1111011111";
      when "0110" =>
         output <= "1110111111";
      when "0111" =>
         output <= "1101111111";
      when "1000" =>
         output <= "1011111111";
      when "1001" =>
         output <= "0111111111";
      when others =>
         output <= "1111111111";
      end case;
   end process;
   
end architecture rtl;

