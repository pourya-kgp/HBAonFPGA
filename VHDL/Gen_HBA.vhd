----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : HBA (Hardware Bee Algorithm)
-- File Name        : Gen_HBA
-- Module Name      : Gen_HBA
-- HDL Standard     : VHDL
-- Approach         : Behavioral (Moore FSM)
-- Description      : Generic core for Hardware Bee Algorithm for solving the TSP
-- Comments         : 
-- Dependencies     : 7 Cores
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : 118 MHz
-- Area  Estimation : 10300 LUTs + 4397 FFs + 28 RAM/FIFO + 22 DSPs (eil51 Database)
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/09
-- Revision Date    : 2024/06/29
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity Gen_HBA is
	generic (
				INDX_WIDTH  : integer := 8;
				ADDR_WIDTH  : integer := 11;
				TOUR_WIDTH  : integer := 32);
	port    (
				CLK         : in  std_logic;
				RESET       : in  std_logic;
				CE          : in  std_logic;
				TOUR        : out std_logic_vector (INDX_WIDTH-1 downto 0);
				TOUR_LENGTH : out std_logic_vector (TOUR_WIDTH-1 downto 0);
				DONE        : out std_logic);
end Gen_HBA;

architecture Behavioral of Gen_HBA is

	---------- Components ----------
	
	component Gen_Nearest_Neighbor_Tour is
		generic (
					INDX_WIDTH  : integer := 8;
					ADDR_WIDTH  : integer := 11;
					TOUR_WIDTH  : integer := 32);
		port    (
					CLK         : in  std_logic;
					RESET       : in  std_logic;
					CE          : in  std_logic;
					NEXT_TOUR   : in  std_logic;
					SEND_TOUR   : in  std_logic;
					CITIES      : in  std_logic_vector (INDX_WIDTH-1 downto 0);
					TOUR        : out std_logic_vector (INDX_WIDTH-1 downto 0);
					INDX        : out std_logic_vector (INDX_WIDTH-1 downto 0);
					TOUR_LENGTH : out std_logic_vector (TOUR_WIDTH-1 downto 0);
					DONE        : out std_logic);
	end component;
	
	component Gen_Bee_Sync is
		generic (
					INDX_WIDTH : integer := 8;
					ADDR_WIDTH : integer := 11;
					TOUR_WIDTH : integer := 32);
		port    (
					CLK        : in  std_logic;
					RESET      : in  std_logic;
					CE         : in  std_logic;
					SEL        : in  std_logic_vector (2 downto 0);
					CITIES     : in  std_logic_vector (INDX_WIDTH-1 downto 0);
					DATA1_IN   : in  std_logic_vector (INDX_WIDTH-1 downto 0);
					DATA2_IN   : in  std_logic_vector (INDX_WIDTH-1 downto 0);
					FITSS_IN   : in  std_logic_vector (TOUR_WIDTH-1 downto 0);
					DATA1_OUT  : out std_logic_vector (INDX_WIDTH-1 downto 0);
					DATA2_OUT  : out std_logic_vector (INDX_WIDTH-1 downto 0);
					FITSS_OUT  : out std_logic_vector (TOUR_WIDTH-1 downto 0);
					DONE       : out std_logic);
	end component;
	
	component Gen_Sort_Permit is
		generic (
					DATA_WIDTH  : integer := 8);
		port    (
					DATA1_IN    : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					DATA2_IN    : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					CE          : in  std_logic;
					NEXT_PERMIT : in  std_logic;
					COMPARE_IN  : in  std_logic;
					COMPARE_OUT : out std_logic;
					PERMIT      : out std_logic);
	end component;
	
	component Gen_Mux4_1 is
		generic (
					DATA_WIDTH : integer := 8);
		port    (
					S          : in  std_logic_vector (1 downto 0);
					D0         : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					D1         : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					D2         : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					D3         : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					O          : out std_logic_vector (DATA_WIDTH-1 downto 0));
	end component;
	
	component Gen_Mux2_1 is
		generic (
					DATA_WIDTH : integer := 8);
		port    (
					S          : in  std_logic;
					D0         : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					D1         : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					O          : out std_logic_vector (DATA_WIDTH-1 downto 0));
	end component;
	
	component Gen_Local_Search is
		generic (
					INDX_WIDTH : integer := 8;
					ADDR_WIDTH : integer := 11;
					TOUR_WIDTH : integer := 32);
		port    (
					CLK        : in  std_logic;
					RESET      : in  std_logic;
					CE         : in  std_logic;
					DONE_BEE   : in  std_logic;
					CITIES     : in  std_logic_vector (INDX_WIDTH-1 downto 0);
					ITERS_IN   : in  std_logic_vector (INDX_WIDTH-1 downto 0);
					DATA1_IN   : in  std_logic_vector (INDX_WIDTH-1 downto 0);
					DATA2_IN   : in  std_logic_vector (INDX_WIDTH-1 downto 0);
					FITSS_IN   : in  std_logic_vector (TOUR_WIDTH-1 downto 0);
					DATA1_OUT  : out std_logic_vector (INDX_WIDTH-1 downto 0);
					DATA2_OUT  : out std_logic_vector (INDX_WIDTH-1 downto 0);
					FITSS_OUT  : out std_logic_vector (TOUR_WIDTH-1 downto 0);
					NEXT_DATA  : out std_logic;
					DONE       : out std_logic);
	end component;
	
	component Gen_Update_Tour_V1 is
		generic (
					DATA_WIDTH : integer := 8);
		port    (
					CLK        : in  std_logic;
					RESET      : in  std_logic;
					CE         : in  std_logic;
					DONE_BEE   : in  std_logic;
					DATA1_IN   : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					DATA2_IN   : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					DATA1_OUT  : out std_logic_vector (DATA_WIDTH-1 downto 0);
					DATA2_OUT  : out std_logic_vector (DATA_WIDTH-1 downto 0);
					CE_BEE     : out std_logic;
					DONE       : out std_logic);
	end component;
	
	---------- Signals ----------
	
	-- Constants
	constant Cities                  : std_logic_vector (INDX_WIDTH-1 downto 0) := conv_std_logic_vector (51 , INDX_WIDTH);
	constant Local_Iter              : std_logic_vector (INDX_WIDTH-1 downto 0) := conv_std_logic_vector (30 , INDX_WIDTH); -- Begins at 1
	constant Iterations              : std_logic_vector (INDX_WIDTH-1 downto 0) := conv_std_logic_vector (50 , INDX_WIDTH); -- Begins at 1
	
	constant Bees_All                : integer range 1 to 2**INDX_WIDTH-1       := 10; -- Number of the Bees
	constant Bees_Selected           : integer range 1 to 2**INDX_WIDTH-1       := 10; -- Number of the Selected Bees
	constant Bees_Elite              : integer range 1 to 2**INDX_WIDTH-1       := 2;  -- Number of the Elite Bees
	constant Bee_Best                : integer range 1 to 2**INDX_WIDTH-1       := 1;  -- Starts from Bee number 1
	constant Recruited_Bees_Selected : std_logic_vector (INDX_WIDTH-1 downto 0) := conv_std_logic_vector (2 , INDX_WIDTH); -- Begins at 1
	constant Recruited_Bees_Elite    : std_logic_vector (INDX_WIDTH-1 downto 0) := conv_std_logic_vector (2 , INDX_WIDTH); -- Begins at 1
	
	constant Zero_Indx               : std_logic_vector (INDX_WIDTH-1 downto 0) := (others => '0');
	constant Zero_Tour               : std_logic_vector (TOUR_WIDTH-1 downto 0) := (others => '0');

	-- Nearest Neighbor Tour Constructor Module
	signal NNT_CE , Next_Tour , Send_Tour , NNT_Done : std_logic := '0';
	signal NNT_Tour , NNT_Indx                       : std_logic_vector (INDX_WIDTH-1 downto 0) := (others => '0');
	signal NNT_Tour_Length                           : std_logic_vector (TOUR_WIDTH-1 downto 0) := (others => '0');
	
	-- Bee Modules
	subtype Bee_Sel_Sub is std_logic_vector (2 downto 0);
	subtype Bee_Ind_Sub is std_logic_vector (INDX_WIDTH-1 downto 0);
	subtype Bee_Len_Sub is std_logic_vector (TOUR_WIDTH-1 downto 0);
	
	type Bee_Sel is array (Bees_All-1 downto 0) of Bee_Sel_Sub;
	type Bee_Ind is array (Bees_All-1 downto 0) of Bee_Ind_Sub;
	type Bee_Len is array (Bees_All-1 downto 0) of Bee_Len_Sub;
	
	signal Bee_CE , Bee_Done                           : std_logic_vector (Bees_All-1 downto 0) := (others => '0');
	signal Bee_Select                                  : Bee_Sel := (others => (others => '0'));
	signal Data1_In , Data2_In , Data1_Out , Data2_Out : Bee_Ind := (others => (others => '0'));
	signal Fitss_In , Fitss_Out                        : Bee_Len := (others => (others => '0'));
	
	-- Multiplex Modules
	signal Mux_D0_Data1 , Mux_D0_Data2                 : Bee_Ind := (others => (others => '0'));
	signal Mux_D0_Fitss                                : Bee_Len := (others => (others => '0'));
	
	-- Sort Permit Module
	signal Sort_CE , Next_Permit , Sort_Done : std_logic := '0';
	signal Compare , Permit                  : std_logic_vector (Bees_All-2 downto 0) := (others => '0');
	
	-- Local Search (2_Opt) Module
	type Local_Ind is array (Bees_Selected-1 downto 0) of Bee_Ind_Sub;
	type Local_Len is array (Bees_Selected-1 downto 0) of Bee_Len_Sub;
	
	signal Local_CE                    : std_logic := '0';
	signal Local_Next , Local_Done     : std_logic_vector (Bees_Selected-1 downto 0) := (others => '0');
	signal Local_Data1 , Local_Data2   : Local_Ind := (others => (others => '0'));
	signal Local_Fitss                 : Local_Len := (others => (others => '0'));
	
	-- Update Tour Module
	signal Update_CE                   : std_logic := '0';
	signal Update_Next , Update_Done   : std_logic_vector (Bees_Selected-1 downto 0) := (others => '0');
	signal Update_Data1 , Update_Data2 : Local_Ind := (others => (others => '0'));
	
	-- State Machine & Control Signals
	type State is (Idle_Mode ,
						Start_NNT_M , Done_NNT_M , Send_Request , Sending , Done_Send , Next_NNT_M ,
						Enable_Sort_M  , Permit_Request , Start_Sorting , Done_Sorting , Disable_Sort_M ,
						Local_Search_M , Local_Results ,	Update_Tour_M ,
						Show_Conditions , Delay , Show_Results , Next_Iteration , Final);
	signal S_Curr , S_Next : State;                                                          -- State Signal
	
	signal C_Curr , C_Next : std_logic_vector (INDX_WIDTH-1 downto 0)    := (others => '0'); -- Counter
	signal L_Curr , L_Next : std_logic_vector (INDX_WIDTH-1 downto 0)    := (others => '0'); -- Local Optimization Counter
	signal I_Curr , I_Next : std_logic_vector (INDX_WIDTH-1 downto 0)    := (others => '0'); -- Iterations Counter
	signal F_Curr , F_Next : std_logic_vector (Bees_Selected-1 downto 0) := (others => '0'); -- Flag for showing the results on the outputs
	signal B_Curr , B_Next : integer range 0 to 2**INDX_WIDTH-1          := 0;               -- Bees Counter

	---------- Functions ----------

	-- or_reduce
	function or_reduce (input : std_logic_vector) return std_logic is
		variable output : std_logic := '0';
	begin
		for i in input'range loop
			output := output or input(i);
		end loop;
		return output;
	end function or_reduce;
	
	-- and_reduce
	function and_reduce (input : std_logic_vector) return std_logic is
		variable output : std_logic := '1';
	begin
		for i in input'range loop
			output := output and input(i);
		end loop;
		return output;
	end function and_reduce;
	
