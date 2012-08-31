robotron-fpga
=============

An FPGA implementation of the classic Robotron: 2084 video game. Both the
sound board and CPU/interface boards are implemented, but are in separate
sub-projects at the moment.

![robotron-cpu on NEXYS2 FPGA board](https://github.com/sharebrained/robotron-fpga/raw/master/doc/photo/robotron-on-nexys2.jpg)

The latest version of this repository can be found at
https://github.com/sharebrained/robotron-fpga

Status
======

The CPU/interface and sound boards are implemented as separate projects.
Both appear to function well.

The MC6809E breakout board has been fabricated, but has some design issues
that need to be addressed. The primary issue is the lack of pull-up/-down
resistors on key MC6809E signals, to keep the processor in a RESET state
until the FPGA board is ready to work with the MC6809E. I also screwed up
and put the NEXYS2 connector on the "bottom side" of the board. Smooth!

Requirements
============

* Digilent NEXYS2 Spartan-3E FPGA development board.

    This is the board I've done my development on, and is a good choice
    because it has plenty of inputs, a VGA output connector, many switches
    and LEDs, and enough onboard RAM and flash to meet the game's memory
    needs.

* Williams Robotron: 2084 ROM binary files:

    These files are often used with MAME, the arcade emulator. CPU board
    ROM files are named "robotron.sb?", where "?" is "1" through "9" and
    "a" through "c". The sound board ROM file is named "robotron.snd".

* Python 2.7:

    Used to transform ROM and PROM files into VHDL files.

* Xilinx ISE WebPack 13.4:

    For compiling VHDL and generating the bit file for the FPGA.

* Digilent Adept or other JTAG tool:

    For loading the bit file into FPGA board.

* VGA monitor:

    Video output is 31.25 kHz horizontal sync and 60 Hz vertical sync,
    which is compatible with VGA monitors. The output is line-doubled
    from the arcade game's original 15.625 kHz horizontal sync.

* RC lowpass filter:

    The PWM audio output from the FPGA needs filtering to sound reasonable,
    or an eight-bit DAC can be attached to the 8-bit audio output pins of
    the FPGA board.

Tools
=====

* make_rom_file.py:

    Translates a set of Robotron ROM board ROM files
    (like those you would use with the MAME arcade emulator) into a
    binary file that can be loaded into the flash device on the Digilent
    FPGA board.

* make_decoder_vhdl.py:

    Translates a decoder.4 or decoder.6 file (data
    dumped from decoder PROMs on the Robotron CPU board) into a VHDL
    file used by the robotron_cpu project.

* dac_out_wave.py:

    Translates the text file output of robotron_test.vhd
    into a WAV file that can be played.

* make_sound_rom.py:

    Produces rom_snd_blocks.vhd, containing VHDL ROM
    blocks, from the contents of a robotron.snd ROM file. The
    robotron.snd file is not provided due to copyright on the original
    ROM binaries produced by Williams. I happen to have a physical
    instance of the ROM board, so I'm in the clear. :-)

Contributing
============

Contributions are welcome!

Please respect Williams Electronics' copyright and do not post any VHDL
or .bit files containing their binary code.

License
=======

This hardware design is licensed under a
[Creative Commons Attribution-ShareAlike 3.0 Unported License]
(http://creativecommons.org/licenses/by-sa/3.0/).

The associated software is provided under the GNU Public License, 
version 3:

This project is free software: you can redistribute it and/or
modify it under the terms of the GNU General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This project is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this project. If not, see <http://www.gnu.org/licenses/>.

Contact
=======

ShareBrained Technology, Inc.

<http://www.sharebrained.com/>

Jared Boone <jared@sharebrained.com>
