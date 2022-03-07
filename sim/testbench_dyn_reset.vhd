library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;
use ieee.std_logic_textio.all;
use STD.textio.all;

entity testbench_dyn_reset is
    generic(file_path: string := "ram_contents");
end testbench_dyn_reset;

architecture Behavioural of testbench_dyn_reset is
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
    
    type ram_type is array (1600 downto 0) of std_logic_vector(7 downto 0);
    signal RAM: ram_type;
    signal TARGET: ram_type;
    signal f_read: boolean := false;
    signal f_read_done: boolean := false;
    shared variable num: integer;
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
    end process;
    
    MEM : process(tb_clk)
        file input: text open read_mode is file_path;
        variable l: line;
        variable n: integer;
    begin
        if tb_clk'event and tb_clk = '1' then
            if (f_read) then
                readline(input, l);
                read(l, num);
                for i in 0 to 1600 loop
                    RAM(i) <= std_logic_vector(to_unsigned(0, 8));
                    TARGET(i) <= std_logic_vector(to_unsigned(0, 8));
                end loop;

                RAM(0) <= std_logic_vector(to_unsigned(num, 8));
                TARGET(0) <= std_logic_vector(to_unsigned(num, 8));
                for i in 1 to num loop
                    readline(input, l);
                    read(l, n);
                    RAM(i) <= std_logic_vector(to_unsigned(n, 8));
                    TARGET(i) <= std_logic_vector(to_unsigned(n, 8));
                end loop;
                for i in 0 to (2 * num - 1) loop
                    readline(input, l);
                    read(l, n);
                    TARGET(1000 + i) <= std_logic_vector(to_unsigned(n, 8));
                end loop;

                if endfile(input) then
                    f_read_done <= true;
                end if;
            elsif (enable_wire = '1') then
                if (mem_we = '1') then
                    RAM(conv_integer(mem_address))  <= mem_i_data;
                    mem_o_data                      <= mem_i_data after 2 ns;
                else
                    mem_o_data <= RAM(conv_integer(mem_address)) after 2 ns;
                end if;
            end if;
        end if;
    end process;
    
    TEST: process
        variable count: integer := 0;
        variable passed: boolean := true;
    begin     
        loop
            count := count + 1;
            if (f_read_done) then exit; end if;
            
            f_read <= true;
            wait for c_CLOCK_PERIOD;
            f_read <= false;
            wait for c_CLOCK_PERIOD;
           
            tb_rst <= '1';
            wait for c_CLOCK_PERIOD;
            tb_rst <= '0';
            wait for c_CLOCK_PERIOD;

            tb_start <= '1';
            wait until tb_done = '1';
            tb_start <= '0';
            wait until tb_done = '0';
            wait for c_CLOCK_PERIOD;

            for i in 0 to 1600 loop
                if (RAM(i) /= TARGET(i)) then
                    passed := false;
                    report integer'image(count) & ") KO: at " &
                        integer'image(i) & " expected " &
                        integer'image(to_integer(unsigned(TARGET(i)))) &
                        " and found " & integer'image(to_integer(unsigned(RAM(i))))
                        severity warning;
                    exit;
                end if;
            end loop;
            
            if (passed) then
                report integer'image(count) & ") OK" severity note;
            end if;
            passed := true;
        end loop;
        std.env.finish;
    end process;
end Behavioural;
