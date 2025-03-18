----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : 
-- File Name        : Xilinx_Dual_Port_RAM_Sync
-- Module Name      : Xilinx_Dual_Port_RAM_Sync
-- HDL Standard     : VHDL
-- Approach         : Behavioral
-- Description      : Dual-port RAM with synchronous read (Distributed RAM)
-- Comments         : 
-- Dependencies     : ---
-- Target Devices   : Virtex 5 - XC5VLX330
-- Speed Estimation : ---
-- Area  Estimation : 1 RAM/FIFO
-- Tools            : ISE Design Suite v14.7 - Altera Quartus 16.1 Lite
-- Module Version   : 
-- Creation Date    : 2016/08
-- Revision Date    : 2016/09
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Xilinx_Dual_Port_RAM_Sync is
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
end Xilinx_Dual_Port_RAM_Sync;

architecture Behavioral of Xilinx_Dual_Port_RAM_Sync is

	type RAM_Type is array (2**ADDR_WIDTH-1 downto 0) of std_logic_vector (DATA_WIDTH-1 downto 0);
	signal RAM : RAM_Type := (others => (others => '1'));

	signal Addr_Reg_A , Addr_Reg_B : std_logic_vector (ADDR_WIDTH-1 downto 0);

begin

	process (CLK)
	begin
		if (rising_edge(CLK)) then
			if (WE = '1') then
				RAM (to_integer(unsigned(ADDR_A))) <= DATA_W;
			end if;
			Addr_Reg_A <= ADDR_A;
			Addr_Reg_B <= ADDR_B;
		end if;
	end process;
	
	DOUT_A <= RAM (to_integer(unsigned(Addr_Reg_A)));
	DOUT_B <= RAM (to_integer(unsigned(Addr_Reg_B)));
	
end Behavioral;

-- Extremely important:
-- In order for Altera Quartus to infer the VHDL code as RAM with initialization, the setting in the path
-- "Assignments/Device…/Device and Pin Options…/Configuration/Configuration mode" must be changed to
-- "Single Uncompressed Image with memory initialization (512 Kbits UFM").
-- However, if the RAM does not need any initialization, the Altera Quartus will infer the RAM from VHDL code
-- with the setting "Single Unompressed Image (3584Kbits UFM)" as long as the RAM has not initialized or the
-- initialization value is zero for all the cells (others => (others => '0')).