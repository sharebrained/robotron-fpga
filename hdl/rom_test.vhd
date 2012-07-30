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
 
ENTITY rom_test IS
END rom_test;
 
ARCHITECTURE behavior OF rom_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT rom_snd
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         cs : IN  std_logic;
         addr : IN  std_logic_vector(11 downto 0);
         data : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal cs : std_logic := '0';
   signal addr : std_logic_vector(11 downto 0) := (others => '0');

 	--Outputs
   signal data : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 280 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: rom_snd PORT MAP (
          clk => clk,
          rst => rst,
          cs => cs,
          addr => addr,
          data => data
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin
		cs <= '1';
		
		rst <= '1';
      wait for clk_period * 2;	
		rst <= '0';
      wait for clk_period * 2;

      -- insert stimulus here 
		addr <= "000000000000";
		wait until rising_edge(clk);
		
		addr <= "000000000001";
		wait until rising_edge(clk);
		--assert data = "01110110" report "Address 0x000 read incorrect" severity failure;

		addr <= "000000000010";
		wait until rising_edge(clk);
		--assert data = "00101000" report "Address 0x001 read incorrect" severity failure;
		
		addr <= "000000000011";
		wait until rising_edge(clk);
		--assert data = "01000011" report "Address 0x002 read incorrect" severity failure;
		
		addr <= "011111111111";
		wait until rising_edge(clk);
		--assert data = "00101001" report "Address 0x003 read incorrect" severity failure;
		
		addr <= "100000000000";
		wait until rising_edge(clk);
		--assert data = "10010001" report "Address 0x7ff read incorrect" severity failure;
		
		addr <= "100000000001";
		wait until rising_edge(clk);
		--assert data = "00000110" report "Address 0x800 read incorrect" severity failure;
		
		addr <= "100000000010";
		wait until rising_edge(clk);
		--assert data = "00100010" report "Address 0x801 read incorrect" severity failure;
		
		addr <= "100000000011";
		wait until rising_edge(clk);
		--assert data = "11110000" report "Address 0x802 read incorrect" severity failure;
		
		addr <= "111111111111";
		wait until rising_edge(clk);
		--assert data = "10010110" report "Address 0x803 read incorrect" severity failure;

		wait until rising_edge(clk);
		--assert data = "00011101" report "Address 0xfff read incorrect" severity failure;

      wait;
   end process;
	
END;
