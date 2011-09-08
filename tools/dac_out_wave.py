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
 
import sys
import wave
from struct import pack

sample_rate = 48000

def convert(code):
    file_in = open('dac_out-%(code)s.txt' % {'code': code}, 'r')

    wave_out = wave.open('dac_out-%(code)s.wav' % {'code': code}, 'wb')
    wave_out.setnchannels(1)
    wave_out.setsampwidth(1)
    wave_out.setframerate(sample_rate)

    wave_out_sample = 0
    dac_sample = 0
    dac_value = 0

    for line in file_in:
        time_ns, dac_binary = line.split('\t')
        if time_ns[-3:] != ' ns':
            raise 'unhandled time format'
        time = float(time_ns[:-3]) / 1000000000.0
        if 'Z' in dac_binary:
            dac = 128
        else:
            dac = int(dac_binary, 2)

        dac_sample = time * sample_rate

        while wave_out_sample < dac_sample:
            wave_out.writeframes(chr(dac_value))
            wave_out_sample += 1

        dac_value = dac
        #print time, dac_value

    wave_out.close()
    file_in.close()

def make_binary_string(i):
    result = []
    while i != 0:
        if i & 1:
            result.append('1')
        else:
            result.append('0')
        i >>= 1
    return ''.join(reversed(result))
        
convert('111111')
#for code in ['000000', '000001', '000101', '001010']:
#    convert(code)
#for n in range(64):
#    n_base_2 = make_binary_string(n).zfill(6)
#    convert(n_base_2)
