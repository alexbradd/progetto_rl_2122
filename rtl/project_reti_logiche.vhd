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
        o_data    : in std_logic_vector(7 downto 0)
    );
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
begin
end Behavioral;

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
signal conv_clk : std_logic;
signal count_clk : std_logic;
signal rst: std_logic;

signal o_total: std_logic_vector(7 downto 0);
signal o_word: std_logic_vector(7 downto 0);

signal o_bit3_counter: std_logic_vector(2 downto 0);
signal o_bit9_counter: std_logic_vector(8 downto 0);
signal o_shiftreg: std_logic_vector(7 downto 0);

signal read_addr: std_logic_vector(15 downto 0);
signal write_addr: std_logic_vector(15 downto 0);

signal i_conv: std_logic;
signal o_conv: std_logic_vector(1 downto 0);
type conv_state is (S0, S1, S2, S3);
signal conv_cur_state, conv_next_state: conv_state;
begin
    conv_clk <= i_clk and conv_start;
    count_clk <= i_clk and count_start;
    rst <= i_rst or conv_rst;
    
    conv_w <= o_bit3_counter(1) and o_bit3_counter(0);
    conv_next <= o_bit3_counter(2) and o_bit3_counter(1) and o_bit3_counter(0);

    o_data <= o_shiftreg;
    o_end <= std_logic(o_total = o_bit9_counter(8 downto 1));

    read_addr <= "00000000" & std_logic_vector(unsigned(o_bit9_counter(8 downto 1)) + 1);
    write_addr <= std_logic_vector(unsigned(o_bit9_counter) + 999);
    with addr_sel select
        o_address <= "0000000000000000" when "00",
                     read_addr when "01",
                     write_addr when "10",
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

    bit3_counter: process(count_clk, rst)
    begin
        if (rst = '1') then
            o_bit3_counter <= "000";
        elsif (count_clk'event and count_clk = '1') then
            o_bit3_counter <= std_logic_vector(unsigned(o_bit3_counter) + 1);
        end if;
    end process;

    bit9_counter: process(conv_w, rst)
    begin
        if (rst = '1') then
            o_bit9_counter <= "000000000";
        elsif (conv_w'event and conv_w = '1') then
            o_bit9_counter <= std_logic_vector(unsigned(o_bit9_counter) + 1);
        end if;
    end process;

    shiftreg: process(i_clk, i_rst)
    begin
        if (i_rst = '1') then
            o_shiftreg <= "00000000";
        elsif (i_clk'event and i_clk = '1') then
            o_shiftreg <= o_conv & o_shiftreg(7 downto 2);
        end if;
    end process;

    ---- convolution state machine ----
    conv_reg: process (conv_clk, rst)
    begin
        if(rst = '1') then
            conv_cur_state <= S0;
        elsif conv_clk'event and conv_clk = '1' then
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
