library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity testbench_6_words is
end testbench_6_words;

architecture Behavioural of testbench_6_words is
component project_reti_logiche is
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
end component;
constant c_CLOCK_PERIOD         : time := 100 ns;
signal   tb_done                : std_logic;
signal   mem_address            : std_logic_vector (15 downto 0) := (others => '0');
signal   tb_rst                 : std_logic := '0';
signal   tb_start               : std_logic := '0';
signal   tb_clk                 : std_logic := '0';
signal   mem_o_data,mem_i_data  : std_logic_vector (7 downto 0);
signal   enable_wire            : std_logic;
signal   mem_we                 : std_logic;

type ram_type is array (65535 downto 0) of std_logic_vector(7 downto 0);

-- Preloaded RAM
signal RAM: ram_type := (0 => std_logic_vector(to_unsigned(6, 8)),
                         1 => std_logic_vector(to_unsigned(163, 8)),
                         2 => std_logic_vector(to_unsigned(47, 8)), 
                         3 => std_logic_vector(to_unsigned(4, 8)), 
                         4 => std_logic_vector(to_unsigned(64, 8)), 
                         5 => std_logic_vector(to_unsigned(67, 8)), 
                         6 => std_logic_vector(to_unsigned(13, 8)), 
                         others => (others => '0'));
begin
    CMP: project_reti_logiche port map (
        i_clk     => tb_clk,
        i_start   => tb_start,
        i_rst     => tb_rst,
        i_data    => mem_o_data,
        o_address => mem_address,
        o_done    => tb_done,
        o_en   	  => enable_wire,
        o_we 	  => mem_we,
        o_data    => mem_i_data 
    );
    
    CLK : process is
    begin
        wait for c_CLOCK_PERIOD/2;
        tb_clk <= not tb_clk;
    end process CLK;
    
    MEM : process(tb_clk)
    begin
        if tb_clk'event and tb_clk = '1' then
            if enable_wire = '1' then
                if mem_we = '1' then
                    RAM(conv_integer(mem_address))  <= mem_i_data;
                    mem_o_data                      <= mem_i_data after 1 ns;
                else
                    mem_o_data <= RAM(conv_integer(mem_address)) after 1 ns;
                end if;
            end if;
        end if;
    end process;
    
    TEST: process
    begin
        tb_start <= '0';
        wait for 100 ns;
        wait for c_CLOCK_PERIOD;
        tb_rst <= '1';
        wait for c_CLOCK_PERIOD;
        wait for 100 ns;
        tb_rst <= '0';
        wait for c_CLOCK_PERIOD;
        wait for 100 ns;
        tb_start <= '1';
        wait for c_CLOCK_PERIOD;
        wait until tb_done = '1';
        wait for c_CLOCK_PERIOD;
        tb_start <= '0';
        wait until tb_done = '0';
        wait for 100 ns;
        
        assert RAM(1000) = std_logic_vector(to_unsigned(209, 8))
            report "E:1000 Expected 209 found" & 
                integer'image(to_integer(unsigned(RAM(1000))))
            severity failure;
        assert RAM(1001) = std_logic_vector(to_unsigned(206, 8))
            report "E:1001 Expected 206 found" & 
                integer'image(to_integer(unsigned(RAM(1001))))
            severity failure;
        assert RAM(1002) = std_logic_vector(to_unsigned(189, 8)) 
            report "E:1002 Expected 189 found" & 
                integer'image(to_integer(unsigned(RAM(1002))))
            severity failure;
        assert RAM(1003) = std_logic_vector(to_unsigned(37, 8))
            report "E:1003 Expected 37 found" &
                integer'image(to_integer(unsigned(RAM(1003))))
            severity failure;
        assert RAM(1004) = std_logic_vector(to_unsigned(176, 8))
            report "E:1004 Expected 176 found" &
                integer'image(to_integer(unsigned(RAM(1004))))
            severity failure;
        assert RAM(1005) = std_logic_vector(to_unsigned(55, 8))
            report "E:1005 Expected 55 found" &
                integer'image(to_integer(unsigned(RAM(1005))))
            severity failure;
        assert RAM(1006) = std_logic_vector(to_unsigned(55, 8))
            report "E:1006 Expected 55 found" &
                integer'image(to_integer(unsigned(RAM(1006))))
            severity failure;
        assert RAM(1007) = std_logic_vector(to_unsigned(0, 8))
            report "E:1007 Expected 0 found" &
                integer'image(to_integer(unsigned(RAM(1007))))
            severity failure;      
        assert RAM(1008) = std_logic_vector(to_unsigned(55, 8))
            report "E:1008 Expected 55 found" &
                integer'image(to_integer(unsigned(RAM(1008))))
            severity failure;      
        assert RAM(1009) = std_logic_vector(to_unsigned(14, 8))
            report "E:1009 Expected 14 found" &
                integer'image(to_integer(unsigned(RAM(1009))))
            severity failure;      
        assert RAM(1010) = std_logic_vector(to_unsigned(176, 8))
            report "E:1010 Expected 176 found" &
                integer'image(to_integer(unsigned(RAM(1010))))
            severity failure;      
        assert RAM(1011) = std_logic_vector(to_unsigned(232, 8))
            report "E:1011 Expected 232 found" &
                integer'image(to_integer(unsigned(RAM(1011))))
            severity failure;      
        assert RAM(1012) = std_logic_vector(to_unsigned(0, 8))
            report "E:1012 Expected 0 found" &
                integer'image(to_integer(unsigned(RAM(1012))))
            severity failure;      

        assert false
            report "Simulation Ended! TEST PASSATO"
            severity failure;
        end process;
end architecture;