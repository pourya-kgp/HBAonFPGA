----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : HBA (Hardware Bee Algorithm)
-- File Name        : Gen_Local_Search
-- Module Name      : Gen_Local_Search
-- HDL Standard     : VHDL
-- Approach         : Behavioral (Moore FSM)
-- Description      : Generic core for the 2-Opt local search
-- Comments         : 
-- Dependencies     : 3 Cores
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : 195 MHz
-- Area  Estimation : 687 LUTs + 369 FFs + 2 RAM/FIFO + 2 DSPs
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/09
-- Revision Date    : 2024/05/28
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity Gen_Local_Search is
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
end Gen_Local_Search;

architecture Moore_FSM of Gen_Local_Search is
	
	---------- Components ----------
	
	component Gen_RNG_City_Set is 
		generic (
					DATA_WIDTH  : integer := 8);
		port    (
					CLK         : in  std_logic;
					RESET       : in  std_logic;
					CE          : in  std_logic;
					CITIES      : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					CITY_IND_R1 : out std_logic_vector (DATA_WIDTH-1 downto 0);
					CITY_IND_R2 : out std_logic_vector (DATA_WIDTH-1 downto 0);
					DONE        : out std_logic);
	end component;
	
	component Gen_Addr_Calc is
		generic (
					DATA_WIDTH   : integer := 8;
					ADDR_WIDTH   : integer := 11);
		port    (
					CLK          : in  std_logic;
					RESET        : in  std_logic;
					CE           : in  std_logic;
					CITIES       : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					CURRENT_CITY : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					NEXT_CITY    : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					RAM_ADDR     : out std_logic_vector (ADDR_WIDTH-1 downto 0);
					DONE         : out std_logic);
	end component;
	
	component TSP_Dist_One_Port_ROM_Sync is
		generic (
					ADDR_WIDTH : integer := 11;
					DATA_WIDTH : integer := 32);
		port    (
					CLK        : in  std_logic;
					ADDR       : in  std_logic_vector (ADDR_WIDTH-1 downto 0);
					DATA       : out std_logic_vector (DATA_WIDTH-1 downto 0));
	end component;
	
	---------- Signals ----------
	
	-- Random City Set Module (R1 , R2)
	signal CE_RNG , Done_RNG : std_logic := '0';
	signal Ind_R1 , Ind_R2   : std_logic_vector (INDX_WIDTH-1 downto 0) := (others => '0');
	
	-- Address Calculator Module
	signal Done_Addr                             : std_logic := '0';
	signal CE_Addr_Curr      , CE_Addr_Next      : std_logic := '0';
	signal Current_City_Curr , Current_City_Next : std_logic_vector (INDX_WIDTH-1 downto 0) := (others => '0');
	signal Next_City_Curr    , Next_City_Next    : std_logic_vector (INDX_WIDTH-1 downto 0) := (others => '0');
	signal Ram_Addr                              : std_logic_vector (ADDR_WIDTH-1 downto 0) := (others => '0');
	
	-- TSP ROM, Distance Matrix Module
	signal Dist_Between : std_logic_vector (TOUR_WIDTH-1 downto 0) := (others => '0');
	
	-- State Machine & Control Signals
	type State is (Idle_Mode , Start_RNG_Set , Done_RNG_Set , Next_RNG_Set , Request_Cities , Specify_Cities ,
						Save_Cities , Inputs_Addr , Request_Addr , Done_RAM_Addr , Done_RAM , Calc_Dist , Compare ,
						Iter_Check , Output_Results , Final);
	signal S_Curr , S_Next : State;
	
	-- Counters
	signal C_Curr , C_Next : integer range 0 to 3 := 0;                                   -- Counter
	signal I_Curr , I_Next : std_logic_vector (INDX_WIDTH-1 downto 0) := (others => '0'); -- Iterations Counter
	
	-- Misc
	signal City_R1_Curr     , City_R1_Next     : std_logic_vector (INDX_WIDTH-1 downto 0) := (others => '0');
	signal After_R1_Curr    , After_R1_Next    : std_logic_vector (INDX_WIDTH-1 downto 0) := (others => '0');
	signal Befor_R2_Curr    , Befor_R2_Next    : std_logic_vector (INDX_WIDTH-1 downto 0) := (others => '0');
	signal City_R2_Curr     , City_R2_Next     : std_logic_vector (INDX_WIDTH-1 downto 0) := (others => '0');
	signal First_Ind_Curr   , First_Ind_Next   : std_logic_vector (INDX_WIDTH-1 downto 0) := (others => '0');
	signal Last_Ind_Curr    , Last_Ind_Next    : std_logic_vector (INDX_WIDTH-1 downto 0) := (others => '0');
	signal Main_Dist_Curr   , Main_Dist_Next   : std_logic_vector (TOUR_WIDTH-1 downto 0) := (others => '0');
	signal Dist_Curr        , Dist_Next        : std_logic_vector (TOUR_WIDTH-1 downto 0) := (others => '0'); -- Distance Accumulator
	
	-- Iterations & Results
	signal Itr_Ind1_Curr    , Itr_Ind1_Next    : std_logic_vector (INDX_WIDTH-1 downto 0) := (others => '0'); -- Initial value must be Zero
	signal Itr_Ind2_Curr    , Itr_Ind2_Next    : std_logic_vector (INDX_WIDTH-1 downto 0) := (others => '0'); -- Initial value must be Zero
	signal Final_First_Curr , Final_First_Next : std_logic_vector (INDX_WIDTH-1 downto 0) := (others => '0'); -- Initial value must be Zero
	signal Final_Last_Curr  , Final_Last_Next  : std_logic_vector (INDX_WIDTH-1 downto 0) := (others => '0'); -- Initial value must be Zero
	signal Data1_Out_Curr   , Data1_Out_Next   : std_logic_vector (INDX_WIDTH-1 downto 0) := (others => '0'); -- Initial value must be Zero
	signal Data2_Out_Curr   , Data2_Out_Next   : std_logic_vector (INDX_WIDTH-1 downto 0) := (others => '0'); -- Initial value must be Zero
	signal Itr_Fits_Curr    , Itr_Fits_Next    : std_logic_vector (TOUR_WIDTH-1 downto 0) := (others => '1'); -- Initial value must be maximum	
	signal Fitness_Curr     , Fitness_Next     : std_logic_vector (TOUR_WIDTH-1 downto 0) := (others => '1'); -- Initial value must be maximum
	
