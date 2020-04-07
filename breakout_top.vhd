library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity breakout_top is
	port(
		CLOCK_50 : in std_logic;
		KEY      : in std_logic_vector(2 downto 0);
		VGA_HS, VGA_VS : out std_logic;
		VGA_R, VGA_B, VGA_G : out std_logic_vector(2 downto 0)
	);
end breakout_top;

architecture arch of breakout_top is
	type state_type is (newgame, play, newball, over);
	signal video_on, pixel_tick : std_logic;
	signal pixel_x, pixel_y : std_logic_vector(9 downto 0);
	signal graph_on, gra_still, hit, miss : std_logic;
	signal text_on : std_logic_vector(2 downto 0);
	signal graph_rgb, text_rgb : std_logic_vector(2 downto 0);
	signal rgb_reg, rgb_next : std_logic_vector(2 downto 0);
	signal state_reg, state_next : state_type;
	signal dig0, dig1 : std_logic_vector(3 downto 0);
	signal d_inc, d_clr : std_logic;
	signal timer_tick, timer_start, timer_up : std_logic;
	signal ball_reg, ball_next : unsigned(1 downto 0);
	signal ball : std_logic_vector(1 downto 0);
	signal left_btn, right_btn : std_logic;
	signal control : std_logic_vector(1 downto 0);
begin
	vga_sync_unit : entity work.vga_sync
		port map(clk => CLOCK_50, reset => not(KEY(0)),
					video_on => video_on, p_tick => pixel_tick,
					hsync => VGA_HS, vsync => VGA_VS, 
					pixel_x => pixel_x, pixel_y => pixel_y);
	ball <= std_logic_vector(ball_reg);
	text_unit : entity work.breakout_text
		port map(clk => CLOCK_50, reset => not(KEY(0)),
					pixel_x => pixel_x, pixel_y => pixel_y,
					dig0 => dig0, dig1 => dig1, ball => ball,
					text_on => text_on, text_rgb => text_rgb);
	breakout_an_unit : entity work.breakout
		port map(clk => CLOCK_50, reset => not(KEY(0)), graph_on => graph_on, gra_still => gra_still,
					btn => control, video_on => video_on, hit => hit, miss => miss,
					pixel_x => pixel_x, pixel_y => pixel_y, graph_rgb => graph_rgb);
	left_btn_db_unit: entity work.debounce(fsmd_arch)
		port map(clk => CLOCK_50, reset => not(KEY(0)), sw => not(KEY(2)),
					db_level => left_btn, db_tick => open);
	right_btn_db_unit: entity work.debounce(fsmd_arch)
		port map(clk => CLOCK_50, reset => not(KEY(0)), sw => not(KEY(1)),
					db_level => right_btn, db_tick => open);
	timer_tick <= 
		'1' when pixel_x = "0000000000" and 
					pixel_y = "0000000000" else
		'0';
	timer_unit : entity work.timer
		port map(clk => CLOCK_50, reset => not(KEY(0)),
					timer_tick => timer_tick,
					timer_start => timer_start,
					timer_up => timer_up);
	counter_unit : entity work.m100_counter
		port map(clk => CLOCK_50, reset => not(KEY(0)),
		d_inc => d_inc, d_clr => d_clr, dig0 => dig0, dig1 => dig1);
	process(CLOCK_50, KEY(0))
	begin
		if KEY(0) = '0' then
			state_reg <= newgame;
			ball_reg <= (others => '0');
			rgb_reg <= (others => '0');
		elsif(CLOCK_50'event and CLOCK_50 = '1') then
			state_reg <= state_next;
			ball_reg <= ball_next;
			if (pixel_tick = '1') then
				rgb_reg <= rgb_next;
			end if;
		end if;
	end process;
	
	process(KEY(2 downto 1), hit, miss, timer_up, state_reg, ball_reg, ball_next)
	begin	
		timer_start <= '0';
		d_inc <= '0';
		d_clr <= '0';
		state_next <= state_reg;
		ball_next <= ball_reg;
		gra_still <= '1';
		case state_reg is
			when newgame =>
				ball_next <= "11";
				d_clr <= '1';
				if(not(KEY(2 DOWNTO 1)) /= "00") then
					state_next <= play;
					ball_next <= ball_reg - 1;
				end if;
			when play =>
				gra_still <= '0';
				if hit = '1' then
					d_inc <= '1';
				elsif miss = '1' then
					if(ball_reg = 0) then
						state_next <= over;
					else
						state_next <= newball;
					end if;
					timer_start <= '1';
					ball_next <= ball_reg-1;
				end if;
			when newball =>
				if timer_up = '1' and (not(KEY(2 downto 1)) /= "00") then
					state_next <= play;
				end if;
			when over =>
				if timer_up = '1' then
					state_next <= newgame;
				end if;
		end case;
	end process;
	
	process(state_reg, video_on, graph_on, graph_rgb, text_on, text_rgb)
	begin
		if video_on = '0' then
			rgb_next <= "000";
		else
			if(text_on(2) = '1') or
				(state_reg = newgame and text_on(1) = '1') or
				(state_reg = over and text_on(0) = '1') then
				rgb_next <= text_rgb;
			elsif graph_on = '1' then
				rgb_next <= graph_rgb;
			else
				rgb_next <= "000";
			end if;
		end if;
	end process;
	control <= left_btn & right_btn;
	VGA_R <= (others => rgb_reg(2));
	VGA_G <= (others => rgb_reg(1));
	VGA_B <= (others => rgb_reg(0));
end arch;



















