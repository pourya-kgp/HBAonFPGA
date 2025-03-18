----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : 
-- File Name        : Gen_Comp
-- Module Name      : Gen_Comp
-- HDL Standard     : VHDL
-- Approach         : Behavioral
-- Description      : Generic comparison core of two data
-- Comments         : 
-- Dependencies     : ---
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : ---
-- Area  Estimation : 26 LUTs
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/08
-- Revision Date    : 2016/08
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity Gen_Comp is
	generic (
				DATA_WIDTH : integer := 8);
	port    (
				A          : in  std_logic_vector (DATA_WIDTH-1 downto 0);
				B          : in  std_logic_vector (DATA_WIDTH-1 downto 0);
				MIN        : out std_logic_vector (DATA_WIDTH-1 downto 0);
				MAX        : out std_logic_vector (DATA_WIDTH-1 downto 0);
				AgB        : out std_logic;
				AeB        : out std_logic;
				AlB        : out std_logic);
end Gen_Comp;

architecture Behavioral of Gen_Comp is
begin

	process (A , B)
	begin
		if (A>B) then
			AgB <= '1';
			AeB <= '0';
			AlB <= '0';
			MAX <= A;
			MIN <= B;
		elsif (A<B) then
			AgB <= '0';
			AeB <= '0';
			AlB <= '1';
			MAX <= B;
			MIN <= A;
		else
			AgB <= '0';
			AeB <= '1';
			AlB <= '0';
			MAX <= A;
			MIN <= A;
		end if;
	end process;

end Behavioral;