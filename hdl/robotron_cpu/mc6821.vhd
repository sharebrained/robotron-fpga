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
    use ieee.numeric_std.all;

entity mc6821 is
    port(
        reset       : in    std_logic;
        clock       : in    std_logic;
        e_sync      : in    std_logic;
        
        rs          : in    std_logic_vector(1 downto 0);
        cs          : in    std_logic;
        write       : in    std_logic;
        
        data_in     : in    std_logic_vector(7 downto 0);
        data_out    : out   std_logic_vector(7 downto 0);
        
        ca1         : in    std_logic;
        ca2_in      : in    std_logic;
        ca2_out     : out   std_logic;
        ca2_dir     : out   std_logic;
        irq_a       : out   std_logic;
        pa_in       : in    std_logic_vector(7 downto 0);
        pa_out      : out   std_logic_vector(7 downto 0);
        pa_dir      : out   std_logic_vector(7 downto 0);
        
        cb1         : in    std_logic;
        cb2_in      : in    std_logic;
        cb2_out     : out   std_logic;
        cb2_dir     : out   std_logic;
        irq_b       : out   std_logic;
        pb_in       : in    std_logic_vector(7 downto 0);
        pb_out      : out   std_logic_vector(7 downto 0);
        pb_dir      : out   std_logic_vector(7 downto 0)
    );
end mc6821;

architecture Behavioral of mc6821 is
    signal read             : std_logic := '0';
    
    signal ca1_q            : std_logic := '0';
    signal ca2_q            : std_logic := '0';
    signal cb1_q            : std_logic := '0';
    signal cb2_q            : std_logic := '0';
    
    signal output_a         : std_logic_vector(7 downto 0) := (others => '0');    
    signal ddr_a            : std_logic_vector(7 downto 0) := (others => '0');
    
    signal cr_a             : std_logic_vector(7 downto 0) := (others => '0');
    signal irqa_1_intf      : std_logic := '0';
    signal irqa_2_intf      : std_logic := '0';
    signal ca2_is_output    : std_logic := '0';
    signal cr_a_4           : std_logic := '0';
    signal cr_a_3           : std_logic := '0';
    signal output_a_access  : std_logic := '0';
    signal ca1_edge         : std_logic := '0';
    signal ca2_edge         : std_logic := '0';
    signal ca1_int_en       : std_logic := '0';
    signal ca2_int_en       : std_logic := '0';
    signal ca2_in_gated     : std_logic := '0';
    signal ca2_out_value    : std_logic := '0';

    signal output_b         : std_logic_vector(7 downto 0) := (others => '0');
    signal ddr_b            : std_logic_vector(7 downto 0) := (others => '0');

    signal cr_b             : std_logic_vector(7 downto 0) := (others => '0');
    signal irqb_1_intf      : std_logic := '0';
    signal irqb_2_intf      : std_logic := '0';
    signal cb2_is_output    : std_logic := '0';
    signal cr_b_4           : std_logic := '0';
    signal cr_b_3           : std_logic := '0';
    signal output_b_access  : std_logic := '0';
    signal cb1_edge         : std_logic := '0';
    signal cb2_edge         : std_logic := '0';
    signal cb1_int_en       : std_logic := '0';
    signal cb2_int_en       : std_logic := '0';
    signal cb2_in_gated     : std_logic := '0';
    signal cb2_out_value    : std_logic := '0';

