library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity lab04 is
 generic (STABLE_CYCLES : positive := 1_000_000);
 port (
 clk : in std_logic;
 i_sw_raw : in std_logic;
 i_rst : in std_logic;
 o_led : out std_logic;
 o_dbg_stable : out std_logic
 );
end entity lab04;
architecture rtl of lab04 is
 -- A. Tự tính độ rộng counter (ít nhất 1 bit)
 function clog2(n : positive) return natural is
 variable v : natural := n - 1;
 variable b : natural := 0;
 begin
 while v > 0 loop
 v := v / 2;
 b := b + 1;
 end loop;
 if b = 0 then return 1; else return b; end if;
 end function;
 constant COUNT_BITS : natural := clog2(STABLE_CYCLES);
 constant LAST_COUNT : unsigned(COUNT_BITS-1 downto 0) :=
 to_unsigned(STABLE_CYCLES - 1, COUNT_BITS);
 signal sw_sync1, sw_sync2 : std_logic;
 signal sw_stable : std_logic;
 signal stable_count : unsigned(COUNT_BITS-1 downto 0);
 signal evt_cur, evt_prev : std_logic;
 signal release_event : std_logic;
 signal led_state : std_logic;
begin
 -- B + C. Synchronizer + counter filter
 process(clk)
 begin
 if rising_edge(clk) then
 if i_rst = '1' then
 sw_sync1 <= '0';
 sw_sync2 <= '0';
 sw_stable <= '0';
 stable_count <= (others => '0');
 else
 sw_sync1 <= i_sw_raw;
 sw_sync2 <= sw_sync1;
 if sw_sync2 = sw_stable then
 stable_count <= (others => '0');
 elsif stable_count = LAST_COUNT then
 sw_stable <= sw_sync2;
 stable_count <= (others => '0');
 else
 stable_count <= stable_count + 1;
 end if;
 end if;
 end if;
 end process;
 -- D. 1 → 0 sau debounce
 release_event <= evt_prev and (not evt_cur);
 -- E. FF lưu trạng thái LED / reset đồng bộ
 process(clk)
 begin
 if rising_edge(clk) then
 if i_rst = '1' then
 evt_prev <= '0';
 evt_cur <= '0';
 led_state <= '0';
 else
 evt_prev <= evt_cur;
 evt_cur <= sw_stable;
 if release_event = '1' then
 led_state <= not led_state;
 end if;
 end if;
 end if;
 end process;
 o_led <= led_state;
 o_dbg_stable <= sw_stable;
end architecture rtl;