library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity project_reti_logiche is
    port(
        i_clk     : in std_logic;
        i_rst     : in std_logic;
        i_start   : in std_logic;
        i_data    : in std_logic_vector(7 downto 0);
        o_address : out std_logic_vector(15 downto 0);
        o_done    : out std_logic;
        o_en      : out std_logic;
        o_we      : out std_logic;
        o_data    : out std_logic_vector(7 downto 0)
    );
end project_reti_logiche;

architecture Behavioural of project_reti_logiche is
component datapath is
    port(
        i_clk: in std_logic;
        i_rst: in std_logic;
        i_data: in std_logic_vector(7 downto 0);
        addr_sel: in std_logic_vector(1 downto 0);
        t_load: in std_logic;
        w_load: in std_logic;
        conv_start: in std_logic;
        count_start: in std_logic;
        conv_rst: in std_logic;
        conv_w: out std_logic;
        conv_next: out std_logic;
        o_address: out std_logic_vector(15 downto 0);
        o_end: out std_logic;
        o_data: out std_logic_vector(7 downto 0)
    );
end component;
signal addr_sel: std_logic_vector(1 downto 0);
signal t_load: std_logic;
signal w_load: std_logic;
signal conv_start: std_logic;
signal count_start: std_logic;
signal conv_rst: std_logic;
signal conv_w: std_logic;
signal conv_next: std_logic;
signal o_end : std_logic;