begin
	
	Sort_Done <= not(or_reduce(Permit));
	
	process (CLK , RESET)
	begin
		if (RESET = '1') then
			S_Curr <= Idle_Mode;
			C_Curr <= (others => '0');
			L_Curr <= (others => '0');
			I_Curr <= (others => '0');
			F_Curr <= (others => '0');
			B_Curr <= 0;
		elsif (rising_edge(CLK)) then
			S_Curr <= S_Next;
			C_Curr <= C_Next;
			L_Curr <= L_Next;
			I_Curr <= I_Next;
			F_Curr <= F_Next;
			B_Curr <= B_Next;
		end if;
	end process;
	
--	process (S_Curr , C_Curr , CE , NNT_Done , Bee_Done , Sort_Done , Local_Next , Local_Done , Update_Next , Update_Done) -- The main sensitivity list that matters
	process (S_Curr , B_Curr , C_Curr , F_Curr , I_Curr , L_Curr , CE ,
				NNT_Done , NNT_Tour_Length , NNT_Tour , NNT_Indx ,                  -- Nearest Neighbor Tour Module
				Bee_Done , Data1_out , Data2_Out , Fitss_Out ,                      -- Bee Module
				Sort_Done , Permit ,                                                -- Sorting Module
				Local_Next , Local_Done , Local_Data1 , Local_Data2 , Local_Fitss , -- Local_Search Module
				Update_Next , Update_Done , Update_Data1 , Update_Data2)            -- Update_Tour Module
	begin
		
		-- Preventing latches and replacing them with registers
		S_Next <= S_Curr;
		C_Next <= C_Curr;
		L_Next <= L_Curr;
		I_Next <= I_Curr;
		F_Next <= F_Curr;
		B_Next <= B_Curr;

		-- Default assignments to prevent latches
		-- CEs
		NNT_CE      <= '1';
		Next_Tour   <= '0';
		Send_Tour   <= '0';
		Sort_CE     <= '0';
		Next_Permit <= '0';
		Local_CE    <= '0';
		Update_CE   <= '0';
		Bee_CE      <= (others => '0');
		-- Arrays
		Bee_Select   <= (others => (others => '0')); ----------> Single_Write
		Mux_D0_Data1 <= (others => (others => '0'));
		Mux_D0_Data2 <= (others => (others => '0'));
		Mux_D0_Fitss <= (others => (others => '0'));
		-- Outputs
		TOUR        <= (others => '0');
		TOUR_LENGTH <= (others => '0');
		DONE        <= '0';

		case S_Curr is
			when Idle_Mode       =>
											if (CE = '1') then
												NNT_CE <= '1';
												C_Next <= (others => '0');
												L_Next <= (others => '0');
												I_Next <= (others => '0');
												F_Next <= (others => '0');
												B_Next <= 0;
												S_Next <= Start_NNT_M;
											else
												NNT_CE <= '0';
												S_Next <= Idle_Mode; -- Redundant, only for clarification purposes
											end if;
			
			when Start_NNT_M     =>
											Next_Tour <= '1';
											S_Next <= Done_NNT_M;
			
			when Done_NNT_M      =>
											if (NNT_Done = '1') then -- It is better to Set Send_Tour at least 1 Clock Pulse after NNT_Done Signal
												Bee_Select(B_Curr) <= "000"; ----------> Single_Write (Redundant, only for clarification purposes)
												S_Next <= Send_Request;
											else
												S_Next <= Done_NNT_M; -- Redundant, only for clarification purposes
											end if;
			
			when Send_Request    =>
											Send_Tour <= '1'; -- Put the data on the output ports of NNT Module in 1 Clock pulse
											Bee_CE(B_Curr) <= '1'; -- Get the data from input ports after 1 Clock pulse
											C_Next <= (others => '0');
											S_Next <= Sending;
			
			when Sending         =>
											-- In ALL Modes except SORTING, Data1_In(B_Curr) signal is connected to Mux_D0_Data1(B_Curr) signal
											-- In ALL Modes except SORTING, Data2_In(B_Curr) signal is connected to Mux_D0_Data2(B_Curr) signal
											-- In ALL Modes except SORTING, Fitss_In(B_Curr) signal is connected to Mux_D0_Fitss(B_Curr) signal
											if (NNT_Tour /= Zero_Indx) then
												Mux_D0_Data1(B_Curr) <= NNT_Tour;        -- Put the NNT_Tour on Data1_In with one clock pulse latency
												Mux_D0_Data2(B_Curr) <= NNT_Indx;        -- Put the NNT_Indx on Data2_In with one clock pulse latency
												Mux_D0_Fitss(B_Curr) <= NNT_Tour_Length; -- Put the NNT_Tour_Length on Fitss_In with one clock pulse latency
												----------------------------------------
												TOUR        <= NNT_Tour;                 -- Demonstrating the Results on output ports
