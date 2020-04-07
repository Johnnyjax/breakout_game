library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity breakout is
	port(
		clk, reset : std_logic;
		btn : std_logic_vector(1 downto 0);
		video_on : in std_logic;
		pixel_x, pixel_y : in std_logic_vector(9 downto 0);
		gra_still : in std_logic;
		hit, miss : out std_logic;
		graph_on : out std_logic;
		graph_rgb : out std_logic_vector(2 downto 0)
	);
end breakout;

architecture arch of breakout is
	signal refr_tick : std_logic;
	signal pix_x, pix_y : unsigned(9 downto 0);
	
	constant MAX_X : integer := 640;
	constant MAX_Y : integer := 480;
	
	-- Wall boundary definitions
	constant WALL_LEFT_X_L : integer := 150;
	constant WALL_LEFT_X_R : integer := 154;
	constant WALL_RIGHT_X_L : integer := 490;
	constant WALL_RIGHT_X_R : integer := 494;
	constant WALL_TOP_Y_T : integer := 3;
	constant WALL_TOP_Y_B : integer := 20;
	
	-- paddle dimensions
	constant BAR_Y_T : integer:= 460;
	constant BAR_Y_B : integer := 468;
	
	signal bar_x_l, bar_x_r : unsigned(9 downto 0);
	constant BAR_X_WIDTH : integer:= 20;
	signal bar_x_reg, bar_x_next : unsigned(9 downto 0):= to_unsigned(310, 10);
	constant BAR_V : integer := 2;
	
	constant BALL_V_P : unsigned(9 downto 0) := to_unsigned(1, 10);
	constant BALL_V_N : unsigned(9 downto 0) := to_unsigned(-1, 10);
	
	constant BALL_SIZE : integer:= 5;
	signal ball_x_l, ball_x_r : unsigned(9 downto 0);
	signal ball_y_t, ball_y_b : unsigned(9 downto 0);
	signal ball_x_reg, ball_x_next : unsigned(9 downto 0):= to_unsigned(310, 10);
	signal ball_y_reg, ball_y_next : unsigned(9 downto 0) :=to_unsigned(250, 10);
	signal x_delta_reg, x_delta_next : unsigned(9 downto 0) := BALL_V_P;
	signal y_delta_reg, y_delta_next : unsigned(9 downto 0):= BALL_V_P;

	constant BLOCK_WIDTH : integer := 20;
	constant BLOCK_HEIGHT : integer := 10;
	
	constant BLOCK1_L : integer := 155;
	constant BLOCK1_R : integer := BLOCK1_L + BLOCK_WIDTH;
	constant BLOCK1_T : integer := 100;
	constant BLOCK1_B : integer := 100 + BLOCK_HEIGHT;
	
	constant BLOCK2_L : integer := BLOCK1_R + 4;
	constant BLOCK2_R : integer := BLOCK2_L + BLOCK_WIDTH;
	constant BLOCK2_T : integer := 100;
	constant BLOCK2_B : integer := 100 + BLOCK_HEIGHT;
	
	constant BLOCK3_L : integer := BLOCK2_R + 4;
	constant BLOCK3_R : integer := BLOCK3_L + BLOCK_WIDTH;
	constant BLOCK3_T : integer := 100;
	constant BLOCK3_B : integer := 100 + BLOCK_HEIGHT;
	
	constant BLOCK4_L : integer := BLOCK3_R + 4;
	constant BLOCK4_R : integer := BLOCK4_L + BLOCK_WIDTH;
	constant BLOCK4_T : integer := 100;
	constant BLOCK4_B : integer := 100 + BLOCK_HEIGHT;
	
	constant BLOCK5_L : integer := BLOCK4_R + 4;
	constant BLOCK5_R : integer := BLOCK5_L + BLOCK_WIDTH;
	constant BLOCK5_T : integer := 100;
	constant BLOCK5_B : integer := 100 + BLOCK_HEIGHT;
	
	constant BLOCK6_L : integer := BLOCK5_R + 4;
	constant BLOCK6_R : integer := BLOCK6_L + BLOCK_WIDTH;
	constant BLOCK6_T : integer := 100;
	constant BLOCK6_B : integer := 100 + BLOCK_HEIGHT;
	
	constant BLOCK7_L : integer := BLOCK6_R + 4;
	constant BLOCK7_R : integer := BLOCK7_L + BLOCK_WIDTH;
	constant BLOCK7_T : integer := 100;
	constant BLOCK7_B : integer := 100 + BLOCK_HEIGHT;
	
	constant BLOCK8_L : integer := BLOCK7_R + 4;
	constant BLOCK8_R : integer := BLOCK8_L + BLOCK_WIDTH;
	constant BLOCK8_T : integer := 100;
	constant BLOCK8_B : integer := 100 + BLOCK_HEIGHT;
	
	constant BLOCK9_L : integer := BLOCK8_R + 4;
	constant BLOCK9_R : integer := BLOCK9_L + BLOCK_WIDTH;
	constant BLOCK9_T : integer := 100;
	constant BLOCK9_B : integer := 100 + BLOCK_HEIGHT;
	
	constant BLOCK10_L : integer := BLOCK9_R + 4;
	constant BLOCK10_R : integer := BLOCK10_L + BLOCK_WIDTH;
	constant BLOCK10_T : integer := 100;
	constant BLOCK10_B : integer := 100 + BLOCK_HEIGHT;
	
	constant BLOCK11_L : integer := BLOCK10_R + 4;
	constant BLOCK11_R : integer := BLOCK11_L + BLOCK_WIDTH;
	constant BLOCK11_T : integer := 100;
	constant BLOCK11_B : integer := 100 + BLOCK_HEIGHT;
	
	constant BLOCK12_L : integer := BLOCK11_R + 4;
	constant BLOCK12_R : integer := BLOCK12_L + BLOCK_WIDTH;
	constant BLOCK12_T : integer := 100;
	constant BLOCK12_B : integer := 100 + BLOCK_HEIGHT;
	
	constant BLOCK13_L : integer := BLOCK12_R + 4;
	constant BLOCK13_R : integer := BLOCK13_L + BLOCK_WIDTH;
	constant BLOCK13_T : integer := 100;
	constant BLOCK13_B : integer := 100 + BLOCK_HEIGHT;
	
	constant BLOCK14_L : integer := BLOCK13_R + 4;
	constant BLOCK14_R : integer := BLOCK14_L + BLOCK_WIDTH;
	constant BLOCK14_T : integer := 100;
	constant BLOCK14_B : integer := 100 + BLOCK_HEIGHT;
	
	constant BLOCK15_L : integer := 155;
	constant BLOCK15_R : integer := BLOCK15_L + BLOCK_WIDTH;
	constant BLOCK15_T : integer := 114;
	constant BLOCK15_B : integer := 114 + BLOCK_HEIGHT;
	
	constant BLOCK16_L : integer := BLOCK15_R + 4;
	constant BLOCK16_R : integer := BLOCK16_L + BLOCK_WIDTH;
	constant BLOCK16_T : integer := 114;
	constant BLOCK16_B : integer := 114 + BLOCK_HEIGHT;
	
	constant BLOCK17_L : integer := BLOCK16_R + 4;
	constant BLOCK17_R : integer := BLOCK17_L + BLOCK_WIDTH;
	constant BLOCK17_T : integer := 114;
	constant BLOCK17_B : integer := 114 + BLOCK_HEIGHT;
	
	constant BLOCK18_L : integer := BLOCK17_R + 4;
	constant BLOCK18_R : integer := BLOCK18_L + BLOCK_WIDTH;
	constant BLOCK18_T : integer := 114;
	constant BLOCK18_B : integer := 114 + BLOCK_HEIGHT;
	
	constant BLOCK19_L : integer := BLOCK18_R + 4;
	constant BLOCK19_R : integer := BLOCK19_L + BLOCK_WIDTH;
	constant BLOCK19_T : integer := 114;
	constant BLOCK19_B : integer := 114 + BLOCK_HEIGHT;
	
	constant BLOCK20_L : integer := BLOCK19_R + 4;
	constant BLOCK20_R : integer := BLOCK20_L + BLOCK_WIDTH;
	constant BLOCK20_T : integer := 114;
	constant BLOCK20_B : integer := 114 + BLOCK_HEIGHT;
	
	constant BLOCK21_L : integer := BLOCK20_R + 4;
	constant BLOCK21_R : integer := BLOCK21_L + BLOCK_WIDTH;
	constant BLOCK21_T : integer := 114;
	constant BLOCK21_B : integer := 114 + BLOCK_HEIGHT;
	
	constant BLOCK22_L : integer := BLOCK21_R + 4;
	constant BLOCK22_R : integer := BLOCK22_L + BLOCK_WIDTH;
	constant BLOCK22_T : integer := 114;
	constant BLOCK22_B : integer := 114 + BLOCK_HEIGHT;
	
	constant BLOCK23_L : integer := BLOCK22_R + 4;
	constant BLOCK23_R : integer := BLOCK23_L + BLOCK_WIDTH;
	constant BLOCK23_T : integer := 114;
	constant BLOCK23_B : integer := 114 + BLOCK_HEIGHT;
	
	constant BLOCK24_L : integer := BLOCK23_R + 4;
	constant BLOCK24_R : integer := BLOCK24_L + BLOCK_WIDTH;
	constant BLOCK24_T : integer := 114;
	constant BLOCK24_B : integer := 114 + BLOCK_HEIGHT;
	
	constant BLOCK25_L : integer := BLOCK24_R + 4;
	constant BLOCK25_R : integer := BLOCK25_L + BLOCK_WIDTH;
	constant BLOCK25_T : integer := 114;
	constant BLOCK25_B : integer := 114 + BLOCK_HEIGHT;
	
	constant BLOCK26_L : integer := BLOCK25_R + 4;
	constant BLOCK26_R : integer := BLOCK26_L + BLOCK_WIDTH;
	constant BLOCK26_T : integer := 114;
	constant BLOCK26_B : integer := 114 + BLOCK_HEIGHT;
	
	constant BLOCK27_L : integer := BLOCK26_R + 4;
	constant BLOCK27_R : integer := BLOCK27_L + BLOCK_WIDTH;
	constant BLOCK27_T : integer := 114;
	constant BLOCK27_B : integer := 114 + BLOCK_HEIGHT;
	
	constant BLOCK28_L : integer := BLOCK27_R + 4;
	constant BLOCK28_R : integer := BLOCK28_L + BLOCK_WIDTH;
	constant BLOCK28_T : integer := 114;
	constant BLOCK28_B : integer := 114 + BLOCK_HEIGHT;
	
	constant BLOCK29_L : integer := 155;
	constant BLOCK29_R : integer := BLOCK29_L + BLOCK_WIDTH;
	constant BLOCK29_T : integer := 128;
	constant BLOCK29_B : integer := 128 + BLOCK_HEIGHT;
	
	constant BLOCK30_L : integer := BLOCK29_R + 4;
	constant BLOCK30_R : integer := BLOCK30_L + BLOCK_WIDTH;
	constant BLOCK30_T : integer := 128;
	constant BLOCK30_B : integer := 128 + BLOCK_HEIGHT;
	
	constant BLOCK31_L : integer := BLOCK30_R + 4;
	constant BLOCK31_R : integer := BLOCK31_L + BLOCK_WIDTH;
	constant BLOCK31_T : integer := 128;
	constant BLOCK31_B : integer := 128 + BLOCK_HEIGHT;
	
	constant BLOCK32_L : integer := BLOCK31_R + 4;
	constant BLOCK32_R : integer := BLOCK32_L + BLOCK_WIDTH;
	constant BLOCK32_T : integer := 128;
	constant BLOCK32_B : integer := 128 + BLOCK_HEIGHT;
	
	constant BLOCK33_L : integer := BLOCK32_R + 4;
	constant BLOCK33_R : integer := BLOCK33_L + BLOCK_WIDTH;
	constant BLOCK33_T : integer := 128;
	constant BLOCK33_B : integer := 128 + BLOCK_HEIGHT;
	
	constant BLOCK34_L : integer := BLOCK33_R + 4;
	constant BLOCK34_R : integer := BLOCK34_L + BLOCK_WIDTH;
	constant BLOCK34_T : integer := 128;
	constant BLOCK34_B : integer := 128 + BLOCK_HEIGHT;
	
	constant BLOCK35_L : integer := BLOCK34_R + 4;
	constant BLOCK35_R : integer := BLOCK35_L + BLOCK_WIDTH;
	constant BLOCK35_T : integer := 128;
	constant BLOCK35_B : integer := 128 + BLOCK_HEIGHT;
	
	constant BLOCK36_L : integer := BLOCK35_R + 4;
	constant BLOCK36_R : integer := BLOCK36_L + BLOCK_WIDTH;
	constant BLOCK36_T : integer := 128;
	constant BLOCK36_B : integer := 128 + BLOCK_HEIGHT;
	
	constant BLOCK37_L : integer := BLOCK36_R + 4;
	constant BLOCK37_R : integer := BLOCK37_L + BLOCK_WIDTH;
	constant BLOCK37_T : integer := 128;
	constant BLOCK37_B : integer := 128 + BLOCK_HEIGHT;
	
	constant BLOCK38_L : integer := BLOCK37_R + 4;
	constant BLOCK38_R : integer := BLOCK38_L + BLOCK_WIDTH;
	constant BLOCK38_T : integer := 128;
	constant BLOCK38_B : integer := 128 + BLOCK_HEIGHT;
	
	constant BLOCK39_L : integer := BLOCK38_R + 4;
	constant BLOCK39_R : integer := BLOCK39_L + BLOCK_WIDTH;
	constant BLOCK39_T : integer := 128;
	constant BLOCK39_B : integer := 128 + BLOCK_HEIGHT;
	
	constant BLOCK40_L : integer := BLOCK39_R + 4;
	constant BLOCK40_R : integer := BLOCK40_L + BLOCK_WIDTH;
	constant BLOCK40_T : integer := 128;
	constant BLOCK40_B : integer := 128 + BLOCK_HEIGHT;
	
	constant BLOCK41_L : integer := BLOCK40_R + 4;
	constant BLOCK41_R : integer := BLOCK41_L + BLOCK_WIDTH;
	constant BLOCK41_T : integer := 128;
	constant BLOCK41_B : integer := 128 + BLOCK_HEIGHT;
	
	constant BLOCK42_L : integer := BLOCK41_R + 4;
	constant BLOCK42_R : integer := BLOCK42_L + BLOCK_WIDTH;
	constant BLOCK42_T : integer := 128;
	constant BLOCK42_B : integer := 128 + BLOCK_HEIGHT;
	
	constant BLOCK43_L : integer := 155;
	constant BLOCK43_R : integer := BLOCK43_L + BLOCK_WIDTH;
	constant BLOCK43_T : integer := 142;
	constant BLOCK43_B : integer := 142 + BLOCK_HEIGHT;
	
	constant BLOCK44_L : integer := BLOCK43_R + 4;
	constant BLOCK44_R : integer := BLOCK44_L + BLOCK_WIDTH;
	constant BLOCK44_T : integer := 142;
	constant BLOCK44_B : integer := 142 + BLOCK_HEIGHT;
	
	constant BLOCK45_L : integer := BLOCK44_R + 4;
	constant BLOCK45_R : integer := BLOCK45_L + BLOCK_WIDTH;
	constant BLOCK45_T : integer := 142;
	constant BLOCK45_B : integer := 142 + BLOCK_HEIGHT;
	
	constant BLOCK46_L : integer := BLOCK45_R + 4;
	constant BLOCK46_R : integer := BLOCK46_L + BLOCK_WIDTH;
	constant BLOCK46_T : integer := 142;
	constant BLOCK46_B : integer := 142 + BLOCK_HEIGHT;
	
	constant BLOCK47_L : integer := BLOCK46_R + 4;
	constant BLOCK47_R : integer := BLOCK47_L + BLOCK_WIDTH;
	constant BLOCK47_T : integer := 142;
	constant BLOCK47_B : integer := 142 + BLOCK_HEIGHT;
	
	constant BLOCK48_L : integer := BLOCK47_R + 4;
	constant BLOCK48_R : integer := BLOCK48_L + BLOCK_WIDTH;
	constant BLOCK48_T : integer := 142;
	constant BLOCK48_B : integer := 142 + BLOCK_HEIGHT;
	
	constant BLOCK49_L : integer := BLOCK48_R + 4;
	constant BLOCK49_R : integer := BLOCK49_L + BLOCK_WIDTH;
	constant BLOCK49_T : integer := 142;
	constant BLOCK49_B : integer := 142 + BLOCK_HEIGHT;
	
	constant BLOCK50_L : integer := BLOCK49_R + 4;
	constant BLOCK50_R : integer := BLOCK50_L + BLOCK_WIDTH;
	constant BLOCK50_T : integer := 142;
	constant BLOCK50_B : integer := 142 + BLOCK_HEIGHT;
	
	constant BLOCK51_L : integer := BLOCK50_R + 4;
	constant BLOCK51_R : integer := BLOCK51_L + BLOCK_WIDTH;
	constant BLOCK51_T : integer := 142;
	constant BLOCK51_B : integer := 142 + BLOCK_HEIGHT;
	
	constant BLOCK52_L : integer := BLOCK51_R + 4;
	constant BLOCK52_R : integer := BLOCK52_L + BLOCK_WIDTH;
	constant BLOCK52_T : integer := 142;
	constant BLOCK52_B : integer := 142 + BLOCK_HEIGHT;
	
	constant BLOCK53_L : integer := BLOCK52_R + 4;
	constant BLOCK53_R : integer := BLOCK53_L + BLOCK_WIDTH;
	constant BLOCK53_T : integer := 142;
	constant BLOCK53_B : integer := 142 + BLOCK_HEIGHT;
	
	constant BLOCK54_L : integer := BLOCK53_R + 4;
	constant BLOCK54_R : integer := BLOCK54_L + BLOCK_WIDTH;
	constant BLOCK54_T : integer := 142;
	constant BLOCK54_B : integer := 142 + BLOCK_HEIGHT;
	
	constant BLOCK55_L : integer := BLOCK54_R + 4;
	constant BLOCK55_R : integer := BLOCK55_L + BLOCK_WIDTH;
	constant BLOCK55_T : integer := 142;
	constant BLOCK55_B : integer := 142 + BLOCK_HEIGHT;
	
	constant BLOCK56_L : integer := BLOCK55_R + 4;
	constant BLOCK56_R : integer := BLOCK56_L + BLOCK_WIDTH;
	constant BLOCK56_T : integer := 142;
	constant BLOCK56_B : integer := 142 + BLOCK_HEIGHT;
	
	constant BLOCK57_L : integer := 155;
	constant BLOCK57_R : integer := BLOCK57_L + BLOCK_WIDTH;
	constant BLOCK57_T : integer := 156;
	constant BLOCK57_B : integer := 156 + BLOCK_HEIGHT;
	
	constant BLOCK58_L : integer := BLOCK57_R + 4;
	constant BLOCK58_R : integer := BLOCK58_L + BLOCK_WIDTH;
	constant BLOCK58_T : integer := 156;
	constant BLOCK58_B : integer := 156 + BLOCK_HEIGHT;
	
	constant BLOCK59_L : integer := BLOCK58_R + 4;
	constant BLOCK59_R : integer := BLOCK59_L + BLOCK_WIDTH;
	constant BLOCK59_T : integer := 156;
	constant BLOCK59_B : integer := 156 + BLOCK_HEIGHT;
	
	constant BLOCK60_L : integer := BLOCK59_R + 4;
	constant BLOCK60_R : integer := BLOCK60_L + BLOCK_WIDTH;
	constant BLOCK60_T : integer := 156;
	constant BLOCK60_B : integer := 156 + BLOCK_HEIGHT;
	
	constant BLOCK61_L : integer := BLOCK60_R + 4;
	constant BLOCK61_R : integer := BLOCK61_L + BLOCK_WIDTH;
	constant BLOCK61_T : integer := 156;
	constant BLOCK61_B : integer := 156 + BLOCK_HEIGHT;
	
	constant BLOCK62_L : integer := BLOCK61_R + 4;
	constant BLOCK62_R : integer := BLOCK62_L + BLOCK_WIDTH;
	constant BLOCK62_T : integer := 156;
	constant BLOCK62_B : integer := 156 + BLOCK_HEIGHT;
	
	constant BLOCK63_L : integer := BLOCK62_R + 4;
	constant BLOCK63_R : integer := BLOCK63_L + BLOCK_WIDTH;
	constant BLOCK63_T : integer := 156;
	constant BLOCK63_B : integer := 156 + BLOCK_HEIGHT;
	
	constant BLOCK64_L : integer := BLOCK63_R + 4;
	constant BLOCK64_R : integer := BLOCK64_L + BLOCK_WIDTH;
	constant BLOCK64_T : integer := 156;
	constant BLOCK64_B : integer := 156 + BLOCK_HEIGHT;
	
	constant BLOCK65_L : integer := BLOCK64_R + 4;
	constant BLOCK65_R : integer := BLOCK65_L + BLOCK_WIDTH;
	constant BLOCK65_T : integer := 156;
	constant BLOCK65_B : integer := 156 + BLOCK_HEIGHT;
	
	constant BLOCK66_L : integer := BLOCK65_R + 4;
	constant BLOCK66_R : integer := BLOCK66_L + BLOCK_WIDTH;
	constant BLOCK66_T : integer := 156;
	constant BLOCK66_B : integer := 156 + BLOCK_HEIGHT;
	
	constant BLOCK67_L : integer := BLOCK66_R + 4;
	constant BLOCK67_R : integer := BLOCK67_L + BLOCK_WIDTH;
	constant BLOCK67_T : integer := 156;
	constant BLOCK67_B : integer := 156 + BLOCK_HEIGHT;
	
	constant BLOCK68_L : integer := BLOCK67_R + 4;
	constant BLOCK68_R : integer := BLOCK68_L + BLOCK_WIDTH;
	constant BLOCK68_T : integer := 156;
	constant BLOCK68_B : integer := 156 + BLOCK_HEIGHT;
	
	constant BLOCK69_L : integer := BLOCK68_R + 4;
	constant BLOCK69_R : integer := BLOCK69_L + BLOCK_WIDTH;
	constant BLOCK69_T : integer := 156;
	constant BLOCK69_B : integer := 156 + BLOCK_HEIGHT;
	
	constant BLOCK70_L : integer := BLOCK69_R + 4;
	constant BLOCK70_R : integer := BLOCK70_L + BLOCK_WIDTH;
	constant BLOCK70_T : integer := 156;
	constant BLOCK70_B : integer := 156 + BLOCK_HEIGHT;
	
	constant BLOCK71_L : integer := 155;
	constant BLOCK71_R : integer := BLOCK71_L + BLOCK_WIDTH;
	constant BLOCK71_T : integer := 170;
	constant BLOCK71_B : integer := 170 + BLOCK_HEIGHT;
	
	constant BLOCK72_L : integer := BLOCK71_R + 4;
	constant BLOCK72_R : integer := BLOCK72_L + BLOCK_WIDTH;
	constant BLOCK72_T : integer := 170;
	constant BLOCK72_B : integer := 170 + BLOCK_HEIGHT;
	
	constant BLOCK73_L : integer := BLOCK72_R + 4;
	constant BLOCK73_R : integer := BLOCK73_L + BLOCK_WIDTH;
	constant BLOCK73_T : integer := 170;
	constant BLOCK73_B : integer := 170 + BLOCK_HEIGHT;
	
	constant BLOCK74_L : integer := BLOCK73_R + 4;
	constant BLOCK74_R : integer := BLOCK74_L + BLOCK_WIDTH;
	constant BLOCK74_T : integer := 170;
	constant BLOCK74_B : integer := 170 + BLOCK_HEIGHT;
	
	constant BLOCK75_L : integer := BLOCK74_R + 4;
	constant BLOCK75_R : integer := BLOCK75_L + BLOCK_WIDTH;
	constant BLOCK75_T : integer := 170;
	constant BLOCK75_B : integer := 170 + BLOCK_HEIGHT;
	
	constant BLOCK76_L : integer := BLOCK75_R + 4;
	constant BLOCK76_R : integer := BLOCK76_L + BLOCK_WIDTH;
	constant BLOCK76_T : integer := 170;
	constant BLOCK76_B : integer := 170 + BLOCK_HEIGHT;
	
	constant BLOCK77_L : integer := BLOCK76_R + 4;
	constant BLOCK77_R : integer := BLOCK77_L + BLOCK_WIDTH;
	constant BLOCK77_T : integer := 170;
	constant BLOCK77_B : integer := 170 + BLOCK_HEIGHT;
	
	constant BLOCK78_L : integer := BLOCK77_R + 4;
	constant BLOCK78_R : integer := BLOCK78_L + BLOCK_WIDTH;
	constant BLOCK78_T : integer := 170;
	constant BLOCK78_B : integer := 170 + BLOCK_HEIGHT;
	
	constant BLOCK79_L : integer := BLOCK78_R + 4;
	constant BLOCK79_R : integer := BLOCK79_L + BLOCK_WIDTH;
	constant BLOCK79_T : integer := 170;
	constant BLOCK79_B : integer := 170 + BLOCK_HEIGHT;
	
	constant BLOCK80_L : integer := BLOCK79_R + 4;
	constant BLOCK80_R : integer := BLOCK80_L + BLOCK_WIDTH;
	constant BLOCK80_T : integer := 170;
	constant BLOCK80_B : integer := 170 + BLOCK_HEIGHT;
	
	constant BLOCK81_L : integer := BLOCK80_R + 4;
	constant BLOCK81_R : integer := BLOCK81_L + BLOCK_WIDTH;
	constant BLOCK81_T : integer := 170;
	constant BLOCK81_B : integer := 170 + BLOCK_HEIGHT;
	
	constant BLOCK82_L : integer := BLOCK81_R + 4;
	constant BLOCK82_R : integer := BLOCK82_L + BLOCK_WIDTH;
	constant BLOCK82_T : integer := 170;
	constant BLOCK82_B : integer := 170 + BLOCK_HEIGHT;
	
	constant BLOCK83_L : integer := BLOCK82_R + 4;
	constant BLOCK83_R : integer := BLOCK83_L + BLOCK_WIDTH;
	constant BLOCK83_T : integer := 170;
	constant BLOCK83_B : integer := 170 + BLOCK_HEIGHT;
	
	constant BLOCK84_L : integer := BLOCK83_R + 4;
	constant BLOCK84_R : integer := BLOCK84_L + BLOCK_WIDTH;
	constant BLOCK84_T : integer := 170;
	constant BLOCK84_B : integer := 170 + BLOCK_HEIGHT;
	
	constant BLOCK85_L : integer := 155;
	constant BLOCK85_R : integer := BLOCK85_L + BLOCK_WIDTH;
	constant BLOCK85_T : integer := 184;
	constant BLOCK85_B : integer := 184 + BLOCK_HEIGHT;
	
	constant BLOCK86_L : integer := BLOCK85_R + 4;
	constant BLOCK86_R : integer := BLOCK86_L + BLOCK_WIDTH;
	constant BLOCK86_T : integer := 184;
	constant BLOCK86_B : integer := 184 + BLOCK_HEIGHT;
	
	constant BLOCK87_L : integer := BLOCK86_R + 4;
	constant BLOCK87_R : integer := BLOCK87_L + BLOCK_WIDTH;
	constant BLOCK87_T : integer := 184;
	constant BLOCK87_B : integer := 184 + BLOCK_HEIGHT;
	
	constant BLOCK88_L : integer := BLOCK87_R + 4;
	constant BLOCK88_R : integer := BLOCK88_L + BLOCK_WIDTH;
	constant BLOCK88_T : integer := 184;
	constant BLOCK88_B : integer := 184 + BLOCK_HEIGHT;
	
	constant BLOCK89_L : integer := BLOCK88_R + 4;
	constant BLOCK89_R : integer := BLOCK89_L + BLOCK_WIDTH;
	constant BLOCK89_T : integer := 184;
	constant BLOCK89_B : integer := 184 + BLOCK_HEIGHT;
	
	constant BLOCK90_L : integer := BLOCK89_R + 4;
	constant BLOCK90_R : integer := BLOCK90_L + BLOCK_WIDTH;
	constant BLOCK90_T : integer := 184;
	constant BLOCK90_B : integer := 184 + BLOCK_HEIGHT;
	
	constant BLOCK91_L : integer := BLOCK90_R + 4;
	constant BLOCK91_R : integer := BLOCK91_L + BLOCK_WIDTH;
	constant BLOCK91_T : integer := 184;
	constant BLOCK91_B : integer := 184 + BLOCK_HEIGHT;
	
	constant BLOCK92_L : integer := BLOCK91_R + 4;
	constant BLOCK92_R : integer := BLOCK92_L + BLOCK_WIDTH;
	constant BLOCK92_T : integer := 184;
	constant BLOCK92_B : integer := 184 + BLOCK_HEIGHT;
	
	constant BLOCK93_L : integer := BLOCK92_R + 4;
	constant BLOCK93_R : integer := BLOCK93_L + BLOCK_WIDTH;
	constant BLOCK93_T : integer := 184;
	constant BLOCK93_B : integer := 184 + BLOCK_HEIGHT;
	
	constant BLOCK94_L : integer := BLOCK93_R + 4;
	constant BLOCK94_R : integer := BLOCK94_L + BLOCK_WIDTH;
	constant BLOCK94_T : integer := 184;
	constant BLOCK94_B : integer := 184 + BLOCK_HEIGHT;
	
	constant BLOCK95_L : integer := BLOCK94_R + 4;
	constant BLOCK95_R : integer := BLOCK95_L + BLOCK_WIDTH;
	constant BLOCK95_T : integer := 184;
	constant BLOCK95_B : integer := 184 + BLOCK_HEIGHT;
	
	constant BLOCK96_L : integer := BLOCK95_R + 4;
	constant BLOCK96_R : integer := BLOCK96_L + BLOCK_WIDTH;
	constant BLOCK96_T : integer := 184;
	constant BLOCK96_B : integer := 184 + BLOCK_HEIGHT;
	
	constant BLOCK97_L : integer := BLOCK96_R + 4;
	constant BLOCK97_R : integer := BLOCK97_L + BLOCK_WIDTH;
	constant BLOCK97_T : integer := 184;
	constant BLOCK97_B : integer := 184 + BLOCK_HEIGHT;
	
	constant BLOCK98_L : integer := BLOCK97_R + 4;
	constant BLOCK98_R : integer := BLOCK98_L + BLOCK_WIDTH;
	constant BLOCK98_T : integer := 184;
	constant BLOCK98_B : integer := 184 + BLOCK_HEIGHT;
	
	constant BLOCK99_L : integer := 155;
	constant BLOCK99_R : integer := BLOCK99_L + BLOCK_WIDTH;
	constant BLOCK99_T : integer := 198;
	constant BLOCK99_B : integer := 198 + BLOCK_HEIGHT;
	
	constant BLOCK100_L : integer := BLOCK99_R + 4;
	constant BLOCK100_R : integer := BLOCK100_L + BLOCK_WIDTH;
	constant BLOCK100_T : integer := 198;
	constant BLOCK100_B : integer := 198 + BLOCK_HEIGHT;
	
	constant BLOCK101_L : integer := BLOCK100_R + 4;
	constant BLOCK101_R : integer := BLOCK101_L + BLOCK_WIDTH;
	constant BLOCK101_T : integer := 198;
	constant BLOCK101_B : integer := 198 + BLOCK_HEIGHT;
	
	constant BLOCK102_L : integer := BLOCK101_R + 4;
	constant BLOCK102_R : integer := BLOCK102_L + BLOCK_WIDTH;
	constant BLOCK102_T : integer := 198;
	constant BLOCK102_B : integer := 198 + BLOCK_HEIGHT;
	
	constant BLOCK103_L : integer := BLOCK102_R + 4;
	constant BLOCK103_R : integer := BLOCK103_L + BLOCK_WIDTH;
	constant BLOCK103_T : integer := 198;
	constant BLOCK103_B : integer := 198 + BLOCK_HEIGHT;
	
	constant BLOCK104_L : integer := BLOCK103_R + 4;
	constant BLOCK104_R : integer := BLOCK104_L + BLOCK_WIDTH;
	constant BLOCK104_T : integer := 198;
	constant BLOCK104_B : integer := 198 + BLOCK_HEIGHT;
	
	constant BLOCK105_L : integer := BLOCK104_R + 4;
	constant BLOCK105_R : integer := BLOCK105_L + BLOCK_WIDTH;
	constant BLOCK105_T : integer := 198;
	constant BLOCK105_B : integer := 198 + BLOCK_HEIGHT;
	
	constant BLOCK106_L : integer := BLOCK105_R + 4;
	constant BLOCK106_R : integer := BLOCK106_L + BLOCK_WIDTH;
	constant BLOCK106_T : integer := 198;
	constant BLOCK106_B : integer := 198 + BLOCK_HEIGHT;
	
	constant BLOCK107_L : integer := BLOCK106_R + 4;
	constant BLOCK107_R : integer := BLOCK107_L + BLOCK_WIDTH;
	constant BLOCK107_T : integer := 198;
	constant BLOCK107_B : integer := 198 + BLOCK_HEIGHT;
	
	constant BLOCK108_L : integer := BLOCK107_R + 4;
	constant BLOCK108_R : integer := BLOCK108_L + BLOCK_WIDTH;
	constant BLOCK108_T : integer := 198;
	constant BLOCK108_B : integer := 198 + BLOCK_HEIGHT;
	
	constant BLOCK109_L : integer := BLOCK108_R + 4;
	constant BLOCK109_R : integer := BLOCK109_L + BLOCK_WIDTH;
	constant BLOCK109_T : integer := 198;
	constant BLOCK109_B : integer := 198 + BLOCK_HEIGHT;
	
	constant BLOCK110_L : integer := BLOCK109_R + 4;
	constant BLOCK110_R : integer := BLOCK110_L + BLOCK_WIDTH;
	constant BLOCK110_T : integer := 198;
	constant BLOCK110_B : integer := 198 + BLOCK_HEIGHT;
	
	constant BLOCK111_L : integer := BLOCK110_R + 4;
	constant BLOCK111_R : integer := BLOCK111_L + BLOCK_WIDTH;
	constant BLOCK111_T : integer := 198;
	constant BLOCK111_B : integer := 198 + BLOCK_HEIGHT;
	
	constant BLOCK112_L : integer := BLOCK111_R + 4;
	constant BLOCK112_R : integer := BLOCK112_L + BLOCK_WIDTH;
	constant BLOCK112_T : integer := 198;
	constant BLOCK112_B : integer := 198 + BLOCK_HEIGHT;
	
	signal wall_on, bar_on, rd_ball_on : std_logic;
	signal block1_on, block2_on, block3_on, block4_on, block5_on, block6_on,
			 block7_on, block8_on, block9_on, block10_on, block11_on, block12_on,
			 block13_on, block14_on: std_logic;
	signal block15_on, block16_on, block17_on, block18_on, block19_on, block20_on,
			 block21_on, block22_on, block23_on, block24_on, block25_on, block26_on,
			 block27_on, block28_on: std_logic;
	signal block29_on, block30_on, block31_on, block32_on, block33_on, block34_on,
			 block35_on, block36_on, block37_on, block38_on, block39_on, block40_on,
			 block41_on, block42_on: std_logic;
	signal block43_on, block44_on, block45_on, block46_on, block47_on, block48_on,
			 block49_on, block50_on, block51_on, block52_on, block53_on, block54_on,
			 block55_on, block56_on: std_logic;
	signal block57_on, block58_on, block59_on, block60_on, block61_on, block62_on,
			 block63_on, block64_on, block65_on, block66_on, block67_on, block68_on,
			 block69_on, block70_on: std_logic;
	signal block71_on, block72_on, block73_on, block74_on, block75_on, block76_on,
			 block77_on, block78_on, block79_on, block80_on, block81_on, block82_on,
			 block83_on, block84_on: std_logic;
	signal block85_on, block86_on, block87_on, block88_on, block89_on, block90_on,
			 block91_on, block92_on, block93_on, block94_on, block95_on, block96_on,
			 block97_on, block98_on: std_logic;
	signal block99_on, block100_on, block101_on, block102_on, block103_on, block104_on,
			 block105_on, block106_on, block107_on, block108_on, block109_on, block110_on,
			 block111_on, block112_on: std_logic;
			 
			 
	signal block1_alive_reg, block2_alive_reg, block3_alive_reg, block4_alive_reg, block5_alive_reg, block6_alive_reg,
			 block7_alive_reg, block8_alive_reg, block9_alive_reg, block10_alive_reg, block11_alive_reg, block12_alive_reg,
			 block13_alive_reg, block14_alive_reg: std_logic:= '1';
	signal block15_alive_reg, block16_alive_reg, block17_alive_reg, block18_alive_reg, block19_alive_reg, block20_alive_reg,
			 block21_alive_reg, block22_alive_reg, block23_alive_reg, block24_alive_reg, block25_alive_reg, block26_alive_reg,
			 block27_alive_reg, block28_alive_reg: std_logic:= '1';
	signal block29_alive_reg, block30_alive_reg, block31_alive_reg, block32_alive_reg, block33_alive_reg, block34_alive_reg,
			 block35_alive_reg, block36_alive_reg, block37_alive_reg, block38_alive_reg, block39_alive_reg, block40_alive_reg,
			 block41_alive_reg, block42_alive_reg: std_logic:= '1';
	signal block43_alive_reg, block44_alive_reg, block45_alive_reg, block46_alive_reg, block47_alive_reg, block48_alive_reg,
			 block49_alive_reg, block50_alive_reg, block51_alive_reg, block52_alive_reg, block53_alive_reg, block54_alive_reg,
			 block55_alive_reg, block56_alive_reg: std_logic:= '1';
	signal block57_alive_reg, block58_alive_reg, block59_alive_reg, block60_alive_reg, block61_alive_reg, block62_alive_reg,
			 block63_alive_reg, block64_alive_reg, block65_alive_reg, block66_alive_reg, block67_alive_reg, block68_alive_reg,
			 block69_alive_reg, block70_alive_reg: std_logic:= '1';
	signal block71_alive_reg, block72_alive_reg, block73_alive_reg, block74_alive_reg, block75_alive_reg, block76_alive_reg,
			 block77_alive_reg, block78_alive_reg, block79_alive_reg, block80_alive_reg, block81_alive_reg, block82_alive_reg,
			 block83_alive_reg, block84_alive_reg: std_logic:= '1';
	signal block85_alive_reg, block86_alive_reg, block87_alive_reg, block88_alive_reg, block89_alive_reg, block90_alive_reg,
			 block91_alive_reg, block92_alive_reg, block93_alive_reg, block94_alive_reg, block95_alive_reg, block96_alive_reg,
			 block97_alive_reg, block98_alive_reg: std_logic:= '1';
	signal block99_alive_reg, block100_alive_reg, block101_alive_reg, block102_alive_reg, block103_alive_reg, block104_alive_reg,
			 block105_alive_reg, block106_alive_reg, block107_alive_reg, block108_alive_reg, block109_alive_reg, block110_alive_reg,
			 block111_alive_reg, block112_alive_reg: std_logic:= '1';		 
	
	signal block1_alive_next, block2_alive_next, block3_alive_next, block4_alive_next, block5_alive_next, block6_alive_next,
			 block7_alive_next, block8_alive_next, block9_alive_next, block10_alive_next, block11_alive_next, block12_alive_next,
			 block13_alive_next, block14_alive_next: std_logic:= '1';
	signal block15_alive_next, block16_alive_next, block17_alive_next, block18_alive_next, block19_alive_next, block20_alive_next,
			 block21_alive_next, block22_alive_next, block23_alive_next, block24_alive_next, block25_alive_next, block26_alive_next,
			 block27_alive_next, block28_alive_next: std_logic:= '1';
	signal block29_alive_next, block30_alive_next, block31_alive_next, block32_alive_next, block33_alive_next, block34_alive_next,
			 block35_alive_next, block36_alive_next, block37_alive_next, block38_alive_next, block39_alive_next, block40_alive_next,
			 block41_alive_next, block42_alive_next: std_logic:= '1';
	signal block43_alive_next, block44_alive_next, block45_alive_next, block46_alive_next, block47_alive_next, block48_alive_next,
			 block49_alive_next, block50_alive_next, block51_alive_next, block52_alive_next, block53_alive_next, block54_alive_next,
			 block55_alive_next, block56_alive_next: std_logic:= '1';
	signal block57_alive_next, block58_alive_next, block59_alive_next, block60_alive_next, block61_alive_next, block62_alive_next,
			 block63_alive_next, block64_alive_next, block65_alive_next, block66_alive_next, block67_alive_next, block68_alive_next,
			 block69_alive_next, block70_alive_next: std_logic:= '1';
	signal block71_alive_next, block72_alive_next, block73_alive_next, block74_alive_next, block75_alive_next, block76_alive_next,
			 block77_alive_next, block78_alive_next, block79_alive_next, block80_alive_next, block81_alive_next, block82_alive_next,
			 block83_alive_next, block84_alive_next: std_logic:= '1';
	signal block85_alive_next, block86_alive_next, block87_alive_next, block88_alive_next, block89_alive_next, block90_alive_next,
			 block91_alive_next, block92_alive_next, block93_alive_next, block94_alive_next, block95_alive_next, block96_alive_next,
			 block97_alive_next, block98_alive_next: std_logic:= '1';
	signal block99_alive_next, block100_alive_next, block101_alive_next, block102_alive_next, block103_alive_next, block104_alive_next,
			 block105_alive_next, block106_alive_next, block107_alive_next, block108_alive_next, block109_alive_next, block110_alive_next,
			 block111_alive_next, block112_alive_next: std_logic:= '1';	
	signal wall_rgb, bar_rgb, ball_rgb : std_logic_vector(2 downto 0);
	signal first_block_rgb, second_block_rgb, third_block_rgb, forth_block_rgb : std_logic_vector(2 downto 0);
	