type state is (S0, S1, S2, S3, S4, S5, S6, S7);
signal cur_state, next_state: state;
begin
    dp: datapath port map(
        i_clk, i_rst, i_data, addr_sel, t_load, w_load, conv_start, count_start,
        conv_rst, conv_w, conv_next, o_address, o_end, o_data
    );

    process(i_clk, i_rst)
    begin
        if (i_rst = '1') then
            cur_state <= S0;
        elsif (i_clk'event and i_clk = '1') then
            cur_state <= next_state;
        end if;
    end process;

    process(cur_state, i_start, o_end, conv_w, conv_next)
    begin
        next_state <= cur_state;
        o_done <= '0';
        addr_sel <= "--";
        t_load <= '0';
        w_load <= '0';
        conv_start <= '0';
        count_start <= '0';
        conv_rst <= '0';
        o_en <= '0';
        o_we <= '-';
        case cur_state is
            when S0 =>
                if (i_start = '0') then
                    next_state <= S0;
                    o_done <= '0';
                    addr_sel <= "--";
                    t_load <= '0';
                    w_load <= '0';
                    conv_start <= '0';
                    count_start <= '0';
                    conv_rst <= '1';
                    o_en <= '0';
                    o_we <= '-';
                elsif (i_start = '1') then
                    next_state <= S1;
                    o_done <= '0';
                    addr_sel <= "00";
                    t_load <= '0';
                    w_load <= '0';
                    conv_start <= '0';
                    count_start <= '0';
                    conv_rst <= '1';
                    o_en <= '1';
                    o_we <= '0';
                end if;
            when S1 =>
                    next_state  <= S2;
                    o_done <= '0';
                    addr_sel <= "01";
                    t_load <= '1';
                    w_load <= '0';
                    conv_start <= '0';
                    count_start <= '0';
                    conv_rst <= '0';
                    o_en <= '1';
                    o_we <= '0';
            when S2 =>
                    if (o_end = '0') then
                        next_state <= S3;
                        o_done <= '0';
                        addr_sel <= "--";
                        t_load <= '0';
                        w_load <= '1';
                        conv_start <= '1';
                        count_start <= '1';
                        conv_rst <= '0';
                        o_en <= '0';
                        o_we <= '-';
                    elsif (o_end = '1') then
                        next_state <= S7;
                        o_done <= '0';
                        addr_sel <= "--";
                        t_load <= '0';
                        w_load <= '0';
                        conv_start <= '0';
                        count_start <= '0';
                        conv_rst <= '0';
                        o_en <= '0';
                        o_we <= '-';
                    end if;
            when S3 =>
                if (conv_w = '0' and conv_next = '0') then
                    next_state  <= S3;
                    o_done <= '0';
                    addr_sel <= "--";
                    t_load <= '0';
                    w_load <= '0';
                    conv_start <= '1';
                    count_start <= '1';
                    conv_rst <= '0';
                    o_en <= '0';
                    o_we <= '-';
                elsif (conv_w = '1' and conv_next = '0') then
                    next_state  <= S4;
                    o_done <= '0';
                    addr_sel <= "11";
                    t_load <= '0';
                    w_load <= '0';
                    conv_start <= '1';
                    count_start <= '1';
                    conv_rst <= '0';
                    o_en <= '0';
                    o_we <= '-';
                elsif (conv_w = '1' and conv_next = '1') then
                    next_state  <= S5;
                    o_done <= '0';
                    addr_sel <= "11";
                    t_load <= '0';
                    w_load <= '0';
                    conv_start <= '0';
                    count_start <= '0';
                    conv_rst <= '0';
                    o_en <= '0';
                    o_we <= '-';
                end if;
            when S4 =>
                next_state  <= S3;
                o_done <= '0';
                addr_sel <= "11";
                t_load <= '0';
                w_load <= '0';
                conv_start <= '1';
                count_start <= '1';
                conv_rst <= '0';
                o_en <= '1';
                o_we <= '1';
            when S5 =>
                if (o_end = '0') then
                    next_state  <= S6;
                    o_done <= '0';
                    addr_sel <= "11";
                    t_load <= '0';
                    w_load <= '0';
                    conv_start <= '0';
                    count_start <= '0';
                    conv_rst <= '0';
                    o_en <= '1';
                    o_we <= '1';
                elsif (o_end = '1') then
                    next_state  <= S7;
                    o_done <= '0';
                    addr_sel <= "11";
                    t_load <= '0';
                    w_load <= '0';
                    conv_start <= '0';
                    count_start <= '0';
                    conv_rst <= '0';
                    o_en <= '1';
                    o_we <= '1';
                end if;
            when S6 =>
                next_state <= S2;
                o_done <= '0';
                addr_sel <= "01";
                t_load <= '0';
                w_load <= '0';
                conv_start <= '0';
                count_start <= '0';
                conv_rst <= '0';
                o_en <= '1';
                o_we <= '0';
            when S7 =>
                if (i_start = '0') then
                    next_state <= S0;
                    o_done <= '1';
                    addr_sel <= "--";
                    t_load <= '0';
                    w_load <= '0';
                    conv_start <= '0';
                    count_start <= '0';
                    conv_rst <= '1';
                    o_en <= '0';
                    o_we <= '-';
                elsif (i_start = '1') then
                    next_state <= S7;
                    o_done <= '1';
                    addr_sel <= "--";
                    t_load <= '0';
                    w_load <= '0';
                    conv_start <= '0';
                    count_start <= '0';
                    conv_rst <= '1';
                    o_en <= '0';
                    o_we <= '-';
                end if;
        end case;
    end process;
end Behavioural;

-------------------------------------------------------------------------------
-- Datapath
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity datapath is
    port(
        i_clk: in std_logic;
        i_rst: in std_logic;
        i_data: in std_logic_vector(7 downto 0);
        addr_sel: in std_logic_vector(1 downto 0);
        t_load: in std_logic;
        w_load: in std_logic;
        conv_start: in std_logic;
        count_start: in std_logic;
        conv_rst: in std_logic;
        conv_w: out std_logic;
        conv_next: out std_logic;
        o_address: out std_logic_vector(15 downto 0);
        o_end: out std_logic;
        o_data: out std_logic_vector(7 downto 0)
    );
end datapath;

architecture Behavioural of datapath is
signal rst: std_logic;

signal o_total: std_logic_vector(7 downto 0);
signal o_word: std_logic_vector(0 to 7);

signal pre_conv_w: std_logic;

signal o_bit3_counter: std_logic_vector(2 downto 0);
signal o_bit9_counter: std_logic_vector(8 downto 0);
signal o_shiftreg: std_logic_vector(0 to 7);

signal i_conv: std_logic;
signal o_conv: std_logic_vector(1 downto 0);
type conv_state is (S0, S1, S2, S3);
signal conv_cur_state, conv_next_state: conv_state;
begin
    rst <= i_rst or conv_rst;

    pre_conv_w <= o_bit3_counter(1) and o_bit3_counter(0);
    conv_w <= pre_conv_w;
    conv_next <= o_bit3_counter(2) and o_bit3_counter(1) and o_bit3_counter(0);

    o_data <= o_shiftreg;
    o_end <= '1' when o_total = o_bit9_counter(8 downto 1) else '0';

    with addr_sel select
        o_address <= "0000000000000000" when "00",
                     (o_bit9_counter(8 downto 1) + "0000000000000001") when "01",
                     (o_bit9_counter + "0000001111100111") when "11", -- +999
                     "XXXXXXXXXXXXXXXX" when others;

    with o_bit3_counter select
        i_conv <= o_word(0) when "000",
                  o_word(1) when "001",
                  o_word(2) when "010",
                  o_word(3) when "011",
                  o_word(4) when "100",
                  o_word(5) when "101",
                  o_word(6) when "110",
                  o_word(7) when "111",
                  'X' when others;

    total: process(i_clk, i_rst)
    begin
        if (i_rst = '1') then
            o_total <= "00000000";
        elsif (i_clk'event and i_clk = '1') then
            if (t_load = '1') then
                o_total <= i_data;
            end if;
        end if;
    end process;

    word: process(i_clk, i_rst)
    begin
        if (i_rst = '1') then
            o_word <= "00000000";
        elsif (i_clk'event and i_clk = '1') then
            if (w_load = '1') then
                o_word <= i_data;
            end if;
        end if;
    end process;

    bit3_counter: process(i_clk, rst)
    begin
        if (rst = '1') then
            o_bit3_counter <= "111";
        elsif (i_clk'event and i_clk = '1' and count_start = '1') then
            o_bit3_counter <= o_bit3_counter + 1;
        end if;
    end process;

    bit9_counter: process(pre_conv_w, rst)
    begin
        if (rst = '1') then
            o_bit9_counter <= "000000000";
        elsif (pre_conv_w'event and pre_conv_w = '1') then
            o_bit9_counter <= o_bit9_counter + 1;
        end if;
    end process;

    shiftreg: process(i_clk, i_rst)
    begin
        if (i_rst = '1') then
            o_shiftreg <= "00000000";
        elsif (i_clk'event and i_clk = '1') then
            o_shiftreg <= o_shiftreg(2 to 7) & o_conv;
        end if;
    end process;

    ---- convolution state machine ----
    conv_reg: process (i_clk, rst)
    begin
        if(rst = '1') then
            conv_cur_state <= S0;
        elsif (i_clk'event and i_clk = '1' and conv_start = '1') then
            conv_cur_state <= conv_next_state;
        end if;
    end process;

    conv_next_out: process(conv_cur_state, i_conv)
    begin
        conv_next_state  <= conv_cur_state;
        case conv_cur_state is
            when S0 =>
                if (i_conv = '0') then
                    conv_next_state <= S0;
                    o_conv <= "00";
                elsif (i_conv = '1') then
                    conv_next_state <= S2;
                    o_conv <= "11";
                end if;
            when S1 =>
                if (i_conv = '0') then
                    conv_next_state <= S0;
                    o_conv <= "11";
                elsif (i_conv = '1') then
                    conv_next_state <= S2;
                    o_conv <= "00";
                end if;
            when S2 =>
                if (i_conv = '0') then
                    conv_next_state <= S1;
                    o_conv <= "01";
                elsif (i_conv = '1') then
                    conv_next_state <= S3;
                    o_conv <= "10";
                end if;
            when S3 =>
                if (i_conv = '0') then
                    conv_next_state <= S1;
                    o_conv <= "10";
                elsif (i_conv = '1') then
                    conv_next_state <= S3;
                    o_conv <= "01";
                end if;
        end case;
    end process;
end Behavioural;
