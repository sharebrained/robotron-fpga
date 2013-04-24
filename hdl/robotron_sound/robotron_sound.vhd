-----------------------------------------------------------------------
--
-- Copyright 2009-2013 ShareBrained Technology, Inc.
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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity robotron_sound is
   port(
      clk_fast    : in     STD_LOGIC;
      clk_cpu     : in     STD_LOGIC;
      reset       : in     STD_LOGIC;
      pb          : in     STD_LOGIC_VECTOR (5 downto 0);
      hand        : in     STD_LOGIC;
      dac         : out    STD_LOGIC_VECTOR (7 downto 0)
   );
end robotron_sound;

architecture Behavioral of robotron_sound is
   
   component cpu68
      port ( clk        : in     std_logic; 
             rst        : in     std_logic; 
             hold       : in     std_logic; 
             halt       : in     std_logic; 
             irq        : in     std_logic; 
             nmi        : in     std_logic; 
             data_in    : in     std_logic_vector (7 downto 0); 
             rw         : out    std_logic; 
             vma        : out    std_logic; 
             address    : out    std_logic_vector (15 downto 0); 
             data_out   : out    std_logic_vector (7 downto 0); 
             test_alu   : out    std_logic_vector (15 downto 0); 
             test_cc    : out    std_logic_vector (7 downto 0)
             );
   end component;
   
   component m6810
      port ( clk        : in     std_logic;
             rst        : in     std_logic;
             address    : in     std_logic_vector (6 downto 0);
             cs         : in     std_logic;
             rw         : in     std_logic;
             data_in    : in     std_logic_vector (7 downto 0);
             data_out   : out    std_logic_vector (7 downto 0)
             );
   end component;
   
   component pia6821
      port ( clk        : in     std_logic; 
             rst        : in     std_logic; 
             cs         : in     std_logic; 
             rw         : in     std_logic; 
             ca1        : in     std_logic; 
             cb1        : in     std_logic; 
             addr       : in     std_logic_vector (1 downto 0); 
             data_in    : in     std_logic_vector (7 downto 0); 
             irqa       : out    std_logic; 
             irqb       : out    std_logic; 
             data_out   : out    std_logic_vector (7 downto 0); 
             ca2_i      : in     std_logic; 
             ca2_o      : out    std_logic; 
             cb2_i      : in     std_logic; 
             cb2_o      : out    std_logic; 
             pa_i       : in     std_logic_vector (7 downto 0); 
             pa_o       : out    std_logic_vector (7 downto 0); 
             pb_i       : in     std_logic_vector (7 downto 0);
             pb_o       : out    std_logic_vector (7 downto 0)
             );
   end component;
   
   component rom_snd
      port ( clk        : in     std_logic; 
             rst        : in     std_logic; 
             cs         : in     std_logic; 
             addr       : in     std_logic_vector (11 downto 0); 
             data       : out    std_logic_vector (7 downto 0)
             );
   end component;
   
   component logic7442
      port ( input      : in     std_logic_vector (3 downto 0);
             output     : out    std_logic_vector (9 downto 0)
             );
   end component;
   
   signal CPU_ADDRESS_OUT           : std_logic_vector (15 downto 0);
   signal CPU_DATA_IN               : std_logic_vector (7 downto 0);
   signal CPU_DATA_OUT              : std_logic_vector (7 downto 0);
   signal CPU_RW                    : std_logic;
   signal CPU_IRQ                   : std_logic;
   signal CPU_VMA                   : std_logic;
   signal CPU_HALT                  : std_logic;
   signal CPU_HOLD                  : std_logic;
   signal CPU_NMI                   : std_logic;
   
   signal ROM_CS                    : std_logic;
   signal ROM_DATA_OUT              : std_logic_vector (7 downto 0);
   
   signal RAM_CS                    : std_logic;
   signal RAM_RW                    : std_logic;
   signal RAM_DATA_IN               : std_logic_vector (7 downto 0);
   signal RAM_DATA_OUT              : std_logic_vector (7 downto 0);
   
   signal PIA_RW                    : std_logic;
   signal PIA_CS                    : std_logic;
   signal PIA_IRQA                  : std_logic;
   signal PIA_IRQB                  : std_logic;
   signal PIA_DATA_IN               : std_logic_vector (7 downto 0);
   signal PIA_DATA_OUT              : std_logic_vector (7 downto 0);
   signal PIA_CA1                   : std_logic;
   signal PIA_CB1                   : std_logic;
   signal PIA_CA2_I                 : std_logic;
   signal PIA_CA2_O                 : std_logic;
   signal PIA_CB2_I                 : std_logic;
   signal PIA_CB2_O                 : std_logic;
   signal PIA_PA_I                  : std_logic_vector (7 downto 0);
   signal PIA_PA_O                  : std_logic_vector (7 downto 0);
   signal PIA_PB_I                  : std_logic_vector (7 downto 0);
   signal PIA_PB_O                  : std_logic_vector (7 downto 0);
   
   signal BCD_DEMUX_INPUT           : std_logic_vector (3 downto 0);
   signal BCD_DEMUX_OUTPUT          : std_logic_vector (9 downto 0);
   
   signal SPEECH_CLOCK              : std_logic;
   signal SPEECH_DATA               : std_logic;

