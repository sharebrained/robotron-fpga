#!/usr/bin/env python

import sys
import numpy
from math import log
from os.path import splitext

filename = sys.argv[1]
entity_name = filename.replace(".", "_")
data = numpy.fromfile(filename, dtype=numpy.uint8)
bit_high = int(log(len(data), 2) - 1)
bit_low = 0

cases = []
for index in range(len(data)):
    value = data[index]
    index_bit_pattern = bin(index)[2:].zfill(bit_high+1)
    value_bit_pattern = bin(value)[2:].zfill(8)
    d = {
        "index": index,
        "index_bin": index_bit_pattern,
        "value": value,
        "value_bin": value_bit_pattern,
    }
    case = """        when "%(index_bin)s" => -- %(index)x
            data <= "%(value_bin)s"; -- %(value)x
""" % d
    cases.append(case)
cases = ''.join(cases)

print("""-- From %(filename)s
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
 
entity %(entity_name)s is
    port(
        address     : in    std_logic_vector(%(bit_high)d downto %(bit_low)d);
        data        : out   std_logic_vector(7 downto 0)
    );
end %(entity_name)s;

architecture Behavioral of %(entity_name)s is
begin

    process(address)
    begin
        case address is
%(cases)s
        when others =>
            data <= (others => '0');
        end case;
    end process;
    
end Behavioral;
""" % locals())