--												TOUR_LENGTH <= X"0000_00" & NNT_Indx;    -- Demonstrating the Results on output ports
												TOUR_LENGTH <= NNT_Tour_Length;          -- Demonstrating the Results on output ports
											end if;
											if (C_Curr < Cities) then
												C_Next <= C_Curr + 1;	
												S_Next <= Sending; -- Redundant, only for clarification purposes
											else
												C_Next <= (others => '0');
												S_Next <= Done_Send;
											end if;
			
			when Done_Send       =>
											Mux_D0_Fitss(B_Curr) <= NNT_Tour_Length; -- Extremely important when assigning a default value to the Mux_D0_Fitss signal
											if (Bee_Done(B_Curr) = '1') then -- Bee_Done(B_Curr) pulse comes 1 Clock pulse after NNT_Done pulse
												if (B_Curr < Bees_All-1 and I_Curr = Zero_Indx) then
													B_Next <= B_Curr + 1; -- The Last Bee is Bees_All-1
													S_Next <= Start_NNT_M;
												else
													S_Next <= Next_NNT_M;
												end if;
											else
												S_Next <= Done_Send; -- Redundant, only for clarification purposes
											end if;
			
			when Next_NNT_M      =>
											Next_Tour <= '1';
											S_Next <= Enable_Sort_M;
			
			when Enable_Sort_M   =>
											Sort_CE <= '1';
											S_Next <= Permit_Request;
			
			when Permit_Request  =>
											Sort_CE <= '1';
											Next_Permit <= '1';
											S_Next <= Start_Sorting;
			
			when Start_Sorting   =>
											Sort_CE <= '1';
											for i in 0 to Bees_All-2 loop
												if (Permit(i) = '1') then
													Bee_CE(i)   <= '1';
													Bee_CE(i+1) <= '1';
												end if;
											end loop;
											S_Next <= Done_Sorting;
			
			when Done_Sorting    =>
											Sort_CE <= '1';
											for i in 0 to Bees_All-1 loop
												Bee_Select(i) <= "100"; ----------> Write_Read
											end loop;
											if (Sort_Done = '1') then
												S_Next <= Disable_Sort_M;
											elsif (or_reduce(Bee_Done) = '1') then
												S_Next <= Permit_Request;
											else
												S_Next <= Done_Sorting; -- Redundant, only for clarification purposes
											end if;
			
			when Disable_Sort_M  =>
											Sort_CE <= '0'; -- Redundant, only for clarification purposes
											S_Next <= Local_Search_M;
