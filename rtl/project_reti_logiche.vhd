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
        address_sel: in std_logic_vector(1 downto 0);
        total_load: in std_logic;
        word_load: in std_logic;
        convolute_start: in std_logic;
        convolute_rst: in std_logic;
        convolute_w: out std_logic;
        convolute_next: out std_logic;
        o_address: out std_logic_vector(15 downto 0);
        o_done: out std_logic;
        o_data: out std_logic_vector(7 downto 0)
    );
end datapath;

architecture Behavioral of datapath is
signal o_total: std_logic_vector(7 downto 0);
signal o_word: std_logic_vector(7 downto 0);
signal convolute_clk: std_logic;

signal o_bit3_counter: std_logic_vector(2 downto 0);
signal o_bit9_counter: std_logic_vector(8 downto 0);
signal o_shiftreg: std_logic_vector(7 downto 0);

signal i_convolute: std_logic;
signal o_convolute: std_logic_vector(1 downto 0);
type convolute_state is (S0, S1, S2, S3);
signal convolute_cur_state: convolute_state;
signal convolute_next_state: convolute_state;

signal read_addr: std_logic_vector(7 downto 0);
signal write_addr: std_logic_vector(15 downto 0);
begin
    convolute_clk <= convolute_start and i_clk;
    convolute_w <= o_bit3_counter(1) and (not o_bit3_counter(0));
    convolute_next <= o_bit3_counter(2) and o_bit3_counter(1) and (not o_bit3_counter(0));

    o_data <= o_shiftreg;
    o_done <= std_logic(o_total = o_bit9_counter(8 downto 1));

    read_addr <= "00000000" & std_logic_vector(unsigned(o_bit9_counter(8 downto 1)) + 1);
    write_addr <= std_logic_vector(unsigned(o_bit9_counter) + 999);
    with address_sel select
        o_address <= "0000000000000000" when "00",
                     read_addr when "01",
                     write_addr when "10",
                     "XXXXXXXXXXXXXXXX" when others;

    with o_bit3_counter select
        i_convolute <= o_word(0) when "000",
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
            if (total_load = '1') then
                o_total <= i_data;
            end if;
        end if;
    end process;

    word: process(i_clk, i_rst)
    begin
        if (i_rst = '1') then
            o_word <= "00000000";
        elsif (i_clk'event and i_clk = '1') then
            if (word_load = '1') then
                o_word <= i_data;
            end if;
        end if;
    end process;

    bit3_counter: process(convolute_clk, convolute_rst)
    begin
        if (convolute_rst = '1') then
            o_bit3_counter <= "000";
        elsif (convolute_clk'event and convolute_clk = '1') then
            o_bit3_counter <= std_logic_vector(unsigned(o_bit3_counter) + 1);
        end if;
    end process;

    bit9_counter: process(convolute_w, i_rst)
    begin
        if (i_rst = '1') then
            o_bit9_counter <= "000000000";
        elsif (convolute_w'event and convolute_w = '1') then
            o_bit9_counter <= std_logic_vector(unsigned(o_bit9_counter) + 1);
        end if;
    end process;

    shiftreg: process(i_clk, i_rst)
    begin
        if (i_rst = '1') then
            o_shiftreg <= "00000000";
        elsif (i_clk'event and i_clk = '1') then
            o_shiftreg <= o_convolute & o_shiftreg(7 downto 2);
        end if;
    end process;

    ---- convolution state machine ----
    convolute_reg: process (convolute_clk, convolute_rst)
    begin
        if(convolute_rst = '1') then
            convolute_cur_state <= S0;
        elsif convolute_clk'event and convolute_clk = '1' then
            convolute_cur_state <= convolute_next_state;
        end if;
    end process;

    convolute_next_out: process(convolute_cur_state, i_convolute)
    begin
        convolute_next_state  <= convolute_cur_state;
        case convolute_cur_state is
            when S0 =>
                if (i_convolute = '0') then
                    convolute_next_state <= S0;
                    o_convolute <= "00";
                elsif (i_convolute = '1') then
                    convolute_next_state <= S2;
                    o_convolute <= "11";
                end if;
            when S1 =>
                if (i_convolute = '0') then
                    convolute_next_state <= S0;
                    o_convolute <= "11";
                elsif (i_convolute = '1') then
                    convolute_next_state <= S2;
                    o_convolute <= "00";
                end if;
            when S2 =>
                if (i_convolute = '0') then
                    convolute_next_state <= S1;
                    o_convolute <= "01";
                elsif (i_convolute = '1') then
                    convolute_next_state <= S3;
                    o_convolute <= "10";
                end if;
            when S3 =>
                if (i_convolute = '0') then
                    convolute_next_state <= S1;
                    o_convolute <= "10";
                elsif (i_convolute = '1') then
                    convolute_next_state <= S3;
                    o_convolute <= "01";
                end if;
        end case;
    end process;
end Behavioral;
