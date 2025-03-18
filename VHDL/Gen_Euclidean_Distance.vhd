----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : HBA (Hardware Bee Algorithm)
-- File Name        : Gen_Euclidean_Distance
-- Module Name      : Gen_Euclidean_Distance
-- HDL Standard     : VHDL
-- Approach         : Behavioral (Moore FSM)
-- Description      : Generic core to calculate the Euclidean distance between two points on the 2D page
-- Comments         : 
-- Dependencies     : Altera SQRT IP core
-- Target Devices   : MAX10 - 10M50DAF484C6GES
-- Speed Estimation : 
-- Area  Estimation : 1061 LEs + 246 FFs + 14 9-bit Multiplier
-- Tools            : Altera Quartus 16.1 Lite
-- Module Version   : 
-- Creation Date    : 2024/07/15
-- Revision Date    : 2024/07/16
----------------------------------------------------------------------------------------------------

-- The "-- Xilinx" and the "-- Altera" shows the differences between the VHDL files
-- "Gen_Euclidean_Distance_Xilinx" and "Gen_Euclidean_Distance", correspondingly

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- Altera Library
library altera_mf;
use altera_mf.all;

entity Gen_Euclidean_Distance is
	generic  (
				DATA_WIDTH : integer := 24;
				DIST_WIDTH : integer := 32);
	port     (
				CLK        : in  std_logic;
				RESET      : in  std_logic;
				CE         : in  std_logic;
				DATA_X1    : in  std_logic_vector (DATA_WIDTH-1 downto 0);
				DATA_X2    : in  std_logic_vector (DATA_WIDTH-1 downto 0);
				DATA_Y1    : in  std_logic_vector (DATA_WIDTH-1 downto 0);
				DATA_Y2    : in  std_logic_vector (DATA_WIDTH-1 downto 0);
				E_DIST     : out std_logic_vector (DIST_WIDTH-1 downto 0);
				DONE       : out std_logic);
end Gen_Euclidean_Distance;

architecture Moore_FSM of Gen_Euclidean_Distance is
	
	-- Square root module constants
	constant SR_In_Width  : integer := 48; -- Max = 48
	constant SR_Out_Width : integer := 25; -- Max = 25

	---------- Components ----------
	
	-- Altera
	component altsqrt
		generic (
					pipeline     : NATURAL;
					q_port_width : NATURAL;
					r_port_width : NATURAL;
					width        : NATURAL;
					lpm_type     : STRING);
		PORT    (
					clk          : in  STD_LOGIC ;
					ena          : in  STD_LOGIC ;
					radical      : in  STD_LOGIC_VECTOR (SR_In_Width -1 downto 0);
					q            : out STD_LOGIC_VECTOR (SR_Out_Width-2 downto 0);
					remainder    : out STD_LOGIC_VECTOR (SR_Out_Width-1 downto 0));
	end component;
	
	---------- Signals ----------
	
	-- Square root module signals
	signal SR_CE    : std_logic := '0';
	signal Data_Out : std_logic_vector (SR_Out_Width-2 downto 0)                    := (others => '0'); -- Altera
	signal Data_In_Curr , Data_In_Next : std_logic_vector (SR_In_Width-1 downto 0)  := (others => '0');
	
	-- Misc
	signal Diff_X_Curr , Diff_X_Next   : std_logic_vector (DATA_WIDTH-1 downto 0)   := (others => '0');
	signal Diff_Y_Curr , Diff_Y_Next   : std_logic_vector (DATA_WIDTH-1 downto 0)   := (others => '0');
	signal Mult_X_Curr , Mult_X_Next   : std_logic_vector (SR_In_Width-1 downto 0)  := (others => '0');
	signal Mult_Y_Curr , Mult_Y_Next   : std_logic_vector (SR_In_Width-1 downto 0)  := (others => '0');

	-- State Machine & Control Signals
	type State is (Idle , Sub , Mult , Add , SR_En , SR_Out , Final); -- Altera
	signal S_Curr , S_Next : State;
	