--											F_Next(Bee_Best-1) <= '1'; -- To observe the results after each sort process
--											S_Next <= Show_Conditions;    -- To observe the results after each sort process
			
			when Local_Search_M  =>
											Local_CE <= '1'; -- Must be kept high for the whole process of searching
											for i in 0 to Bees_Selected-1 loop
												Bee_Select(i) <= "010"; ----------> Dual_Read
												Bee_CE(i)       <= Local_Next(i);
												Mux_D0_Data1(i) <= Local_Data1(i);
												Mux_D0_Data2(i) <= Local_Data2(i);
											end loop;
											if (and_reduce(Local_Done) = '1') then
												S_Next <= Local_Results;
											else
												S_Next <= Local_Search_M; -- Redundant, only for clarification purposes
											end if;
			
			when Local_Results   =>
											for i in 0 to Bees_Selected-1 loop
												if (Local_Fitss(i) < Fitss_Out(i)) then
													F_Next(i) <= '1';
												else
													F_Next(i) <= '0';
												end if;
											end loop;
											S_Next <= Update_Tour_M;
			
			when Update_Tour_M   =>
											Update_CE <= '1'; -- Must be kept high for the whole process of updating
											for i in 0 to Bees_Selected-1 loop
												Bee_Select(i) <= "001"; ----------> Exchange
												Bee_CE(i)       <= Update_Next(i);
												Mux_D0_Data1(i) <= Update_Data1(i);
												Mux_D0_Data2(i) <= Update_Data2(i);
												Mux_D0_Fitss(i) <= Local_Fitss(i);
											end loop;
											if (and_reduce(Update_Done) = '1') then
												S_Next <= Show_Conditions;
											else
												S_Next <= Update_Tour_M; -- Redundant, only for clarification purposes
											end if;
			
			when Show_Conditions =>
											if (F_Curr(Bee_Best-1) = '1' or I_Curr = Iterations-1) then
												F_Next <= (others => '0');
												Bee_CE(Bee_Best-1) <= '1'; -- Bee_Best puts the data on outputs in 3 clock pulses
												C_Next <= (others => '0');
												S_Next <= Delay;
											else
												S_Next <= Next_Iteration;
											end if;
			
			when Delay           =>
											-- Forcing 1 clock pulse delay
											Bee_Select(Bee_Best-1) <= "011"; ----------> Single_Read
											S_Next <= Show_Results;
			
			when Show_Results    =>
											TOUR        <= Data1_Out(Bee_Best-1);
