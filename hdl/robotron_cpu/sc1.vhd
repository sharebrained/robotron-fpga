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

-- This entity models a pair of Williams SC1 pixel BLTter ICs.
-- The interface is modified to be more conducive to synchronous
-- FPGA implementation.

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity sc1 is
    port(
        clk             : in    std_logic;
        reset           : in    std_logic;
        e_sync          : in    std_logic;
        
        reg_cs          : in    std_logic;
        reg_data_in     : in    std_logic_vector(7 downto 0);
        rs              : in    std_logic_vector(2 downto 0);

        halt            : out   boolean;
        halt_ack        : in    boolean;
        
        blt_ack         : in    std_logic;
        
        read            : out   boolean;
        write           : out   boolean;
        
        blt_address_out : out   std_logic_vector(15 downto 0);
        blt_data_in     : in    std_logic_vector(7 downto 0);
        blt_data_out    : out   std_logic_vector(7 downto 0);

        en_upper        : out   boolean;
        en_lower        : out   boolean
    );
end sc1;

architecture Behavioral of sc1 is

    type state_t is (state_idle, state_wait_for_halt, state_src, state_dst);
    
    -- 0: Run register
    signal span_src                 : boolean := false;
    signal span_dst                 : boolean := false;
    signal synchronize_e            : std_logic := '0';
    signal zero_write_suppress      : boolean := false;
    signal constant_substitution    : boolean := false;
    signal shift_right              : std_logic := '0';
    signal suppress_lower           : boolean := false;
    signal suppress_upper           : boolean := false;
    
    -- 1: constant substitution value
    signal constant_value   : std_logic_vector(7 downto 0) := (others => '1');
    
    -- 2, 3: source address
    signal src_base         : unsigned(15 downto 0) := (others => '0');
    
    -- 4, 5: destination address
    signal dst_base         : unsigned(15 downto 0) := (others => '0');
    
    -- 6: width
    signal width            : unsigned(8 downto 0) := (others => '0');
    
    -- 7: height
    signal height           : unsigned(8 downto 0) := (others => '0');
    
    -- Internal
    signal state            : state_t := state_idle;
    
    signal blt_src_data     : std_logic_vector(7 downto 0) := (others => '0');

    signal src_address      : unsigned(15 downto 0) := (others => '0');
    signal dst_address      : unsigned(15 downto 0) := (others => '0');
    
    signal x_count          : unsigned(8 downto 0) := (others => '0');
    signal x_count_next     : unsigned(8 downto 0) := (others => '0');
    signal y_count          : unsigned(8 downto 0) := (others => '0');
    signal y_count_next     : unsigned(8 downto 0) := (others => '0');
    
begin

    halt <= not (state = state_idle);
    
    blt_address_out <= std_logic_vector(dst_address) when state = state_dst else
                       std_logic_vector(src_address);
    read <= (state = state_src);
    write <= (state = state_dst);
    
    en_upper <= (state = state_src) or
                (not (suppress_upper or
                     (zero_write_suppress and blt_src_data(7 downto 4) = "0000")
                ));
    en_lower <= (state = state_src) or
                (not (suppress_lower or
                     (zero_write_suppress and blt_src_data(3 downto 0) = "0000")
                ));
    
    blt_data_out <= constant_value when constant_substitution else
                    blt_src_data;
    
    x_count_next <= x_count + 1;
    y_count_next <= y_count + 1;
    
    process(clk)
    begin
        if rising_edge(clk) then
            case state is
            when state_idle =>
                if reg_cs = '1' then
                    case rs is
                    when "000" =>   -- 0: Start BLT with attributes
                        suppress_upper <= reg_data_in(7) = '1';
                        suppress_lower <= reg_data_in(6) = '1';
                        shift_right <= reg_data_in(5);
                        constant_substitution <= reg_data_in(4) = '1';
                        zero_write_suppress <= reg_data_in(3) = '1';
                        synchronize_e <= reg_data_in(2);
                        span_dst <= reg_data_in(1) = '1';
                        span_src <= reg_data_in(0) = '1';
                
                        state <= state_wait_for_halt;
            
                    when "001" =>   -- 1: mask
                        constant_value <= reg_data_in;
                
                    when "010" =>   -- 2: source address (high)
                        src_base(15 downto 8) <= unsigned(reg_data_in);
                
                    when "011" =>   -- 3: source address (low)
                        src_base(7 downto 0) <= unsigned(reg_data_in);
                
                    when "100" =>   -- 4: destination address (high)
                        dst_base(15 downto 8) <= unsigned(reg_data_in);
                
                    when "101" =>   -- 5: destination address (low)
                        dst_base(7 downto 0) <= unsigned(reg_data_in);
                
                    when "110" =>   -- 6: width
                        width <= '0' & unsigned(reg_data_in xor "00000100");
                
                    when "111" =>   -- 7: height
                        height <= '0' & unsigned(reg_data_in xor "00000100");
                
                    when others =>
                        -- Do nothing.
                
                    end case;
                end if;
                
            when state_wait_for_halt =>
                if halt_ack then
                    src_address <= src_base;
                    dst_address <= dst_base;
                    
                    -- TODO: Handle width or height = 0?
                    x_count <= (others => '0');
                    y_count <= (others => '0');

                    state <= state_src;                    
                end if;
            
            when state_src =>
                if blt_ack = '1' then
                    blt_src_data <= blt_data_in;
                    state <= state_dst;
                end if;
                
            when state_dst =>
                if blt_ack = '1' then
                    state <= state_src;

                    if x_count_next = width then
                        x_count <= (others => '0');
                        y_count <= y_count_next;

                        if y_count_next = height then
                            state <= state_idle;
                        end if;
                    
                        if span_src then
                            src_address <= src_base + resize(y_count_next, 16);
                        else
                            src_address <= src_address + 1;
                        end if;
                    
                        if span_dst then
                            dst_address <= dst_base + resize(y_count_next, 16);
                        else
                            dst_address <= dst_address + 1;
                        end if;
                    else
                        x_count <= x_count_next;

                        if span_src then
                            src_address <= src_address + 256;
                        else
                            src_address <= src_address + 1;
                        end if;
                    
                        if span_dst then
                            dst_address <= dst_address + 256;
                        else
                            dst_address <= dst_address + 1;
                        end if;
                    end if;
                end if;
                
            when others =>
                -- Do nothing.
                
            end case;
        end if;
    end process;
    
end Behavioral;