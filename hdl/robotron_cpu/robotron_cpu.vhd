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

library unisim;
    use unisim.vcomponents.all;

entity robotron_cpu is
    port(
        CLK		        : in    std_logic;
           
        A                : in    std_logic_vector(15 downto 0);
        D                : inout std_logic_vector(7 downto 0);
        RESET_N          : out   std_logic;
        NMI_N            : out   std_logic;
        FIRQ_N           : out   std_logic;
        IRQ_N            : out   std_logic;
        LIC              : in    std_logic;
        AVMA             : in    std_logic;
        R_W_N            : in    std_logic;
        TSC              : out   std_logic;
        HALT_N           : out   std_logic;
        BA               : in    std_logic;
        BS               : in    std_logic;
        BUSY             : in    std_logic;
        E                : out   std_logic;
        Q                : out   std_logic;

        -- USB
        --EppAstb          : in    std_logic;
        --EppDstb          : in    std_logic;
        --UsbFlag          : in    std_logic;
        --EppWait          : in    std_logic;
        --EppDB            : in    std_logic_vector(7 downto 0);
        --UsbClk           : in    std_logic;
        --UsbOE            : in    std_logic;
        --UsbWR            : in    std_logic;
        --UsbPktEnd        : in    std_logic;
        --UsbDir           : in    std_logic;
        --UsbMode          : in    std_logic;
        --UsbAdr           : in    std_logic_vector(1 downto 0);

        -- Cellular RAM / StrataFlash
        MemOE            : out   std_logic;
        MemWR            : out   std_logic;

        RamAdv           : out   std_logic;
        RamCS            : out   std_logic;
        RamClk           : out   std_logic;
        RamCRE           : out   std_logic;
        RamLB            : out   std_logic;
        RamUB            : out   std_logic;
        RamWait          : in    std_logic;

        FlashRp          : out   std_logic;
        FlashCS          : out   std_logic;
        FlashStSts       : in    std_logic;

        MemAdr           : out   std_logic_vector(23 downto 1);
        MemDB            : inout std_logic_vector(15 downto 0);

        -- 7-segment display
        SEG              : out   std_logic_vector(6 downto 0);
        DP               : out   std_logic;
        AN               : out   std_logic_vector(3 downto 0);

        -- LEDs
        LED              : out   std_logic_vector(7 downto 0);

        -- Switches
        SW               : in    std_logic_vector(7 downto 0);

        -- Buttons
        BTN              : in    std_logic_vector(3 downto 0);

        -- VGA connector
        vgaRed           : out   std_logic_vector(2 downto 0);
        vgaGreen         : out   std_logic_vector(2 downto 0);
        vgaBlue          : out   std_logic_vector(1 downto 0);
        Hsync            : out   std_logic;
        Vsync            : out   std_logic;

        -- PS/2 connector
        --PS2C             : in    std_logic;
        --PS2D             : in    std_logic;

        -- 12-pin connectors
        JA               : in    std_logic_vector(7 downto 0);
        JB               : in    std_logic_vector(7 downto 0)
        --JC               : in    std_logic_vector(7 downto 0);
        --JD               : in    std_logic_vector(3 downto 0);

        -- RS-232 connector
        --RsRx             : in    std_logic;
        --RsTx             : in    std_logic
    );
end robotron_cpu;

