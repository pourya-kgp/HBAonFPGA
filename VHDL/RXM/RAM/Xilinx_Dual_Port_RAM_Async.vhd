----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : 
-- File Name        : Xilinx_Dual_Port_RAM_Async
-- Module Name      : Xilinx_Dual_Port_RAM_Async
-- HDL Standard     : VHDL
-- Approach         : Behavioral
-- Description      : Dual-port RAM with asynchronous read (Distributed RAM)
-- Comments         : 
-- Dependencies     : ---
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : ---
-- Area  Estimation : 82 LUTs (Due to asynchronous read)
-- Tools            : ISE Design Suite v14.7
-- Module Version   : 
-- Creation Date    : 2016/08
-- Revision Date    : 2016/09
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Xilinx_Dual_Port_RAM_Async is
	generic (
				ADDR_WIDTH : integer := 8;
				DATA_WIDTH : integer := 8);
	port    (
				CLK        : in  std_logic;
				WE         : in  std_logic;
				ADDR_A     : in  std_logic_vector (ADDR_WIDTH-1 downto 0);
				ADDR_B     : in  std_logic_vector (ADDR_WIDTH-1 downto 0);
				DATA_W     : in  std_logic_vector (DATA_WIDTH-1 downto 0);
				DOUT_A     : out std_logic_vector (DATA_WIDTH-1 downto 0);
				DOUT_B     : out std_logic_vector (DATA_WIDTH-1 downto 0));
end Xilinx_Dual_Port_RAM_Async;

architecture Behavioral of Xilinx_Dual_Port_RAM_Async is

	type RAM_Type is array (2**ADDR_WIDTH-1 downto 0) of std_logic_vector (DATA_WIDTH-1 downto 0);
	signal RAM : RAM_Type := (others => (others => '1'));

begin

	process (CLK)
	begin
		if (rising_edge(CLK)) then
			if (WE = '1') then
				RAM (to_integer(unsigned(ADDR_A))) <= DATA_W;
			end if;
		end if;
	end process;
	
	DOUT_A <= RAM (to_integer(unsigned(ADDR_A)));
	DOUT_B <= RAM (to_integer(unsigned(ADDR_B)));
	
end Behavioral;