begin
	
	DATA1_OUT <= Data1_Out_Curr;
	DATA2_OUT <= Data2_Out_Curr;
	FITSS_OUT <= Fitness_Curr;
	
	process (CLK , RESET)
	begin
		if (RESET = '1') then
			S_Curr <= Idle_Mode; -- State Signal
			
			-- Preventing latches and replacing them with registers
			-- Address Calculator Module
			CE_Addr_Curr      <= '0';
			Current_City_Curr <= (others => '0');
			Next_City_Curr    <= (others => '0');
			-- Misc
			C_Curr            <= 0;
			I_Curr            <= (others => '0');
			City_R1_Curr      <= (others => '0');
			After_R1_Curr     <= (others => '0');
			Befor_R2_Curr     <= (others => '0');
			City_R2_Curr      <= (others => '0');
			First_Ind_Curr    <= (others => '0');
			Last_Ind_Curr     <= (others => '0');
			Dist_Curr         <= (others => '0');
			Main_Dist_Curr    <= (others => '0');
			-- Iterations & Results
			Itr_Ind1_Curr     <= (others => '0');
			Itr_Ind2_Curr     <= (others => '0');
			Final_First_Curr  <= (others => '0');
			Final_Last_Curr   <= (others => '0');
			Data1_Out_Curr    <= (others => '0');
			Data2_Out_Curr    <= (others => '0');
			Itr_Fits_Curr     <= (others => '1');
			Fitness_Curr      <= (others => '1');
		elsif (rising_edge(CLK)) then
			S_Curr <= S_Next; -- State Signal
			
			-- Preventing latches and replacing them with registers
			-- Address Calculator Module
			CE_Addr_Curr      <= CE_Addr_Next;
			Current_City_Curr <= Current_City_Next;
			Next_City_Curr    <= Next_City_Next;
			-- Misc
			C_Curr            <= C_Next; -- Counter
			I_Curr            <= I_Next; -- Iterations Counter
			City_R1_Curr      <= City_R1_Next;
			After_R1_Curr     <= After_R1_Next;
			Befor_R2_Curr     <= Befor_R2_Next;
			City_R2_Curr      <= City_R2_Next;
			First_Ind_Curr    <= First_Ind_Next;
			Last_Ind_Curr     <= Last_Ind_Next;
			Dist_Curr         <= Dist_Next;
			Main_Dist_Curr    <= Main_Dist_Next;
			-- Iterations & Results
			Itr_Ind1_Curr     <= Itr_Ind1_Next;
			Itr_Ind2_Curr     <= Itr_Ind2_Next;
			Final_First_Curr  <= Final_First_Next;
			Final_Last_Curr   <= Final_Last_Next;
			Data1_Out_Curr    <= Data1_Out_Next;
			Data2_Out_Curr    <= Data2_Out_Next;
			Itr_Fits_Curr     <= Itr_Fits_Next;
			Fitness_Curr      <= Fitness_Next;
		end if;
	end process;
	