architecture Behavioral of robotron_cpu is

    component led_decoder
        port(
            input   : in    std_logic_vector (3 downto 0);
            output  : out   std_logic_vector (6 downto 0)
        );
    end component;

    component mc6821
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
    end component;
   
    component sc1 is
        port(
            clk             : in    std_logic;
            reset           : in    std_logic;
        
            e_sync          : in    std_logic;
        
            rs              : in    std_logic_vector(2 downto 0);
            reg_cs          : in    std_logic;
            reg_data_in     : in    std_logic_vector(7 downto 0);

            halt            : out   boolean;
            halt_ack        : in    boolean;
        
            blt_ack         : in    std_logic;
            blt_address_out : out   std_logic_vector(15 downto 0);
        
            read            : out   boolean;
            write           : out   boolean;
            
            blt_data_in     : in    std_logic_vector(7 downto 0);
            blt_data_out    : out   std_logic_vector(7 downto 0);

            en_upper        : out   boolean;
            en_lower        : out   boolean
        );
    end component;

    component decoder_4 is
        port(
            address     : in    std_logic_vector(8 downto 0);
            data        : out   std_logic_vector(7 downto 0)
        );
    end component;

    component decoder_6 is
        port(
            address     : in    std_logic_vector(8 downto 0);
            data        : out   std_logic_vector(7 downto 0)
        );
    end component;

    signal reset_request            : std_logic;
    signal reset_counter            : unsigned(7 downto 0);
    signal reset                    : std_logic;

    signal clock_50m                : std_logic;
    signal clock_50m_0              : std_logic;
    signal clock_50m_fb             : std_logic;

    signal clock                    : std_logic;
    
    signal clock_12_phase           : unsigned(11 downto 0) := (0 => '1', others => '0');
    
    signal clock_q_set              : boolean;
    signal clock_q_clear            : boolean;
    signal clock_q                  : std_logic := '0';
    
    signal clock_e_set              : boolean;
    signal clock_e_clear            : boolean;
    signal clock_e                  : std_logic := '0';
    
    -------------------------------------------------------------------
    
    signal video_count              : unsigned(14 downto 0) := (others => '0');
    signal video_count_next         : unsigned(14 downto 0);
    signal video_address_or_mask    : unsigned(13 downto 0);
    signal video_address            : unsigned(13 downto 0) := (others => '0');
    
    signal count_240                : std_logic;
    signal irq_4ms                  : std_logic;
    
    signal horizontal_sync          : std_logic;
    signal vertical_sync            : std_logic;
    
    signal video_blank              : boolean := true;
    
    -------------------------------------------------------------------
    
    signal led_bcd_in               : std_logic_vector(15 downto 0);
    signal led_bcd_in_digit         : std_logic_vector(3 downto 0);
    
    signal led_counter              : unsigned(15 downto 0) := (others => '0');
    signal led_digit_index          : unsigned(1 downto 0);
    
    signal led_segment              : std_logic_vector(6 downto 0);
    signal led_dp                   : std_logic;
    signal led_anode                : std_logic_vector(3 downto 0);

    -------------------------------------------------------------------

    signal address                  : std_logic_vector(15 downto 0);
    
    signal write                    : boolean;
    signal read                     : boolean;
    
    -------------------------------------------------------------------

    signal mpu_address              : std_logic_vector(15 downto 0);
    signal mpu_data_in              : std_logic_vector(7 downto 0);
    signal mpu_data_out             : std_logic_vector(7 downto 0);
    
    signal mpu_bus_status           : std_logic;
    signal mpu_bus_available        : std_logic;
    
    signal mpu_read                 : boolean;
    signal mpu_write                : boolean;
    
    signal mpu_reset                : std_logic := '1';
    signal mpu_halt                 : std_logic := '0';
    signal mpu_halted               : boolean := false;
    signal mpu_irq                  : std_logic := '0';
    signal mpu_firq                 : std_logic := '0';
    signal mpu_nmi                  : std_logic := '0';

    -------------------------------------------------------------------

    signal memory_address           : std_logic_vector(15 downto 0);
    signal memory_data_in           : std_logic_vector(7 downto 0);
    signal memory_data_out          : std_logic_vector(7 downto 0);
    
    signal memory_output_enable     : boolean := false;
    signal memory_write             : boolean := false;
    signal flash_enable             : boolean := false;
    
    signal ram_enable               : boolean := false;
    signal ram_lower_enable         : boolean := false;
    signal ram_upper_enable         : boolean := false;
    
    -------------------------------------------------------------------
    
    signal e_rom                    : std_logic := '0';
    signal screen_control           : std_logic := '0';
    
    signal rom_access               : boolean;
    signal ram_access               : boolean;
    signal color_table_access       : boolean;
    signal widget_pia_access        : boolean;
    signal rom_pia_access           : boolean;
    signal blt_register_access      : boolean;
    signal video_counter_access     : boolean;
    signal watchdog_access          : boolean;
    signal control_access           : boolean;
    signal cmos_access              : boolean;

    signal video_counter_value      : std_logic_vector(7 downto 0);
    
    -------------------------------------------------------------------
    
    signal HAND                 : std_logic := '1';
    signal SLAM                 : std_logic := '1';
    signal R_COIN               : std_logic := '1';
    signal C_COIN               : std_logic := '1';
    signal L_COIN               : std_logic := '1';
    signal H_S_RESET            : std_logic := '1';
    signal ADVANCE              : std_logic := '1';
    signal AUTO_UP              : std_logic := '0';
    signal PB                   : std_logic_vector(5 downto 0);
    
    signal rom_pia_rs           : std_logic_vector(1 downto 0) := (others => '0');
    signal rom_pia_cs           : std_logic := '0';
    signal rom_pia_write        : std_logic := '0';
    signal rom_pia_data_in      : std_logic_vector(7 downto 0);
    signal rom_pia_data_out     : std_logic_vector(7 downto 0);
    signal rom_pia_ca2_out      : std_logic;
    signal rom_pia_ca2_dir      : std_logic;
    signal rom_pia_irq_a        : std_logic;
    signal rom_pia_pa_in        : std_logic_vector(7 downto 0);
    signal rom_pia_pa_out       : std_logic_vector(7 downto 0);
    signal rom_pia_pa_dir       : std_logic_vector(7 downto 0);

    signal rom_pia_cb2_out      : std_logic;
    signal rom_pia_cb2_dir      : std_logic;
    signal rom_pia_irq_b        : std_logic;
    signal rom_pia_pb_in        : std_logic_vector(7 downto 0);
    signal rom_pia_pb_out       : std_logic_vector(7 downto 0);
    signal rom_pia_pb_dir       : std_logic_vector(7 downto 0);
    
    signal rom_led_digit        : std_logic_vector(3 downto 0);
    
    -------------------------------------------------------------------

    signal MOVE_UP_1            : std_logic := '1';
    signal MOVE_DOWN_1          : std_logic := '1';
    signal MOVE_LEFT_1          : std_logic := '1';
    signal MOVE_RIGHT_1         : std_logic := '1';
    signal PLAYER_1_START       : std_logic := '1';
    signal PLAYER_2_START       : std_logic := '1';
    signal FIRE_UP_1            : std_logic := '1';
    signal FIRE_DOWN_1          : std_logic := '1';
    signal FIRE_RIGHT_1         : std_logic := '1';
    signal FIRE_LEFT_1          : std_logic := '1';
    signal MOVE_UP_2            : std_logic := '1';
    signal MOVE_DOWN_2          : std_logic := '1';
    signal MOVE_LEFT_2          : std_logic := '1';
    signal MOVE_RIGHT_2         : std_logic := '1';
    signal FIRE_RIGHT_2         : std_logic := '1';
    signal FIRE_UP_2            : std_logic := '1';
    signal FIRE_DOWN_2          : std_logic := '1';
    signal FIRE_LEFT_2          : std_logic := '1';
    
    signal board_interface_w1   : std_logic := '1';  -- Upright application: '1' = jumper present
    
    signal widget_pia_rs        : std_logic_vector(1 downto 0) := (others => '0');
    signal widget_pia_cs        : std_logic;
    signal widget_pia_write     : std_logic := '0';
    signal widget_pia_data_in   : std_logic_vector(7 downto 0);
    signal widget_pia_data_out  : std_logic_vector(7 downto 0);
    signal widget_pia_ca2_out   : std_logic;
    signal widget_pia_ca2_dir   : std_logic;
    signal widget_pia_irq_a     : std_logic;
    signal widget_pia_pa_in     : std_logic_vector(7 downto 0);
    signal widget_pia_pa_out    : std_logic_vector(7 downto 0);
    signal widget_pia_pa_dir    : std_logic_vector(7 downto 0);
    signal widget_pia_input_select  : std_logic;
    signal widget_pia_cb2_out   : std_logic;
    signal widget_pia_cb2_dir   : std_logic;
    signal widget_pia_irq_b     : std_logic;
    signal widget_pia_pb_in     : std_logic_vector(7 downto 0);
    signal widget_pia_pb_out    : std_logic_vector(7 downto 0);
    signal widget_pia_pb_dir    : std_logic_vector(7 downto 0);
    
    signal widget_ic3_a         : std_logic_vector(4 downto 1);
    signal widget_ic3_b         : std_logic_vector(4 downto 1);
    signal widget_ic3_y         : std_logic_vector(4 downto 1);

    signal widget_ic4_a         : std_logic_vector(4 downto 1);
    signal widget_ic4_b         : std_logic_vector(4 downto 1);
    signal widget_ic4_y         : std_logic_vector(4 downto 1);
    
    -------------------------------------------------------------------

    signal blt_rs               : std_logic_vector(2 downto 0) := (others => '0');
    signal blt_reg_cs           : std_logic := '0';
    signal blt_reg_data_in      : std_logic_vector(7 downto 0) := (others => '0');
    
    signal blt_halt             : boolean := false;
    signal blt_halt_ack         : boolean := false;
    signal blt_read             : boolean := false;
    signal blt_write            : boolean := false;
    signal blt_blt_ack          : std_logic := '0';
    signal blt_address_out      : std_logic_vector(15 downto 0);
    signal blt_data_in          : std_logic_vector(7 downto 0);
    signal blt_data_out         : std_logic_vector(7 downto 0);
    signal blt_en_lower         : boolean := false;
    signal blt_en_upper         : boolean := false;
    
    -------------------------------------------------------------------

    function to_std_logic(L: boolean) return std_logic is
    begin
        if L then
            return '1';
        else
            return '0';
        end if;
    end function;
    
    subtype pixel_color_t is std_logic_vector(7 downto 0);
    type color_table_t is array(0 to 15) of pixel_color_t;
    signal color_table : color_table_t;
    
    signal pixel_nibbles : std_logic_vector(7 downto 0);
    signal pixel_byte_l : std_logic_vector(7 downto 0);
    signal pixel_byte_h : std_logic_vector(7 downto 0);
    
    -------------------------------------------------------------------

    signal decoder_4_in : std_logic_vector(8 downto 0);
    signal pseudo_address : std_logic_vector(15 downto 8);
    
    signal decoder_6_in : std_logic_vector(8 downto 0);
    signal video_prom_address : std_logic_vector(13 downto 6);
    
    -------------------------------------------------------------------
    
    signal debug_blt_source_address : std_logic_vector(15 downto 0) := (others => '0');
    signal debug_last_mpu_address   : std_logic_vector(15 downto 0) := (others => '0');
    
