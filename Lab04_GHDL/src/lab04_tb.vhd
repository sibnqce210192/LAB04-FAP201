library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity lab04_tb is end entity;
architecture sim of lab04_tb is
 constant T : time := 20 ns; -- clock mô phỏng 50 MHz
 signal clk : std_logic := '0';
 signal i_sw_raw : std_logic := '0';
 signal i_rst : std_logic := '1';
 signal o_led, o_dbg_stable : std_logic;
begin
 clk <= not clk after T/2;
 dut: entity work.lab04
 generic map (STABLE_CYCLES => 5) -- CHỈ TB
 port map (clk, i_sw_raw, i_rst, o_led, o_dbg_stable);
 stimulus: process
 begin
 wait for 5*T;
 i_rst <= '0';
 wait for 4*T;
 assert o_led='0' report "T0 reset FAIL" severity error;
 -- T1: xung nhiễu 1 cycle, không đủ N
 i_sw_raw <= '1'; wait for T;
 i_sw_raw <= '0'; wait for 12*T;
 assert o_dbg_stable='0' report "T1 bounce FAIL" severity error;
 assert o_led='0' report "T1 LED FAIL" severity error;
 -- T2: nhấn ổn định → stable=1, LED vẫn tắt
 i_sw_raw <= '1'; wait for 18*T;
 assert o_dbg_stable='1' report "T2 press FAIL" severity error;
 assert o_led='0' report "T2 LED FAIL" severity error;
 -- T3: giữ nút lâu → không toggle
 wait for 20*T;
 assert o_led='0' report "T3 hold FAIL" severity error;
 -- T4: nhả có bounce → chỉ chấp nhận sau ổn định
 i_sw_raw <= '0'; wait for T;
 i_sw_raw <= '1'; wait for T;
 i_sw_raw <= '0'; wait for 18*T;
 assert o_dbg_stable='0' report "T4 release FAIL" severity error;
 assert o_led='1' report "T4 toggle FAIL" severity error;
 -- T5: giữ nhả / lặp lại nhấn–nhả
 wait for 16*T;
 assert o_led='1' report "T5 extra toggle FAIL" severity error;
 i_sw_raw <= '1'; wait for 18*T;
 i_sw_raw <= '0'; wait for 18*T;
 assert o_led='0' report "T5 second toggle FAIL" severity error;
 report "LAB04 TB PASS" severity note;
 wait;
 end process;
end architecture;