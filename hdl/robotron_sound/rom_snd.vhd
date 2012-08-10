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
library unisim;
use unisim.vcomponents.all;

entity rom_snd is
    Port (  clk   : in  std_logic;
            rst   : in  std_logic;
            cs    : in  std_logic;
            addr  : in  std_logic_vector (11 downto 0);
            data  : out std_logic_vector (7 downto 0)
            );
end rom_snd;

architecture rtl of rom_snd is

  signal cs0    : std_logic;
  signal cs1    : std_logic;
  signal data0  : std_logic_vector(7 downto 0);
  signal data1  : std_logic_vector(7 downto 0);

component ROM_SND_F000
    Port (  clk   : in  std_logic;
            rst   : in  std_logic;
            cs    : in  std_logic;
            addr  : in  std_logic_vector (10 downto 0);
            data  : out std_logic_vector (7 downto 0)
            );
end component;

component ROM_SND_F800
    Port (  clk   : in  std_logic;
            rst   : in  std_logic;
            cs    : in  std_logic;
            addr  : in  std_logic_vector (10 downto 0);
            data  : out std_logic_vector (7 downto 0)
            );
end component;

begin
   addr_f000 : ROM_SND_F000 port map (
       clk   => clk,
       rst   => rst,
       cs    => cs0,
       addr  => addr(10 downto 0),
       data  => data0
    );
   
   addr_f800 : ROM_SND_F800 port map (
       clk   => clk,
       rst   => rst,
       cs    => cs1,
       addr  => addr(10 downto 0),
       data  => data1
    );
   
   rom_snd : process ( clk, addr, cs, data0, data1 )
   begin
       case addr(11) is
       when '0' =>
         cs0   <= cs;
         cs1   <= '0';
         data  <= data0;
       when '1' =>
         cs0   <= '0';
         cs1   <= cs;
         data  <= data1;
       when others =>
         null;
       end case;
   end process;
   
end architecture rtl;