begin

    dcm_12m: DCM_SP
        generic map (
            CLKDV_DIVIDE => 2.0,    --  Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
                                    --     7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
            CLKFX_DIVIDE => 25,     --  Can be any interger from 1 to 32
            CLKFX_MULTIPLY => 6,    --  Can be any integer from 1 to 32
            CLKIN_DIVIDE_BY_2 => false, -- TRUE/FALSE to enable CLKIN divide by two feature
            CLKIN_PERIOD => 20.0,       -- Specify period of input clock
            CLKOUT_PHASE_SHIFT => "NONE",   -- Specify phase shift of "NONE", "FIXED" or "VARIABLE" 
            CLK_FEEDBACK => "1X",           -- Specify clock feedback of "NONE", "1X" or "2X" 
            DESKEW_ADJUST => "SYSTEM_SYNCHRONOUS",  -- "SOURCE_SYNCHRONOUS", "SYSTEM_SYNCHRONOUS" or
                                                    -- an integer from 0 to 15
            DLL_FREQUENCY_MODE => "LOW",    -- "HIGH" or "LOW" frequency mode for DLL
            DUTY_CYCLE_CORRECTION => true,  -- Duty cycle correction, TRUE or FALSE
            PHASE_SHIFT => 0,       -- Amount of fixed phase shift from -255 to 255
            STARTUP_WAIT => true    -- Delay configuration DONE until DCM_SP LOCK, TRUE/FALSE
        )
        port map(
            CLKFX => clock,   -- DCM CLK synthesis out (M/D)
            CLKIN => clock_50m,  -- Clock input (from IBUFG, BUFG or DCM)
            CLK0 => clock_50m_0,
            CLKFB => clock_50m_fb
        );
        
    clock_50m_fb <= clock_50m_0;

    -- clock    0   1   2   3   4   5   6   7   8   9   10  11
    -- Q        0   0   0   1   1   1   1   1   1   0   0   0
    -- E        0   0   0   0   0   0   1   1   1   1   1   1
    -- Memory   0   0   1   1   2   2   3   3   4   4   5   5
        
    -- Micro 128Mb (8M x 16) CellularRAM MT45W8MW16BGX-701 WT (marking "PW503")
    -- MT: Micron Technology
    -- 45: PSRAM/CellularRAM memory
    -- W: 1.70-1.95V
    -- 8M: 8 Meg address space
    -- W: 1.7 - 3.6V
    -- 16: 16-bit bus
    -- B: asynchronous/page/burst read/write operation mode
    -- GX: 54-ball "green" VFBGA
    -- -70: 70ns access/cycle time
    -- 1: 104MHz frequency
    --  : standard standby power option
    -- WT: -30C to +85C operating temperature
    -------------------------------------------------------------------
    -- Asynchronous mode:
    --  tRC (read cycle): 70 ns
    --      from CE#/OE#/ADDRESS/LB#/UB# asserted to DATA valid and CE#/OE#/ADDRESS/LB#/UB# de-asserted.
    --  tWC (write cycle): 70 ns
    --      from CE#/ADDRESS/LB#/UB# asserted to DATA valid and CE#/WE#/LB#/UB# de-asserted.
    --  tCEM: 4 us maximum
    --      from WE# asserted to DATA valid and CE#/WE#/LB#/UB# de-asserted.
    
    -- Intel JS28F128J3D75
    -------------------------------------------------------------------
    -- Read:
    --      75 ns read/write cycle time
    --      75 ns address to output delay
    --      75 ns CE# to output delay
    
    clock_50m <= CLK;
    reset_request <= BTN(0);
    
    mpu_reset <= reset;
    mpu_halt <= to_std_logic(blt_halt);
    mpu_irq <= rom_pia_irq_a or rom_pia_irq_b;
    mpu_firq <= '0';
    mpu_nmi <= '0';
    
    address <= blt_address_out when mpu_halted else
               mpu_address;
    write <= blt_write when mpu_halted else
             mpu_write;
    read <= blt_read when mpu_halted else
            mpu_read;
             
    rom_access <= (address <  X"9000" and read and e_rom = '1') or
                  (address >= X"D000" and read);
    ram_access <= (address <  X"9000" and write) or
                  (address <  X"9000" and read and e_rom = '0') or
                  (address >= X"9000" and address < X"C000");

    -- Color table: write: C000-C3FF
    color_table_access <= std_match(address, "110000----------");

    -- Widget PIA: read/write: C8X4 - C8X7
    widget_pia_access <= std_match(address, "11001000----01--");
    
    -- ROM PIA: read/write: C8XC - C8XF
    rom_pia_access <= std_match(address, "11001000----11--");

    -- Control address: write: C9XX
    control_access <= std_match(address, "11001001--------");

    -- Special chips: read/write? CAXX
    blt_register_access <= std_match(address, "11001010--------");
    
    -- Video counter: read: CBXX (even addresses)
    video_counter_access <= std_match(address, "11001011-------0");
    
    -- Watchdog register: write: CBFE or CBFF
    watchdog_access <= std_match(address, "110010111111111-");
    
    -- CMOS "nonvolatile" RAM: read/write: CC00 - CFFF
    cmos_access <= std_match(address, "110011----------");
    
    SLAM <= not SW(6);
    H_S_RESET <= not SW(2);
    ADVANCE <= not SW(1);
    AUTO_UP <= not SW(0);
    
    PLAYER_1_START <= not BTN(3);
    PLAYER_2_START <= not BTN(2);
    C_COIN <= not BTN(1);
    
    MOVE_UP_1 <= JA(0);
    MOVE_DOWN_1 <= JA(1);
    MOVE_LEFT_1 <= JA(2);
    MOVE_RIGHT_1 <= JA(3);
    FIRE_UP_1 <= JA(4);
    FIRE_DOWN_1 <= JA(5);
    FIRE_LEFT_1 <= JA(6);
    FIRE_RIGHT_1 <= JA(7);
    
    MOVE_UP_2 <= JB(0);
    MOVE_DOWN_2 <= JB(1);
    MOVE_LEFT_2 <= JB(2);
    MOVE_RIGHT_2 <= JB(3);
    FIRE_UP_2 <= JB(4);
    FIRE_DOWN_2 <= JB(5);
    FIRE_LEFT_2 <= JB(6);
    FIRE_RIGHT_2 <= JB(7);
    
    video_counter_value <= std_logic_vector(video_address(13 downto 8)) & "00";
    
    decoder_4_in <= screen_control & address(15 downto 8);
    decoder_6_in <= screen_control & std_logic_vector(video_address(13 downto 6));

    process(clock)
    begin
        if rising_edge(clock) then
            ram_enable <= false;
            ram_lower_enable <= false;
            ram_upper_enable <= false;
            
            flash_enable <= false;
            
            memory_output_enable <= false;
            memory_write <= false;
            memory_data_out <= (others => '0');
            
            blt_reg_cs <= '0';
            blt_blt_ack <= '0';
            
            rom_pia_cs <= '0';
            rom_pia_write <= '0';
            
            widget_pia_cs <= '0';
            widget_pia_write <= '0';
            
            if clock_12_phase( 0) = '1' then
                memory_address <= "00" & video_prom_address &
                                  std_logic_vector(video_address(4 downto 0)) & "0";
            end if;
            
            if clock_12_phase( 2) = '1' then
                memory_address <= "01" & video_prom_address &
                                  std_logic_vector(video_address(4 downto 0)) & "0";
            end if;
            
            if clock_12_phase( 4) = '1' then
                memory_address <= "10" & video_prom_address &
                                  std_logic_vector(video_address(4 downto 0)) & "0";
            end if;
            
            if clock_12_phase( 6) = '1' then
                memory_address <= "00" & video_prom_address &
                                  std_logic_vector(video_address(4 downto 0)) & "1";
            end if;
            
            if clock_12_phase( 8) = '1' then
                memory_address <= "01" & video_prom_address &
                                   std_logic_vector(video_address(4 downto 0)) & "1";
            end if;
            
            if clock_12_phase(10) = '1' then
                memory_address <= "10" & video_prom_address &
                                  std_logic_vector(video_address(4 downto 0)) & "1";
            end if;

            if clock_12_phase(5) = '1' then
                if std_match(video_address(4 downto 0) & "1", "11-1-1") then
                    video_blank <= true;
                elsif std_match(video_address(4 downto 0) & "1", "0---11") then
                    video_blank <= false;
                end if;
            end if;
            
            if clock_12_phase( 0) = '1' or
               clock_12_phase( 2) = '1' or
               clock_12_phase( 4) = '1' or
               clock_12_phase( 6) = '1' or
               clock_12_phase( 8) = '1' or
               clock_12_phase(10) = '1' then
                memory_output_enable <= true;
                ram_enable <= true;
                ram_lower_enable <= true;
                ram_upper_enable <= true;

                if video_blank then
                    vgaRed <= (others => '0');
                    vgaGreen <= (others => '0');
                    vgaBlue <= (others => '0');
                else
                    vgaRed <= pixel_byte_h(2 downto 0);
                    vgaGreen <= pixel_byte_h(5 downto 3);
                    vgaBlue <= pixel_byte_h(7 downto 6);
                end if;
            end if;
            
            if clock_12_phase( 1) = '1' or
               clock_12_phase( 3) = '1' or
               clock_12_phase( 5) = '1' or
               clock_12_phase( 7) = '1' or
               clock_12_phase( 9) = '1' or
               clock_12_phase(11) = '1' then
                pixel_nibbles <= memory_data_in;

                pixel_byte_l <= color_table(to_integer(unsigned(pixel_nibbles(3 downto 0))));
                pixel_byte_h <= color_table(to_integer(unsigned(pixel_nibbles(7 downto 4))));

                if video_blank then
                    vgaRed <= (others => '0');
                    vgaGreen <= (others => '0');
                    vgaBlue <= (others => '0');
                else
                    vgaRed <= pixel_byte_l(2 downto 0);
                    vgaGreen <= pixel_byte_l(5 downto 3);
                    vgaBlue <= pixel_byte_l(7 downto 6);
                end if;
            end if;
            
            -- BLT-only cycles
            -- NOTE: the next cycle must be a read if coming from RAM, since the
            -- RAM WE# needs to deassert for a time in order for another write to
            -- take place.
            if clock_12_phase(11) = '1' or clock_12_phase(1) = '1' then
                if mpu_halted then
                    if ram_access then
                        if pseudo_address(15 downto 14) = "11" then
                            memory_address <= address;
                        else
                            memory_address <= pseudo_address(15 downto 14) &
                                              address(7 downto 0) &
                                              pseudo_address(13 downto 8);
                        end if;
                    elsif rom_access or cmos_access or color_table_access then
                        memory_address <= address;
                    end if;

                    if ram_access and write then
                        memory_data_out <= blt_data_out;
                        memory_write <= true;
                    else
                        memory_output_enable <= true;
                    end if;

                    if ram_access then
                        ram_enable <= true;
                        ram_lower_enable <= blt_en_lower;
                        ram_upper_enable <= blt_en_upper;
                    end if;

                    if rom_access then
                        flash_enable <= true;
                    end if;

                    blt_blt_ack <= '1';
                end if;
            end if;
            
            -- MPU-only cycle
            -- NOTE: the next cycle must be a read if coming from RAM, since the
            -- RAM WE# needs to deassert for a time in order for another write to
            -- take place.
            if clock_12_phase(7) = '1' then
                if not mpu_halted then
                    if ram_access then
                        if pseudo_address(15 downto 14) = "11" then
                            memory_address <= address;
                        else
                            memory_address <= pseudo_address(15 downto 14) &
                                              address(7 downto 0) &
                                              pseudo_address(13 downto 8);
                        end if;
                    elsif rom_access or cmos_access or color_table_access then
                        memory_address <= address;
                    end if;
                
                    if (ram_access or cmos_access or color_table_access) and write then
                        memory_data_out <= mpu_data_in;
                        memory_write <= true;
                    else
                        memory_output_enable <= true;
                    end if;
                
                    if ram_access or cmos_access or color_table_access then
                        ram_enable <= true;
                        ram_lower_enable <= true;
                        ram_upper_enable <= true;
                    end if;
                
                    if rom_access then
                        flash_enable <= true;
                    end if;

                    if blt_register_access and write then
                        blt_rs <= address(2 downto 0);
                        blt_reg_cs <= '1';
                        blt_reg_data_in <= mpu_data_in;
                    
                        -- NOTE: To display BLT source address:
                        if address(2 downto 0) = "010" then
                            debug_blt_source_address(15 downto 8) <= mpu_data_in;
                        end if;
                        
                        if address(2 downto 0) = "011" then
                            debug_blt_source_address(7 downto 0) <= mpu_data_in;
                        end if;
                    end if;
                
                    if rom_pia_access then
                        rom_pia_rs <= address(1 downto 0);
                        rom_pia_data_in <= mpu_data_in;
                        rom_pia_write <= to_std_logic(write);
                        rom_pia_cs <= '1';
                    end if;
                
                    if widget_pia_access then
                        widget_pia_rs <= address(1 downto 0);
                        widget_pia_data_in <= mpu_data_in;
                        widget_pia_write <= to_std_logic(write);
                        widget_pia_cs <= '1';
                    end if;

                    if control_access and write then
                        screen_control <= mpu_data_in(1);
                        e_rom <= mpu_data_in(0);
                    end if;

                    if color_table_access and write then
                        color_table(to_integer(unsigned(address(3 downto 0)))) <= mpu_data_in;
                    end if;
                end if;
            end if;
            
            if clock_12_phase(8) = '1' then
                if not mpu_halted then
                    if read then
                        if ram_access or rom_access or cmos_access then
                            mpu_data_out <= memory_data_in;
                        end if;
                    
                        if widget_pia_access then
                            mpu_data_out <= widget_pia_data_out;
                        end if;
                    
                        if rom_pia_access then
                            mpu_data_out <= rom_pia_data_out;
                        end if;
                    
                        if video_counter_access then
                            mpu_data_out <= video_counter_value;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    LED <= mpu_irq &
           mpu_halt &
           to_std_logic(mpu_halted) &
           to_std_logic(ram_access) &
           to_std_logic(rom_access) &
           to_std_logic(rom_pia_access) &
           to_std_logic(widget_pia_access) &
           to_std_logic(blt_register_access);
           
    led_bcd_in <= debug_blt_source_address;
    
    -------------------------------------------------------------------

    horizontal_decoder: decoder_4
        port map(
            address => decoder_4_in,
            data => pseudo_address
        );
        
    -------------------------------------------------------------------

    vertical_decoder: decoder_6
        port map(
            address => decoder_6_in,
            data => video_prom_address
        );
        
    -------------------------------------------------------------------
    
    blt_halt_ack <= mpu_halted;
    blt_data_in <= memory_data_in;
    
    blt: sc1
        port map(
            clk => clock,
            reset => reset,
            e_sync => to_std_logic(clock_e_clear),
        
            reg_cs => blt_reg_cs,
            reg_data_in => blt_reg_data_in,
            rs => blt_rs,

            halt => blt_halt,
            halt_ack => blt_halt_ack,
        
            blt_ack => blt_blt_ack,
            blt_address_out => blt_address_out,
        
            read => blt_read,
            write => blt_write,
            
            blt_data_in => blt_data_in,
            blt_data_out => blt_data_out,

            en_upper => blt_en_upper,
            en_lower => blt_en_lower
        );

    -------------------------------------------------------------------

    rom_pia_pa_in <= not HAND &
                     not SLAM &
                     not R_COIN &
                     not C_COIN &
                     not L_COIN &
                     not H_S_RESET &
                     not ADVANCE &
                     not AUTO_UP;
    PB(5 downto 0) <= rom_pia_pb_out(5 downto 0);
    rom_led_digit(0) <= rom_pia_pb_out(6);
    rom_led_digit(1) <= rom_pia_pb_out(7);
    rom_led_digit(2) <= rom_pia_cb2_out;
    rom_led_digit(3) <= rom_pia_ca2_out;
    rom_pia_pb_in <= (others => '1');
    
    rom_pia: mc6821
        port map(
            reset => reset,
            clock => clock,
            e_sync => to_std_logic(clock_e_clear),
        
            rs => rom_pia_rs,
            cs => rom_pia_cs,
            write => rom_pia_write,
        
            data_in => rom_pia_data_in,
            data_out => rom_pia_data_out,
        
            ca1 => count_240,
            ca2_in => '1',
            ca2_out => rom_pia_ca2_out,
            ca2_dir => rom_pia_ca2_dir,
            irq_a => rom_pia_irq_a,
            pa_in => rom_pia_pa_in,
            pa_out => rom_pia_pa_out,
            pa_dir => rom_pia_pa_dir,
        
            cb1 => irq_4ms,
            cb2_in => '1',
            cb2_out => rom_pia_cb2_out,
            cb2_dir => rom_pia_cb2_dir,
            irq_b => rom_pia_irq_b,
            pb_in => rom_pia_pb_in,
            pb_out => rom_pia_pb_out,
            pb_dir => rom_pia_pb_dir
        );

    -------------------------------------------------------------------

    widget_pia_input_select <= widget_pia_cb2_out;

    widget_ic3_a <= not (MOVE_RIGHT_2 & MOVE_LEFT_2 & MOVE_DOWN_2 & MOVE_UP_2);
    widget_ic3_b <= not (MOVE_RIGHT_1 & MOVE_LEFT_1 & MOVE_DOWN_1 & MOVE_UP_1);
    
    widget_ic3_y <= widget_ic3_b when widget_pia_input_select = '1' else widget_ic3_a;
    
    widget_ic4_a <= not (FIRE_RIGHT_2 & FIRE_LEFT_2 & FIRE_DOWN_2 & FIRE_UP_2);
    widget_ic4_b <= not (FIRE_RIGHT_1 & FIRE_LEFT_1 & FIRE_DOWN_1 & FIRE_UP_1);

    widget_ic4_y <= widget_ic4_b when widget_pia_input_select = '1' else widget_ic4_a;
    
    widget_pia_pa_in <= widget_ic4_y(2) &
                        widget_ic4_y(1) &
                        not PLAYER_2_START &
                        not PLAYER_1_START &
                        widget_ic3_y(4) &
                        widget_ic3_y(3) &
                        widget_ic3_y(2) &
                        widget_ic3_y(1);
    widget_pia_pb_in <= not board_interface_w1 &
                        "00000" &
                        widget_ic4_y(4) &
                        widget_ic4_y(3);
    
    widget_pia: mc6821
        port map(
            reset => reset,
            clock => clock,
            e_sync => to_std_logic(clock_e_clear),
        
            rs => widget_pia_rs,
            cs => widget_pia_cs,
            write => widget_pia_write,
        
            data_in => widget_pia_data_in,
            data_out => widget_pia_data_out,
        
            ca1 => '0',
            ca2_in => '0',
            ca2_out => widget_pia_ca2_out,
            ca2_dir => widget_pia_ca2_dir,
            irq_a => widget_pia_irq_a,
            pa_in => widget_pia_pa_in,
            pa_out => widget_pia_pa_out,
            pa_dir => widget_pia_pa_dir,
        
            cb1 => '0',
            cb2_in => '1',
            cb2_out => widget_pia_cb2_out,
            cb2_dir => widget_pia_cb2_dir,
            irq_b => widget_pia_irq_b,
            pb_in => widget_pia_pb_in,
            pb_out => widget_pia_pb_out,
            pb_dir => widget_pia_pb_dir
        );

    -------------------------------------------------------------------

    E <= clock_e;
    Q <= clock_q;
    
    -- Always react instantly to processor R/W# state, to protect
    -- data bus bidirectional buffer.
    D <= mpu_data_out when R_W_N = '1' and BA = '0' else
         (others => 'Z');
    
    TSC <= '0';
    
    process(clock)
    begin
        if rising_edge(clock) and clock_q_set then
            -- RESET, HALT, interrupts are captured by microprocessor
            -- on Q falling edge. Present once per processor clock,
            -- on Q rising edge -- just because.
            RESET_N <= not mpu_reset;
            HALT_N <= not mpu_halt;
            IRQ_N <= not mpu_irq;
            FIRQ_N <= not mpu_firq;
            NMI_N <= not mpu_nmi;
        end if;
    end process;
    
    process(clock)
    begin
        if rising_edge(clock) and clock_q_set then
            mpu_address <= A;
            mpu_bus_status <= BS;
            mpu_bus_available <= BA;
            mpu_halted <= BS = '1' and BA = '1';
            mpu_write <= R_W_N = '0' and BA = '0';
            mpu_read <= R_W_N = '1' and BA = '0';
            
            if BA = '0' then
                debug_last_mpu_address <= A;
            end if;
        end if;
    end process;
    
    process(clock)
    begin
        if rising_edge(clock) and clock_e_set then
            mpu_data_in <= D;
        end if;
    end process;
    
    -------------------------------------------------------------------

    MemOE <= '0' when memory_output_enable else '1';
    MemWR <= '0' when memory_write else '1';
    
    RamAdv <= '0';
    RamCS <= '0' when ram_enable else '1';
    RamClk <= '0';
    RamCRE <= '0';
    RamLB <= '0' when ram_lower_enable else '1';
    RamUB <= '0' when ram_upper_enable else '1';
    
    FlashRp <= '1';
    FlashCS <= '0' when flash_enable else '1';
    
    MemAdr <= "0000000" & memory_address;
    
    MemDB <= memory_data_out(7 downto 4) &
             memory_data_out(7 downto 4) &
             memory_data_out(3 downto 0) &
             memory_data_out(3 downto 0) when memory_write
                                         else (others => 'Z');
    memory_data_in <= MemDB(11 downto 8) & MemDB(3 downto 0);

    -------------------------------------------------------------------
    -- VGA output

    Hsync <= not horizontal_sync;
    Vsync <= not vertical_sync;
    
    -------------------------------------------------------------------

    DP <= led_dp;
    SEG <= led_segment;
    AN <= led_anode;
    
    -------------------------------------------------------------------
    -- 1MHz, 12-phase counter.
    
    process(clock)
    begin
        if rising_edge(clock) then
            clock_12_phase <= clock_12_phase rol 1;
        end if;
    end process;
    
    -------------------------------------------------------------------
    -- Q clock

    clock_q_set <= clock_12_phase(2) = '1';
    clock_q_clear <= clock_12_phase(8) = '1';

    process(clock)
    begin
        if rising_edge(clock) then
            if clock_q_set then
                clock_q <= '1';
            elsif clock_q_clear then
                clock_q <= '0';
            end if;
        end if;
    end process;
    
    -------------------------------------------------------------------
    -- E clock

    clock_e_set <= clock_12_phase(5) = '1';
    clock_e_clear <= clock_12_phase(11) = '1';
    
    process(clock)
    begin
        if rising_edge(clock) then
            if clock_e_set then
                clock_e <= '1';
            elsif clock_e_clear then
                clock_e <= '0';
            end if;
        end if;
    end process;
    
    -------------------------------------------------------------------
    -- Reset generator
    
    process(clock)
    begin
        if rising_edge(clock) then
            if reset_request = '1' then
                reset_counter <= (others => '0');
                reset <= '1';
            else
                if reset_counter < 100 then
                    reset_counter <= reset_counter + 1;
                else
                    reset <= '0';
                end if;
            end if;
        end if;
    end process;

    -------------------------------------------------------------------
    -- Video counter

    video_count_next <= video_count + 1 when (video_count /= 16639)
                                        else (others => '0');
    video_address_or_mask <= "11111100000000" when video_count_next(14) = '1' else (others => '0');
    irq_4ms <= video_count(11);
    
    process(clock)
    begin
        -- Advance video count at end of video memory phase.
        if rising_edge(clock) and clock_e_clear then
            --watchdog_increment <= '0';
            video_count <= video_count_next;
            video_address <= video_count_next(13 downto 0) or video_address_or_mask;
            --if video_count(14 downto 0) = "011111111111111" then
            --    watchdog_increment <= '1';
            --end if;
        end if;
    end process;

    -------------------------------------------------------------------
    -- Video generator
    
    count_240 <= '1' when video_address(13 downto 10) = "1111" else '0';

    horizontal_sync <= '1' when video_address(4 downto 1) = "1110" else '0';
    vertical_sync <= '1' when video_address(13 downto 9) = "11111" else '0';

    -------------------------------------------------------------------
    -- LED numeric display
    
    process(clock)
    begin
        if rising_edge(clock) then
            led_counter <= led_counter + 1;
        end if;
    end process;
    
    led_digit_index <= led_counter(15 downto 14);
    
    with led_digit_index select
        led_anode <= "1110" when "00",
                     "1101" when "01",
                     "1011" when "10",
                     "0111" when "11",
                     "1111" when others;
    
    with led_digit_index select
        led_bcd_in_digit <= led_bcd_in( 3 downto  0) when "00",
                            led_bcd_in( 7 downto  4) when "01",
                            led_bcd_in(11 downto  8) when "10",
                            led_bcd_in(15 downto 12) when "11",
                            "XXXX" when others;
        
    bcd_demux: led_decoder
        port map(
            input => led_bcd_in_digit,
            output => led_segment
        );
        
    led_dp <= '1';

end Behavioral;