begin
	
	process (CLK , RESET)
	begin
		if (RESET = '1') then
			S_Curr <= Idle;
			-- Preventing latches and replacing them with registers
			Data_In_Curr <= (others => '0');
			Diff_X_Curr  <= (others => '0');
			Diff_Y_Curr  <= (others => '0');
			Mult_X_Curr  <= (others => '0');
			Mult_Y_Curr  <= (others => '0');
		elsif (rising_edge(CLK)) then
			S_Curr <= S_Next;
			-- Preventing latches and replacing them with registers
			Data_In_Curr <= Data_In_Next;
			Diff_X_Curr  <= Diff_X_Next;
			Diff_Y_Curr  <= Diff_Y_Next;
			Mult_X_Curr  <= Mult_X_Next;
			Mult_Y_Curr  <= Mult_Y_Next;
		end if;
	end process;

--	process (S_Curr , CE , SR_CE) -- The main sensitivity list that matters -- Altera
	process (S_Curr , Data_In_Curr , Diff_X_Curr , Diff_Y_Curr , Mult_X_Curr , Mult_Y_Curr , Data_Out ,
				CE , SR_CE , DATA_X1 , DATA_X2 , DATA_Y1 , DATA_Y2) -- Altera
	begin

		S_Next <= S_Curr;
		-- Preventing latches and replacing them with registers
		Data_In_Next <= Data_In_Curr;
		Diff_X_Next  <= Diff_X_Curr;
		Diff_Y_Next  <= Diff_Y_Curr;
		Mult_X_Next  <= Mult_X_Curr;
		Mult_Y_Next  <= Mult_Y_Curr;

		-- Default assignments to prevent latches
		SR_CE   <= '0';
		DONE    <= '0';
		E_DIST  <= (others => '1');
		
		case S_Curr is
			when Idle    =>
								if (CE = '1') then
									S_Next <= Sub;
								end if;
			
			when Sub     =>
								if (DATA_X1 > DATA_X2) then
									Diff_X_Next <= DATA_X1 - DATA_X2;
								else
									Diff_X_Next <= DATA_X2 - DATA_X1;
								end if;
								if (DATA_Y1 > DATA_Y2) then
									Diff_Y_Next <= DATA_Y1 - DATA_Y2;
								else
									Diff_Y_Next <= DATA_Y2 - DATA_Y1;
								end if;
								S_Next <= Mult;
			
			when Mult    =>
								Mult_X_Next <= Diff_X_Curr*Diff_X_Curr;
								Mult_Y_Next <= Diff_Y_Curr*Diff_Y_Curr;
								S_Next <= Add;
			
			when Add     =>
								Data_In_Next <= Mult_X_Curr + Mult_Y_Curr;
								S_Next <= SR_En;
			
			when SR_En   => -- Altera
								SR_CE <= '1'; -- Enable the square root module
								S_Next <= SR_Out;
			
			when SR_Out  =>
								SR_CE <= '1'; -- Keep the square root module enabled
								E_DIST <= "00000000" & Data_Out; -- Altera
								S_Next <= Final;
			
			when Final   =>
								SR_CE <= '1'; -- Keep the square root module enabled
								DONE <= '1';
								E_DIST <= "00000000" & Data_Out; -- Altera
								if (CE = '0') then
									S_Next <= Idle;
								end if;
		end case;
	end process;

	---------- Instantiations ----------

	-- Altera
	ALTSQRT_component : ALTSQRT
	generic map (
					pipeline     => 1,
					q_port_width => SR_Out_Width-1,
					r_port_width => SR_Out_Width,
					width        => SR_In_Width,
					lpm_type     => "ALTSQRT")
	port map    (
					clk          => CLK,
					ena          => SR_CE,
					radical      => Data_In_Curr,
					q            => Data_Out,
					remainder    => open);
	
end Moore_FSM;