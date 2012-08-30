-----------------------------------------------------------------------
--
-- Copyright 2012 ShareBrained Technology, Inc.
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
 
entity mc6821_tb is
end mc6821_tb;
 
architecture behavior of mc6821_tb is
    component mc6821
        port(
            reset       : in    std_logic;
            clock       : in    std_logic;
            e_set       : in    std_logic;
            e_clear     : in    std_logic;
            rs          : in    std_logic_vector(1 downto 0);
            cs          : in    std_logic;
            write       : in    std_logic;
            data_in     : in    std_logic_vector(7 downto 0);
            data_out    : out   std_logic_vector(7 downto 0);
            ca1         : in    std_logic;
            ca2_in      : in    std_logic;
            ca2_out     : out   std_logic;
            ca2_dir     : out   std_logic;
            irq_a_n     : out   std_logic;
            pa_in       : in    std_logic_vector(7 downto 0);
            pa_out      : out   std_logic_vector(7 downto 0);
            pa_dir      : out   std_logic_vector(7 downto 0);
            cb1         : in    std_logic;
            cb2_in      : in    std_logic;
            cb2_out     : out   std_logic;
            cb2_dir     : out   std_logic;
            irq_b_n     : out   std_logic;
            pb_in       : in    std_logic_vector(7 downto 0);
            pb_out      : out   std_logic_vector(7 downto 0);
            pb_dir      : out   std_logic_vector(7 downto 0)
        );
    end component;

    signal reset    : std_logic := '0';
    signal clock    : std_logic := '0';
    signal e_set    : std_logic := '0';
    signal e_clear  : std_logic := '0';
    signal rs       : std_logic_vector(1 downto 0) := (others => '0');
    signal cs       : std_logic := '0';
    signal write    : std_logic := '0';
    signal data_in  : std_logic_vector(7 downto 0) := (others => '0');
    signal data_out : std_logic_vector(7 downto 0);
    signal ca1      : std_logic := '0';
    signal ca2_in   : std_logic := '0';
    signal ca2_out  : std_logic;
    signal ca2_dir  : std_logic;
    signal irq_a_n  : std_logic;
    signal pa_in    : std_logic_vector(7 downto 0) := (others => '0');
    signal pa_out   : std_logic_vector(7 downto 0);
    signal pa_dir   : std_logic_vector(7 downto 0);
    signal cb1      : std_logic := '0';
    signal cb2_in   : std_logic := '0';
    signal cb2_out  : std_logic;
    signal cb2_dir  : std_logic;
    signal irq_b_n  : std_logic;
    signal pb_in    : std_logic_vector(7 downto 0) := (others => '0');
    signal pb_out   : std_logic_vector(7 downto 0);
    signal pb_dir   : std_logic_vector(7 downto 0);

    constant clock_period : time := 83.333 ns;

BEGIN
 
    uut: mc6821
        port map(
            reset => reset,
            clock => clock,
            e_set => e_set,
            e_clear => e_clear,
            rs => rs,
            cs => cs,
            write => write,
            data_in => data_in,
            data_out => data_out,
            ca1 => ca1,
            ca2_in => ca2_in,
            ca2_out => ca2_out,
            ca2_dir => ca2_dir,
            irq_a_n => irq_a_n,
            pa_in => pa_in,
            pa_out => pa_out,
            pa_dir => pa_dir,
            cb1 => cb1,
            cb2_in => cb2_in,
            cb2_out => cb2_out,
            cb2_dir => cb2_dir,
            irq_b_n => irq_b_n,
            pb_in => pb_in,
            pb_out => pb_out,
            pb_dir => pb_dir
        );

    clock_process: process
    begin
        clock <= '0';
        wait for clock_period/2;
        clock <= '1';
        wait for clock_period/2;
    end process;

    e_process: process
    begin
        wait until rising_edge(clock);
        wait until rising_edge(clock);
        e_set <= '1';
        wait until rising_edge(clock);
        e_set <= '0';
        wait until rising_edge(clock);
        wait until rising_edge(clock);
        wait until rising_edge(clock);
        wait until rising_edge(clock);
        wait until rising_edge(clock);
        e_clear <= '1';
        wait until rising_edge(clock);
        e_clear <= '0';
        wait until rising_edge(clock);
        wait until rising_edge(clock);
        wait until rising_edge(clock);
    end process;

    stim_proc: process
    begin		
        pb_in <= "01010101";

        -- Configure CRA, with DDR register selected
        wait until rising_edge(e_set);
        rs <= "01";
        cs <= '1';
        data_in <= "00011011";
        write <= '1';

        -- Configure DDR as all outputs
        wait until rising_edge(e_set);
        rs <= "00";
        cs <= '1';
        data_in <= "11111111";
        write <= '1';

        -- Configure CRA, with output register selected
        wait until rising_edge(e_set);
        rs <= "01";
        cs <= '1';
        data_in <= "00011111";
        write <= '1';

        -- Configure output register value
        wait until rising_edge(e_set);
        rs <= "00";
        cs <= '1';
        data_in <= "10101010";
        write <= '1';

        -- Configure CRB, with output register selected
        wait until rising_edge(e_set);
        rs <= "11";
        cs <= '1';
        data_in <= "00011111";
        write <= '1';

        wait until rising_edge(e_set);
        cs <= '0';
        write <= '0';
        ca1 <= '1';
        ca2_in <= '1';

        wait until rising_edge(e_set);
        wait until rising_edge(e_set);
        rs <= "00";
        cs <= '1';
        write <= '0';

        wait until rising_edge(e_set);
        cs <= '0';

        wait until rising_edge(e_set);
        rs <= "00";
        cs <= '1';
        write <= '0';

        wait until rising_edge(e_set);
        rs <= "10";
        cs <= '1';
        write <= '0';

        wait until rising_edge(e_set);

        wait;
    end process;

end;
