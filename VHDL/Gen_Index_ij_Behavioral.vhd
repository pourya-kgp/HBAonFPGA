----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : HBA (Hardware Bee Algorithm)
-- File Name        : Gen_Index_ij_Behavioral
-- Module Name      : Gen_Index_ij_Behavioral
-- HDL Standard     : VHDL
-- Approach         : Behavioral
-- Description      : Generic core for sequentially selecting two RAM addresses (Complete cases)
-- Comments         : 
-- Dependencies     : ---
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : 276 MHz
-- Area  Estimation : 87 LUTs + 19 FFs
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/09
-- Revision Date    : 2024/05/04
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity Gen_Index_ij_Behavioral is
	generic (
				DATA_WIDTH       : integer := 8);
	port    (
				CLK              : in  std_logic;
				RESET            : in  std_logic;
				CE               : in  std_logic;
				NEXT_J           : in  std_logic;
				CITIES           : in  std_logic_vector (DATA_WIDTH-1 downto 0);
				LAST_J           : out std_logic;
				NEXT_I           : out std_logic;
				LAST_I           : out std_logic;
				ENABLE_OUT       : out std_logic;
				CURRENT_CITY_IND : out std_logic_vector (DATA_WIDTH-1 downto 0);
				NEXT_CITY_IND    : out std_logic_vector (DATA_WIDTH-1 downto 0));
end Gen_Index_ij_Behavioral;

architecture Behavioral of Gen_Index_ij_Behavioral is
	
	-- Signals
	signal Current_Ind : std_logic_vector (DATA_WIDTH-1 downto 0) := (others => '0');
	signal Next_Ind    : std_logic_vector (DATA_WIDTH-1 downto 0) := (others => '0');
	
	-- Constants
	constant Zero      : std_logic_vector (DATA_WIDTH-1 downto 0) := (others => '0');
	
begin

	CURRENT_CITY_IND <= Current_Ind;
	NEXT_CITY_IND    <= Next_Ind;

--	process (CLK , RESET , CE , NEXT_J) -- The main sensitivity list that matters
	process (CLK , RESET , CE , NEXT_J , CITIES , Current_Ind , Next_Ind)
	begin
		if (RESET = '1') then
			Current_Ind <= (others => '0');
			Next_Ind    <= (others => '0');
			LAST_J      <= '0';
			NEXT_I      <= '0';
			LAST_I      <= '0';
			ENABLE_OUT  <= '0';
		elsif (rising_edge(CLK)) then
			NEXT_I     <= '0'; -- Pulse width = 1 CLK Puls Width
			ENABLE_OUT <= '0'; -- Pulse width = 1 CLK Puls Width
			if (CE = '1' and NEXT_J = '1') then

				-- Last_J (Pulse width = rising_edge(NEXT_J) to the next rising_edge(NEXT_J))
				if (Next_Ind = CITIES-2 or Current_Ind = CITIES-2 or Current_Ind = CITIES-3) then
					LAST_J <= '1';
				else
					LAST_J <= '0';
				end if;
				-- Last_I (Pulse width = rising_edge(NEXT_J) to the next rising_edge(NEXT_J))
				if (Current_Ind = CITIES-2) then
					LAST_I <= '1';
				else
					LAST_I <= '0';
				end if;
				-- NEXT_I     (Pulse width = 1 CLK Puls Width)
				if (Next_Ind = CITIES-1 or Current_Ind = CITIES-1) then
					NEXT_I <= '1';
				end if;
				-- ENABLE_OUT (Pulse width = 1 CLK Puls Width)
				ENABLE_OUT <= '1';
				-- Next_Ind , Current_Ind
				if (Next_Ind = Zero) then         -- Next_Ind = 0
					Next_Ind <= Zero + 1;
					Current_Ind <= Zero;
				elsif (Next_Ind < CITIES-1) then  -- 0 < Next_Ind < CITIES-1
					Next_Ind <= Next_Ind + 1;
				elsif (Next_Ind  = CITIES-1) then -- Next_Ind = CITIES-1
					if (current_Ind = CITIES-2) then
						Next_Ind <= Zero;
					else
						Next_Ind <= Current_Ind + 2;
					end if;
					Current_Ind <= Current_Ind + 1;
				end if;
			
			end if;
		end if;
	end process;	
					 
end Behavioral;