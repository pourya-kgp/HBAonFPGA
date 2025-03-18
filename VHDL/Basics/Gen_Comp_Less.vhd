----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : 
-- File Name        : Gen_Comp_Less
-- Module Name      : Gen_Comp_Less
-- HDL Standard     : VHDL
-- Approach         : Behavioral
-- Description      : Generic core for comparing two values and specifying the lesser one
-- Comments         : 
-- Dependencies     : ---
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : ---
-- Area  Estimation : 12 LUTs
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/08
-- Revision Date    : 2016/08
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity Gen_Comp_Less is
	generic (
				DATA_WIDTH : integer := 8);
	port    (
				A          : in  std_logic_vector (DATA_WIDTH-1 downto 0);
				B          : in  std_logic_vector (DATA_WIDTH-1 downto 0);
				MIN        : out std_logic_vector (DATA_WIDTH-1 downto 0);
				AgB        : out std_logic);
end Gen_Comp_Less;

architecture Behavioral of Gen_Comp_Less is
begin

	process (A , B)
	begin
		if (A>B) then
			AgB <= '1';
			MIN <= B;
		else
			AgB <= '0';
			MIN <= A;
		end if;
	end process;

end Behavioral;