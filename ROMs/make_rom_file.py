#!/usr/bin/env python

#######################################################################
#
# Copyright 2012 ShareBrained Technology, Inc.
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
#
#######################################################################

# Generate a ROM file appropriate for uploading into the flash device
# on the Digilent Nexys 2 FPGA development board.

# The ROM files are those from the individual ROMs on the Robotron
# ROM board. They are named in the same fashion as used with the MAME
# arcade emulator.

import numpy

def make_robotron_rom():
    rom_map = {
        '1': 0x0000,
        '2': 0x1000,
        '3': 0x2000,
        '4': 0x3000,
        '5': 0x4000,
        '6': 0x5000,
        '7': 0x6000,
        '8': 0x7000,
        '9': 0x8000,
        'a': 0xd000,
        'b': 0xe000,
        'c': 0xf000,
    }

    memory = numpy.zeros((65536,), dtype=numpy.uint8)
    block_size = 4096
    for c, address in rom_map.items():
        filename = 'robotron.sb%s' % c
        block = numpy.fromfile(filename, dtype=numpy.uint8)
        memory[address:address+block_size] = block

    return memory

memory = make_robotron_rom()

# Alternately, make a BLT test ROM image for Sean Riddle's
# BLITTEST.BIN, available from his Web site.
#memory = numpy.fromfile("BLITTEST.BIN", dtype=numpy.uint8)

flash = numpy.array(memory, dtype=numpy.uint16)
for i in range(len(flash)):
    l = (memory[i] >> 0) & 0xF
    h = (memory[i] >> 4) & 0xF
    flash[i] = (((((h << 4) | h) << 4) | l) << 4) | l
flash.tofile('rom.bin')
