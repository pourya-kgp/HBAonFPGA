----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : HBA (Hardware Bee Algorithm)
-- File Name        : Gen_Euclidean_Distance_Xilinx
-- Module Name      : Gen_Euclidean_Distance
-- HDL Standard     : VHDL
-- Approach         : Behavioral (Moore FSM)
-- Description      : Generic core to calculate the Euclidean distance between two points on the 2D page
-- Comments         : 
-- Dependencies     : Xilinx SQRT IP core
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : 147 MHz
-- Area  Estimation : 640 LUTs + 682 FFs + 4 DSPs
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/09
-- Revision Date    : 2024/07/10
----------------------------------------------------------------------------------------------------

-- The "-- Xilinx" and the "-- Altera" shows the differences between the VHDL files
-- "Gen_Euclidean_Distance_Xilinx" and "Gen_Euclidean_Distance", correspondingly

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

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
	
	-- Xilinx
	component Square_Root
		port (
				clk   : in  std_logic;
				ce    : in  std_logic;
				sclr  : in  std_logic;
				x_in  : in  std_logic_vector (SR_In_Width-1  downto 0);
				x_out : out std_logic_vector (SR_Out_Width-1 downto 0);
				rdy   : out std_logic);
	end component;
	
	---------- Signals ----------
	
	-- Square root module signals
	signal SR_CE    : std_logic := '0';
	signal SR_SClr  : std_logic := '0';                                                                 -- Xilinx
	signal SR_Rdy   : std_logic := '0';                                                                 -- Xilinx
	signal Data_Out : std_logic_vector (SR_Out_Width-1 downto 0)                    := (others => '0'); -- Xilinx
	signal Data_In_Curr , Data_In_Next : std_logic_vector (SR_In_Width-1 downto 0)  := (others => '0');
	
	-- Misc
	signal Diff_X_Curr , Diff_X_Next   : std_logic_vector (DATA_WIDTH-1  downto 0)  := (others => '0');
	signal Diff_Y_Curr , Diff_Y_Next   : std_logic_vector (DATA_WIDTH-1  downto 0)  := (others => '0');
	signal Mult_X_Curr , Mult_X_Next   : std_logic_vector (SR_In_Width-1 downto 0)  := (others => '0');
	signal Mult_Y_Curr , Mult_Y_Next   : std_logic_vector (SR_In_Width-1 downto 0)  := (others => '0');

	-- State Machine & Control Signals
	type State is (Idle , Sub , Mult , Add , SR_En , SR_Calc , SR_Out , Final); -- Xilinx
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

--	process (S_Curr , CE , SR_CE , SR_Rdy) -- The main sensitivity list that matters -- Xilinx
	process (S_Curr , Data_In_Curr , Diff_X_Curr , Diff_Y_Curr , Mult_X_Curr , Mult_Y_Curr , Data_Out ,
				CE , SR_CE , SR_Rdy , DATA_X1 , DATA_X2 , DATA_Y1 , DATA_Y2) -- Xilinx
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
		SR_SClr <= '0';    -- Xilinx
		DONE    <= '0';
--		DONE    <= SR_Rdy; -- Xilinx
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
			
			when SR_En   => -- Xilinx
								-- Wait until the square root module's "rdy" output gets low (it takes more than 1 clock pulse after a clear signal)
								if (SR_Rdy = '0') then
									SR_CE <= '1'; -- Enable the square root module
								end if;
								S_Next <= SR_Calc;
			
			when SR_Calc => -- Xilinx
								SR_CE <= '1'; -- Keep the square root module enabled
								if (SR_Rdy = '1') then -- Read the square root module's output data 1 clock pulse after receiving "rdy" signal
									S_Next <= SR_Out;
								end if;
			
			when SR_Out  =>
								SR_CE <= '1'; -- Keep the square root module enabled
								E_DIST <= "0000000" & Data_Out; -- Xilinx
								S_Next <= Final;
			
			when Final   =>
								SR_CE <= '1'; -- Keep the square root module enabled
								DONE <= '1';
								E_DIST <= "0000000" & Data_Out; -- Xilinx
								if (CE = '0') then
									SR_SClr <= '1'; -- Clear the square root module's output (the module must be enabled) -- Xilinx
									S_Next <= Idle;
								end if;
		end case;
	end process;

	---------- Instantiations ----------

	-- Xilinx
	SR: Square_Root
		port map (
				clk   => CLK,
				ce    => SR_CE,
				sclr  => SR_SClr,
				x_in  => Data_In_Curr,
				x_out => Data_Out,
				rdy   => SR_Rdy);
	
end Moore_FSM;