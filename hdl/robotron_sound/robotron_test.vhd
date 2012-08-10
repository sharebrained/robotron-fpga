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

LIBRARY ieee;
	USE ieee.std_logic_1164.ALL;
	USE ieee.std_logic_unsigned.all;
	USE ieee.numeric_std.ALL;
	use ieee.std_logic_textio.all;

library std;
	use std.textio.all;
	
ENTITY robotron_test IS
END robotron_test;
 
ARCHITECTURE behavior OF robotron_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT top
    PORT(
         CLK : IN  std_logic;
         RST : IN  std_logic;
         PB_IN : INOUT  std_logic_vector(5 downto 0);
         HAND_IN : INOUT  std_logic;
         DAC_OUT : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal RST : std_logic := '0';

	--BiDirs
   signal PB_IN : std_logic_vector(5 downto 0);
   signal HAND_IN : std_logic;

 	--Outputs
   signal DAC_OUT : std_logic_vector(7 downto 0);

	constant CLK_frequency : integer := 3579545 / 4;
	constant CLK_period : TIME := 1000 ms / CLK_frequency;
	 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: top PORT MAP (
          CLK => CLK,
          RST => RST,
          PB_IN => PB_IN,
          HAND_IN => HAND_IN,
          DAC_OUT => DAC_OUT
        );

   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period / 2;
		CLK <= '1';
		wait for CLK_period / 2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
		PB_IN <= "111111";
		HAND_IN <= '1';
		
      -- hold reset state
		RST <= '1';
      wait for CLK_period * 10;
		RST <= '0';
		
      wait for 100 us;
		PB_IN <= "111111";
		HAND_IN <= '0';
		
      wait;
   end process;

	dac_proc: process(DAC_OUT)
		file dac_out_file : text is out "dac_out-111111.txt";
		variable dac_out_line : line;
	begin
		if DAC_OUT'event then
			write(dac_out_line, now);
			write(dac_out_line, HT);
			write(dac_out_line, DAC_OUT);
			writeline(dac_out_file, dac_out_line);
		end if;
	end process;
	
END;
