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
 
entity m6810_test is
end m6810_test;
 
architecture behavior of m6810_test is 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    component m6810
    port(
         clk : IN  std_logic;
         rst : IN  std_logic;
         address : IN  std_logic_vector(6 downto 0);
         cs : IN  std_logic;
         rw : IN  std_logic;
         data_in : IN  std_logic_vector(7 downto 0);
         data_out : OUT  std_logic_vector(7 downto 0)
        );
    end component;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal address : std_logic_vector(6 downto 0) := (others => 'Z');
   signal cs : std_logic := '0';
   signal rw : std_logic := '0';
   signal data_in : std_logic_vector(7 downto 0) := (others => 'Z');

 	--Outputs
   signal data_out : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := (279.365 ns * 4);
	
	signal phase_1 : std_logic;
	signal phase_2 : std_logic;
	signal E : std_logic;

begin

   clk_process: process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;

	phase_1 <= clk;
	phase_2 <= not phase_1;
	E <= phase_2;
	
	-- Instantiate the Unit Under Test (UUT)
   uut: m6810 port map (
          clk => clk,
          rst => rst,
          address => address,
          cs => cs,
          rw => rw,
          data_in => data_in,
          data_out => data_out
        );
 
   -- Stimulus process
   stim_proc: process
   begin		
		rw <= '1';
		
		rst <= '1';
      wait for clk_period*10;
		rst <= '0';
		
		-- WRITE
		wait until falling_edge(E);
		wait for (clk_period / 2) - 160 ns;
		address <= "0110110";
		cs <= '1';
		rw <= '0';
		
		wait until rising_edge(E);
		wait for 225 ns;
		data_in <= "01011010";
		
		wait until falling_edge(E);
		wait for 20 ns;
		cs <= '0';
		address <= "ZZZZZZZ";
		rw <= '1';
		wait for 10 ns;
		data_in <= "ZZZZZZZZ";		
		
		-- READ
		wait until falling_edge(E);
		wait for (clk_period / 2) - 160 ns;
		address <= "0100110";
		cs <= '1';
		rw <= '1';

		wait until rising_edge(E);
		wait for (clk_period / 2) - 100 ns;
		-- sample data_in
		wait until falling_edge(E);
		wait for 10 ns;
		-- sample data_in
		wait for 10 ns;
		cs <= '0';
		address <= "ZZZZZZZ";
		rw <= '0';
		
		-- READ
		wait until falling_edge(E);
		wait for (clk_period / 2) - 160 ns;
		address <= "0110110";
		cs <= '1';
		rw <= '1';

		wait until rising_edge(E);
		wait for (clk_period / 2) - 100 ns;
		-- sample data_in
		wait until falling_edge(E);
		wait for 10 ns;
		-- sample data_in
		wait for 10 ns;
		cs <= '0';
		address <= "ZZZZZZZ";
		rw <= '0';
		
      wait;
   end process;

end;