begin

    irq_a <= ((irqa_1_intf and ca1_int_en) or
              (irqa_2_intf and ca2_int_en));
    irq_b <= ((irqb_1_intf and cb1_int_en) or
              (irqb_2_intf and cb2_int_en));
    
    ca2_out <= ca2_out_value;
    ca2_dir <= ca2_is_output;
    
    cb2_out <= cb2_out_value;
    cb2_dir <= cb2_is_output;
    
    read <= not write;
    
    pa_out <= output_a;
    pa_dir <= ddr_a;
    
    pb_out <= output_b;
    pb_dir <= ddr_b;
    
    cr_a <= irqa_1_intf & irqa_2_intf & ca2_is_output &
            cr_a_4 & cr_a_3 &
            output_a_access & ca1_edge & ca1_int_en;
    cr_b <= irqb_1_intf & irqb_2_intf & cb2_is_output &
            cr_b_4 & cr_b_3 &
            output_b_access & cb1_edge & cb1_int_en;
    
    -- TODO: Port B reads from output data register, not from pin state.
    
    data_out <= pa_in when rs = "00" and output_a_access = '1' else
                ddr_a when rs = "00" and output_a_access = '0' else
                cr_a when rs = "01" else
                pb_in when rs = "10" and output_b_access = '1' else
                ddr_b when rs = "10" and output_b_access = '0' else
                cr_b when rs = "11" else
                (others => '0');
    
    ca2_edge <= cr_a_4;
    cb2_edge <= cr_b_4;
    
    ca2_int_en <= cr_a_3 and (not ca2_is_output);
    cb2_int_en <= cr_b_3 and (not cb2_is_output);
    
    -------------------------------------------------------------------
    -- Effects of register reads.
    -- See elsewhere, this is not the only place.
    
    process(clock)
    begin
        if rising_edge(clock) then
            if cs = '1' and read = '1' then
                case rs is
                when "00" =>
                    -- TODO: Crazy CA2 output handling
                    --if ddr_a_access = '0' then
                    --    if ca2_is_output = '1' and cr_a_4 = '0' then
                    --        ca2_output <= '0';
                    --    end if;
                    --end if;
                    
                when "01" =>
                    -- Do nothing!
                    
                when "10" =>
                    -- TODO: Crazy CB2 output handling
                    --if ddr_b_access = '0' then
                    --    if cb2_is_output = '1' and cr_b_4 = '0' then
                    --        cb2_output <= '0';
                    --    end if;
                    --end if;
                    
                when "11" =>
                    -- Do nothing!
                
                when others =>
                    -- Do nothing!
                    
                end case;
            end if;
        end if;
    end process;
    
    -------------------------------------------------------------------
    -- Register writes.
    
    process(clock)
    begin
        if rising_edge(clock) then
            if cs = '1' and write = '1' then
                case rs is
                when "00" =>
                    if output_a_access = '1' then
                        output_a <= data_in;
                    else
                        ddr_a <= data_in;
                    end if;
                    
                when "01" =>
                    ca2_is_output <= data_in(5);
                    cr_a_4 <= data_in(4);
                    cr_a_3 <= data_in(3);
                    output_a_access <= data_in(2);
                    ca1_edge <= data_in(1);
                    ca1_int_en <= data_in(0);
                    
                    if data_in(4) = '1' and data_in(5) = '1' then
                        ca2_out_value <= data_in(3);
                    end if;
                    
                when "10" =>
                    if output_b_access = '1' then
                        output_b <= data_in;
                    else
                        ddr_b <= data_in;
                    end if;
                    
                when "11" =>
                    cb2_is_output <= data_in(5);
                    cr_b_4 <= data_in(4);
                    cr_b_3 <= data_in(3);
                    output_b_access <= data_in(2);
                    cb1_edge <= data_in(1);
                    cb1_int_en <= data_in(0);
                
                    if data_in(4) = '1' and data_in(5) = '1' then
                        cb2_out_value <= data_in(3);
                    end if;
                    
                when others =>
                    -- Do nothing!
                    
                end case;
            end if;
        end if;
    end process;
    
    -------------------------------------------------------------------
    -- Sampling of interrupt inputs.
    
    ca2_in_gated <= ca2_in and (not ca2_is_output);
    cb2_in_gated <= cb2_in and (not cb2_is_output);
    
    process(clock, e_sync)
    begin
        if rising_edge(clock) and e_sync = '1' then
            ca1_q <= ca1;
            ca2_q <= ca2_in_gated;
            cb1_q <= cb1;
            cb2_q <= cb2_in_gated;
        end if;
    end process;
    
    -------------------------------------------------------------------
    -- Interrupt edge detection.

    process(clock, e_sync)
    begin
        if rising_edge(clock) then
            if ((ca1_edge = '0' and ca1_q = '1' and ca1 = '0') or
                (ca1_edge = '1' and ca1_q = '0' and ca1 = '1')) and
                e_sync = '1' then
                irqa_1_intf <= '1';
            elsif cs = '1' and read = '1' and rs = "00" and output_a_access = '1' then
                irqa_1_intf <= '0';
            end if;
        end if;
    end process;
    
    process(clock, e_sync)
    begin
        if rising_edge(clock) then
            if ((ca2_edge = '0' and ca2_q = '1' and ca2_in_gated = '0') or
                (ca2_edge = '1' and ca2_q = '0' and ca2_in_gated = '1')) and
                e_sync = '1' then
                irqa_2_intf <= '1';
            elsif cs = '1' and read = '1' and rs = "00" and output_a_access = '1' then
                irqa_2_intf <= '0';
            end if;
        end if;
    end process;
    
    process(clock, e_sync)
    begin
        if rising_edge(clock) then
            if ((cb1_edge = '0' and cb1_q = '1' and cb1 = '0') or
                (cb1_edge = '1' and cb1_q = '0' and cb1 = '1')) and
                e_sync = '1' then
                irqb_1_intf <= '1';
            elsif cs = '1' and read = '1' and rs = "00" and output_b_access = '1' then
                irqb_1_intf <= '0';
            end if;
        end if;
    end process;
    
    process(clock, e_sync)
    begin
        if rising_edge(clock) then
            if ((cb2_edge = '0' and cb2_q = '1' and cb2_in_gated = '0') or
                (cb2_edge = '1' and cb2_q = '0' and cb2_in_gated = '1')) and
                e_sync = '1' then
                irqb_2_intf <= '1';
            elsif cs = '1' and read = '1' and rs = "00" and output_b_access = '1' then
                irqb_2_intf <= '0';
            end if;
        end if;
    end process;
            
end Behavioral;
