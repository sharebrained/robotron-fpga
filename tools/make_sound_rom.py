#!/usr/bin/env python

#
# Copyright 2009-2011 ShareBrained Technology, Inc.
#
# This file is part of robotron-fpga.
#
# robotron-fpga is free software: you can redistribute
# it and/or modify it under the terms of the GNU General
# Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your
# option) any later version.
#
# robotron-fpga is distributed in the hope that it will
# be useful, but WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General
# Public License along with robotron-fpga. If not, see
# <http://www.gnu.org/licenses/>.

def write_file_header(f):
    f.write("""library IEEE;
   use IEEE.std_logic_1164.all;
   use IEEE.std_logic_arith.all;
library unisim;
   use unisim.vcomponents.all;
   
""")

def write_entity(name, f):
    f.write("""entity %(name)s is
   port(
      clk    : in  std_logic;
      rst    : in  std_logic;
      cs     : in  std_logic;
      addr   : in  std_logic_vector(10 downto 0);
      data   : out std_logic_vector(7 downto 0)
   );
end %(name)s;

""" % {'name': name})

def write_architecture(name, data, f):
    f.write("""architecture rtl of %(name)s is
   signal dp : std_logic;
begin
   ROM: RAMB16_S9
      generic map (
""" % {'name': name})
    step = 32
    init_lines = []
    for n in range(0, len(data) / step):
        start = n * step
        end = (n + 1) * step
        init_data = reversed(data[start:end])
        init_data = ''.join([hex(ord(c))[2:].zfill(2) for c in init_data])
        init_line = '         INIT_%02x => x"%s"' % (n, init_data)
        init_lines.append(init_line)
    f.write(',\n'.join(init_lines))
    f.write("""
      )
      port map (
         do    => data,
         dop(0)  => dp,
         addr    => addr,
         clk     => clk,
         di      => "00000000",
         dip(0)  => '0',
         en      => cs,
         ssr     => rst,
         we      => '0'
      );
end architecture rtl;

""")

data = open('robotron.snd', 'rb').read()
file_out = open('rom_snd_blocks.vhd', 'w')

write_file_header(file_out)
write_entity('ROM_SND_F000', file_out)
write_architecture('ROM_SND_F000', data[0:2048], file_out)

write_file_header(file_out)
write_entity('ROM_SND_F800', file_out)
write_architecture('ROM_SND_F800', data[2048:4096], file_out)

file_out.close()