-- process (S_Curr , CE , DONE_BEE , Done_RNG , Done_Addr) -- The main sensitivity list that matters
	process (S_Curr , C_Curr , I_Curr , CE_Addr_Curr , Current_City_Curr , Next_City_Curr ,
				City_R1_Curr , After_R1_Curr , Befor_R2_Curr , City_R2_Curr , First_Ind_Curr , Last_Ind_Curr ,
				Itr_Ind1_Curr , Itr_Ind2_Curr , Final_First_Curr , Final_Last_Curr , Data1_Out_Curr , Data2_Out_Curr ,
				Dist_Curr , Main_Dist_Curr , Itr_Fits_Curr , Fitness_Curr ,
				Ind_R1 , Ind_R2 , Done_RNG , Done_Addr , Dist_Between ,
				CE , ITERS_IN , DATA1_IN , DATA2_IN , FITSS_IN , DONE_BEE)
	begin
		
		S_Next <= S_Curr;

		-- Default assignments to prevent latches
		CE_RNG    <= '0';
		NEXT_DATA <= '0';
		DONE      <= '0';
		
		-- Preventing latches and replacing them with registers
		-- Address Calculator Module
		CE_Addr_Next      <= CE_Addr_Curr;
		Current_City_Next <= Current_City_Curr;
		Next_City_Next    <= Next_City_Curr;
		-- Misc
		C_Next            <= C_Curr;
		I_Next            <= I_Curr;
		City_R1_Next      <= City_R1_Curr;
		After_R1_Next     <= After_R1_Curr;
		Befor_R2_Next     <= Befor_R2_Curr;
		City_R2_Next      <= City_R2_Curr;
		First_Ind_Next    <= First_Ind_Curr;
		Last_Ind_Next     <= Last_Ind_Curr;
		Dist_Next         <= Dist_Curr;
		Main_Dist_Next    <= Main_Dist_Curr;
		-- Iterations & Results
		Itr_Ind1_Next     <= Itr_Ind1_Curr;
		Itr_Ind2_Next     <= Itr_Ind2_Curr;
		Final_First_Next  <= Final_First_Curr;
		Final_Last_Next   <= Final_Last_Curr;
		Data1_Out_Next    <= Data1_Out_Curr;
		Data2_Out_Next    <= Data2_Out_Curr;
		Itr_Fits_Next     <= Itr_Fits_Curr;
		Fitness_Next      <= Fitness_Curr;
		
		case S_Curr is
			when Idle_Mode      =>
											if (CE = '1') then
												Fitness_Next <= (others => '1');
												S_Next <= Start_RNG_Set;
											else
												S_Next <= Idle_Mode; -- Redundant, only for clarification purposes
											end if;
											C_Next           <= 0;
											I_Next           <= (others => '0');
											City_R1_Next     <= (others => '0');
											After_R1_Next    <= (others => '0');
											Befor_R2_Next    <= (others => '0');
											City_R2_Next     <= (others => '0');
											First_Ind_Next   <= (others => '0');
											Last_Ind_Next    <= (others => '0');
											Dist_Next        <= (others => '0');
											Main_Dist_Next   <= (others => '0');
											Itr_Ind1_Next    <= (others => '0');
											Itr_Ind2_Next    <= (others => '0');
											Final_First_Next <= (others => '0');
											Final_Last_Next  <= (others => '0');
											Itr_Fits_Next    <= (others => '1');
			
			when Start_RNG_Set  =>
											CE_RNG <= '1'; -- Start RNG Generator
											S_Next <= Done_RNG_Set;
			
			when Done_RNG_Set   =>
											if (Done_RNG = '1') then
												First_Ind_Next <= Ind_R1;
												Last_Ind_Next  <= Ind_R2;
												S_Next <= Next_RNG_Set;
											else
												S_Next <= Done_RNG_Set; -- Redundant, only for clarification purposes
											end if;
			
			when Next_RNG_Set   =>
											-- Generate the next random cities, if needed
											if (ITERS_IN > 1 and I_Curr < ITERS_IN-1) then
												CE_RNG <= '1'; -- Start the RNG Generator to construct the next random values
											end if;
											S_Next <= Specify_Cities;
			
			when Specify_Cities =>
											if    (C_Curr = 0) then
												Data1_Out_Next <= First_Ind_Curr;
												Data2_Out_Next <= First_ind_Curr + 1;
												S_Next <= Request_Cities;
											elsif (C_Curr = 1) then
												Data1_Out_Next <= Last_Ind_Curr - 1;
												Data2_Out_Next <= Last_Ind_Curr;
												S_Next <= Request_Cities;
											else
												C_Next <= 0;
												S_Next <= Specify_Cities; -- Redundant, only for clarification purposes
											end if;
			
			when Request_Cities =>
											NEXT_DATA <= '1';
											S_Next <= Save_Cities;
			
			when Save_Cities    =>
											if (DONE_BEE = '1') then
												if    (C_Curr = 0) then
													City_R1_Next  <= DATA1_IN;
													After_R1_Next <= DATA2_IN;
													C_Next <= C_Curr + 1;
													S_Next <= Specify_Cities;
												elsif (C_Curr = 1) then
													Befor_R2_Next <= DATA1_IN;
													City_R2_Next  <= DATA2_IN;
													C_Next <= 0;
													Dist_Next <= (others => '0');
													S_Next <= Inputs_Addr;
												else
													C_Next <= 0;
													S_Next <= Specify_Cities;
												end if;
											else
												S_Next <= Save_Cities; -- Redundant, only for clarification purposes
											end if;
			
			when Inputs_Addr    =>
											if    (C_Curr = 0) then
												Current_City_Next <= City_R1_Curr;
												Next_City_Next    <= After_R1_Curr;
												S_Next <= Request_Addr;
											elsif (C_Curr = 1) then
												Current_City_Next <= Befor_R2_Curr;
												Next_City_Next    <= City_R2_Curr;
												S_Next <= Request_Addr;
											elsif (C_Curr = 2) then
												Current_City_Next <= City_R1_Curr;
												Next_City_Next    <= Befor_R2_Curr;
												S_Next <= Request_Addr;
											elsif (C_Curr = 3) then
												Current_City_Next <= After_R1_Curr;
												Next_City_Next    <= City_R2_Curr;
												S_Next <= Request_Addr;
											else
												C_Next <= 0;
												S_Next <= Inputs_Addr; -- Redundant, only for clarification purposes
											end if;
											CE_Addr_Next <= '0';
											   -- This command is needed due to the constraints of the Nearest_Neighbor Module.
											   -- In this module, the output of the Gen_Addr_Formula Module in CE = 0 mode must be Zero.
											   -- Otherwise, the results of the Nearest_Neighbor_Tour Module (Tour Length) differ.
											   -- However, the current Core needs the results of the RAM to remain on the output port
											   -- until the next RAM address calculation. So, CE input must be set to zero in the
											   -- current state and set to one in the next state.
			
			when Request_Addr   =>
											CE_Addr_Next <= '1'; -- Enable the RAM Address Calculator Module after setting its inputs 
											S_Next <= Done_RAM_Addr;
			
			when Done_RAM_Addr  =>
											if (Done_Addr = '1') then
												if (C_Curr = 2) then
													Main_Dist_Next <= Dist_Curr; -- The sum of the selected distances from the original tour
													Dist_Next <= (others => '0');
												end if;
												S_Next <= Done_RAM; -- Corresponding Distance comes 1 clock pulse after the calculated RAM address
											else
												S_Next <= Done_RAM_Addr; -- Redundant, only for clarification purposes
											end if;
			
			when Done_RAM       =>
											S_Next <= Calc_Dist; -- Providing 1 clock pulse delay for the RAM to respond to input addresses
			
			when Calc_Dist      =>
											Dist_Next <= Dist_Curr + Dist_Between;
											if (C_Curr < 3) then
												C_Next <= C_Curr + 1;
												S_Next <= Inputs_Addr;
											else
												C_Next <= 0;
												S_Next <= Compare;
											end if;
			
			when Compare        =>
											if (Dist_Curr < Main_Dist_Curr) then
												Itr_Fits_Next <= FITSS_IN - Main_Dist_Curr + Dist_Curr;
												Itr_Ind1_Next <= First_Ind_Curr;
												Itr_Ind2_Next <= Last_Ind_Curr;
											end if;
											S_Next <= Iter_Check;
			
			when Iter_Check     =>	
											if (Itr_Fits_Curr < Fitness_Curr) then
												Fitness_Next     <= Itr_Fits_Curr;
												Final_First_Next <= Itr_Ind1_Curr;
												Final_Last_Next  <= Itr_Ind2_Curr;
											end if;
											if (I_Curr < ITERS_IN-1) then
												I_Next <= I_Curr + 1;
												S_Next <= Done_RNG_Set;
											else
												S_Next <= Output_Results;
											end if;
			
			when Output_Results =>
											Data1_Out_Next <= Final_First_Curr;
											Data2_Out_Next <= Final_Last_Curr;
											S_Next <= Final;
			
			when Final          =>
											DONE <= '1'; -- Stays high as long as CE = 1 or a reset occurrence
											Data1_Out_Next <= Final_First_Curr;
											Data2_Out_Next <= Final_Last_Curr;
											if (CE = '0') then
												S_Next <= Idle_Mode;
											else
												S_Next <= Final; -- Redundant, only for clarification purposes
											end if;
		end case;
	end process;

	---------- Instantiations ----------

	--------------------> Random City Set Module (R1, R2)
	RNG_City_Set: Gen_RNG_City_Set
		generic map (
						DATA_WIDTH  => INDX_WIDTH)
		port map    (
						CLK         => CLK,
						RESET       => RESET,
						CE          => CE_RNG,
						CITIES      => CITIES,
						CITY_IND_R1 => Ind_R1,
						CITY_IND_R2 => Ind_R2,
						DONE        => Done_RNG);
	
	--------------------> RAM Address Calculator Module
	Addr_Calc: Gen_Addr_Calc
		generic map (
						DATA_WIDTH   => INDX_WIDTH,
						ADDR_WIDTH   => ADDR_WIDTH)
		port map    (
						CLK          => CLK,
						RESET        => RESET,
						CE           => CE_Addr_Curr,
						CITIES       => CITIES,
						CURRENT_CITY => Current_City_Curr,
						NEXT_CITY    => Next_City_Curr,
						RAM_ADDR     => Ram_Addr,
						DONE         => Done_Addr);
	
	--------------------> TSP Data ROM Module
	TSP_Dist_DATA_ROM: TSP_Dist_One_Port_ROM_Sync
		generic map (
						ADDR_WIDTH => ADDR_WIDTH,
						DATA_WIDTH => TOUR_WIDTH)
		port map    (
						CLK        => CLK,
						ADDR       => Ram_Addr,
						DATA       => Dist_Between);

end Moore_FSM;