begin
   
   CPU_HALT <= '0';
   CPU_HOLD <= '0';
   CPU_NMI <= '0';
   
   SPEECH_CLOCK <= '0';
   SPEECH_DATA <= '0';
   
   CPU : cpu68
      port map (clk => clk_cpu,
                data_in => CPU_DATA_IN,
                halt => CPU_HALT,
                hold => CPU_HOLD,
                irq => CPU_IRQ,
                nmi => CPU_NMI,
                rst => reset,
                address => CPU_ADDRESS_OUT,
                data_out => CPU_DATA_OUT,
                rw => CPU_RW,
                test_alu => open,
                test_cc => open,
                vma => CPU_VMA);
                
   CPU_IRQ <= PIA_IRQA or PIA_IRQB;
   
   process (PIA_CS, PIA_DATA_OUT, RAM_CS, RAM_DATA_OUT, ROM_DATA_OUT)
   begin
      if (PIA_CS = '1') then
         CPU_DATA_IN <= PIA_DATA_OUT;
      elsif (RAM_CS = '1') then
         CPU_DATA_IN <= RAM_DATA_OUT;
      else
         CPU_DATA_IN <= ROM_DATA_OUT;
      end if;
   end process;
   
   RAM : m6810
      port map (clk => clk_cpu,
                rst => reset,
                address   => CPU_ADDRESS_OUT(6 downto 0),
                cs => RAM_CS,
                rw => RAM_RW,
                data_in => RAM_DATA_IN,
                data_out => RAM_DATA_OUT);
   
   RAM_CS <= (not CPU_ADDRESS_OUT(8)) and (not CPU_ADDRESS_OUT(9)) and (not CPU_ADDRESS_OUT(10)) and (not CPU_ADDRESS_OUT(11))
              and (not BCD_DEMUX_OUTPUT(8))
              and CPU_VMA;
   RAM_RW <= CPU_RW;
   RAM_DATA_IN <= CPU_DATA_OUT;
   
   PIA : pia6821
      port map (addr => CPU_ADDRESS_OUT(1 downto 0),
                ca1 => PIA_CA1,
                cb1 => PIA_CB1,
                clk => clk_cpu,
                cs => PIA_CS,
                data_in => PIA_DATA_IN,
                rst => reset,
                rw => PIA_RW,
                data_out=> PIA_DATA_OUT,
                irqa => PIA_IRQA,
                irqb => PIA_IRQB,
                ca2_i => PIA_CA2_I,
                ca2_o => PIA_CA2_O,
                cb2_i => PIA_CB2_I,
                cb2_o => PIA_CB2_O,
                pa_i => PIA_PA_I,
                pa_o => PIA_PA_O,
                pb_i => PIA_PB_I,
                pb_o => PIA_PB_O
                );
   
   PIA_CA1 <= '1';
   PIA_CA2_I <= SPEECH_DATA;
   PIA_CB1 <= not (HAND and pb(5) and pb(4) and pb(3) and pb(2) and pb(1) and pb(0));
   PIA_CB2_I <= SPEECH_CLOCK;
   PIA_CS <= (not (BCD_DEMUX_OUTPUT(0) and BCD_DEMUX_OUTPUT(8)))
              and CPU_ADDRESS_OUT(10)
              and CPU_VMA;
   PIA_DATA_IN <= CPU_DATA_OUT;
   PIA_RW <= CPU_RW;
   PIA_PA_I <= "00000000";
   dac <= PIA_PA_O;
   PIA_PB_I(5 downto 0) <= pb(5 downto 0);
   PIA_PB_I(6) <= '0';
   PIA_PB_I(7) <= '0';
   
   ROM : rom_snd
      port map (addr => CPU_ADDRESS_OUT(11 downto 0),
                clk => clk_cpu,
                cs => ROM_CS,
                rst => reset,
                data => ROM_DATA_OUT);
   
   ROM_CS <= (not BCD_DEMUX_OUTPUT(7))
              and CPU_VMA;
   
   BCD_DEMUX : logic7442
      port map (input => BCD_DEMUX_INPUT,
                output => BCD_DEMUX_OUTPUT);
   
   BCD_DEMUX_INPUT <= (not CPU_ADDRESS_OUT(15)) & CPU_ADDRESS_OUT(14 downto 12);

end Behavioral;