begin
	process(clk, reset)
	begin
		if reset = '1' then
			bar_x_reg <= to_unsigned(310, 10);
			ball_x_reg <= to_unsigned(310, 10);
			ball_y_reg <= to_unsigned(250, 10);
			y_delta_reg <= BALL_V_P;
			x_delta_reg <= BALL_V_P;
		elsif(clk'event and clk = '1') then
			bar_x_reg <= bar_x_next;
			ball_x_reg <= ball_x_next;
			ball_y_reg <= ball_y_next;
			y_delta_reg <= y_delta_next;
			x_delta_reg <= x_delta_next;
			
		end if;
	end process;
	
	process(clk, reset)
	begin
		if reset = '1' then
			block1_alive_reg <= '1';
			block2_alive_reg <= '1';
			block3_alive_reg <= '1';
			block4_alive_reg <= '1';
			block5_alive_reg <= '1';
			block6_alive_reg <= '1';
			block7_alive_reg <= '1';
			block8_alive_reg <= '1';
			block9_alive_reg <= '1';
			block10_alive_reg <= '1';
			block11_alive_reg <= '1';
			block12_alive_reg <= '1';
			block13_alive_reg <= '1';
			block14_alive_reg <= '1';
			block15_alive_reg <= '1';
			block16_alive_reg <= '1';
			block17_alive_reg <= '1';
			block18_alive_reg <= '1';
			block19_alive_reg <= '1';
			block20_alive_reg <= '1';
			block21_alive_reg <= '1';
			block22_alive_reg <= '1';
			block23_alive_reg <= '1';
			block24_alive_reg <= '1';
			block25_alive_reg <= '1';
			block26_alive_reg <= '1';
			block27_alive_reg <= '1';
			block28_alive_reg <= '1';
			block29_alive_reg <= '1';
			block30_alive_reg <= '1';
			block31_alive_reg <= '1';
			block32_alive_reg <= '1';
			block33_alive_reg <= '1';
			block34_alive_reg <= '1';
			block35_alive_reg <= '1';
			block36_alive_reg <= '1';
			block37_alive_reg <= '1';
			block38_alive_reg <= '1';
			block39_alive_reg <= '1';
			block40_alive_reg <= '1';
			block41_alive_reg <= '1';
			block42_alive_reg <= '1';
			block43_alive_reg <= '1';
			block44_alive_reg <= '1';
			block45_alive_reg <= '1';
			block46_alive_reg <= '1';
			block47_alive_reg <= '1';
			block48_alive_reg <= '1';
			block49_alive_reg <= '1';
			block50_alive_reg <= '1';
			block51_alive_reg <= '1';
			block52_alive_reg <= '1';
			block53_alive_reg <= '1';
			block54_alive_reg <= '1';
			block55_alive_reg <= '1';
			block56_alive_reg <= '1';
			block57_alive_reg <= '1';
			block58_alive_reg <= '1';
			block59_alive_reg <= '1';
			block60_alive_reg <= '1';
			block61_alive_reg <= '1';
			block62_alive_reg <= '1';
			block63_alive_reg <= '1';
			block64_alive_reg <= '1';
			block65_alive_reg <= '1';
			block66_alive_reg <= '1';
			block67_alive_reg <= '1';
			block68_alive_reg <= '1';
			block69_alive_reg <= '1';
			block70_alive_reg <= '1';
			block71_alive_reg <= '1';
			block72_alive_reg <= '1';
			block73_alive_reg <= '1';
			block74_alive_reg <= '1';
			block75_alive_reg <= '1';
			block76_alive_reg <= '1';
			block77_alive_reg <= '1';
			block78_alive_reg <= '1';
			block79_alive_reg <= '1';
			block80_alive_reg <= '1';
			block81_alive_reg <= '1';
			block82_alive_reg <= '1';
			block83_alive_reg <= '1';
			block84_alive_reg <= '1';
			block85_alive_reg <= '1';
			block86_alive_reg <= '1';
			block87_alive_reg <= '1';
			block88_alive_reg <= '1';
			block89_alive_reg <= '1';
			block90_alive_reg <= '1';
			block91_alive_reg <= '1';
			block92_alive_reg <= '1';
			block93_alive_reg <= '1';
			block94_alive_reg <= '1';
			block95_alive_reg <= '1';
			block96_alive_reg <= '1';
			block97_alive_reg <= '1';
			block98_alive_reg <= '1';
			block99_alive_reg <= '1';
			block100_alive_reg <= '1';
			block101_alive_reg <= '1';
			block102_alive_reg <= '1';
			block103_alive_reg <= '1';
			block104_alive_reg <= '1';
			block105_alive_reg <= '1';
			block106_alive_reg <= '1';
			block107_alive_reg <= '1';
			block108_alive_reg <= '1';
			block109_alive_reg <= '1';
			block110_alive_reg <= '1';
			block111_alive_reg <= '1';
			block112_alive_reg <= '1';
		elsif(clk'event and clk = '1') then
			block1_alive_reg <= block1_alive_next;
			block2_alive_reg <= block2_alive_next;
			block3_alive_reg <= block3_alive_next;
			block4_alive_reg <= block4_alive_next;
			block5_alive_reg <= block5_alive_next;
			block6_alive_reg <= block6_alive_next;
			block7_alive_reg <= block7_alive_next;
			block8_alive_reg <= block8_alive_next;
			block9_alive_reg <= block9_alive_next;
			block10_alive_reg <= block10_alive_next;
			block11_alive_reg <= block11_alive_next;
			block12_alive_reg <= block12_alive_next;
			block13_alive_reg <= block13_alive_next;
			block14_alive_reg <= block14_alive_next;
			block15_alive_reg <= block15_alive_next;
			block16_alive_reg <= block16_alive_next;
			block17_alive_reg <= block17_alive_next;
			block18_alive_reg <= block18_alive_next;
			block19_alive_reg <= block19_alive_next;
			block20_alive_reg <= block20_alive_next;
			block21_alive_reg <= block21_alive_next;
			block22_alive_reg <= block22_alive_next;
			block23_alive_reg <= block23_alive_next;
			block24_alive_reg <= block24_alive_next;
			block25_alive_reg <= block25_alive_next;
			block26_alive_reg <= block26_alive_next;
			block27_alive_reg <= block27_alive_next;
			block28_alive_reg <= block28_alive_next;
			block29_alive_reg <= block29_alive_next;
			block30_alive_reg <= block30_alive_next;
			block31_alive_reg <= block31_alive_next;
			block32_alive_reg <= block32_alive_next;
			block33_alive_reg <= block33_alive_next;
			block34_alive_reg <= block34_alive_next;
			block35_alive_reg <= block35_alive_next;
			block36_alive_reg <= block36_alive_next;
			block37_alive_reg <= block37_alive_next;
			block38_alive_reg <= block38_alive_next;
			block39_alive_reg <= block39_alive_next;
			block40_alive_reg <= block40_alive_next;
			block41_alive_reg <= block41_alive_next;
			block42_alive_reg <= block42_alive_next;
			block43_alive_reg <= block43_alive_next;
			block44_alive_reg <= block44_alive_next;
			block45_alive_reg <= block45_alive_next;
			block46_alive_reg <= block46_alive_next;
			block47_alive_reg <= block47_alive_next;
			block48_alive_reg <= block48_alive_next;
			block49_alive_reg <= block49_alive_next;
			block50_alive_reg <= block50_alive_next;
			block51_alive_reg <= block51_alive_next;
			block52_alive_reg <= block52_alive_next;
			block53_alive_reg <= block53_alive_next;
			block54_alive_reg <= block54_alive_next;
			block55_alive_reg <= block55_alive_next;
			block56_alive_reg <= block56_alive_next;
			block57_alive_reg <= block57_alive_next;
			block58_alive_reg <= block58_alive_next;
			block59_alive_reg <= block59_alive_next;
			block60_alive_reg <= block60_alive_next;
			block61_alive_reg <= block61_alive_next;
			block62_alive_reg <= block62_alive_next;
			block63_alive_reg <= block63_alive_next;
			block64_alive_reg <= block64_alive_next;
			block65_alive_reg <= block65_alive_next;
			block66_alive_reg <= block66_alive_next;
			block67_alive_reg <= block67_alive_next;
			block68_alive_reg <= block68_alive_next;
			block69_alive_reg <= block69_alive_next;
			block70_alive_reg <= block70_alive_next;
			block71_alive_reg <= block71_alive_next;
			block72_alive_reg <= block72_alive_next;
			block73_alive_reg <= block73_alive_next;
			block74_alive_reg <= block74_alive_next;
			block75_alive_reg <= block75_alive_next;
			block76_alive_reg <= block76_alive_next;
			block77_alive_reg <= block77_alive_next;
			block78_alive_reg <= block78_alive_next;
			block79_alive_reg <= block79_alive_next;
			block80_alive_reg <= block80_alive_next;
			block81_alive_reg <= block81_alive_next;
			block82_alive_reg <= block82_alive_next;
			block83_alive_reg <= block83_alive_next;
			block84_alive_reg <= block84_alive_next;
			block85_alive_reg <= block85_alive_next;
			block86_alive_reg <= block86_alive_next;
			block87_alive_reg <= block87_alive_next;
			block88_alive_reg <= block88_alive_next;
			block89_alive_reg <= block89_alive_next;
			block90_alive_reg <= block90_alive_next;
			block91_alive_reg <= block91_alive_next;
			block92_alive_reg <= block92_alive_next;
			block93_alive_reg <= block93_alive_next;
			block94_alive_reg <= block94_alive_next;
			block95_alive_reg <= block95_alive_next;
			block96_alive_reg <= block96_alive_next;
			block97_alive_reg <= block97_alive_next;
			block98_alive_reg <= block98_alive_next;
			block99_alive_reg <= block99_alive_next;
			block100_alive_reg <= block100_alive_next;
			block101_alive_reg <= block101_alive_next;
			block102_alive_reg <= block102_alive_next;
			block103_alive_reg <= block103_alive_next;
			block104_alive_reg <= block104_alive_next;
			block105_alive_reg <= block105_alive_next;
			block106_alive_reg <= block106_alive_next;
			block107_alive_reg <= block107_alive_next;
			block108_alive_reg <= block108_alive_next;
			block109_alive_reg <= block109_alive_next;
			block110_alive_reg <= block110_alive_next;
			block111_alive_reg <= block111_alive_next;
			block112_alive_reg <= block112_alive_next;
		end if;
	end process;
	
	pix_x <= unsigned(pixel_x);
	pix_y <= unsigned(pixel_y);
	
	refr_tick <= '1' when (pix_y = 523) and (pix_x = 0) else
					 '0';
	wall_on <= 
		'1' when (((WALL_LEFT_X_L <= pix_x) and (pix_x <= WALL_LEFT_X_R)) and
					((WALL_TOP_Y_T <= pix_y) and (pix_y <= 474)))or
					(((WALL_RIGHT_X_L <= pix_x) and (pix_x <= WALL_RIGHT_X_R)) and
					((WALL_TOP_Y_T <= pix_y) and (pix_y <= 474)))or
					(((WALL_LEFT_X_L <= pix_x) and (pix_x <= WALL_RIGHT_X_R)) and
					((WALL_TOP_Y_T <= pix_y) and (pix_y <= WALL_TOP_Y_B))) else
		'0';
	wall_rgb <= "111";
	bar_x_l <= bar_x_reg;
	bar_x_r <= bar_x_l + BAR_X_WIDTH - 1;
	bar_on <= 
		'1' when (bar_x_l <= pix_x) and (pix_x <= bar_x_r) and
					(BAR_Y_T <= pix_y) and (pix_y <= BAR_Y_B) else
		'0';
	bar_rgb <= "011";
	process(bar_x_reg, bar_x_l, bar_x_r, refr_tick, btn)
	begin
		bar_x_next <= bar_x_reg;
		if refr_tick = '1' then
			if btn(1) = '1' and bar_x_l > (WALL_LEFT_X_R) then
				bar_x_next <= bar_x_reg - BAR_V;
			elsif btn(0) = '1' and bar_x_r < WALL_RIGHT_X_L then
				bar_x_next <= bar_x_reg + BAR_V;
			end if;
		end if;
	end process;
	
						
	block1_on <= '1' when (BLOCK1_L <= pix_x) and (pix_x <= BLOCK1_R) and
								 (BLOCK1_T <= pix_y) and (pix_y <= BLOCK1_B) and 
								 block1_alive_reg = '1' else
					 '0';
	block2_on <= '1' when (BLOCK2_L <= pix_x) and (pix_x <= BLOCK2_R) and
								 (BLOCK2_T <= pix_y) and (pix_y <= BLOCK2_B) and 
								 block2_alive_reg = '1' else
					 '0';
	block3_on <= '1' when (BLOCK3_L <= pix_x) and (pix_x <= BLOCK3_R) and
								 (BLOCK3_T <= pix_y) and (pix_y <= BLOCK3_B) and 
								 block3_alive_reg = '1' else
					 '0';
	block4_on <= '1' when (BLOCK4_L <= pix_x) and (pix_x <= BLOCK4_R) and
								 (BLOCK4_T <= pix_y) and (pix_y <= BLOCK4_B) and 
								 block4_alive_reg = '1' else
					 '0';
	block5_on <= '1' when (BLOCK5_L <= pix_x) and (pix_x <= BLOCK5_R) and
								 (BLOCK5_T <= pix_y) and (pix_y <= BLOCK5_B) and 
								 block5_alive_reg = '1' else
					 '0';
	block6_on <= '1' when (BLOCK6_L <= pix_x) and (pix_x <= BLOCK6_R) and
								 (BLOCK6_T <= pix_y) and (pix_y <= BLOCK6_B) and 
								 block6_alive_reg = '1' else
					 '0';
	block7_on <= '1' when (BLOCK7_L <= pix_x) and (pix_x <= BLOCK7_R) and
								 (BLOCK7_T <= pix_y) and (pix_y <= BLOCK7_B) and 
								 block7_alive_reg = '1' else
					 '0';
	block8_on <= '1' when (BLOCK8_L <= pix_x) and (pix_x <= BLOCK8_R) and
								 (BLOCK8_T <= pix_y) and (pix_y <= BLOCK8_B) and 
								 block8_alive_reg = '1' else
					 '0';
	block9_on <= '1' when (BLOCK9_L <= pix_x) and (pix_x <= BLOCK9_R) and
								 (BLOCK9_T <= pix_y) and (pix_y <= BLOCK9_B) and 
								 block9_alive_reg = '1' else
					 '0';
	block10_on <= '1' when (BLOCK10_L <= pix_x) and (pix_x <= BLOCK10_R) and
								 (BLOCK10_T <= pix_y) and (pix_y <= BLOCK10_B) and 
								 block10_alive_reg = '1' else
					 '0';
	block11_on <= '1' when (BLOCK11_L <= pix_x) and (pix_x <= BLOCK11_R) and
								 (BLOCK11_T <= pix_y) and (pix_y <= BLOCK11_B) and 
								 block11_alive_reg = '1' else
					 '0';
	block12_on <= '1' when (BLOCK12_L <= pix_x) and (pix_x <= BLOCK12_R) and
								 (BLOCK12_T <= pix_y) and (pix_y <= BLOCK12_B) and 
								 block12_alive_reg = '1' else
					 '0';
	block13_on <= '1' when (BLOCK13_L <= pix_x) and (pix_x <= BLOCK13_R) and
								 (BLOCK13_T <= pix_y) and (pix_y <= BLOCK13_B) and 
								 block13_alive_reg = '1' else
					 '0';
	block14_on <= '1' when (BLOCK14_L <= pix_x) and (pix_x <= BLOCK14_R) and
								 (BLOCK14_T <= pix_y) and (pix_y <= BLOCK14_B) and 
								 block14_alive_reg = '1' else
					 '0';				 
	block15_on <= '1' when (BLOCK15_L <= pix_x) and (pix_x <= BLOCK15_R) and
								 (BLOCK15_T <= pix_y) and (pix_y <= BLOCK15_B) and 
								 block15_alive_reg = '1' else
					 '0';
	block16_on <= '1' when (BLOCK16_L <= pix_x) and (pix_x <= BLOCK16_R) and
								 (BLOCK16_T <= pix_y) and (pix_y <= BLOCK16_B) and 
								 block16_alive_reg = '1' else
					 '0';
	block17_on <= '1' when (BLOCK17_L <= pix_x) and (pix_x <= BLOCK17_R) and
								 (BLOCK17_T <= pix_y) and (pix_y <= BLOCK17_B) and 
								 block17_alive_reg = '1' else
					 '0';
	block18_on <= '1' when (BLOCK18_L <= pix_x) and (pix_x <= BLOCK18_R) and
								 (BLOCK18_T <= pix_y) and (pix_y <= BLOCK18_B) and 
								 block18_alive_reg = '1' else
					 '0';
	block19_on <= '1' when (BLOCK19_L <= pix_x) and (pix_x <= BLOCK19_R) and
								 (BLOCK19_T <= pix_y) and (pix_y <= BLOCK19_B) and 
								 block19_alive_reg = '1' else
					 '0';
	block20_on <= '1' when (BLOCK20_L <= pix_x) and (pix_x <= BLOCK20_R) and
								 (BLOCK20_T <= pix_y) and (pix_y <= BLOCK20_B) and 
								 block20_alive_reg = '1' else
					 '0';
	block21_on <= '1' when (BLOCK21_L <= pix_x) and (pix_x <= BLOCK21_R) and
								 (BLOCK21_T <= pix_y) and (pix_y <= BLOCK21_B) and 
								 block21_alive_reg = '1' else
					 '0';
	block22_on <= '1' when (BLOCK22_L <= pix_x) and (pix_x <= BLOCK22_R) and
								 (BLOCK22_T <= pix_y) and (pix_y <= BLOCK22_B) and 
								 block22_alive_reg = '1' else
					 '0';
	block23_on <= '1' when (BLOCK23_L <= pix_x) and (pix_x <= BLOCK23_R) and
								 (BLOCK23_T <= pix_y) and (pix_y <= BLOCK23_B) and 
								 block23_alive_reg = '1' else
					 '0';
	block24_on <= '1' when (BLOCK24_L <= pix_x) and (pix_x <= BLOCK24_R) and
								 (BLOCK24_T <= pix_y) and (pix_y <= BLOCK24_B) and 
								 block24_alive_reg = '1' else
					 '0';
	block25_on <= '1' when (BLOCK25_L <= pix_x) and (pix_x <= BLOCK25_R) and
								 (BLOCK25_T <= pix_y) and (pix_y <= BLOCK25_B) and 
								 block25_alive_reg = '1' else
					 '0';
	block26_on <= '1' when (BLOCK26_L <= pix_x) and (pix_x <= BLOCK26_R) and
								 (BLOCK26_T <= pix_y) and (pix_y <= BLOCK26_B) and 
								 block26_alive_reg = '1' else
					 '0';
	block27_on <= '1' when (BLOCK27_L <= pix_x) and (pix_x <= BLOCK27_R) and
								 (BLOCK27_T <= pix_y) and (pix_y <= BLOCK27_B) and 
								 block27_alive_reg = '1' else
					 '0';
	block28_on <= '1' when (BLOCK28_L <= pix_x) and (pix_x <= BLOCK28_R) and
								 (BLOCK28_T <= pix_y) and (pix_y <= BLOCK28_B) and 
								 block28_alive_reg = '1' else
					 '0';
	block29_on <= '1' when (BLOCK29_L <= pix_x) and (pix_x <= BLOCK29_R) and
								 (BLOCK29_T <= pix_y) and (pix_y <= BLOCK29_B) and 
								 block29_alive_reg = '1' else
					 '0';				 
	block30_on <= '1' when (BLOCK30_L <= pix_x) and (pix_x <= BLOCK30_R) and
								 (BLOCK30_T <= pix_y) and (pix_y <= BLOCK30_B) and 
								 block30_alive_reg = '1' else
					 '0';
	block31_on <= '1' when (BLOCK31_L <= pix_x) and (pix_x <= BLOCK31_R) and
								 (BLOCK31_T <= pix_y) and (pix_y <= BLOCK31_B) and 
								 block31_alive_reg = '1' else
					 '0';
	block32_on <= '1' when (BLOCK32_L <= pix_x) and (pix_x <= BLOCK32_R) and
								 (BLOCK32_T <= pix_y) and (pix_y <= BLOCK32_B) and 
								 block32_alive_reg = '1' else
					 '0';
	block33_on <= '1' when (BLOCK33_L <= pix_x) and (pix_x <= BLOCK33_R) and
								 (BLOCK33_T <= pix_y) and (pix_y <= BLOCK33_B) and 
								 block33_alive_reg = '1' else
					 '0';
	block34_on <= '1' when (BLOCK34_L <= pix_x) and (pix_x <= BLOCK34_R) and
								 (BLOCK34_T <= pix_y) and (pix_y <= BLOCK34_B) and 
								 block34_alive_reg = '1' else
					 '0';
	block35_on <= '1' when (BLOCK35_L <= pix_x) and (pix_x <= BLOCK35_R) and
								 (BLOCK35_T <= pix_y) and (pix_y <= BLOCK35_B) and 
								 block35_alive_reg = '1' else
					 '0';
	block36_on <= '1' when (BLOCK36_L <= pix_x) and (pix_x <= BLOCK36_R) and
								 (BLOCK36_T <= pix_y) and (pix_y <= BLOCK36_B) and 
								 block36_alive_reg = '1' else
					 '0';
	block37_on <= '1' when (BLOCK37_L <= pix_x) and (pix_x <= BLOCK37_R) and
								 (BLOCK37_T <= pix_y) and (pix_y <= BLOCK37_B) and 
								 block37_alive_reg = '1' else
					 '0';
	block38_on <= '1' when (BLOCK38_L <= pix_x) and (pix_x <= BLOCK38_R) and
								 (BLOCK38_T <= pix_y) and (pix_y <= BLOCK38_B) and 
								 block38_alive_reg = '1' else
					 '0';
	block39_on <= '1' when (BLOCK39_L <= pix_x) and (pix_x <= BLOCK39_R) and
								 (BLOCK39_T <= pix_y) and (pix_y <= BLOCK39_B) and 
								 block39_alive_reg = '1' else
					 '0';
	block40_on <= '1' when (BLOCK40_L <= pix_x) and (pix_x <= BLOCK40_R) and
								 (BLOCK40_T <= pix_y) and (pix_y <= BLOCK40_B) and 
								 block40_alive_reg = '1' else
					 '0';
	block41_on <= '1' when (BLOCK41_L <= pix_x) and (pix_x <= BLOCK41_R) and
								 (BLOCK41_T <= pix_y) and (pix_y <= BLOCK41_B) and 
								 block41_alive_reg = '1' else
					 '0';
	block42_on <= '1' when (BLOCK42_L <= pix_x) and (pix_x <= BLOCK42_R) and
								 (BLOCK42_T <= pix_y) and (pix_y <= BLOCK42_B) and 
								 block42_alive_reg = '1' else
					 '0';
	block43_on <= '1' when (BLOCK43_L <= pix_x) and (pix_x <= BLOCK43_R) and
								 (BLOCK43_T <= pix_y) and (pix_y <= BLOCK43_B) and 
								 block43_alive_reg = '1' else
					 '0';
	block44_on <= '1' when (BLOCK44_L <= pix_x) and (pix_x <= BLOCK44_R) and
								 (BLOCK44_T <= pix_y) and (pix_y <= BLOCK44_B) and 
								 block44_alive_reg = '1' else
					 '0';				 
	block45_on <= '1' when (BLOCK45_L <= pix_x) and (pix_x <= BLOCK45_R) and
								 (BLOCK45_T <= pix_y) and (pix_y <= BLOCK45_B) and 
								 block45_alive_reg = '1' else
					 '0';
	block46_on <= '1' when (BLOCK46_L <= pix_x) and (pix_x <= BLOCK46_R) and
								 (BLOCK46_T <= pix_y) and (pix_y <= BLOCK46_B) and 
								 block46_alive_reg = '1' else
					 '0';
	block47_on <= '1' when (BLOCK47_L <= pix_x) and (pix_x <= BLOCK47_R) and
								 (BLOCK47_T <= pix_y) and (pix_y <= BLOCK47_B) and 
								 block47_alive_reg = '1' else
					 '0';
	block48_on <= '1' when (BLOCK48_L <= pix_x) and (pix_x <= BLOCK48_R) and
								 (BLOCK48_T <= pix_y) and (pix_y <= BLOCK48_B) and 
								 block48_alive_reg = '1' else
					 '0';
	block49_on <= '1' when (BLOCK49_L <= pix_x) and (pix_x <= BLOCK49_R) and
								 (BLOCK49_T <= pix_y) and (pix_y <= BLOCK49_B) and 
								 block49_alive_reg = '1' else
					 '0';
	block50_on <= '1' when (BLOCK50_L <= pix_x) and (pix_x <= BLOCK50_R) and
								 (BLOCK50_T <= pix_y) and (pix_y <= BLOCK50_B) and 
								 block50_alive_reg = '1' else
					 '0';
	block51_on <= '1' when (BLOCK51_L <= pix_x) and (pix_x <= BLOCK51_R) and
								 (BLOCK51_T <= pix_y) and (pix_y <= BLOCK51_B) and 
								 block51_alive_reg = '1' else
					 '0';
	block52_on <= '1' when (BLOCK52_L <= pix_x) and (pix_x <= BLOCK52_R) and
								 (BLOCK52_T <= pix_y) and (pix_y <= BLOCK52_B) and 
								 block52_alive_reg = '1' else
					 '0';
	block53_on <= '1' when (BLOCK53_L <= pix_x) and (pix_x <= BLOCK53_R) and
								 (BLOCK53_T <= pix_y) and (pix_y <= BLOCK53_B) and 
								 block53_alive_reg = '1' else
					 '0';
	block54_on <= '1' when (BLOCK54_L <= pix_x) and (pix_x <= BLOCK54_R) and
								 (BLOCK54_T <= pix_y) and (pix_y <= BLOCK54_B) and 
								 block54_alive_reg = '1' else
					 '0';
	block55_on <= '1' when (BLOCK55_L <= pix_x) and (pix_x <= BLOCK55_R) and
								 (BLOCK55_T <= pix_y) and (pix_y <= BLOCK55_B) and 
								 block55_alive_reg = '1' else
					 '0';
	block56_on <= '1' when (BLOCK56_L <= pix_x) and (pix_x <= BLOCK56_R) and
								 (BLOCK56_T <= pix_y) and (pix_y <= BLOCK56_B) and 
								 block56_alive_reg = '1' else
					 '0';
	block57_on <= '1' when (BLOCK57_L <= pix_x) and (pix_x <= BLOCK57_R) and
								 (BLOCK57_T <= pix_y) and (pix_y <= BLOCK57_B) and 
								 block57_alive_reg = '1' else
					 '0';				 
	block58_on <= '1' when (BLOCK58_L <= pix_x) and (pix_x <= BLOCK58_R) and
								 (BLOCK58_T <= pix_y) and (pix_y <= BLOCK58_B) and 
								 block58_alive_reg = '1' else
					 '0';
	block59_on <= '1' when (BLOCK59_L <= pix_x) and (pix_x <= BLOCK59_R) and
								 (BLOCK59_T <= pix_y) and (pix_y <= BLOCK59_B) and 
								 block59_alive_reg = '1' else
					 '0';
	block60_on <= '1' when (BLOCK60_L <= pix_x) and (pix_x <= BLOCK60_R) and
								 (BLOCK60_T <= pix_y) and (pix_y <= BLOCK60_B) and 
								 block60_alive_reg = '1' else
					 '0';
	block61_on <= '1' when (BLOCK61_L <= pix_x) and (pix_x <= BLOCK61_R) and
								 (BLOCK61_T <= pix_y) and (pix_y <= BLOCK61_B) and 
								 block61_alive_reg = '1' else
					 '0';
	block62_on <= '1' when (BLOCK62_L <= pix_x) and (pix_x <= BLOCK62_R) and
								 (BLOCK62_T <= pix_y) and (pix_y <= BLOCK62_B) and 
								 block62_alive_reg = '1' else
					 '0';
	block63_on <= '1' when (BLOCK63_L <= pix_x) and (pix_x <= BLOCK63_R) and
								 (BLOCK63_T <= pix_y) and (pix_y <= BLOCK63_B) and 
								 block63_alive_reg = '1' else
					 '0';
	block64_on <= '1' when (BLOCK64_L <= pix_x) and (pix_x <= BLOCK64_R) and
								 (BLOCK64_T <= pix_y) and (pix_y <= BLOCK64_B) and 
								 block64_alive_reg = '1' else
					 '0';
	block65_on <= '1' when (BLOCK65_L <= pix_x) and (pix_x <= BLOCK65_R) and
								 (BLOCK65_T <= pix_y) and (pix_y <= BLOCK65_B) and 
								 block65_alive_reg = '1' else
					 '0';
	block66_on <= '1' when (BLOCK66_L <= pix_x) and (pix_x <= BLOCK66_R) and
								 (BLOCK66_T <= pix_y) and (pix_y <= BLOCK66_B) and 
								 block66_alive_reg = '1' else
					 '0';
	block67_on <= '1' when (BLOCK67_L <= pix_x) and (pix_x <= BLOCK67_R) and
								 (BLOCK67_T <= pix_y) and (pix_y <= BLOCK67_B) and 
								 block67_alive_reg = '1' else
					 '0';
	block68_on <= '1' when (BLOCK68_L <= pix_x) and (pix_x <= BLOCK68_R) and
								 (BLOCK68_T <= pix_y) and (pix_y <= BLOCK68_B) and 
								 block68_alive_reg = '1' else
					 '0';
	block69_on <= '1' when (BLOCK69_L <= pix_x) and (pix_x <= BLOCK69_R) and
								 (BLOCK69_T <= pix_y) and (pix_y <= BLOCK69_B) and 
								 block69_alive_reg = '1' else
					 '0';
	block70_on <= '1' when (BLOCK70_L <= pix_x) and (pix_x <= BLOCK70_R) and
								 (BLOCK70_T <= pix_y) and (pix_y <= BLOCK70_B) and 
								 block70_alive_reg = '1' else
					 '0';
	block71_on <= '1' when (BLOCK71_L <= pix_x) and (pix_x <= BLOCK71_R) and
								 (BLOCK71_T <= pix_y) and (pix_y <= BLOCK71_B) and 
								 block71_alive_reg = '1' else
					 '0';
	block72_on <= '1' when (BLOCK72_L <= pix_x) and (pix_x <= BLOCK72_R) and
								 (BLOCK72_T <= pix_y) and (pix_y <= BLOCK72_B) and 
								 block72_alive_reg = '1' else
					 '0';				 
	block73_on <= '1' when (BLOCK73_L <= pix_x) and (pix_x <= BLOCK73_R) and
								 (BLOCK73_T <= pix_y) and (pix_y <= BLOCK73_B) and 
								 block73_alive_reg = '1' else
					 '0';
	block74_on <= '1' when (BLOCK74_L <= pix_x) and (pix_x <= BLOCK74_R) and
								 (BLOCK74_T <= pix_y) and (pix_y <= BLOCK74_B) and 
								 block74_alive_reg = '1' else
					 '0';
	block75_on <= '1' when (BLOCK75_L <= pix_x) and (pix_x <= BLOCK75_R) and
								 (BLOCK75_T <= pix_y) and (pix_y <= BLOCK75_B) and 
								 block75_alive_reg = '1' else
					 '0';
	block76_on <= '1' when (BLOCK76_L <= pix_x) and (pix_x <= BLOCK76_R) and
								 (BLOCK76_T <= pix_y) and (pix_y <= BLOCK76_B) and 
								 block76_alive_reg = '1' else
					 '0';
	block77_on <= '1' when (BLOCK77_L <= pix_x) and (pix_x <= BLOCK77_R) and
								 (BLOCK77_T <= pix_y) and (pix_y <= BLOCK77_B) and 
								 block77_alive_reg = '1' else
					 '0';
	block78_on <= '1' when (BLOCK78_L <= pix_x) and (pix_x <= BLOCK78_R) and
								 (BLOCK78_T <= pix_y) and (pix_y <= BLOCK78_B) and 
								 block78_alive_reg = '1' else
					 '0';
	block79_on <= '1' when (BLOCK79_L <= pix_x) and (pix_x <= BLOCK79_R) and
								 (BLOCK79_T <= pix_y) and (pix_y <= BLOCK79_B) and 
								 block79_alive_reg = '1' else
					 '0';
	block80_on <= '1' when (BLOCK80_L <= pix_x) and (pix_x <= BLOCK80_R) and
								 (BLOCK80_T <= pix_y) and (pix_y <= BLOCK80_B) and 
								 block80_alive_reg = '1' else
					 '0';
	block81_on <= '1' when (BLOCK81_L <= pix_x) and (pix_x <= BLOCK81_R) and
								 (BLOCK81_T <= pix_y) and (pix_y <= BLOCK81_B) and 
								 block81_alive_reg = '1' else
					 '0';
	block82_on <= '1' when (BLOCK82_L <= pix_x) and (pix_x <= BLOCK82_R) and
								 (BLOCK82_T <= pix_y) and (pix_y <= BLOCK82_B) and 
								 block82_alive_reg = '1' else
					 '0';
	block83_on <= '1' when (BLOCK83_L <= pix_x) and (pix_x <= BLOCK83_R) and
								 (BLOCK83_T <= pix_y) and (pix_y <= BLOCK83_B) and 
								 block83_alive_reg = '1' else
					 '0';
	block84_on <= '1' when (BLOCK84_L <= pix_x) and (pix_x <= BLOCK84_R) and
								 (BLOCK84_T <= pix_y) and (pix_y <= BLOCK84_B) and 
								 block84_alive_reg = '1' else
					 '0';
	block85_on <= '1' when (BLOCK85_L <= pix_x) and (pix_x <= BLOCK85_R) and
								 (BLOCK85_T <= pix_y) and (pix_y <= BLOCK85_B) and 
								 block85_alive_reg = '1' else
					 '0';				 
	block86_on <= '1' when (BLOCK86_L <= pix_x) and (pix_x <= BLOCK86_R) and
								 (BLOCK86_T <= pix_y) and (pix_y <= BLOCK86_B) and 
								 block86_alive_reg = '1' else
					 '0';
	block87_on <= '1' when (BLOCK87_L <= pix_x) and (pix_x <= BLOCK87_R) and
								 (BLOCK87_T <= pix_y) and (pix_y <= BLOCK87_B) and 
								 block87_alive_reg = '1' else
					 '0';
	block88_on <= '1' when (BLOCK88_L <= pix_x) and (pix_x <= BLOCK88_R) and
								 (BLOCK88_T <= pix_y) and (pix_y <= BLOCK88_B) and 
								 block88_alive_reg = '1' else
					 '0';
	block89_on <= '1' when (BLOCK89_L <= pix_x) and (pix_x <= BLOCK89_R) and
								 (BLOCK89_T <= pix_y) and (pix_y <= BLOCK89_B) and 
								 block89_alive_reg = '1' else
					 '0';
	block90_on <= '1' when (BLOCK90_L <= pix_x) and (pix_x <= BLOCK90_R) and
								 (BLOCK90_T <= pix_y) and (pix_y <= BLOCK90_B) and 
								 block90_alive_reg = '1' else
					 '0';
	block91_on <= '1' when (BLOCK91_L <= pix_x) and (pix_x <= BLOCK91_R) and
								 (BLOCK91_T <= pix_y) and (pix_y <= BLOCK91_B) and 
								 block91_alive_reg = '1' else
					 '0';
	block92_on <= '1' when (BLOCK92_L <= pix_x) and (pix_x <= BLOCK92_R) and
								 (BLOCK92_T <= pix_y) and (pix_y <= BLOCK92_B) and 
								 block92_alive_reg = '1' else
					 '0';
	block93_on <= '1' when (BLOCK93_L <= pix_x) and (pix_x <= BLOCK93_R) and
								 (BLOCK93_T <= pix_y) and (pix_y <= BLOCK93_B) and 
								 block93_alive_reg = '1' else
					 '0';
	block94_on <= '1' when (BLOCK94_L <= pix_x) and (pix_x <= BLOCK94_R) and
								 (BLOCK94_T <= pix_y) and (pix_y <= BLOCK94_B) and 
								 block94_alive_reg = '1' else
					 '0';
	block95_on <= '1' when (BLOCK95_L <= pix_x) and (pix_x <= BLOCK95_R) and
								 (BLOCK95_T <= pix_y) and (pix_y <= BLOCK95_B) and 
								 block95_alive_reg = '1' else
					 '0';
	block96_on <= '1' when (BLOCK96_L <= pix_x) and (pix_x <= BLOCK96_R) and
								 (BLOCK96_T <= pix_y) and (pix_y <= BLOCK96_B) and 
								 block96_alive_reg = '1' else
					 '0';
	block97_on <= '1' when (BLOCK97_L <= pix_x) and (pix_x <= BLOCK97_R) and
								 (BLOCK97_T <= pix_y) and (pix_y <= BLOCK97_B) and 
								 block97_alive_reg = '1' else
					 '0';
	block98_on <= '1' when (BLOCK98_L <= pix_x) and (pix_x <= BLOCK98_R) and
								 (BLOCK98_T <= pix_y) and (pix_y <= BLOCK98_B) and 
								 block98_alive_reg = '1' else
					 '0';
	block99_on <= '1' when (BLOCK99_L <= pix_x) and (pix_x <= BLOCK99_R) and
								 (BLOCK99_T <= pix_y) and (pix_y <= BLOCK99_B) and 
								 block99_alive_reg = '1' else
					 '0';
	block100_on <= '1' when (BLOCK100_L <= pix_x) and (pix_x <= BLOCK100_R) and
								 (BLOCK100_T <= pix_y) and (pix_y <= BLOCK100_B) and 
								 block100_alive_reg = '1' else
					 '0';				 
	block101_on <= '1' when (BLOCK101_L <= pix_x) and (pix_x <= BLOCK101_R) and
								 (BLOCK101_T <= pix_y) and (pix_y <= BLOCK101_B) and 
								 block101_alive_reg = '1' else
					 '0';
	block102_on <= '1' when (BLOCK102_L <= pix_x) and (pix_x <= BLOCK102_R) and
								 (BLOCK102_T <= pix_y) and (pix_y <= BLOCK102_B) and 
								 block102_alive_reg = '1' else
					 '0';
	block103_on <= '1' when (BLOCK103_L <= pix_x) and (pix_x <= BLOCK103_R) and
								 (BLOCK103_T <= pix_y) and (pix_y <= BLOCK103_B) and 
								 block103_alive_reg = '1' else
					 '0';
	block104_on <= '1' when (BLOCK104_L <= pix_x) and (pix_x <= BLOCK104_R) and
								 (BLOCK104_T <= pix_y) and (pix_y <= BLOCK104_B) and 
								 block104_alive_reg = '1' else
					 '0';
	block105_on <= '1' when (BLOCK105_L <= pix_x) and (pix_x <= BLOCK105_R) and
								 (BLOCK105_T <= pix_y) and (pix_y <= BLOCK105_B) and 
								 block105_alive_reg = '1' else
					 '0';
	block106_on <= '1' when (BLOCK106_L <= pix_x) and (pix_x <= BLOCK106_R) and
								 (BLOCK106_T <= pix_y) and (pix_y <= BLOCK106_B) and 
								 block106_alive_reg = '1' else
					 '0';
	block107_on <= '1' when (BLOCK107_L <= pix_x) and (pix_x <= BLOCK107_R) and
								 (BLOCK107_T <= pix_y) and (pix_y <= BLOCK107_B) and 
								 block107_alive_reg = '1' else
					 '0';
	block108_on <= '1' when (BLOCK108_L <= pix_x) and (pix_x <= BLOCK108_R) and
								 (BLOCK108_T <= pix_y) and (pix_y <= BLOCK108_B) and 
								 block108_alive_reg = '1' else
					 '0';
	block109_on <= '1' when (BLOCK109_L <= pix_x) and (pix_x <= BLOCK109_R) and
								 (BLOCK109_T <= pix_y) and (pix_y <= BLOCK109_B) and 
								 block109_alive_reg = '1' else
					 '0';
	block110_on <= '1' when (BLOCK110_L <= pix_x) and (pix_x <= BLOCK110_R) and
								 (BLOCK110_T <= pix_y) and (pix_y <= BLOCK110_B) and 
								 block110_alive_reg = '1' else
					 '0';
	block111_on <= '1' when (BLOCK111_L <= pix_x) and (pix_x <= BLOCK111_R) and
								 (BLOCK111_T <= pix_y) and (pix_y <= BLOCK111_B) and 
								 block111_alive_reg = '1' else
					 '0';
	block112_on <= '1' when (BLOCK112_L <= pix_x) and (pix_x <= BLOCK112_R) and
								 (BLOCK112_T <= pix_y) and (pix_y <= BLOCK112_B) and 
								 block112_alive_reg = '1' else
					 '0';
	first_block_rgb <= "100";
	second_block_rgb <= "001";
	third_block_rgb <= "010";
	forth_block_rgb <= "110";
	
	ball_x_l <= ball_x_reg;
	ball_y_t <= ball_y_reg;
	ball_x_r <= ball_x_l + BALL_SIZE-1;
	ball_y_b <= ball_y_t + BALL_SIZE-1;
			
	rd_ball_on <= 
		'1' when (ball_x_l <= pix_x) and (pix_x <= ball_x_r) and	
					 (ball_y_t <= pix_y) and (pix_y <= ball_y_b) else
		'0';
	
	ball_rgb <= "111";
	
	ball_x_next <= to_unsigned(310, 10) when gra_still = '1' else
						ball_x_reg + x_delta_reg 
							when refr_tick = '1' else
						ball_x_reg;
	ball_y_next <= to_unsigned(250, 10) when gra_still = '1' else
						ball_y_reg + y_delta_reg
							when refr_tick = '1' else
						ball_y_reg;
						
	process(x_delta_reg, y_delta_reg, ball_y_t, ball_x_l, ball_x_r,
				 ball_y_b, bar_x_l, bar_x_r, ball_y_reg,
				block1_alive_reg, block2_alive_reg, block3_alive_reg, block4_alive_reg, block5_alive_reg, block6_alive_reg,
				 block7_alive_reg, block8_alive_reg, block9_alive_reg, block10_alive_reg, block11_alive_reg, block12_alive_reg,
				 block13_alive_reg, block14_alive_reg, block15_alive_reg,
				 block16_alive_reg, block17_alive_reg, block18_alive_reg, block19_alive_reg, block20_alive_reg,
				 block21_alive_reg, block22_alive_reg, block23_alive_reg, block24_alive_reg, block25_alive_reg, block26_alive_reg,
				 block27_alive_reg, block28_alive_reg, block29_alive_reg, block30_alive_reg,
				 block31_alive_reg, block32_alive_reg, block33_alive_reg, block34_alive_reg,
				 block35_alive_reg, block36_alive_reg, block37_alive_reg, block38_alive_reg, block39_alive_reg, block40_alive_reg,
				 block41_alive_reg, block42_alive_reg, block43_alive_reg, block44_alive_reg, block45_alive_reg, block46_alive_reg, block47_alive_reg, block48_alive_reg,
				 block49_alive_reg, block50_alive_reg, block51_alive_reg, block52_alive_reg, block53_alive_reg, block54_alive_reg,
				 block55_alive_reg, block56_alive_reg, block57_alive_reg, block58_alive_reg, block59_alive_reg, block60_alive_reg, block61_alive_reg, block62_alive_reg,
				 block63_alive_reg, block64_alive_reg, block65_alive_reg, block66_alive_reg, block67_alive_reg, block68_alive_reg,
				 block69_alive_reg, block70_alive_reg,  block71_alive_reg, block72_alive_reg, block73_alive_reg, block74_alive_reg, block75_alive_reg, block76_alive_reg,
				 block77_alive_reg, block78_alive_reg, block79_alive_reg, block80_alive_reg, block81_alive_reg, block82_alive_reg,
				 block83_alive_reg, block84_alive_reg,  block85_alive_reg, block86_alive_reg, block87_alive_reg, block88_alive_reg, block89_alive_reg, block90_alive_reg,
				 block91_alive_reg, block92_alive_reg, block93_alive_reg, block94_alive_reg, block95_alive_reg, block96_alive_reg,
				 block97_alive_reg, block98_alive_reg, block99_alive_reg, block100_alive_reg, block101_alive_reg, block102_alive_reg, block103_alive_reg, block104_alive_reg,
				 block105_alive_reg, block106_alive_reg, block107_alive_reg, block108_alive_reg, block109_alive_reg, block110_alive_reg,
				 block111_alive_reg, block112_alive_reg)
	begin
		hit <= '0';
		miss <= '0';
		x_delta_next <= x_delta_reg;
		y_delta_next <= y_delta_reg;
		block1_alive_next <= block1_alive_reg;
		block2_alive_next <= block2_alive_reg;
		block3_alive_next <= block3_alive_reg;
		block4_alive_next <= block4_alive_reg;
		block5_alive_next <= block5_alive_reg;
		block6_alive_next <= block6_alive_reg;
		block7_alive_next <= block7_alive_reg;
		block8_alive_next <= block8_alive_reg;
		block9_alive_next <= block9_alive_reg;
		block10_alive_next <= block10_alive_reg;
		block11_alive_next <= block11_alive_reg;
		block12_alive_next <= block12_alive_reg;
		block13_alive_next <= block13_alive_reg;
		block14_alive_next <= block14_alive_reg;
		block15_alive_next <= block15_alive_reg;
		block16_alive_next <= block16_alive_reg;
		block17_alive_next <= block17_alive_reg;
		block18_alive_next <= block18_alive_reg;
		block19_alive_next <= block19_alive_reg;
		block20_alive_next <= block20_alive_reg;
		block21_alive_next <= block21_alive_reg;
		block22_alive_next <= block22_alive_reg;
		block23_alive_next <= block23_alive_reg;
		block24_alive_next <= block24_alive_reg;
		block25_alive_next <= block25_alive_reg;
		block26_alive_next <= block26_alive_reg;
		block27_alive_next <= block27_alive_reg;
		block28_alive_next <= block28_alive_reg;
		block29_alive_next <= block29_alive_reg;
		block30_alive_next <= block30_alive_reg;
		block31_alive_next <= block31_alive_reg;
		block32_alive_next <= block32_alive_reg;
		block33_alive_next <= block33_alive_reg;
		block34_alive_next <= block34_alive_reg;
		block35_alive_next <= block35_alive_reg;
		block36_alive_next <= block36_alive_reg;
		block37_alive_next <= block37_alive_reg;
		block38_alive_next <= block38_alive_reg;
		block39_alive_next <= block39_alive_reg;
		block40_alive_next <= block40_alive_reg;
		block41_alive_next <= block41_alive_reg;
		block42_alive_next <= block42_alive_reg;
		block43_alive_next <= block43_alive_reg;
		block44_alive_next <= block44_alive_reg;
		block45_alive_next <= block45_alive_reg;
		block46_alive_next <= block46_alive_reg;
		block47_alive_next <= block47_alive_reg;
		block48_alive_next <= block48_alive_reg;
		block49_alive_next <= block49_alive_reg;
		block50_alive_next <= block50_alive_reg;
		block51_alive_next <= block51_alive_reg;
		block52_alive_next <= block52_alive_reg;
		block53_alive_next <= block53_alive_reg;
		block54_alive_next <= block54_alive_reg;
		block55_alive_next <= block55_alive_reg;
		block56_alive_next <= block56_alive_reg;
		block57_alive_next <= block57_alive_reg;
		block58_alive_next <= block58_alive_reg;
		block59_alive_next <= block59_alive_reg;
		block60_alive_next <= block60_alive_reg;
		block61_alive_next <= block61_alive_reg;
		block62_alive_next <= block62_alive_reg;
		block63_alive_next <= block63_alive_reg;
		block64_alive_next <= block64_alive_reg;
		block65_alive_next <= block65_alive_reg;
		block66_alive_next <= block66_alive_reg;
		block67_alive_next <= block67_alive_reg;
		block68_alive_next <= block68_alive_reg;
		block69_alive_next <= block69_alive_reg;
		block70_alive_next <= block70_alive_reg;
		block71_alive_next <= block71_alive_reg;
		block72_alive_next <= block72_alive_reg;
		block73_alive_next <= block73_alive_reg;
		block74_alive_next <= block74_alive_reg;
		block75_alive_next <= block75_alive_reg;
		block76_alive_next <= block76_alive_reg;
		block77_alive_next <= block77_alive_reg;
		block78_alive_next <= block78_alive_reg;
		block79_alive_next <= block79_alive_reg;
		block80_alive_next <= block80_alive_reg;
		block81_alive_next <= block81_alive_reg;
		block82_alive_next <= block82_alive_reg;
		block83_alive_next <= block83_alive_reg;
		block84_alive_next <= block84_alive_reg;
		block85_alive_next <= block85_alive_reg;
		block86_alive_next <= block86_alive_reg;
		block87_alive_next <= block87_alive_reg;
		block88_alive_next <= block88_alive_reg;
		block89_alive_next <= block89_alive_reg;
		block90_alive_next <= block90_alive_reg;
		block91_alive_next <= block91_alive_reg;
		block92_alive_next <= block92_alive_reg;
		block93_alive_next <= block93_alive_reg;
		block94_alive_next <= block94_alive_reg;
		block95_alive_next <= block95_alive_reg;
		block96_alive_next <= block96_alive_reg;
		block97_alive_next <= block97_alive_reg;
		block98_alive_next <= block98_alive_reg;
		block99_alive_next <= block99_alive_reg;
		block100_alive_next <= block100_alive_reg;
		block101_alive_next <= block101_alive_reg;
		block102_alive_next <= block102_alive_reg;
		block103_alive_next <= block103_alive_reg;
		block104_alive_next <= block104_alive_reg;
		block105_alive_next <= block105_alive_reg;
		block106_alive_next <= block106_alive_reg;
		block107_alive_next <= block107_alive_reg;
		block108_alive_next <= block108_alive_reg;
		block109_alive_next <= block109_alive_reg;
		block110_alive_next <= block110_alive_reg;
		block111_alive_next <= block111_alive_reg;
		block112_alive_next <= block112_alive_reg;
		if gra_still = '1' then
			x_delta_next <= BALL_V_P;
			y_delta_next <= BALL_V_P;
		elsif ball_y_t < WALL_TOP_Y_B then
			y_delta_next <= BALL_V_P;
		elsif (ball_y_b > BAR_Y_T) and (ball_y_b <= BAR_Y_B) then
			if (bar_x_l <= ball_x_r) and (ball_x_l <= bar_x_r) then
				y_delta_next <= BALL_V_N;
			end if;
		elsif ball_x_l <= WALL_LEFT_X_R then
			x_delta_next <= BALL_V_P;
		elsif ball_x_l >= WALL_RIGHT_X_L then
			x_delta_next <= BALL_V_N;
		elsif ball_y_b > MAX_Y-1 then
			miss <= '1';
		end if;
		if (BLOCK1_B >= ball_y_t) and (ball_y_t >= BLOCK1_T) and block1_alive_reg = '1' then
			if (BLOCK1_L <= ball_x_r) and  (ball_x_l <= BLOCK1_R) then
				block1_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK1_T) and (ball_y_b <= BLOCK1_B) and block1_alive_reg = '1' then
			if (BLOCK1_L <= ball_x_r) and  (ball_x_l <= BLOCK1_R) then
				block1_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK1_L <= ball_x_r) and (ball_x_r <= BLOCK1_R) and block1_alive_reg = '1' then
			if (BLOCK1_T <= ball_y_b) and (ball_y_t <= BLOCK1_B) then
				block1_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK1_R) and (ball_x_l >= BLOCK1_L) and block1_alive_reg = '1' then
			if (BLOCK1_T <= ball_y_b) and (ball_y_t <= BLOCK1_B) then
				block1_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK2_B >= ball_y_t) and (ball_y_t >= BLOCK2_T) and block2_alive_reg = '1' then
			if (BLOCK2_L <= ball_x_r) and  (ball_x_l <= BLOCK2_R) then
				block2_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK2_T) and (ball_y_b <= BLOCK2_B) and block2_alive_reg = '1' then
			if (BLOCK2_L <= ball_x_r) and  (ball_x_l <= BLOCK2_R) then
				block2_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK2_L <= ball_x_r) and (ball_x_r <= BLOCK2_R) and block2_alive_reg = '1' then
			if (BLOCK2_T <= ball_y_b) and (ball_y_t <= BLOCK2_B) then
				block2_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK2_R) and (ball_x_l >= BLOCK2_L) and block2_alive_reg = '1'then
			if (BLOCK2_T <= ball_y_b) and (ball_y_t <= BLOCK2_B) then
				block2_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK3_B >= ball_y_t) and (ball_y_t >= BLOCK3_T) and block3_alive_reg = '1' then
			if (BLOCK3_L <= ball_x_r) and  (ball_x_l <= BLOCK3_R) then
				block3_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK3_T) and (ball_y_b <= BLOCK3_B) and block3_alive_reg = '1' then
			if (BLOCK3_L <= ball_x_r) and  (ball_x_l <= BLOCK3_R) then
				block3_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK3_L <= ball_x_r) and (ball_x_r <= BLOCK3_R) and block3_alive_reg = '1' then
			if (BLOCK3_T <= ball_y_b) and (ball_y_t <= BLOCK3_B) then
				block3_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK3_R) and (ball_x_l >= BLOCK3_L) and block3_alive_reg = '1'then
			if (BLOCK3_T <= ball_y_b) and (ball_y_t <= BLOCK3_B) then
				block3_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK4_B >= ball_y_t) and (ball_y_t >= BLOCK4_T) and block4_alive_reg = '1'then
			if (BLOCK4_L <= ball_x_r) and  (ball_x_l <= BLOCK4_R) then
				block4_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK4_T) and (ball_y_b <= BLOCK4_B) and block4_alive_reg = '1'then
			if (BLOCK4_L <= ball_x_r) and  (ball_x_l <= BLOCK4_R) then
				block4_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK4_L <= ball_x_r) and (ball_x_r <= BLOCK4_R) and block4_alive_reg = '1'then
			if (BLOCK4_T <= ball_y_b) and (ball_y_t <= BLOCK4_B) then
				block4_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK4_R) and (ball_x_l >= BLOCK4_L) and block4_alive_reg = '1'then
			if (BLOCK4_T <= ball_y_b) and (ball_y_t <= BLOCK4_B) then
				block4_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK5_B >= ball_y_t) and (ball_y_t >= BLOCK5_T) and block5_alive_reg = '1' then
			if (BLOCK5_L <= ball_x_r) and  (ball_x_l <= BLOCK5_R) then
				block5_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK5_T) and (ball_y_b <= BLOCK5_B) and block5_alive_reg = '1' then
			if (BLOCK5_L <= ball_x_r) and  (ball_x_l <= BLOCK5_R) then
				block5_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK5_L <= ball_x_r) and (ball_x_r <= BLOCK5_R) and block5_alive_reg = '1' then
			if (BLOCK5_T <= ball_y_b) and (ball_y_t <= BLOCK5_B) then
				block5_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK5_R) and (ball_x_l >= BLOCK5_L) and block5_alive_reg = '1'then
			if (BLOCK5_T <= ball_y_b) and (ball_y_t <= BLOCK5_B) then
				block5_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK6_B >= ball_y_t) and (ball_y_t >= BLOCK6_T) and block6_alive_reg = '1' then
			if (BLOCK6_L <= ball_x_r) and  (ball_x_l <= BLOCK6_R) then
				block6_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK6_T) and (ball_y_b <= BLOCK6_B) and block6_alive_reg = '1' then
			if (BLOCK6_L <= ball_x_r) and  (ball_x_l <= BLOCK6_R) then
				block6_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK6_L <= ball_x_r) and (ball_x_r <= BLOCK6_R) and block6_alive_reg = '1' then
			if (BLOCK6_T <= ball_y_b) and (ball_y_t <= BLOCK6_B) then
				block6_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK6_R) and (ball_x_l >= BLOCK6_L) and block6_alive_reg = '1' then
			if (BLOCK6_T <= ball_y_b) and (ball_y_t <= BLOCK6_B) then
				block6_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK7_B >= ball_y_t) and (ball_y_t >= BLOCK7_T) and block7_alive_reg = '1' then
			if (BLOCK7_L <= ball_x_r) and  (ball_x_l <= BLOCK7_R) then
				block7_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK7_T) and (ball_y_b <= BLOCK7_B) and block7_alive_reg = '1' then
			if (BLOCK7_L <= ball_x_r) and  (ball_x_l <= BLOCK7_R) then
				block7_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK7_L <= ball_x_r) and (ball_x_r <= BLOCK7_R) and block7_alive_reg = '1' then
			if (BLOCK7_T <= ball_y_b) and (ball_y_t <= BLOCK7_B) then
				block7_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK7_R) and (ball_x_l >= BLOCK7_L) and block7_alive_reg = '1' then
			if (BLOCK7_T <= ball_y_b) and (ball_y_t <= BLOCK7_B) then
				block7_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK8_B >= ball_y_t) and (ball_y_t >= BLOCK8_T) and block8_alive_reg = '1' then
			if (BLOCK8_L <= ball_x_r) and  (ball_x_l <= BLOCK8_R) then
				block8_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK8_T) and (ball_y_b <= BLOCK8_B) and block8_alive_reg = '1' then
			if (BLOCK8_L <= ball_x_r) and  (ball_x_l <= BLOCK8_R) then
				block8_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK8_L <= ball_x_r) and (ball_x_r <= BLOCK8_R) and block8_alive_reg = '1' then
			if (BLOCK8_T <= ball_y_b) and (ball_y_t <= BLOCK8_B) then
				block8_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK8_R) and (ball_x_l >= BLOCK8_L) and block8_alive_reg = '1' then
			if (BLOCK8_T <= ball_y_b) and (ball_y_t <= BLOCK8_B) then
				block8_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK9_B >= ball_y_t) and (ball_y_t >= BLOCK9_T) and block9_alive_reg = '1' then
			if (BLOCK9_L <= ball_x_r) and  (ball_x_l <= BLOCK9_R) then
				block9_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK9_T) and (ball_y_b <= BLOCK9_B) and block9_alive_reg = '1' then
			if (BLOCK9_L <= ball_x_r) and  (ball_x_l <= BLOCK9_R) then
				block9_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK9_L <= ball_x_r) and (ball_x_r <= BLOCK9_R) and block9_alive_reg = '1' then
			if (BLOCK9_T <= ball_y_b) and (ball_y_t <= BLOCK9_B) then
				block9_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK9_R) and (ball_x_l >= BLOCK9_L) and block9_alive_reg = '1' then
			if (BLOCK9_T <= ball_y_b) and (ball_y_t <= BLOCK9_B) then
				block9_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK10_B >= ball_y_t) and (ball_y_t >= BLOCK10_T) and block10_alive_reg = '1' then
			if (BLOCK10_L <= ball_x_r) and  (ball_x_l <= BLOCK10_R) then
				block10_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK10_T) and (ball_y_b <= BLOCK10_B) and block10_alive_reg = '1' then
			if (BLOCK10_L <= ball_x_r) and  (ball_x_l <= BLOCK10_R) then
				block10_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK10_L <= ball_x_r) and (ball_x_r <= BLOCK10_R) and block10_alive_reg = '1' then
			if (BLOCK10_T <= ball_y_b) and (ball_y_t <= BLOCK10_B) then
				block10_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK10_R) and (ball_x_l >= BLOCK10_L) and block10_alive_reg = '1' then
			if (BLOCK10_T <= ball_y_b) and (ball_y_t <= BLOCK10_B) then
				block10_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK11_B >= ball_y_t) and (ball_y_t >= BLOCK11_T) and block11_alive_reg = '1' then
			if (BLOCK11_L <= ball_x_r) and  (ball_x_l <= BLOCK11_R) then
				block11_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK11_T) and (ball_y_b <= BLOCK11_B) and block11_alive_reg = '1' then
			if (BLOCK11_L <= ball_x_r) and  (ball_x_l <= BLOCK11_R) then
				block11_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK11_L <= ball_x_r) and (ball_x_r <= BLOCK11_R) and block11_alive_reg = '1' then
			if (BLOCK11_T <= ball_y_b) and (ball_y_t <= BLOCK11_B) then
				block11_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK11_R) and (ball_x_l >= BLOCK11_L) and block11_alive_reg = '1' then
			if (BLOCK11_T <= ball_y_b) and (ball_y_t <= BLOCK11_B) then
				block11_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK12_B >= ball_y_t) and (ball_y_t >= BLOCK12_T) and block12_alive_reg = '1' then
			if (BLOCK12_L <= ball_x_r) and  (ball_x_l <= BLOCK12_R) then
				block12_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK12_T) and (ball_y_b <= BLOCK12_B) and block12_alive_reg = '1' then
			if (BLOCK12_L <= ball_x_r) and  (ball_x_l <= BLOCK12_R) then
				block12_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK12_L <= ball_x_r) and (ball_x_r <= BLOCK12_R) and block12_alive_reg = '1' then
			if (BLOCK12_T <= ball_y_b) and (ball_y_t <= BLOCK12_B) then
				block12_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK12_R) and (ball_x_l >= BLOCK12_L) and block12_alive_reg = '1' then
			if (BLOCK12_T <= ball_y_b) and (ball_y_t <= BLOCK12_B) then
				block12_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK13_B >= ball_y_t) and (ball_y_t >= BLOCK13_T) and block13_alive_reg = '1' then
			if (BLOCK13_L <= ball_x_r) and  (ball_x_l <= BLOCK13_R) then
				block13_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK13_T) and (ball_y_b <= BLOCK13_B) and block13_alive_reg = '1' then
			if (BLOCK13_L <= ball_x_r) and  (ball_x_l <= BLOCK13_R) then
				block13_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK13_L <= ball_x_r) and (ball_x_r <= BLOCK13_R) and block13_alive_reg = '1' then
			if (BLOCK13_T <= ball_y_b) and (ball_y_t <= BLOCK13_B) then
				block13_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK13_R) and (ball_x_l >= BLOCK13_L) and block13_alive_reg = '1' then
			if (BLOCK13_T <= ball_y_b) and (ball_y_t <= BLOCK13_B) then
				block13_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK14_B >= ball_y_t) and (ball_y_t >= BLOCK14_T) and block14_alive_reg = '1' then
			if (BLOCK14_L <= ball_x_r) and  (ball_x_l <= BLOCK14_R) then
				block14_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK14_T) and (ball_y_b <= BLOCK14_B) and block14_alive_reg = '1' then
			if (BLOCK14_L <= ball_x_r) and  (ball_x_l <= BLOCK14_R) then
				block14_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK14_L <= ball_x_r) and (ball_x_r <= BLOCK14_R) and block14_alive_reg = '1' then
			if (BLOCK14_T <= ball_y_b) and (ball_y_t <= BLOCK14_B) then
				block14_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK14_R) and (ball_x_l >= BLOCK14_L) and block14_alive_reg = '1' then
			if (BLOCK14_T <= ball_y_b) and (ball_y_t <= BLOCK14_B) then
				block14_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK15_B >= ball_y_t) and (ball_y_t >= BLOCK15_T) and block15_alive_reg = '1' then
			if (BLOCK15_L <= ball_x_r) and  (ball_x_l <= BLOCK15_R) then
				block15_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK15_T) and (ball_y_b <= BLOCK15_B) and block15_alive_reg = '1' then
			if (BLOCK15_L <= ball_x_r) and  (ball_x_l <= BLOCK15_R) then
				block15_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK15_L <= ball_x_r) and (ball_x_r <= BLOCK15_R) and block15_alive_reg = '1' then
			if (BLOCK15_T <= ball_y_b) and (ball_y_t <= BLOCK15_B) then
				block15_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK15_R) and (ball_x_l >= BLOCK15_L) and block15_alive_reg = '1' then
			if (BLOCK15_T <= ball_y_b) and (ball_y_t <= BLOCK15_B) then
				block15_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK16_B >= ball_y_t) and (ball_y_t >= BLOCK16_T) and block16_alive_reg = '1' then
			if (BLOCK16_L <= ball_x_r) and  (ball_x_l <= BLOCK16_R) then
				block16_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK16_T) and (ball_y_b <= BLOCK16_B) and block16_alive_reg = '1' then
			if (BLOCK16_L <= ball_x_r) and  (ball_x_l <= BLOCK16_R) then
				block16_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK16_L <= ball_x_r) and (ball_x_r <= BLOCK16_R) and block16_alive_reg = '1' then
			if (BLOCK16_T <= ball_y_b) and (ball_y_t <= BLOCK16_B) then
				block16_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK16_R) and (ball_x_l >= BLOCK16_L) and block16_alive_reg = '1' then
			if (BLOCK16_T <= ball_y_b) and (ball_y_t <= BLOCK16_B) then
				block16_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK17_B >= ball_y_t) and (ball_y_t >= BLOCK17_T) and block17_alive_reg = '1' then
			if (BLOCK17_L <= ball_x_r) and  (ball_x_l <= BLOCK17_R) then
				block17_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK17_T) and (ball_y_b <= BLOCK17_B) and block17_alive_reg = '1' then
			if (BLOCK17_L <= ball_x_r) and  (ball_x_l <= BLOCK17_R) then
				block17_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK17_L <= ball_x_r) and (ball_x_r <= BLOCK17_R) and block17_alive_reg = '1' then
			if (BLOCK17_T <= ball_y_b) and (ball_y_t <= BLOCK17_B) then
				block17_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK17_R) and (ball_x_l >= BLOCK17_L) and block17_alive_reg = '1' then
			if (BLOCK17_T <= ball_y_b) and (ball_y_t <= BLOCK17_B) then
				block17_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK18_B >= ball_y_t) and (ball_y_t >= BLOCK18_T) and block18_alive_reg = '1' then
			if (BLOCK18_L <= ball_x_r) and  (ball_x_l <= BLOCK18_R) then
				block18_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK18_T) and (ball_y_b <= BLOCK18_B) and block18_alive_reg = '1' then
			if (BLOCK18_L <= ball_x_r) and  (ball_x_l <= BLOCK18_R) then
				block18_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK18_L <= ball_x_r) and (ball_x_r <= BLOCK18_R) and block18_alive_reg = '1' then
			if (BLOCK18_T <= ball_y_b) and (ball_y_t <= BLOCK18_B) then
				block18_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK18_R) and (ball_x_l >= BLOCK18_L) and block18_alive_reg = '1' then
			if (BLOCK18_T <= ball_y_b) and (ball_y_t <= BLOCK18_B) then
				block18_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK19_B >= ball_y_t) and (ball_y_t >= BLOCK19_T) and block19_alive_reg = '1' then
			if (BLOCK19_L <= ball_x_r) and  (ball_x_l <= BLOCK19_R) then
				block19_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK19_T) and (ball_y_b <= BLOCK19_B) and block19_alive_reg = '1' then
			if (BLOCK19_L <= ball_x_r) and  (ball_x_l <= BLOCK19_R) then
				block19_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK19_L <= ball_x_r) and (ball_x_r <= BLOCK19_R) and block19_alive_reg = '1' then
			if (BLOCK19_T <= ball_y_b) and (ball_y_t <= BLOCK19_B) then
				block19_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK19_R) and (ball_x_l >= BLOCK19_L) and block19_alive_reg = '1' then
			if (BLOCK19_T <= ball_y_b) and (ball_y_t <= BLOCK19_B) then
				block19_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK20_B >= ball_y_t) and (ball_y_t >= BLOCK20_T) and block20_alive_reg = '1' then
			if (BLOCK20_L <= ball_x_r) and  (ball_x_l <= BLOCK20_R) then
				block20_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK20_T) and (ball_y_b <= BLOCK20_B) and block20_alive_reg = '1' then
			if (BLOCK20_L <= ball_x_r) and  (ball_x_l <= BLOCK20_R) then
				block20_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK20_L <= ball_x_r) and (ball_x_r <= BLOCK20_R) and block20_alive_reg = '1' then
			if (BLOCK20_T <= ball_y_b) and (ball_y_t <= BLOCK20_B) then
				block20_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK20_R) and (ball_x_l >= BLOCK20_L) and block20_alive_reg = '1' then
			if (BLOCK20_T <= ball_y_b) and (ball_y_t <= BLOCK20_B) then
				block20_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK21_B >= ball_y_t) and (ball_y_t >= BLOCK21_T) and block21_alive_reg = '1' then
			if (BLOCK21_L <= ball_x_r) and  (ball_x_l <= BLOCK21_R) then
				block21_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK21_T) and (ball_y_b <= BLOCK21_B) and block21_alive_reg = '1' then
			if (BLOCK21_L <= ball_x_r) and  (ball_x_l <= BLOCK21_R) then
				block21_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK21_L <= ball_x_r) and (ball_x_r <= BLOCK21_R) and block21_alive_reg = '1' then
			if (BLOCK21_T <= ball_y_b) and (ball_y_t <= BLOCK21_B) then
				block21_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK21_R) and (ball_x_l >= BLOCK21_L) and block21_alive_reg = '1' then
			if (BLOCK21_T <= ball_y_b) and (ball_y_t <= BLOCK21_B) then
				block21_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK22_B >= ball_y_t) and (ball_y_t >= BLOCK22_T) and block22_alive_reg = '1' then
			if (BLOCK22_L <= ball_x_r) and  (ball_x_l <= BLOCK22_R) then
				block22_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK22_T) and (ball_y_b <= BLOCK22_B) and block22_alive_reg = '1' then
			if (BLOCK22_L <= ball_x_r) and  (ball_x_l <= BLOCK22_R) then
				block22_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK22_L <= ball_x_r) and (ball_x_r <= BLOCK22_R) and block22_alive_reg = '1' then
			if (BLOCK22_T <= ball_y_b) and (ball_y_t <= BLOCK22_B) then
				block22_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK22_R) and (ball_x_l >= BLOCK22_L) and block22_alive_reg = '1' then
			if (BLOCK22_T <= ball_y_b) and (ball_y_t <= BLOCK22_B) then
				block22_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK23_B >= ball_y_t) and (ball_y_t >= BLOCK23_T) and block23_alive_reg = '1' then
			if (BLOCK23_L <= ball_x_r) and  (ball_x_l <= BLOCK23_R) then
				block23_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK23_T) and (ball_y_b <= BLOCK23_B) and block23_alive_reg = '1' then
			if (BLOCK23_L <= ball_x_r) and  (ball_x_l <= BLOCK23_R) then
				block23_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK23_L <= ball_x_r) and (ball_x_r <= BLOCK23_R) and block23_alive_reg = '1' then
			if (BLOCK23_T <= ball_y_b) and (ball_y_t <= BLOCK23_B) then
				block23_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK23_R) and (ball_x_l >= BLOCK23_L) and block23_alive_reg = '1' then
			if (BLOCK23_T <= ball_y_b) and (ball_y_t <= BLOCK23_B) then
				block23_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK24_B >= ball_y_t) and (ball_y_t >= BLOCK24_T) and block24_alive_reg = '1' then
			if (BLOCK24_L <= ball_x_r) and  (ball_x_l <= BLOCK24_R) then
				block24_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK24_T) and (ball_y_b <= BLOCK24_B) and block24_alive_reg = '1' then
			if (BLOCK24_L <= ball_x_r) and  (ball_x_l <= BLOCK24_R) then
				block24_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK24_L <= ball_x_r) and (ball_x_r <= BLOCK24_R) and block24_alive_reg = '1' then
			if (BLOCK24_T <= ball_y_b) and (ball_y_t <= BLOCK24_B) then
				block24_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK24_R) and (ball_x_l >= BLOCK24_L) and block24_alive_reg = '1' then
			if (BLOCK24_T <= ball_y_b) and (ball_y_t <= BLOCK24_B) then
				block24_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if; 
		end if;
		if (BLOCK25_B >= ball_y_t) and (ball_y_t >= BLOCK25_T) and block25_alive_reg = '1' then
			if (BLOCK25_L <= ball_x_r) and  (ball_x_l <= BLOCK25_R) then
				block25_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK25_T) and (ball_y_b <= BLOCK25_B) and block25_alive_reg = '1' then
			if (BLOCK25_L <= ball_x_r) and  (ball_x_l <= BLOCK25_R) then
				block25_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK25_L <= ball_x_r) and (ball_x_r <= BLOCK25_R) and block25_alive_reg = '1' then
			if (BLOCK25_T <= ball_y_b) and (ball_y_t <= BLOCK25_B) then
				block25_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK25_R) and (ball_x_l >= BLOCK25_L) and block25_alive_reg = '1' then
			if (BLOCK25_T <= ball_y_b) and (ball_y_t <= BLOCK25_B) then
				block25_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK26_B >= ball_y_t) and (ball_y_t >= BLOCK26_T) and block26_alive_reg = '1' then
			if (BLOCK26_L <= ball_x_r) and  (ball_x_l <= BLOCK26_R) then
				block26_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK26_T) and (ball_y_b <= BLOCK26_B) and block26_alive_reg = '1' then
			if (BLOCK26_L <= ball_x_r) and  (ball_x_l <= BLOCK26_R) then
				block26_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK26_L <= ball_x_r) and (ball_x_r <= BLOCK26_R) and block26_alive_reg = '1' then
			if (BLOCK26_T <= ball_y_b) and (ball_y_t <= BLOCK26_B) then
				block26_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK26_R) and (ball_x_l >= BLOCK26_L) and block26_alive_reg = '1' then
			if (BLOCK26_T <= ball_y_b) and (ball_y_t <= BLOCK26_B) then
				block26_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK27_B >= ball_y_t) and (ball_y_t >= BLOCK27_T) and block27_alive_reg = '1' then
			if (BLOCK27_L <= ball_x_r) and  (ball_x_l <= BLOCK27_R) then
				block27_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK27_T) and (ball_y_b <= BLOCK27_B) and block27_alive_reg = '1' then
			if (BLOCK27_L <= ball_x_r) and  (ball_x_l <= BLOCK27_R) then
				block27_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK27_L <= ball_x_r) and (ball_x_r <= BLOCK27_R) and block27_alive_reg = '1' then
			if (BLOCK27_T <= ball_y_b) and (ball_y_t <= BLOCK27_B) then
				block27_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK27_R) and (ball_x_l >= BLOCK27_L) and block27_alive_reg = '1' then
			if (BLOCK27_T <= ball_y_b) and (ball_y_t <= BLOCK27_B) then
				block27_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK28_B >= ball_y_t) and (ball_y_t >= BLOCK28_T) and block28_alive_reg = '1' then
			if (BLOCK28_L <= ball_x_r) and  (ball_x_l <= BLOCK28_R) then
				block28_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK28_T) and (ball_y_b <= BLOCK28_B) and block28_alive_reg = '1' then
			if (BLOCK28_L <= ball_x_r) and  (ball_x_l <= BLOCK28_R) then
				block28_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK28_L <= ball_x_r) and (ball_x_r <= BLOCK28_R) and block28_alive_reg = '1' then
			if (BLOCK28_T <= ball_y_b) and (ball_y_t <= BLOCK28_B) then
				block28_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK28_R) and (ball_x_l >= BLOCK28_L) and block28_alive_reg = '1' then
			if (BLOCK28_T <= ball_y_b) and (ball_y_t <= BLOCK28_B) then
				block28_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK29_B >= ball_y_t) and (ball_y_t >= BLOCK29_T) and block29_alive_reg = '1' then
			if (BLOCK29_L <= ball_x_r) and  (ball_x_l <= BLOCK29_R) then
				block29_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK29_T) and (ball_y_b <= BLOCK29_B) and block29_alive_reg = '1' then
			if (BLOCK29_L <= ball_x_r) and  (ball_x_l <= BLOCK29_R) then
				block29_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK29_L <= ball_x_r) and (ball_x_r <= BLOCK29_R) and block29_alive_reg = '1' then
			if (BLOCK29_T <= ball_y_b) and (ball_y_t <= BLOCK29_B) then
				block29_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK29_R) and (ball_x_l >= BLOCK29_L) and block29_alive_reg = '1' then
			if (BLOCK29_T <= ball_y_b) and (ball_y_t <= BLOCK29_B) then
				block29_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK30_B >= ball_y_t) and (ball_y_t >= BLOCK30_T) and block30_alive_reg = '1' then
			if (BLOCK30_L <= ball_x_r) and  (ball_x_l <= BLOCK30_R) then
				block30_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK30_T) and (ball_y_b <= BLOCK30_B) and block30_alive_reg = '1' then
			if (BLOCK30_L <= ball_x_r) and  (ball_x_l <= BLOCK30_R) then
				block30_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK30_L <= ball_x_r) and (ball_x_r <= BLOCK30_R) and block30_alive_reg = '1' then
			if (BLOCK30_T <= ball_y_b) and (ball_y_t <= BLOCK30_B) then
				block30_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK30_R) and (ball_x_l >= BLOCK30_L) and block30_alive_reg = '1' then
			if (BLOCK30_T <= ball_y_b) and (ball_y_t <= BLOCK30_B) then
				block30_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK31_B >= ball_y_t) and (ball_y_t >= BLOCK31_T) and block31_alive_reg = '1' then
			if (BLOCK31_L <= ball_x_r) and  (ball_x_l <= BLOCK31_R) then
				block31_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK31_T) and (ball_y_b <= BLOCK31_B) and block31_alive_reg = '1' then
			if (BLOCK31_L <= ball_x_r) and  (ball_x_l <= BLOCK31_R) then
				block31_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK31_L <= ball_x_r) and (ball_x_r <= BLOCK31_R) and block31_alive_reg = '1' then
			if (BLOCK31_T <= ball_y_b) and (ball_y_t <= BLOCK31_B) then
				block31_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK31_R) and (ball_x_l >= BLOCK31_L) and block31_alive_reg = '1' then
			if (BLOCK31_T <= ball_y_b) and (ball_y_t <= BLOCK31_B) then
				block31_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK32_B >= ball_y_t) and (ball_y_t >= BLOCK32_T) and block32_alive_reg = '1' then
			if (BLOCK32_L <= ball_x_r) and  (ball_x_l <= BLOCK32_R) then
				block32_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK32_T) and (ball_y_b <= BLOCK32_B) and block32_alive_reg = '1' then
			if (BLOCK32_L <= ball_x_r) and  (ball_x_l <= BLOCK32_R) then
				block32_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK32_L <= ball_x_r) and (ball_x_r <= BLOCK32_R) and block32_alive_reg = '1' then
			if (BLOCK32_T <= ball_y_b) and (ball_y_t <= BLOCK32_B) then
				block32_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK32_R) and (ball_x_l >= BLOCK32_L) and block32_alive_reg = '1' then
			if (BLOCK32_T <= ball_y_b) and (ball_y_t <= BLOCK32_B) then
				block32_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK33_B >= ball_y_t) and (ball_y_t >= BLOCK33_T) and block33_alive_reg = '1' then
			if (BLOCK33_L <= ball_x_r) and  (ball_x_l <= BLOCK33_R) then
				block33_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK33_T) and (ball_y_b <= BLOCK33_B) and block33_alive_reg = '1' then
			if (BLOCK33_L <= ball_x_r) and  (ball_x_l <= BLOCK33_R) then
				block33_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK33_L <= ball_x_r) and (ball_x_r <= BLOCK33_R) and block33_alive_reg = '1' then
			if (BLOCK33_T <= ball_y_b) and (ball_y_t <= BLOCK33_B) then
				block33_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK33_R) and (ball_x_l >= BLOCK33_L) and block33_alive_reg = '1' then
			if (BLOCK33_T <= ball_y_b) and (ball_y_t <= BLOCK33_B) then
				block33_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK34_B >= ball_y_t) and (ball_y_t >= BLOCK34_T) and block34_alive_reg = '1' then
			if (BLOCK34_L <= ball_x_r) and  (ball_x_l <= BLOCK34_R) then
				block34_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK34_T) and (ball_y_b <= BLOCK34_B) and block34_alive_reg = '1' then
			if (BLOCK34_L <= ball_x_r) and  (ball_x_l <= BLOCK34_R) then
				block34_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK34_L <= ball_x_r) and (ball_x_r <= BLOCK34_R) and block34_alive_reg = '1' then
			if (BLOCK34_T <= ball_y_b) and (ball_y_t <= BLOCK34_B) then
				block34_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK34_R) and (ball_x_l >= BLOCK34_L) and block34_alive_reg = '1' then
			if (BLOCK34_T <= ball_y_b) and (ball_y_t <= BLOCK34_B) then
				block34_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK35_B >= ball_y_t) and (ball_y_t >= BLOCK35_T) and block35_alive_reg = '1' then
			if (BLOCK35_L <= ball_x_r) and  (ball_x_l <= BLOCK35_R) then
				block35_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK35_T) and (ball_y_b <= BLOCK35_B) and block35_alive_reg = '1' then
			if (BLOCK35_L <= ball_x_r) and  (ball_x_l <= BLOCK35_R) then
				block35_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK35_L <= ball_x_r) and (ball_x_r <= BLOCK35_R) and block35_alive_reg = '1' then
			if (BLOCK35_T <= ball_y_b) and (ball_y_t <= BLOCK35_B) then
				block35_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK35_R) and (ball_x_l >= BLOCK35_L) and block35_alive_reg = '1' then
			if (BLOCK35_T <= ball_y_b) and (ball_y_t <= BLOCK35_B) then
				block35_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK36_B >= ball_y_t) and (ball_y_t >= BLOCK36_T) and block36_alive_reg = '1' then
			if (BLOCK36_L <= ball_x_r) and  (ball_x_l <= BLOCK36_R) then
				block36_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK36_T) and (ball_y_b <= BLOCK36_B) and block36_alive_reg = '1' then
			if (BLOCK36_L <= ball_x_r) and  (ball_x_l <= BLOCK36_R) then
				block36_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK36_L <= ball_x_r) and (ball_x_r <= BLOCK36_R) and block36_alive_reg = '1' then
			if (BLOCK36_T <= ball_y_b) and (ball_y_t <= BLOCK36_B) then
				block36_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK36_R) and (ball_x_l >= BLOCK36_L) and block36_alive_reg = '1' then
			if (BLOCK36_T <= ball_y_b) and (ball_y_t <= BLOCK36_B) then
				block36_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK37_B >= ball_y_t) and (ball_y_t >= BLOCK37_T) and block37_alive_reg = '1' then
			if (BLOCK37_L <= ball_x_r) and  (ball_x_l <= BLOCK37_R) then
				block37_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK37_T) and (ball_y_b <= BLOCK37_B) and block37_alive_reg = '1' then
			if (BLOCK37_L <= ball_x_r) and  (ball_x_l <= BLOCK37_R) then
				block37_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK37_L <= ball_x_r) and (ball_x_r <= BLOCK37_R) and block37_alive_reg = '1' then
			if (BLOCK37_T <= ball_y_b) and (ball_y_t <= BLOCK37_B) then
				block37_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK37_R) and (ball_x_l >= BLOCK37_L) and block37_alive_reg = '1' then
			if (BLOCK37_T <= ball_y_b) and (ball_y_t <= BLOCK37_B) then
				block37_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK38_B >= ball_y_t) and (ball_y_t >= BLOCK38_T) and block38_alive_reg = '1' then
			if (BLOCK38_L <= ball_x_r) and  (ball_x_l <= BLOCK38_R) then
				block38_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK38_T) and (ball_y_b <= BLOCK38_B) and block38_alive_reg = '1' then
			if (BLOCK38_L <= ball_x_r) and  (ball_x_l <= BLOCK38_R) then
				block38_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK38_L <= ball_x_r) and (ball_x_r <= BLOCK38_R) and block38_alive_reg = '1' then
			if (BLOCK38_T <= ball_y_b) and (ball_y_t <= BLOCK38_B) then
				block38_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK38_R) and (ball_x_l >= BLOCK38_L) and block38_alive_reg = '1' then
			if (BLOCK38_T <= ball_y_b) and (ball_y_t <= BLOCK38_B) then
				block38_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK39_B >= ball_y_t) and (ball_y_t >= BLOCK39_T) and block39_alive_reg = '1' then
			if (BLOCK39_L <= ball_x_r) and  (ball_x_l <= BLOCK39_R) then
				block39_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK39_T) and (ball_y_b <= BLOCK39_B) and block39_alive_reg = '1' then
			if (BLOCK39_L <= ball_x_r) and  (ball_x_l <= BLOCK39_R) then
				block39_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK39_L <= ball_x_r) and (ball_x_r <= BLOCK39_R) and block39_alive_reg = '1' then
			if (BLOCK39_T <= ball_y_b) and (ball_y_t <= BLOCK39_B) then
				block39_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK39_R) and (ball_x_l >= BLOCK39_L) and block39_alive_reg = '1' then
			if (BLOCK39_T <= ball_y_b) and (ball_y_t <= BLOCK39_B) then
				block39_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK40_B >= ball_y_t) and (ball_y_t >= BLOCK40_T) and block40_alive_reg = '1' then
			if (BLOCK40_L <= ball_x_r) and  (ball_x_l <= BLOCK40_R) then
				block40_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK40_T) and (ball_y_b <= BLOCK40_B) and block40_alive_reg = '1' then
			if (BLOCK40_L <= ball_x_r) and  (ball_x_l <= BLOCK40_R) then
				block40_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK40_L <= ball_x_r) and (ball_x_r <= BLOCK40_R) and block40_alive_reg = '1' then
			if (BLOCK40_T <= ball_y_b) and (ball_y_t <= BLOCK40_B) then
				block40_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK40_R) and (ball_x_l >= BLOCK40_L) and block40_alive_reg = '1' then
			if (BLOCK40_T <= ball_y_b) and (ball_y_t <= BLOCK40_B) then
				block40_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK41_B >= ball_y_t) and (ball_y_t >= BLOCK41_T) and block41_alive_reg = '1' then
			if (BLOCK41_L <= ball_x_r) and  (ball_x_l <= BLOCK41_R) then
				block41_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK41_T) and (ball_y_b <= BLOCK41_B) and block41_alive_reg = '1' then
			if (BLOCK41_L <= ball_x_r) and  (ball_x_l <= BLOCK41_R) then
				block41_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK41_L <= ball_x_r) and (ball_x_r <= BLOCK41_R) and block41_alive_reg = '1' then
			if (BLOCK41_T <= ball_y_b) and (ball_y_t <= BLOCK41_B) then
				block41_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK41_R) and (ball_x_l >= BLOCK41_L) and block41_alive_reg = '1' then
			if (BLOCK41_T <= ball_y_b) and (ball_y_t <= BLOCK41_B) then
				block41_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK42_B >= ball_y_t) and (ball_y_t >= BLOCK42_T) and block42_alive_reg = '1' then
			if (BLOCK42_L <= ball_x_r) and  (ball_x_l <= BLOCK42_R) then
				block42_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK42_T) and (ball_y_b <= BLOCK42_B) and block42_alive_reg = '1' then
			if (BLOCK42_L <= ball_x_r) and  (ball_x_l <= BLOCK42_R) then
				block42_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK42_L <= ball_x_r) and (ball_x_r <= BLOCK42_R) and block42_alive_reg = '1' then
			if (BLOCK42_T <= ball_y_b) and (ball_y_t <= BLOCK42_B) then
				block42_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK42_R) and (ball_x_l >= BLOCK42_L) and block42_alive_reg = '1' then
			if (BLOCK42_T <= ball_y_b) and (ball_y_t <= BLOCK42_B) then
				block42_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK43_B >= ball_y_t) and (ball_y_t >= BLOCK43_T) and block43_alive_reg = '1' then
			if (BLOCK43_L <= ball_x_r) and  (ball_x_l <= BLOCK43_R) then
				block43_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK43_T) and (ball_y_b <= BLOCK43_B) and block43_alive_reg = '1' then
			if (BLOCK43_L <= ball_x_r) and  (ball_x_l <= BLOCK43_R) then
				block43_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK43_L <= ball_x_r) and (ball_x_r <= BLOCK43_R) and block43_alive_reg = '1' then
			if (BLOCK43_T <= ball_y_b) and (ball_y_t <= BLOCK43_B) then
				block43_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK43_R) and (ball_x_l >= BLOCK43_L) and block43_alive_reg = '1' then
			if (BLOCK43_T <= ball_y_b) and (ball_y_t <= BLOCK43_B) then
				block43_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK44_B >= ball_y_t) and (ball_y_t >= BLOCK44_T) and block44_alive_reg = '1' then
			if (BLOCK44_L <= ball_x_r) and  (ball_x_l <= BLOCK44_R) then
				block44_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK44_T) and (ball_y_b <= BLOCK44_B) and block44_alive_reg = '1' then
			if (BLOCK44_L <= ball_x_r) and  (ball_x_l <= BLOCK44_R) then
				block44_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK44_L <= ball_x_r) and (ball_x_r <= BLOCK44_R) and block44_alive_reg = '1' then
			if (BLOCK44_T <= ball_y_b) and (ball_y_t <= BLOCK44_B) then
				block44_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK44_R) and (ball_x_l >= BLOCK44_L) and block44_alive_reg = '1' then
			if (BLOCK44_T <= ball_y_b) and (ball_y_t <= BLOCK44_B) then
				block44_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK45_B >= ball_y_t) and (ball_y_t >= BLOCK45_T) and block45_alive_reg = '1' then
			if (BLOCK45_L <= ball_x_r) and  (ball_x_l <= BLOCK45_R) then
				block45_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK45_T) and (ball_y_b <= BLOCK45_B) and block45_alive_reg = '1' then
			if (BLOCK45_L <= ball_x_r) and  (ball_x_l <= BLOCK45_R) then
				block45_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK45_L <= ball_x_r) and (ball_x_r <= BLOCK45_R) and block45_alive_reg = '1' then
			if (BLOCK45_T <= ball_y_b) and (ball_y_t <= BLOCK45_B) then
				block45_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK45_R) and (ball_x_l >= BLOCK45_L) and block45_alive_reg = '1' then
			if (BLOCK45_T <= ball_y_b) and (ball_y_t <= BLOCK45_B) then
				block45_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK46_B >= ball_y_t) and (ball_y_t >= BLOCK46_T) and block46_alive_reg = '1' then
			if (BLOCK46_L <= ball_x_r) and  (ball_x_l <= BLOCK46_R) then
				block46_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK46_T) and (ball_y_b <= BLOCK46_B) and block46_alive_reg = '1' then
			if (BLOCK46_L <= ball_x_r) and  (ball_x_l <= BLOCK46_R) then
				block46_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK46_L <= ball_x_r) and (ball_x_r <= BLOCK46_R) and block46_alive_reg = '1' then
			if (BLOCK46_T <= ball_y_b) and (ball_y_t <= BLOCK46_B) then
				block46_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK46_R) and (ball_x_l >= BLOCK46_L) and block46_alive_reg = '1' then
			if (BLOCK46_T <= ball_y_b) and (ball_y_t <= BLOCK46_B) then
				block46_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK47_B >= ball_y_t) and (ball_y_t >= BLOCK47_T) and block47_alive_reg = '1' then
			if (BLOCK47_L <= ball_x_r) and  (ball_x_l <= BLOCK47_R) then
				block47_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK47_T) and (ball_y_b <= BLOCK47_B) and block47_alive_reg = '1' then
			if (BLOCK47_L <= ball_x_r) and  (ball_x_l <= BLOCK47_R) then
				block47_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK47_L <= ball_x_r) and (ball_x_r <= BLOCK47_R) and block47_alive_reg = '1' then
			if (BLOCK47_T <= ball_y_b) and (ball_y_t <= BLOCK47_B) then
				block47_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK47_R) and (ball_x_l >= BLOCK47_L) and block47_alive_reg = '1' then
			if (BLOCK47_T <= ball_y_b) and (ball_y_t <= BLOCK47_B) then
				block47_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK48_B >= ball_y_t) and (ball_y_t >= BLOCK48_T) and block48_alive_reg = '1' then
			if (BLOCK48_L <= ball_x_r) and  (ball_x_l <= BLOCK48_R) then
				block48_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK48_T) and (ball_y_b <= BLOCK48_B) and block48_alive_reg = '1' then
			if (BLOCK48_L <= ball_x_r) and  (ball_x_l <= BLOCK48_R) then
				block48_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK48_L <= ball_x_r) and (ball_x_r <= BLOCK48_R) and block48_alive_reg = '1' then
			if (BLOCK48_T <= ball_y_b) and (ball_y_t <= BLOCK48_B) then
				block48_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK48_R) and (ball_x_l >= BLOCK48_L) and block48_alive_reg = '1' then
			if (BLOCK48_T <= ball_y_b) and (ball_y_t <= BLOCK48_B) then
				block48_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK49_B >= ball_y_t) and (ball_y_t >= BLOCK49_T) and block49_alive_reg = '1' then
			if (BLOCK49_L <= ball_x_r) and  (ball_x_l <= BLOCK49_R) then
				block49_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK49_T) and (ball_y_b <= BLOCK49_B) and block49_alive_reg = '1' then
			if (BLOCK49_L <= ball_x_r) and  (ball_x_l <= BLOCK49_R) then
				block49_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK49_L <= ball_x_r) and (ball_x_r <= BLOCK49_R) and block49_alive_reg = '1' then
			if (BLOCK49_T <= ball_y_b) and (ball_y_t <= BLOCK49_B) then
				block49_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK49_R) and (ball_x_l >= BLOCK49_L) and block49_alive_reg = '1' then
			if (BLOCK49_T <= ball_y_b) and (ball_y_t <= BLOCK49_B) then
				block49_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK50_B >= ball_y_t) and (ball_y_t >= BLOCK50_T) and block50_alive_reg = '1' then
			if (BLOCK50_L <= ball_x_r) and  (ball_x_l <= BLOCK50_R) then
				block50_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK50_T) and (ball_y_b <= BLOCK50_B) and block50_alive_reg = '1' then
			if (BLOCK50_L <= ball_x_r) and  (ball_x_l <= BLOCK50_R) then
				block50_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK50_L <= ball_x_r) and (ball_x_r <= BLOCK50_R) and block50_alive_reg = '1' then
			if (BLOCK50_T <= ball_y_b) and (ball_y_t <= BLOCK50_B) then
				block50_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK50_R) and (ball_x_l >= BLOCK50_L) and block50_alive_reg = '1' then
			if (BLOCK50_T <= ball_y_b) and (ball_y_t <= BLOCK50_B) then
				block50_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK51_B >= ball_y_t) and (ball_y_t >= BLOCK51_T) and block51_alive_reg = '1' then
			if (BLOCK51_L <= ball_x_r) and  (ball_x_l <= BLOCK51_R) then
				block51_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK51_T) and (ball_y_b <= BLOCK51_B) and block51_alive_reg = '1' then
			if (BLOCK51_L <= ball_x_r) and  (ball_x_l <= BLOCK51_R) then
				block51_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK51_L <= ball_x_r) and (ball_x_r <= BLOCK51_R) and block51_alive_reg = '1' then
			if (BLOCK51_T <= ball_y_b) and (ball_y_t <= BLOCK51_B) then
				block51_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK51_R) and (ball_x_l >= BLOCK51_L) and block51_alive_reg = '1' then
			if (BLOCK51_T <= ball_y_b) and (ball_y_t <= BLOCK51_B) then
				block51_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK52_B >= ball_y_t) and (ball_y_t >= BLOCK52_T) and block52_alive_reg = '1' then
			if (BLOCK52_L <= ball_x_r) and  (ball_x_l <= BLOCK52_R) then
				block52_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK52_T) and (ball_y_b <= BLOCK52_B) and block52_alive_reg = '1' then
			if (BLOCK52_L <= ball_x_r) and  (ball_x_l <= BLOCK52_R) then
				block52_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK52_L <= ball_x_r) and (ball_x_r <= BLOCK52_R) and block52_alive_reg = '1' then
			if (BLOCK52_T <= ball_y_b) and (ball_y_t <= BLOCK52_B) then
				block52_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK52_R) and (ball_x_l >= BLOCK52_L) and block52_alive_reg = '1' then
			if (BLOCK52_T <= ball_y_b) and (ball_y_t <= BLOCK52_B) then
				block52_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK53_B >= ball_y_t) and (ball_y_t >= BLOCK53_T) and block53_alive_reg = '1' then
			if (BLOCK53_L <= ball_x_r) and  (ball_x_l <= BLOCK53_R) then
				block53_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK53_T) and (ball_y_b <= BLOCK53_B) and block53_alive_reg = '1' then
			if (BLOCK53_L <= ball_x_r) and  (ball_x_l <= BLOCK53_R) then
				block53_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK53_L <= ball_x_r) and (ball_x_r <= BLOCK53_R) and block53_alive_reg = '1' then
			if (BLOCK53_T <= ball_y_b) and (ball_y_t <= BLOCK53_B) then
				block53_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK53_R) and (ball_x_l >= BLOCK53_L) and block53_alive_reg = '1' then
			if (BLOCK53_T <= ball_y_b) and (ball_y_t <= BLOCK53_B) then
				block53_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK54_B >= ball_y_t) and (ball_y_t >= BLOCK54_T) and block54_alive_reg = '1' then
			if (BLOCK54_L <= ball_x_r) and  (ball_x_l <= BLOCK54_R) then
				block54_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK54_T) and (ball_y_b <= BLOCK54_B) and block54_alive_reg = '1' then
			if (BLOCK54_L <= ball_x_r) and  (ball_x_l <= BLOCK54_R) then
				block54_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK54_L <= ball_x_r) and (ball_x_r <= BLOCK54_R) and block54_alive_reg = '1' then
			if (BLOCK54_T <= ball_y_b) and (ball_y_t <= BLOCK54_B) then
				block54_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK54_R) and (ball_x_l >= BLOCK54_L) and block54_alive_reg = '1' then
			if (BLOCK54_T <= ball_y_b) and (ball_y_t <= BLOCK54_B) then
				block54_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK55_B >= ball_y_t) and (ball_y_t >= BLOCK55_T) and block55_alive_reg = '1' then
			if (BLOCK55_L <= ball_x_r) and  (ball_x_l <= BLOCK55_R) then
				block55_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK55_T) and (ball_y_b <= BLOCK55_B) and block55_alive_reg = '1' then
			if (BLOCK55_L <= ball_x_r) and  (ball_x_l <= BLOCK55_R) then
				block55_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK55_L <= ball_x_r) and (ball_x_r <= BLOCK55_R) and block55_alive_reg = '1' then
			if (BLOCK55_T <= ball_y_b) and (ball_y_t <= BLOCK55_B) then
				block55_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK55_R) and (ball_x_l >= BLOCK55_L) and block55_alive_reg = '1' then
			if (BLOCK55_T <= ball_y_b) and (ball_y_t <= BLOCK55_B) then
				block55_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK56_B >= ball_y_t) and (ball_y_t >= BLOCK56_T) and block56_alive_reg = '1' then
			if (BLOCK56_L <= ball_x_r) and  (ball_x_l <= BLOCK56_R) then
				block56_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK56_T) and (ball_y_b <= BLOCK56_B) and block56_alive_reg = '1' then
			if (BLOCK56_L <= ball_x_r) and  (ball_x_l <= BLOCK56_R) then
				block56_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK56_L <= ball_x_r) and (ball_x_r <= BLOCK56_R) and block56_alive_reg = '1' then
			if (BLOCK56_T <= ball_y_b) and (ball_y_t <= BLOCK56_B) then
				block56_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK56_R) and (ball_x_l >= BLOCK56_L) and block56_alive_reg = '1' then
			if (BLOCK56_T <= ball_y_b) and (ball_y_t <= BLOCK56_B) then
				block56_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK57_B >= ball_y_t) and (ball_y_t >= BLOCK57_T) and block57_alive_reg = '1' then
			if (BLOCK57_L <= ball_x_r) and  (ball_x_l <= BLOCK57_R) then
				block57_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK57_T) and (ball_y_b <= BLOCK57_B) and block57_alive_reg = '1' then
			if (BLOCK57_L <= ball_x_r) and  (ball_x_l <= BLOCK57_R) then
				block57_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK57_L <= ball_x_r) and (ball_x_r <= BLOCK57_R) and block57_alive_reg = '1' then
			if (BLOCK57_T <= ball_y_b) and (ball_y_t <= BLOCK57_B) then
				block57_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK57_R) and (ball_x_l >= BLOCK57_L) and block57_alive_reg = '1' then
			if (BLOCK57_T <= ball_y_b) and (ball_y_t <= BLOCK57_B) then
				block57_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK58_B >= ball_y_t) and (ball_y_t >= BLOCK58_T) and block58_alive_reg = '1' then
			if (BLOCK58_L <= ball_x_r) and  (ball_x_l <= BLOCK58_R) then
				block58_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK58_T) and (ball_y_b <= BLOCK58_B) and block58_alive_reg = '1' then
			if (BLOCK58_L <= ball_x_r) and  (ball_x_l <= BLOCK58_R) then
				block58_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK58_L <= ball_x_r) and (ball_x_r <= BLOCK58_R) and block58_alive_reg = '1' then
			if (BLOCK58_T <= ball_y_b) and (ball_y_t <= BLOCK58_B) then
				block58_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK58_R) and (ball_x_l >= BLOCK58_L) and block58_alive_reg = '1' then
			if (BLOCK58_T <= ball_y_b) and (ball_y_t <= BLOCK58_B) then
				block58_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK59_B >= ball_y_t) and (ball_y_t >= BLOCK59_T) and block59_alive_reg = '1' then
			if (BLOCK59_L <= ball_x_r) and  (ball_x_l <= BLOCK59_R) then
				block59_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK59_T) and (ball_y_b <= BLOCK59_B) and block59_alive_reg = '1' then
			if (BLOCK59_L <= ball_x_r) and  (ball_x_l <= BLOCK59_R) then
				block59_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK59_L <= ball_x_r) and (ball_x_r <= BLOCK59_R) and block59_alive_reg = '1' then
			if (BLOCK59_T <= ball_y_b) and (ball_y_t <= BLOCK59_B) then
				block59_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK59_R) and (ball_x_l >= BLOCK59_L) and block59_alive_reg = '1' then
			if (BLOCK59_T <= ball_y_b) and (ball_y_t <= BLOCK59_B) then
				block59_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK60_B >= ball_y_t) and (ball_y_t >= BLOCK60_T) and block60_alive_reg = '1' then
			if (BLOCK60_L <= ball_x_r) and  (ball_x_l <= BLOCK60_R) then
				block60_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK60_T) and (ball_y_b <= BLOCK60_B) and block60_alive_reg = '1' then
			if (BLOCK60_L <= ball_x_r) and  (ball_x_l <= BLOCK60_R) then
				block60_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK60_L <= ball_x_r) and (ball_x_r <= BLOCK60_R) and block60_alive_reg = '1' then
			if (BLOCK60_T <= ball_y_b) and (ball_y_t <= BLOCK60_B) then
				block60_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK60_R) and (ball_x_l >= BLOCK60_L) and block60_alive_reg = '1' then
			if (BLOCK60_T <= ball_y_b) and (ball_y_t <= BLOCK60_B) then
				block60_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK61_B >= ball_y_t) and (ball_y_t >= BLOCK61_T) and block61_alive_reg = '1' then
			if (BLOCK61_L <= ball_x_r) and  (ball_x_l <= BLOCK61_R) then
				block61_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK61_T) and (ball_y_b <= BLOCK61_B) and block61_alive_reg = '1' then
			if (BLOCK61_L <= ball_x_r) and  (ball_x_l <= BLOCK61_R) then
				block61_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK61_L <= ball_x_r) and (ball_x_r <= BLOCK61_R) and block61_alive_reg = '1' then
			if (BLOCK61_T <= ball_y_b) and (ball_y_t <= BLOCK61_B) then
				block61_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK61_R) and (ball_x_l >= BLOCK61_L) and block61_alive_reg = '1' then
			if (BLOCK61_T <= ball_y_b) and (ball_y_t <= BLOCK61_B) then
				block61_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK62_B >= ball_y_t) and (ball_y_t >= BLOCK62_T) and block62_alive_reg = '1' then
			if (BLOCK62_L <= ball_x_r) and  (ball_x_l <= BLOCK62_R) then
				block62_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK62_T) and (ball_y_b <= BLOCK62_B) and block62_alive_reg = '1' then
			if (BLOCK62_L <= ball_x_r) and  (ball_x_l <= BLOCK62_R) then
				block62_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK62_L <= ball_x_r) and (ball_x_r <= BLOCK62_R) and block62_alive_reg = '1' then
			if (BLOCK62_T <= ball_y_b) and (ball_y_t <= BLOCK62_B) then
				block62_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK62_R) and (ball_x_l >= BLOCK62_L) and block62_alive_reg = '1' then
			if (BLOCK62_T <= ball_y_b) and (ball_y_t <= BLOCK62_B) then
				block62_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK63_B >= ball_y_t) and (ball_y_t >= BLOCK63_T) and block63_alive_reg = '1' then
			if (BLOCK63_L <= ball_x_r) and  (ball_x_l <= BLOCK63_R) then
				block63_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK63_T) and (ball_y_b <= BLOCK63_B) and block63_alive_reg = '1' then
			if (BLOCK63_L <= ball_x_r) and  (ball_x_l <= BLOCK63_R) then
				block63_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK63_L <= ball_x_r) and (ball_x_r <= BLOCK63_R) and block63_alive_reg = '1' then
			if (BLOCK63_T <= ball_y_b) and (ball_y_t <= BLOCK63_B) then
				block63_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK63_R) and (ball_x_l >= BLOCK63_L) and block63_alive_reg = '1' then
			if (BLOCK63_T <= ball_y_b) and (ball_y_t <= BLOCK63_B) then
				block63_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK64_B >= ball_y_t) and (ball_y_t >= BLOCK64_T) and block64_alive_reg = '1' then
			if (BLOCK64_L <= ball_x_r) and  (ball_x_l <= BLOCK64_R) then
				block64_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK64_T) and (ball_y_b <= BLOCK64_B) and block64_alive_reg = '1' then
			if (BLOCK64_L <= ball_x_r) and  (ball_x_l <= BLOCK64_R) then
				block64_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK64_L <= ball_x_r) and (ball_x_r <= BLOCK64_R) and block64_alive_reg = '1' then
			if (BLOCK64_T <= ball_y_b) and (ball_y_t <= BLOCK64_B) then
				block64_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK64_R) and (ball_x_l >= BLOCK64_L) and block64_alive_reg = '1' then
			if (BLOCK64_T <= ball_y_b) and (ball_y_t <= BLOCK64_B) then
				block64_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK65_B >= ball_y_t) and (ball_y_t >= BLOCK65_T) and block65_alive_reg = '1' then
			if (BLOCK65_L <= ball_x_r) and  (ball_x_l <= BLOCK65_R) then
				block65_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK65_T) and (ball_y_b <= BLOCK65_B) and block65_alive_reg = '1' then
			if (BLOCK65_L <= ball_x_r) and  (ball_x_l <= BLOCK65_R) then
				block65_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK65_L <= ball_x_r) and (ball_x_r <= BLOCK65_R) and block65_alive_reg = '1' then
			if (BLOCK65_T <= ball_y_b) and (ball_y_t <= BLOCK65_B) then
				block65_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK65_R) and (ball_x_l >= BLOCK65_L) and block65_alive_reg = '1' then
			if (BLOCK65_T <= ball_y_b) and (ball_y_t <= BLOCK65_B) then
				block65_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK66_B >= ball_y_t) and (ball_y_t >= BLOCK66_T) and block66_alive_reg = '1' then
			if (BLOCK66_L <= ball_x_r) and  (ball_x_l <= BLOCK66_R) then
				block66_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK66_T) and (ball_y_b <= BLOCK66_B) and block66_alive_reg = '1' then
			if (BLOCK66_L <= ball_x_r) and  (ball_x_l <= BLOCK66_R) then
				block66_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK66_L <= ball_x_r) and (ball_x_r <= BLOCK66_R) and block66_alive_reg = '1' then
			if (BLOCK66_T <= ball_y_b) and (ball_y_t <= BLOCK66_B) then
				block66_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK66_R) and (ball_x_l >= BLOCK66_L) and block66_alive_reg = '1' then
			if (BLOCK66_T <= ball_y_b) and (ball_y_t <= BLOCK66_B) then
				block66_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK67_B >= ball_y_t) and (ball_y_t >= BLOCK67_T) and block67_alive_reg = '1' then
			if (BLOCK67_L <= ball_x_r) and  (ball_x_l <= BLOCK67_R) then
				block67_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK67_T) and (ball_y_b <= BLOCK67_B) and block67_alive_reg = '1' then
			if (BLOCK67_L <= ball_x_r) and  (ball_x_l <= BLOCK67_R) then
				block67_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK67_L <= ball_x_r) and (ball_x_r <= BLOCK67_R) and block67_alive_reg = '1' then
			if (BLOCK67_T <= ball_y_b) and (ball_y_t <= BLOCK67_B) then
				block67_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK67_R) and (ball_x_l >= BLOCK67_L) and block67_alive_reg = '1' then
			if (BLOCK67_T <= ball_y_b) and (ball_y_t <= BLOCK67_B) then
				block67_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK68_B >= ball_y_t) and (ball_y_t >= BLOCK68_T) and block68_alive_reg = '1' then
			if (BLOCK68_L <= ball_x_r) and  (ball_x_l <= BLOCK68_R) then
				block68_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK68_T) and (ball_y_b <= BLOCK68_B) and block68_alive_reg = '1' then
			if (BLOCK68_L <= ball_x_r) and  (ball_x_l <= BLOCK68_R) then
				block68_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK68_L <= ball_x_r) and (ball_x_r <= BLOCK68_R) and block68_alive_reg = '1' then
			if (BLOCK68_T <= ball_y_b) and (ball_y_t <= BLOCK68_B) then
				block68_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK68_R) and (ball_x_l >= BLOCK68_L) and block68_alive_reg = '1' then
			if (BLOCK68_T <= ball_y_b) and (ball_y_t <= BLOCK68_B) then
				block68_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK69_B >= ball_y_t) and (ball_y_t >= BLOCK69_T) and block69_alive_reg = '1' then
			if (BLOCK69_L <= ball_x_r) and  (ball_x_l <= BLOCK69_R) then
				block69_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK69_T) and (ball_y_b <= BLOCK69_B) and block69_alive_reg = '1' then
			if (BLOCK69_L <= ball_x_r) and  (ball_x_l <= BLOCK69_R) then
				block69_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK69_L <= ball_x_r) and (ball_x_r <= BLOCK69_R) and block69_alive_reg = '1' then
			if (BLOCK69_T <= ball_y_b) and (ball_y_t <= BLOCK69_B) then
				block69_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK69_R) and (ball_x_l >= BLOCK69_L) and block69_alive_reg = '1' then
			if (BLOCK69_T <= ball_y_b) and (ball_y_t <= BLOCK69_B) then
				block69_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK70_B >= ball_y_t) and (ball_y_t >= BLOCK70_T) and block70_alive_reg = '1' then
			if (BLOCK70_L <= ball_x_r) and  (ball_x_l <= BLOCK70_R) then
				block70_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK70_T) and (ball_y_b <= BLOCK70_B) and block70_alive_reg = '1' then
			if (BLOCK70_L <= ball_x_r) and  (ball_x_l <= BLOCK70_R) then
				block70_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK70_L <= ball_x_r) and (ball_x_r <= BLOCK70_R) and block70_alive_reg = '1' then
			if (BLOCK70_T <= ball_y_b) and (ball_y_t <= BLOCK70_B) then
				block70_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK70_R) and (ball_x_l >= BLOCK70_L) and block70_alive_reg = '1' then
			if (BLOCK70_T <= ball_y_b) and (ball_y_t <= BLOCK70_B) then
				block70_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK71_B >= ball_y_t) and (ball_y_t >= BLOCK71_T) and block71_alive_reg = '1' then
			if (BLOCK71_L <= ball_x_r) and  (ball_x_l <= BLOCK71_R) then
				block71_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK71_T) and (ball_y_b <= BLOCK71_B) and block71_alive_reg = '1' then
			if (BLOCK71_L <= ball_x_r) and  (ball_x_l <= BLOCK71_R) then
				block71_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK71_L <= ball_x_r) and (ball_x_r <= BLOCK71_R) and block71_alive_reg = '1' then
			if (BLOCK71_T <= ball_y_b) and (ball_y_t <= BLOCK71_B) then
				block71_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK71_R) and (ball_x_l >= BLOCK71_L) and block71_alive_reg = '1' then
			if (BLOCK71_T <= ball_y_b) and (ball_y_t <= BLOCK71_B) then
				block71_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK72_B >= ball_y_t) and (ball_y_t >= BLOCK72_T) and block72_alive_reg = '1' then
			if (BLOCK72_L <= ball_x_r) and  (ball_x_l <= BLOCK72_R) then
				block72_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK72_T) and (ball_y_b <= BLOCK72_B) and block72_alive_reg = '1' then
			if (BLOCK72_L <= ball_x_r) and  (ball_x_l <= BLOCK72_R) then
				block72_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK72_L <= ball_x_r) and (ball_x_r <= BLOCK72_R) and block72_alive_reg = '1' then
			if (BLOCK72_T <= ball_y_b) and (ball_y_t <= BLOCK72_B) then
				block72_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK72_R) and (ball_x_l >= BLOCK72_L) and block72_alive_reg = '1' then
			if (BLOCK72_T <= ball_y_b) and (ball_y_t <= BLOCK72_B) then
				block72_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK73_B >= ball_y_t) and (ball_y_t >= BLOCK73_T) and block73_alive_reg = '1' then
			if (BLOCK73_L <= ball_x_r) and  (ball_x_l <= BLOCK73_R) then
				block73_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK73_T) and (ball_y_b <= BLOCK73_B) and block73_alive_reg = '1' then
			if (BLOCK73_L <= ball_x_r) and  (ball_x_l <= BLOCK73_R) then
				block73_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK73_L <= ball_x_r) and (ball_x_r <= BLOCK73_R) and block73_alive_reg = '1' then
			if (BLOCK73_T <= ball_y_b) and (ball_y_t <= BLOCK73_B) then
				block73_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK73_R) and (ball_x_l >= BLOCK73_L) and block73_alive_reg = '1' then
			if (BLOCK73_T <= ball_y_b) and (ball_y_t <= BLOCK73_B) then
				block73_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK74_B >= ball_y_t) and (ball_y_t >= BLOCK74_T) and block74_alive_reg = '1' then
			if (BLOCK74_L <= ball_x_r) and  (ball_x_l <= BLOCK74_R) then
				block74_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK74_T) and (ball_y_b <= BLOCK74_B) and block74_alive_reg = '1' then
			if (BLOCK74_L <= ball_x_r) and  (ball_x_l <= BLOCK74_R) then
				block74_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK74_L <= ball_x_r) and (ball_x_r <= BLOCK74_R) and block74_alive_reg = '1' then
			if (BLOCK74_T <= ball_y_b) and (ball_y_t <= BLOCK74_B) then
				block74_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK74_R) and (ball_x_l >= BLOCK74_L) and block74_alive_reg = '1' then
			if (BLOCK74_T <= ball_y_b) and (ball_y_t <= BLOCK74_B) then
				block74_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK75_B >= ball_y_t) and (ball_y_t >= BLOCK75_T) and block75_alive_reg = '1' then
			if (BLOCK75_L <= ball_x_r) and  (ball_x_l <= BLOCK75_R) then
				block75_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK75_T) and (ball_y_b <= BLOCK75_B) and block75_alive_reg = '1' then
			if (BLOCK75_L <= ball_x_r) and  (ball_x_l <= BLOCK75_R) then
				block75_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK75_L <= ball_x_r) and (ball_x_r <= BLOCK75_R) and block75_alive_reg = '1' then
			if (BLOCK75_T <= ball_y_b) and (ball_y_t <= BLOCK75_B) then
				block75_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK75_R) and (ball_x_l >= BLOCK75_L) and block75_alive_reg = '1' then
			if (BLOCK75_T <= ball_y_b) and (ball_y_t <= BLOCK75_B) then
				block75_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK76_B >= ball_y_t) and (ball_y_t >= BLOCK76_T) and block76_alive_reg = '1' then
			if (BLOCK76_L <= ball_x_r) and  (ball_x_l <= BLOCK76_R) then
				block76_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK76_T) and (ball_y_b <= BLOCK76_B) and block76_alive_reg = '1' then
			if (BLOCK76_L <= ball_x_r) and  (ball_x_l <= BLOCK76_R) then
				block76_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK76_L <= ball_x_r) and (ball_x_r <= BLOCK76_R) and block76_alive_reg = '1' then
			if (BLOCK76_T <= ball_y_b) and (ball_y_t <= BLOCK76_B) then
				block76_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK76_R) and (ball_x_l >= BLOCK76_L) and block76_alive_reg = '1' then
			if (BLOCK76_T <= ball_y_b) and (ball_y_t <= BLOCK76_B) then
				block76_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK77_B >= ball_y_t) and (ball_y_t >= BLOCK77_T) and block77_alive_reg = '1' then
			if (BLOCK77_L <= ball_x_r) and  (ball_x_l <= BLOCK77_R) then
				block77_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK77_T) and (ball_y_b <= BLOCK77_B) and block77_alive_reg = '1' then
			if (BLOCK77_L <= ball_x_r) and  (ball_x_l <= BLOCK77_R) then
				block77_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK77_L <= ball_x_r) and (ball_x_r <= BLOCK77_R) and block77_alive_reg = '1' then
			if (BLOCK77_T <= ball_y_b) and (ball_y_t <= BLOCK77_B) then
				block77_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK77_R) and (ball_x_l >= BLOCK77_L) and block77_alive_reg = '1' then
			if (BLOCK77_T <= ball_y_b) and (ball_y_t <= BLOCK77_B) then
				block77_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK78_B >= ball_y_t) and (ball_y_t >= BLOCK78_T) and block78_alive_reg = '1' then
			if (BLOCK78_L <= ball_x_r) and  (ball_x_l <= BLOCK78_R) then
				block78_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK78_T) and (ball_y_b <= BLOCK78_B) and block78_alive_reg = '1' then
			if (BLOCK78_L <= ball_x_r) and  (ball_x_l <= BLOCK78_R) then
				block78_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK78_L <= ball_x_r) and (ball_x_r <= BLOCK78_R) and block78_alive_reg = '1' then
			if (BLOCK78_T <= ball_y_b) and (ball_y_t <= BLOCK78_B) then
				block78_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK78_R) and (ball_x_l >= BLOCK78_L) and block78_alive_reg = '1' then
			if (BLOCK78_T <= ball_y_b) and (ball_y_t <= BLOCK78_B) then
				block78_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK79_B >= ball_y_t) and (ball_y_t >= BLOCK79_T) and block79_alive_reg = '1' then
			if (BLOCK79_L <= ball_x_r) and  (ball_x_l <= BLOCK79_R) then
				block79_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK79_T) and (ball_y_b <= BLOCK79_B) and block79_alive_reg = '1' then
			if (BLOCK79_L <= ball_x_r) and  (ball_x_l <= BLOCK79_R) then
				block79_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK79_L <= ball_x_r) and (ball_x_r <= BLOCK79_R) and block79_alive_reg = '1' then
			if (BLOCK79_T <= ball_y_b) and (ball_y_t <= BLOCK79_B) then
				block79_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK79_R) and (ball_x_l >= BLOCK79_L) and block79_alive_reg = '1' then
			if (BLOCK79_T <= ball_y_b) and (ball_y_t <= BLOCK79_B) then
				block79_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK80_B >= ball_y_t) and (ball_y_t >= BLOCK80_T) and block80_alive_reg = '1' then
			if (BLOCK80_L <= ball_x_r) and  (ball_x_l <= BLOCK80_R) then
				block80_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK80_T) and (ball_y_b <= BLOCK80_B) and block80_alive_reg = '1' then
			if (BLOCK80_L <= ball_x_r) and  (ball_x_l <= BLOCK80_R) then
				block80_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK80_L <= ball_x_r) and (ball_x_r <= BLOCK80_R) and block80_alive_reg = '1' then
			if (BLOCK80_T <= ball_y_b) and (ball_y_t <= BLOCK80_B) then
				block80_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK80_R) and (ball_x_l >= BLOCK80_L) and block80_alive_reg = '1' then
			if (BLOCK80_T <= ball_y_b) and (ball_y_t <= BLOCK80_B) then
				block80_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK81_B >= ball_y_t) and (ball_y_t >= BLOCK81_T) and block81_alive_reg = '1' then
			if (BLOCK81_L <= ball_x_r) and  (ball_x_l <= BLOCK81_R) then
				block81_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK81_T) and (ball_y_b <= BLOCK81_B) and block81_alive_reg = '1' then
			if (BLOCK81_L <= ball_x_r) and  (ball_x_l <= BLOCK81_R) then
				block81_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK81_L <= ball_x_r) and (ball_x_r <= BLOCK81_R) and block81_alive_reg = '1' then
			if (BLOCK81_T <= ball_y_b) and (ball_y_t <= BLOCK81_B) then
				block81_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK81_R) and (ball_x_l >= BLOCK81_L) and block81_alive_reg = '1' then
			if (BLOCK81_T <= ball_y_b) and (ball_y_t <= BLOCK81_B) then
				block81_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK82_B >= ball_y_t) and (ball_y_t >= BLOCK82_T) and block82_alive_reg = '1' then
			if (BLOCK82_L <= ball_x_r) and  (ball_x_l <= BLOCK82_R) then
				block82_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK82_T) and (ball_y_b <= BLOCK82_B) and block82_alive_reg = '1' then
			if (BLOCK82_L <= ball_x_r) and  (ball_x_l <= BLOCK82_R) then
				block82_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK82_L <= ball_x_r) and (ball_x_r <= BLOCK82_R) and block82_alive_reg = '1' then
			if (BLOCK82_T <= ball_y_b) and (ball_y_t <= BLOCK82_B) then
				block82_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK82_R) and (ball_x_l >= BLOCK82_L) and block82_alive_reg = '1' then
			if (BLOCK82_T <= ball_y_b) and (ball_y_t <= BLOCK82_B) then
				block82_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK83_B >= ball_y_t) and (ball_y_t >= BLOCK83_T) and block83_alive_reg = '1' then
			if (BLOCK83_L <= ball_x_r) and  (ball_x_l <= BLOCK83_R) then
				block83_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK83_T) and (ball_y_b <= BLOCK83_B) and block83_alive_reg = '1' then
			if (BLOCK83_L <= ball_x_r) and  (ball_x_l <= BLOCK83_R) then
				block83_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK83_L <= ball_x_r) and (ball_x_r <= BLOCK83_R) and block83_alive_reg = '1' then
			if (BLOCK83_T <= ball_y_b) and (ball_y_t <= BLOCK83_B) then
				block83_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK83_R) and (ball_x_l >= BLOCK83_L) and block83_alive_reg = '1' then
			if (BLOCK83_T <= ball_y_b) and (ball_y_t <= BLOCK83_B) then
				block83_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK84_B >= ball_y_t) and (ball_y_t >= BLOCK84_T) and block84_alive_reg = '1' then
			if (BLOCK84_L <= ball_x_r) and  (ball_x_l <= BLOCK84_R) then
				block84_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK84_T) and (ball_y_b <= BLOCK84_B) and block84_alive_reg = '1' then
			if (BLOCK84_L <= ball_x_r) and  (ball_x_l <= BLOCK84_R) then
				block84_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK84_L <= ball_x_r) and (ball_x_r <= BLOCK84_R) and block84_alive_reg = '1' then
			if (BLOCK84_T <= ball_y_b) and (ball_y_t <= BLOCK84_B) then
				block84_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK84_R) and (ball_x_l >= BLOCK84_L) and block84_alive_reg = '1' then
			if (BLOCK84_T <= ball_y_b) and (ball_y_t <= BLOCK84_B) then
				block84_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK85_B >= ball_y_t) and (ball_y_t >= BLOCK85_T) and block85_alive_reg = '1' then
			if (BLOCK85_L <= ball_x_r) and  (ball_x_l <= BLOCK85_R) then
				block85_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK85_T) and (ball_y_b <= BLOCK85_B) and block85_alive_reg = '1' then
			if (BLOCK85_L <= ball_x_r) and  (ball_x_l <= BLOCK85_R) then
				block85_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK85_L <= ball_x_r) and (ball_x_r <= BLOCK85_R) and block85_alive_reg = '1' then
			if (BLOCK85_T <= ball_y_b) and (ball_y_t <= BLOCK85_B) then
				block85_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK85_R) and (ball_x_l >= BLOCK85_L) and block85_alive_reg = '1' then
			if (BLOCK85_T <= ball_y_b) and (ball_y_t <= BLOCK85_B) then
				block85_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK86_B >= ball_y_t) and (ball_y_t >= BLOCK86_T) and block86_alive_reg = '1' then
			if (BLOCK86_L <= ball_x_r) and  (ball_x_l <= BLOCK86_R) then
				block86_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK86_T) and (ball_y_b <= BLOCK86_B) and block86_alive_reg = '1' then
			if (BLOCK86_L <= ball_x_r) and  (ball_x_l <= BLOCK86_R) then
				block86_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK86_L <= ball_x_r) and (ball_x_r <= BLOCK86_R) and block86_alive_reg = '1' then
			if (BLOCK86_T <= ball_y_b) and (ball_y_t <= BLOCK86_B) then
				block86_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK86_R) and (ball_x_l >= BLOCK86_L) and block86_alive_reg = '1'  then
			if (BLOCK86_T <= ball_y_b) and (ball_y_t <= BLOCK86_B) then
				block86_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK87_B >= ball_y_t) and (ball_y_t >= BLOCK87_T) and block87_alive_reg = '1' then
			if (BLOCK87_L <= ball_x_r) and  (ball_x_l <= BLOCK87_R) then
				block87_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK87_T) and (ball_y_b <= BLOCK87_B) and block87_alive_reg = '1' then
			if (BLOCK87_L <= ball_x_r) and  (ball_x_l <= BLOCK87_R) then
				block87_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK87_L <= ball_x_r) and (ball_x_r <= BLOCK87_R) and block87_alive_reg = '1' then
			if (BLOCK87_T <= ball_y_b) and (ball_y_t <= BLOCK87_B) then
				block87_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK87_R) and (ball_x_l >= BLOCK87_L) and block87_alive_reg = '1' then
			if (BLOCK87_T <= ball_y_b) and (ball_y_t <= BLOCK87_B) then
				block87_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK88_B >= ball_y_t) and (ball_y_t >= BLOCK88_T) and block88_alive_reg = '1' then
			if (BLOCK88_L <= ball_x_r) and  (ball_x_l <= BLOCK88_R) then
				block88_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK88_T) and (ball_y_b <= BLOCK88_B) and block88_alive_reg = '1' then
			if (BLOCK88_L <= ball_x_r) and  (ball_x_l <= BLOCK88_R) then
				block88_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK88_L <= ball_x_r) and (ball_x_r <= BLOCK88_R) and block88_alive_reg = '1' then
			if (BLOCK88_T <= ball_y_b) and (ball_y_t <= BLOCK88_B) then
				block88_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK88_R) and (ball_x_l >= BLOCK88_L) and block88_alive_reg = '1' then
			if (BLOCK88_T <= ball_y_b) and (ball_y_t <= BLOCK88_B) then
				block88_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK89_B >= ball_y_t) and (ball_y_t >= BLOCK89_T) and block89_alive_reg = '1' then
			if (BLOCK89_L <= ball_x_r) and  (ball_x_l <= BLOCK89_R) then
				block89_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK89_T) and (ball_y_b <= BLOCK89_B) and block89_alive_reg = '1' then
			if (BLOCK89_L <= ball_x_r) and  (ball_x_l <= BLOCK89_R) then
				block89_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK89_L <= ball_x_r) and (ball_x_r <= BLOCK89_R) and block89_alive_reg = '1' then
			if (BLOCK89_T <= ball_y_b) and (ball_y_t <= BLOCK89_B) then
				block89_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK89_R) and (ball_x_l >= BLOCK89_L) and block89_alive_reg = '1' then
			if (BLOCK89_T <= ball_y_b) and (ball_y_t <= BLOCK89_B) then
				block89_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK90_B >= ball_y_t) and (ball_y_t >= BLOCK90_T) and block90_alive_reg = '1' then
			if (BLOCK90_L <= ball_x_r) and  (ball_x_l <= BLOCK90_R) then
				block90_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK90_T) and (ball_y_b <= BLOCK90_B) and block90_alive_reg = '1' then
			if (BLOCK90_L <= ball_x_r) and  (ball_x_l <= BLOCK90_R) then
				block90_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK90_L <= ball_x_r) and (ball_x_r <= BLOCK90_R) and block90_alive_reg = '1' then
			if (BLOCK90_T <= ball_y_b) and (ball_y_t <= BLOCK90_B) then
				block90_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK90_R) and (ball_x_l >= BLOCK90_L) and block90_alive_reg = '1' then
			if (BLOCK90_T <= ball_y_b) and (ball_y_t <= BLOCK90_B) then
				block90_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK91_B >= ball_y_t) and (ball_y_t >= BLOCK91_T) and block91_alive_reg = '1' then
			if (BLOCK91_L <= ball_x_r) and  (ball_x_l <= BLOCK91_R) then
				block91_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK91_T) and (ball_y_b <= BLOCK91_B) and block91_alive_reg = '1' then
			if (BLOCK91_L <= ball_x_r) and  (ball_x_l <= BLOCK91_R) then
				block91_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK91_L <= ball_x_r) and (ball_x_r <= BLOCK91_R) and block91_alive_reg = '1' then
			if (BLOCK91_T <= ball_y_b) and (ball_y_t <= BLOCK91_B) then
				block91_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK91_R) and (ball_x_l >= BLOCK91_L) and block91_alive_reg = '1' then
			if (BLOCK91_T <= ball_y_b) and (ball_y_t <= BLOCK91_B) then
				block91_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK92_B >= ball_y_t) and (ball_y_t >= BLOCK92_T) and block92_alive_reg = '1' then
			if (BLOCK92_L <= ball_x_r) and  (ball_x_l <= BLOCK92_R) then
				block92_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK92_T) and (ball_y_b <= BLOCK92_B) and block92_alive_reg = '1' then
			if (BLOCK92_L <= ball_x_r) and  (ball_x_l <= BLOCK92_R) then
				block92_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK92_L <= ball_x_r) and (ball_x_r <= BLOCK92_R) and block92_alive_reg = '1' then
			if (BLOCK92_T <= ball_y_b) and (ball_y_t <= BLOCK92_B) then
				block92_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK92_R) and (ball_x_l >= BLOCK92_L) and block92_alive_reg = '1' then
			if (BLOCK92_T <= ball_y_b) and (ball_y_t <= BLOCK92_B) then
				block92_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK93_B >= ball_y_t) and (ball_y_t >= BLOCK93_T) and block93_alive_reg = '1' then
			if (BLOCK93_L <= ball_x_r) and  (ball_x_l <= BLOCK93_R) then
				block93_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK93_T) and (ball_y_b <= BLOCK93_B) and block93_alive_reg = '1' then
			if (BLOCK93_L <= ball_x_r) and  (ball_x_l <= BLOCK93_R) then
				block93_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK93_L <= ball_x_r) and (ball_x_r <= BLOCK93_R) and block93_alive_reg = '1' then
			if (BLOCK93_T <= ball_y_b) and (ball_y_t <= BLOCK93_B) then
				block93_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK93_R) and (ball_x_l >= BLOCK93_L) and block93_alive_reg = '1' then
			if (BLOCK93_T <= ball_y_b) and (ball_y_t <= BLOCK93_B) then
				block93_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK94_B >= ball_y_t) and (ball_y_t >= BLOCK94_T) and block94_alive_reg = '1' then
			if (BLOCK94_L <= ball_x_r) and  (ball_x_l <= BLOCK94_R) then
				block94_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK94_T) and (ball_y_b <= BLOCK94_B) and block94_alive_reg = '1' then
			if (BLOCK94_L <= ball_x_r) and  (ball_x_l <= BLOCK94_R) then
				block94_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK94_L <= ball_x_r) and (ball_x_r <= BLOCK94_R) and block94_alive_reg = '1' then
			if (BLOCK94_T <= ball_y_b) and (ball_y_t <= BLOCK94_B) then
				block94_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK94_R) and (ball_x_l >= BLOCK94_L) and block94_alive_reg = '1' then
			if (BLOCK94_T <= ball_y_b) and (ball_y_t <= BLOCK94_B) then
				block94_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK95_B >= ball_y_t) and (ball_y_t >= BLOCK95_T) and block95_alive_reg = '1' then
			if (BLOCK95_L <= ball_x_r) and  (ball_x_l <= BLOCK95_R) then
				block95_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK95_T) and (ball_y_b <= BLOCK95_B) and block95_alive_reg = '1' then
			if (BLOCK95_L <= ball_x_r) and  (ball_x_l <= BLOCK95_R) then
				block95_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK95_L <= ball_x_r) and (ball_x_r <= BLOCK95_R) and block95_alive_reg = '1' then
			if (BLOCK95_T <= ball_y_b) and (ball_y_t <= BLOCK95_B) then
				block95_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK95_R) and (ball_x_l >= BLOCK95_L) and block95_alive_reg = '1' then
			if (BLOCK95_T <= ball_y_b) and (ball_y_t <= BLOCK95_B) then
				block95_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK96_B >= ball_y_t) and (ball_y_t >= BLOCK96_T) and block96_alive_reg = '1' then
			if (BLOCK96_L <= ball_x_r) and  (ball_x_l <= BLOCK96_R) then
				block96_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK96_T) and (ball_y_b <= BLOCK96_B) and block96_alive_reg = '1' then
			if (BLOCK96_L <= ball_x_r) and  (ball_x_l <= BLOCK96_R) then
				block96_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK96_L <= ball_x_r) and (ball_x_r <= BLOCK96_R) and block96_alive_reg = '1' then
			if (BLOCK96_T <= ball_y_b) and (ball_y_t <= BLOCK96_B) then
				block96_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK96_R) and (ball_x_l >= BLOCK96_L) and block96_alive_reg = '1' then
			if (BLOCK96_T <= ball_y_b) and (ball_y_t <= BLOCK96_B) then
				block96_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK97_B >= ball_y_t) and (ball_y_t >= BLOCK97_T) and block97_alive_reg = '1' then
			if (BLOCK97_L <= ball_x_r) and  (ball_x_l <= BLOCK97_R) then
				block97_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK97_T) and (ball_y_b <= BLOCK97_B) and block97_alive_reg = '1' then
			if (BLOCK97_L <= ball_x_r) and  (ball_x_l <= BLOCK97_R) then
				block97_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK97_L <= ball_x_r) and (ball_x_r <= BLOCK97_R) and block97_alive_reg = '1' then
			if (BLOCK97_T <= ball_y_b) and (ball_y_t <= BLOCK97_B) then
				block97_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK97_R) and (ball_x_l >= BLOCK97_L) and block97_alive_reg = '1' then
			if (BLOCK97_T <= ball_y_b) and (ball_y_t <= BLOCK97_B) then
				block97_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK98_B >= ball_y_t) and (ball_y_t >= BLOCK98_T) and block98_alive_reg = '1' then
			if (BLOCK98_L <= ball_x_r) and  (ball_x_l <= BLOCK98_R) then
				block98_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK98_T) and (ball_y_b <= BLOCK98_B) and block98_alive_reg = '1' then
			if (BLOCK98_L <= ball_x_r) and  (ball_x_l <= BLOCK98_R) then
				block98_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK98_L <= ball_x_r) and (ball_x_r <= BLOCK98_R) and block98_alive_reg = '1' then
			if (BLOCK98_T <= ball_y_b) and (ball_y_t <= BLOCK98_B) then
				block98_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK98_R) and (ball_x_l >= BLOCK98_L) and block98_alive_reg = '1' then
			if (BLOCK98_T <= ball_y_b) and (ball_y_t <= BLOCK98_B) then
				block98_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK99_B >= ball_y_t) and (ball_y_t >= BLOCK99_T) and block99_alive_reg = '1' then
			if (BLOCK99_L <= ball_x_r) and  (ball_x_l <= BLOCK99_R) then
				block99_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK99_T) and (ball_y_b <= BLOCK99_B) and block99_alive_reg = '1' then
			if (BLOCK99_L <= ball_x_r) and  (ball_x_l <= BLOCK99_R) then
				block99_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK99_L <= ball_x_r) and (ball_x_r <= BLOCK99_R) and block99_alive_reg = '1' then
			if (BLOCK99_T <= ball_y_b) and (ball_y_t <= BLOCK99_B) then
				block99_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK99_R) and (ball_x_l >= BLOCK99_L) and block99_alive_reg = '1' then
			if (BLOCK99_T <= ball_y_b) and (ball_y_t <= BLOCK99_B) then
				block99_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK100_B >= ball_y_t) and (ball_y_t >= BLOCK100_T) and block100_alive_reg = '1' then
			if (BLOCK100_L <= ball_x_r) and  (ball_x_l <= BLOCK100_R) then
				block100_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK100_T) and (ball_y_b <= BLOCK100_B) and block100_alive_reg = '1' then
			if (BLOCK100_L <= ball_x_r) and  (ball_x_l <= BLOCK100_R) then
				block100_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK100_L <= ball_x_r) and (ball_x_r <= BLOCK100_R) and block100_alive_reg = '1' then
			if (BLOCK100_T <= ball_y_b) and (ball_y_t <= BLOCK100_B) then
				block100_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK100_R) and (ball_x_l >= BLOCK100_L) and block100_alive_reg = '1' then
			if (BLOCK100_T <= ball_y_b) and (ball_y_t <= BLOCK100_B) then
				block100_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK101_B >= ball_y_t) and (ball_y_t >= BLOCK101_T) and block101_alive_reg = '1' then
			if (BLOCK101_L <= ball_x_r) and  (ball_x_l <= BLOCK101_R) then
				block101_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK101_T) and (ball_y_b <= BLOCK101_B) and block101_alive_reg = '1' then
			if (BLOCK101_L <= ball_x_r) and  (ball_x_l <= BLOCK101_R) then
				block101_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK101_L <= ball_x_r) and (ball_x_r <= BLOCK101_R) and block101_alive_reg = '1' then
			if (BLOCK101_T <= ball_y_b) and (ball_y_t <= BLOCK101_B) then
				block101_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK101_R) and (ball_x_l >= BLOCK101_L) and block101_alive_reg = '1' then
			if (BLOCK101_T <= ball_y_b) and (ball_y_t <= BLOCK101_B) then
				block101_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK102_B >= ball_y_t) and (ball_y_t >= BLOCK102_T) and block102_alive_reg = '1' then
			if (BLOCK102_L <= ball_x_r) and  (ball_x_l <= BLOCK102_R) then
				block102_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK102_T) and (ball_y_b <= BLOCK102_B) and block102_alive_reg = '1' then
			if (BLOCK102_L <= ball_x_r) and  (ball_x_l <= BLOCK102_R) then
				block102_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK102_L <= ball_x_r) and (ball_x_r <= BLOCK102_R) and block102_alive_reg = '1' then
			if (BLOCK102_T <= ball_y_b) and (ball_y_t <= BLOCK102_B) then
				block102_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK102_R) and (ball_x_l >= BLOCK102_L) and block102_alive_reg = '1' then
			if (BLOCK102_T <= ball_y_b) and (ball_y_t <= BLOCK102_B) then
				block102_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK103_B >= ball_y_t) and (ball_y_t >= BLOCK103_T) and block103_alive_reg = '1' then
			if (BLOCK103_L <= ball_x_r) and  (ball_x_l <= BLOCK103_R) then
				block103_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK103_T) and (ball_y_b <= BLOCK103_B) and block103_alive_reg = '1' then
			if (BLOCK103_L <= ball_x_r) and  (ball_x_l <= BLOCK103_R) then
				block103_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK103_L <= ball_x_r) and (ball_x_r <= BLOCK103_R) and block103_alive_reg = '1' then
			if (BLOCK103_T <= ball_y_b) and (ball_y_t <= BLOCK103_B) then
				block103_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK103_R) and (ball_x_l >= BLOCK103_L) and block103_alive_reg = '1' then
			if (BLOCK103_T <= ball_y_b) and (ball_y_t <= BLOCK103_B) then
				block103_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK104_B >= ball_y_t) and (ball_y_t >= BLOCK104_T) and block104_alive_reg = '1' then
			if (BLOCK104_L <= ball_x_r) and  (ball_x_l <= BLOCK104_R) then
				block104_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK104_T) and (ball_y_b <= BLOCK104_B) and block104_alive_reg = '1' then
			if (BLOCK104_L <= ball_x_r) and  (ball_x_l <= BLOCK104_R) then
				block104_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK104_L <= ball_x_r) and (ball_x_r <= BLOCK104_R) and block104_alive_reg = '1' then
			if (BLOCK104_T <= ball_y_b) and (ball_y_t <= BLOCK104_B) then
				block104_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK104_R) and (ball_x_l >= BLOCK104_L) and block104_alive_reg = '1' then
			if (BLOCK104_T <= ball_y_b) and (ball_y_t <= BLOCK104_B) then
				block104_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK105_B >= ball_y_t) and (ball_y_t >= BLOCK105_T) and block105_alive_reg = '1' then
			if (BLOCK105_L <= ball_x_r) and  (ball_x_l <= BLOCK105_R) then
				block105_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK105_T) and (ball_y_b <= BLOCK105_B) and block105_alive_reg = '1' then
			if (BLOCK105_L <= ball_x_r) and  (ball_x_l <= BLOCK105_R) then
				block105_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK105_L <= ball_x_r) and (ball_x_r <= BLOCK105_R) and block105_alive_reg = '1' then
			if (BLOCK105_T <= ball_y_b) and (ball_y_t <= BLOCK105_B) then
				block105_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK105_R) and (ball_x_l >= BLOCK105_L) and block105_alive_reg = '1'  then
			if (BLOCK105_T <= ball_y_b) and (ball_y_t <= BLOCK105_B) then
				block105_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK106_B >= ball_y_t) and (ball_y_t >= BLOCK106_T) and block106_alive_reg = '1' then
			if (BLOCK106_L <= ball_x_r) and  (ball_x_l <= BLOCK106_R) then
				block106_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK106_T) and (ball_y_b <= BLOCK106_B) and block106_alive_reg = '1' then
			if (BLOCK106_L <= ball_x_r) and  (ball_x_l <= BLOCK106_R) then
				block106_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK106_L <= ball_x_r) and (ball_x_r <= BLOCK106_R) and block106_alive_reg = '1' then
			if (BLOCK106_T <= ball_y_b) and (ball_y_t <= BLOCK106_B) then
				block106_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK106_R) and (ball_x_l >= BLOCK106_L) and block106_alive_reg = '1' then
			if (BLOCK106_T <= ball_y_b) and (ball_y_t <= BLOCK106_B) then
				block106_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK107_B >= ball_y_t) and (ball_y_t >= BLOCK107_T) and block107_alive_reg = '1' then
			if (BLOCK107_L <= ball_x_r) and  (ball_x_l <= BLOCK107_R) then
				block107_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK107_T) and (ball_y_b <= BLOCK107_B) and block107_alive_reg = '1' then
			if (BLOCK107_L <= ball_x_r) and  (ball_x_l <= BLOCK107_R) then
				block107_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK107_L <= ball_x_r) and (ball_x_r <= BLOCK107_R) and block107_alive_reg = '1' then
			if (BLOCK107_T <= ball_y_b) and (ball_y_t <= BLOCK107_B) then
				block107_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK107_R) and (ball_x_l >= BLOCK107_L) and block107_alive_reg = '1' then
			if (BLOCK107_T <= ball_y_b) and (ball_y_t <= BLOCK107_B) then
				block107_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK108_B >= ball_y_t) and (ball_y_t >= BLOCK108_T) and block108_alive_reg = '1' then
			if (BLOCK108_L <= ball_x_r) and  (ball_x_l <= BLOCK108_R) then
				block108_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK108_T) and (ball_y_b <= BLOCK108_B) and block108_alive_reg = '1' then
			if (BLOCK108_L <= ball_x_r) and  (ball_x_l <= BLOCK108_R) then
				block108_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK108_L <= ball_x_r) and (ball_x_r <= BLOCK108_R) and block108_alive_reg = '1' then
			if (BLOCK108_T <= ball_y_b) and (ball_y_t <= BLOCK108_B) then
				block108_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK108_R) and (ball_x_l >= BLOCK108_L) and block108_alive_reg = '1' then
			if (BLOCK108_T <= ball_y_b) and (ball_y_t <= BLOCK108_B) then
				block108_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK109_B >= ball_y_t) and (ball_y_t >= BLOCK109_T) and block109_alive_reg = '1' then
			if (BLOCK109_L <= ball_x_r) and  (ball_x_l <= BLOCK109_R) then
				block109_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK109_T) and (ball_y_b <= BLOCK109_B) and block109_alive_reg = '1' then
			if (BLOCK109_L <= ball_x_r) and  (ball_x_l <= BLOCK109_R) then
				block109_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK109_L <= ball_x_r) and (ball_x_r <= BLOCK109_R) and block109_alive_reg = '1' then
			if (BLOCK109_T <= ball_y_b) and (ball_y_t <= BLOCK109_B) then
				block109_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK109_R) and (ball_x_l >= BLOCK109_L) and block109_alive_reg = '1' then
			if (BLOCK109_T <= ball_y_b) and (ball_y_t <= BLOCK109_B) then
				block109_alive_next <= '0';
				hit <= '1';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK110_B >= ball_y_t) and (ball_y_t >= BLOCK110_T) and block110_alive_reg = '1' then
			if (BLOCK110_L <= ball_x_r) and  (ball_x_l <= BLOCK110_R) then
				block110_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK110_T) and (ball_y_b <= BLOCK110_B) and block110_alive_reg = '1' then
			if (BLOCK110_L <= ball_x_r) and  (ball_x_l <= BLOCK110_R) then
				block110_alive_next <= '0';
				hit <= '1';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK110_L <= ball_x_r) and (ball_x_r <= BLOCK110_R) and block110_alive_reg = '1' then
			if (BLOCK110_T <= ball_y_b) and (ball_y_t <= BLOCK110_B) then
				block110_alive_next <= '0';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK110_R) and (ball_x_l >= BLOCK110_L) and block110_alive_reg = '1' then
			if (BLOCK110_T <= ball_y_b) and (ball_y_t <= BLOCK110_B) then
				block110_alive_next <= '0';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK111_B >= ball_y_t) and (ball_y_t >= BLOCK111_T) and block111_alive_reg = '1' then
			if (BLOCK111_L <= ball_x_r) and  (ball_x_l <= BLOCK111_R) then
				block111_alive_next <= '0';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK111_T) and (ball_y_b <= BLOCK111_B) and block111_alive_reg = '1' then
			if (BLOCK111_L <= ball_x_r) and  (ball_x_l <= BLOCK111_R) then
				block111_alive_next <= '0';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK111_L <= ball_x_r) and (ball_x_r <= BLOCK111_R) and block111_alive_reg = '1' then
			if (BLOCK111_T <= ball_y_b) and (ball_y_t <= BLOCK111_B) then
				block111_alive_next <= '0';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK111_R) and (ball_x_l >= BLOCK111_L) and block111_alive_reg = '1' then
			if (BLOCK111_T <= ball_y_b) and (ball_y_t <= BLOCK111_B) then
				block111_alive_next <= '0';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
		if (BLOCK112_B >= ball_y_t) and (ball_y_t >= BLOCK112_T) and block112_alive_reg = '1' then
			if (BLOCK112_L <= ball_x_r) and  (ball_x_l <= BLOCK112_R) then
				block112_alive_next <= '0';
				y_delta_next <= BALL_V_P;
			end if;
		elsif (ball_y_b >= BLOCK112_T) and (ball_y_b <= BLOCK112_B) and block112_alive_reg = '1' then
			if (BLOCK112_L <= ball_x_r) and  (ball_x_l <= BLOCK112_R) then
				block112_alive_next <= '0';
				y_delta_next <= BALL_V_N;
			end if;
		elsif (BLOCK112_L <= ball_x_r) and (ball_x_r <= BLOCK112_R) and block112_alive_reg = '1' then
			if (BLOCK112_T <= ball_y_b) and (ball_y_t <= BLOCK112_B) then
				block112_alive_next <= '0';
				x_delta_next <= BALL_V_N;
			end if;
		elsif (ball_x_l <= BLOCK112_R) and (ball_x_l >= BLOCK112_L) and block112_alive_reg = '1' then
			if (BLOCK112_T <= ball_y_b) and (ball_y_t <= BLOCK112_B) then
				block112_alive_next <= '0';
				x_delta_next <= BALL_V_P;
			end if;
		end if;
	end process;
	
	
	
	process(video_on, wall_on, bar_on, rd_ball_on,
				wall_rgb, bar_rgb, ball_rgb, block1_on, block2_on, block3_on, block4_on, block5_on, block6_on,
			 block7_on, block8_on, block9_on, block10_on, block11_on, block12_on,
			 block13_on, block14_on, block15_on, block16_on, block17_on, block18_on, block19_on, block20_on,
			 block21_on, block22_on, block23_on, block24_on, block25_on, block26_on,
			 block27_on, block28_on, block29_on, block30_on, block31_on, block32_on, block33_on, block34_on,
			 block35_on, block36_on, block37_on, block38_on, block39_on, block40_on,
			 block41_on, block42_on, block43_on, block44_on, block45_on, block46_on, block47_on, block48_on,
			 block49_on, block50_on, block51_on, block52_on, block53_on, block54_on,
			 block55_on, block56_on, block57_on, block58_on, block59_on, block60_on, block61_on, block62_on,
			 block63_on, block64_on, block65_on, block66_on, block67_on, block68_on,
			 block69_on, block70_on, block71_on, block72_on, block73_on, block74_on, block75_on, block76_on,
			 block77_on, block78_on, block79_on, block80_on, block81_on, block82_on,
			 block83_on, block84_on, block85_on, block86_on, block87_on, block88_on, block89_on, block90_on,
			 block91_on, block92_on, block93_on, block94_on, block95_on, block96_on,
			 block97_on, block98_on, block99_on, block100_on, block101_on, block102_on, block103_on, block104_on,
			 block105_on, block106_on, block107_on, block108_on, block109_on, block110_on,
			 block111_on, block112_on, first_block_rgb, second_block_rgb, third_block_rgb, forth_block_rgb)
	begin
		if video_on = '0' then
			graph_rgb <= "000";
		else
			if wall_on = '1' then
				graph_rgb <= wall_rgb;
			elsif bar_on = '1' then
				graph_rgb <= bar_rgb;
			elsif block1_on = '1' or block2_on = '1' or block3_on = '1' or block4_on = '1'
					or block5_on = '1' or block6_on = '1' or block7_on = '1' or block8_on = '1'
					or block9_on = '1' or block10_on = '1' or block11_on = '1' or block12_on = '1' 
					or block13_on = '1' or block14_on = '1' or block15_on = '1' or block16_on = '1'
				   or block17_on = '1' or block18_on = '1' or block19_on = '1' or block20_on = '1'
				   or block21_on = '1' or block22_on = '1' or block23_on = '1' or block24_on = '1'
				   or block25_on = '1' or block26_on = '1' or block27_on = '1' or block28_on = '1'	then
				graph_rgb <= first_block_rgb;
			elsif block29_on = '1' or block30_on = '1' or block31_on = '1' or block32_on = '1' 
					or block33_on = '1' or block34_on = '1' or block35_on = '1' or block36_on = '1'
					or block37_on = '1' or block38_on = '1' or block39_on = '1' or block40_on = '1' 
					or block41_on = '1' or block42_on = '1' or block43_on = '1' or block44_on = '1'
					or block45_on = '1' or block46_on = '1' or block47_on = '1' or block48_on = '1'
					or block49_on = '1' or block50_on = '1' or block51_on = '1' or block52_on = '1'
					or block53_on = '1' or block54_on = '1' or block55_on = '1'	or block56_on = '1' then
				graph_rgb <= second_block_rgb;
			elsif block57_on = '1' or block58_on = '1' or block59_on = '1' or block60_on = '1' 
					or block61_on = '1' or block62_on = '1' or block63_on = '1' or block64_on = '1'
					or block65_on = '1' or block66_on = '1' or block67_on = '1' or block68_on = '1' 
					or block69_on = '1' or block70_on = '1' or block71_on = '1' or block72_on = '1'
					or block73_on = '1' or block74_on = '1' or block75_on = '1' or block76_on = '1'
					or block77_on = '1' or block78_on = '1' or block79_on = '1' or block80_on = '1'
					or block81_on = '1' or block82_on = '1' or block83_on = '1'	or block84_on = '1' then
				graph_rgb <= third_block_rgb;
			elsif block85_on = '1' or block86_on = '1' or block87_on = '1' or block88_on = '1' 
					or block89_on = '1' or block90_on = '1' or block91_on = '1' or block92_on = '1'
					or block93_on = '1' or block94_on = '1' or block95_on = '1' or block96_on = '1' 
					or block97_on = '1' or block98_on = '1' or block99_on = '1' or block100_on = '1'
					or block101_on = '1' or block102_on = '1' or block103_on = '1' or block104_on = '1'
					or block105_on = '1' or block106_on = '1' or block107_on = '1' or block108_on = '1'
					or block109_on = '1' or block110_on = '1' or block111_on = '1'	or block112_on = '1' then
				graph_rgb <= forth_block_rgb;
			elsif rd_ball_on = '1' then
				graph_rgb <= ball_rgb;
			else 
				graph_rgb <= "000";
			end if;
		end if;
	end process;
	graph_on <= wall_on or bar_on or rd_ball_on or 
					 block1_on or  block2_on or  block3_on or block4_on or block5_on or block6_on or
					 block7_on or block8_on or block9_on or block10_on or block11_on or block12_on or
					 block13_on or block14_on or block15_on or block16_on or block17_on or block18_on or
					 block19_on or block20_on or block21_on or block22_on or block23_on or block24_on or
					 block25_on or block26_on or block27_on or block28_on or block29_on or block30_on or
					 block31_on or block32_on or block33_on or block34_on or block35_on or block36_on or
					 block37_on or block38_on or block39_on or block40_on or block41_on or block42_on or
					 block43_on or block44_on or block45_on or block46_on or block47_on or block48_on or
					 block49_on or block50_on or block51_on or block52_on or block53_on or block54_on or
					 block55_on or block56_on or block57_on or block58_on or block59_on or block60_on or
					 block61_on or block62_on or block63_on or block64_on or block65_on or block66_on or
					 block67_on or block68_on or block69_on or block70_on or block71_on or block72_on or
					 block73_on or block74_on or block75_on or block76_on or block77_on or block78_on or 
					 block79_on or block80_on or block81_on or block82_on or block83_on or block84_on or
					 block85_on or block86_on or block87_on or block88_on or block89_on or block90_on or
					 block91_on or block92_on or block93_on or block94_on or block95_on or block96_on or
					 block97_on or block98_on or block99_on or block100_on or block101_on or block102_on or 
					 block103_on or block104_on or block105_on or block106_on or block107_on or block108_on or
					 block109_on or block110_on or block111_on or block112_on;
end arch;