--											TOUR_LENGTH <= X"0000_00" & Data2_Out(Bee_Best-1);
											TOUR_LENGTH <= Fitss_Out(Bee_Best-1);
											DONE        <= Bee_Done(Bee_Best-1);
											if (C_Curr <= Cities) then
												C_Next <= C_Curr + 1;
												S_Next <= Show_Results; -- Redundant, only for clarification purposes
											else
												S_Next <= Next_Iteration;
											end if;
			
			when Next_Iteration  =>
											if (I_Curr < Iterations-1) then
												if (L_Curr < Local_Iter-1) then
													L_Next <= L_Curr + 1;
													S_Next <= Enable_Sort_M;
												else
													I_Next <= I_Curr + 1;	
													L_Next <= (others => '0');
													if (I_Curr < Cities - conv_std_logic_vector (Bees_All , INDX_WIDTH)) then
														Done <= '1'; -- Demonstrate the end of one iteration after loading a new tour from the NNT module
														S_Next <= Done_NNT_M;
													else
														S_Next <= Enable_Sort_M;
													end if;
												end if;
											else
												S_Next <= Final;
											end if;
			
			when Final           =>
											DONE <= '1';
											if (CE = '0') then
												S_Next <= Idle_Mode;
											else
												S_Next <= Final; -- Redundant, only for clarification purposes
											end if;
		end case;
	end process;
	
	---------- Instantiations ----------

	--------------------> Nearest Neighbor Module
	Nearest_Neighbor_Tour: Gen_Nearest_Neighbor_Tour
		generic map (
						INDX_WIDTH  => INDX_WIDTH,
						ADDR_WIDTH  => ADDR_WIDTH,
						TOUR_WIDTH  => TOUR_WIDTH)	
		port map    (
						CLK         => CLK,
						RESET       => RESET,
						CE          => NNT_CE,
						NEXT_TOUR   => Next_Tour,
						SEND_TOUR   => Send_Tour,
						CITIES      => Cities,
						TOUR        => NNT_Tour,
						INDX        => NNT_Indx,
						TOUR_LENGTH => NNT_Tour_Length,
						DONE        => NNT_Done);
	
	--------------------> Bee Modules
	Generate_Bees: for i in 0 to Bees_All-1 generate
		Bee: Gen_Bee_Sync
			generic map (
							INDX_WIDTH => INDX_WIDTH,
							ADDR_WIDTH => ADDR_WIDTH,
							TOUR_WIDTH => TOUR_WIDTH)
			port map    (
							CLK        => CLK,
							RESET      => RESET,
							CE         => Bee_CE(i),
							SEL        => Bee_Select(i),
							CITIES     => Cities,
							DATA1_IN   => Data1_In(i),
							DATA2_IN   => Data2_In(i),
							FITSS_IN   => Fitss_In(i),
							DATA1_OUT  => Data1_Out(i),
							DATA2_OUT  => Data2_Out(i),
							FITSS_OUT  => Fitss_Out(i),
							DONE       => Bee_Done(i));
	end generate;
	
	--------------------> Multiplex Modules for Bees Data1_In
	Generate_Mux_Bee_Data1_In: for i in 0 to Bees_All-1 generate
		Generate_Mux2_1_First: if (i = 0) generate
			Mux2_1: Gen_Mux2_1
				generic map (
								DATA_WIDTH => INDX_WIDTH)
				port map    (
								S          => Permit(i),
								D0         => Mux_D0_Data1(i),
								D1         => Data1_Out(i+1),
								O          => Data1_In(i));
		end generate;
		Generate_Mux4_1: if (i > 0 and i < Bees_All-1) generate
			Mux4_1: Gen_Mux4_1
				generic map (
								DATA_WIDTH => INDX_WIDTH)
				port map    (
								S          => Permit(i downto i-1),
								D0         => Mux_D0_Data1(i),
								D1         => Data1_Out(i-1),
								D2         => Data1_Out(i+1),
								D3         => Zero_Indx,
								O          => Data1_In(i));
		end generate;
		Generate_Mux2_1_Last: if (i = Bees_All-1) generate
			Mux2_1: Gen_Mux2_1
				generic map (
								DATA_WIDTH => INDX_WIDTH)
				port map    (
								S          => Permit(i-1),
								D0         => Mux_D0_Data1(i),
								D1         => Data1_Out(i-1),
								O          => Data1_In(i));
		end generate;
	end generate;
	
	--------------------> Multiplex Modules for Bees Data2_In
	Generate_Mux_Bee_Data2_In: for i in 0 to Bees_All-1 generate
		Generate_Mux2_1_First: if (i = 0) generate
			Mux2_1: Gen_Mux2_1
				generic map (
								DATA_WIDTH => INDX_WIDTH)
				port map    (
								S          => Permit(i),
								D0         => Mux_D0_Data2(i),
								D1         => Data2_Out(i+1),
								O          => Data2_In(i));
		end generate;
		Generate_Mux4_1: if (i > 0 and i < Bees_All-1) generate
			Mux4_1: Gen_Mux4_1
				generic map (
								DATA_WIDTH => INDX_WIDTH)
				port map    (
								S          => Permit(i downto i-1),
								D0         => Mux_D0_Data2(i),
								D1         => Data2_Out(i-1),
								D2         => Data2_Out(i+1),
								D3         => Zero_Indx,
								O          => Data2_In(i));
		end generate;
		Generate_Mux2_1_Last: if (i = Bees_All-1) generate
			Mux2_1: Gen_Mux2_1
				generic map (
								DATA_WIDTH => INDX_WIDTH)
				port map    (
								S          => Permit(i-1),
								D0         => Mux_D0_Data2(i),
								D1         => Data2_Out(i-1),
								O          => Data2_In(i));
		end generate;
	end generate;
	
	--------------------> Multiplex Modules for Bees Fitss_In	
	Generate_Mux_Bee_Fitss_In: for i in 0 to Bees_All-1 generate
		Generate_Mux2_1_First: if (i = 0) generate
			Mux2_1: Gen_Mux2_1
				generic map (
								DATA_WIDTH => TOUR_WIDTH)
				port map    (
								S          => Permit(i),
								D0         => Mux_D0_Fitss(i),
								D1         => Fitss_Out(i+1),
								O          => Fitss_In(i));
		end generate;
		Generate_Mux4_1: if (i > 0 and i < Bees_All-1) generate
			Mux4_1: Gen_Mux4_1
				generic map (
								DATA_WIDTH => TOUR_WIDTH)
				port map    (
								S          => Permit(i downto i-1),
								D0         => Mux_D0_Fitss(i),
								D1         => Fitss_Out(i-1),
								D2         => Fitss_Out(i+1),
								D3         => Zero_Tour,
								O          => Fitss_In(i));
		end generate;
		Generate_Mux2_1_Last: if (i = Bees_All-1) generate
			Mux2_1: Gen_Mux2_1
				generic map (
								DATA_WIDTH => TOUR_WIDTH)
				port map    (
								S          => Permit(i-1),
								D0         => Mux_D0_Fitss(i),
								D1         => Fitss_Out(i-1),
								O          => Fitss_In(i));
		end generate;
	end generate;
	
	--------------------> Sort process Permit Modules
	Generate_Sort_Permit: for i in 0 to Bees_All-2 generate
		Generate_Sort_P1: if (i < Bees_All-2) generate
			Sort_Permit: Gen_Sort_Permit 
				generic map (
								DATA_WIDTH  => TOUR_WIDTH)
				port map    (
								DATA1_IN    => Fitss_Out(i),
								DATA2_IN    => Fitss_Out(i+1),
								CE          => Sort_CE,
								NEXT_PERMIT => Next_Permit,
								COMPARE_IN  => Compare(i+1),
								COMPARE_OUT => Compare(i),
								PERMIT      => Permit(i));
		end generate;
		Generate_Sort_P2: if (i = Bees_All-2) generate
			Sort_Permit: Gen_Sort_Permit
				generic map (
								DATA_WIDTH  => TOUR_WIDTH)	
				port map    (
								DATA1_IN    => Fitss_Out(i),
								DATA2_IN    => Fitss_Out(i+1),
								CE          => Sort_CE,
								NEXT_PERMIT => Next_Permit,
								COMPARE_IN  => '0',
								COMPARE_OUT => Compare(i),
								PERMIT      => Permit(i));
		end generate;
	end generate;
	
	--------------------> Local Search (2_Opt) Module (For Elite and Selected Bees)
	Generate_Local_Search: for i in 0 to Bees_Selected-1 generate
		Generate_Local_1: if (i < Bees_Elite) generate
			Local_Search: Gen_Local_Search
				generic map (
								INDX_WIDTH => INDX_WIDTH,
								ADDR_WIDTH => ADDR_WIDTH,
								TOUR_WIDTH => TOUR_WIDTH)
				port map    (
								CLK        => CLK,
								RESET      => RESET,
								CE         => Local_CE,
								DONE_BEE   => Bee_Done(i),
								CITIES     => Cities,
								ITERS_IN   => Recruited_Bees_Elite,
								DATA1_IN   => Data1_Out(i),
								DATA2_IN   => Data2_Out(i),
								FITSS_IN   => Fitss_Out(i),
								DATA1_OUT  => Local_Data1(i),
								DATA2_OUT  => Local_Data2(i),
								FITSS_OUT  => Local_Fitss(i),
								NEXT_DATA  => Local_Next(i),
								DONE       => Local_Done(i));
		end generate;
		Generate_Local_2: if (i >= Bees_Elite) generate
			Local_Search: Gen_Local_Search
				generic map (
								INDX_WIDTH => INDX_WIDTH,
								ADDR_WIDTH => ADDR_WIDTH,
								TOUR_WIDTH => TOUR_WIDTH)
				port map    (
								CLK        => CLK,
								RESET      => RESET,
								CE         => Local_CE,
								DONE_BEE   => Bee_Done(i),
								CITIES     => Cities,
								ITERS_IN   => Recruited_Bees_Selected,
								DATA1_IN   => Data1_Out(i),
								DATA2_IN   => Data2_Out(i),
								FITSS_IN   => Fitss_Out(i),
								DATA1_OUT  => Local_Data1(i),
								DATA2_OUT  => Local_Data2(i),
								FITSS_OUT  => Local_Fitss(i),
								NEXT_DATA  => Local_Next(i),
								DONE       => Local_Done(i));
		end generate;
	end generate;
	
	--------------------> Update Tour Module
	Generate_Update_Tour: for i in 0 to Bees_Selected-1 generate
		Update_Tour: Gen_Update_Tour_V1
			generic map (
							DATA_WIDTH => INDX_WIDTH)
			port map    (
							CLK        => CLK,
							RESET      => RESET,
							CE         => Update_CE,
							DONE_BEE   => Bee_Done(i),
							DATA1_IN   => Local_Data1(i),
							DATA2_IN   => Local_Data2(i),
							DATA1_OUT  => Update_Data1(i),
							DATA2_OUT  => Update_Data2(i),
							CE_BEE     => Update_Next(i),
							DONE       => Update_Done(i));
	end generate;
	
end Behavioral;

-- In HDL, for figuring out how many bits are required to represent a signal, For example, for storing N elements in
-- RAM, the number of bits required for addressing that RAM is ceil(log2(N)).  