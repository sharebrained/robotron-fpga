-----------------------------------------------------------------------
--
-- Copyright 2009-2012 ShareBrained Technology, Inc.
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

library ieee;
    use ieee.std_logic_1164.all;

entity led_decoder is
    port(
        input   : in    std_logic_vector (3 downto 0);
        output  : out   std_logic_vector (6 downto 0)
    );
end led_decoder;

architecture rtl of led_decoder is

begin
   
    with input select
    output <= "1111001" when "0001",   --1
              "0100100" when "0010",   --2
              "0110000" when "0011",   --3
              "0011001" when "0100",   --4
              "0010010" when "0101",   --5
              "0000010" when "0110",   --6
              "1111000" when "0111",   --7
              "0000000" when "1000",   --8
              "0010000" when "1001",   --9
              "0001000" when "1010",   --A
              "0000011" when "1011",   --b
              "1000110" when "1100",   --C
              "0100001" when "1101",   --d
              "0000110" when "1110",   --E
              "0001110" when "1111",   --F
              "1000000" when others;   --0

end architecture rtl;
