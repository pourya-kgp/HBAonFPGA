----------------------------------------------------------------------------------------------------
-- Author           : Pourya Khodagholipour (P.KH)
-- Project Name     : HBA (Hardware Bee Algorithm)
-- File Name        : RTL_Extra
-- Module Name      : RTL_Extra
-- HDL Standard     : VHDL
-- Approach         : Structural
-- Description      : A core to collect the unused cores for better access and more order in the hierarchy. 
-- Comments         : ---
-- Dependencies     : ---
-- Target Devices   : ---
-- Speed Estimation : ---
-- Area  Estimation : ---
-- Tools            : ---
-- Module Version   : ---
-- Creation Date    : 2024/07/09
-- Revision Date    : 2024/07/09
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity RTL_Extra is
end RTL_Extra;

architecture Idle of RTL_Extra is

	---------- Components ----------

	component Bit_Comp_Eq is
		port (
				A  : in  std_logic;
				B  : in  std_logic;
				EQ : out std_logic);
	end component;

	component Bit_Flipflop_D_Sync is
		port (
				CLK   : in  std_logic;
				RESET : in  std_logic;
				D_IN  : in  std_logic;
				D_OUT : out std_logic := '0');
	end component;

	component Gen_Demux1_4 is
		generic (
					DATA_WIDTH : integer := 8);
		port    (
					S          : in  std_logic_vector (1 downto 0);
					D          : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					D0         : out std_logic_vector (DATA_WIDTH-1 downto 0);
					D1         : out std_logic_vector (DATA_WIDTH-1 downto 0);
					D2         : out std_logic_vector (DATA_WIDTH-1 downto 0);
					D3         : out std_logic_vector (DATA_WIDTH-1 downto 0));
	end component;

	component Xilinx_Dual_Port_ROM_Sync is
		generic (
					ADDR_WIDTH : natural := 8;
					DATA_WIDTH : natural := 8);
		port    (
					CLK        : in  std_logic;
					ADDR_A     : in  std_logic_vector (ADDR_WIDTH-1 downto 0);
					ADDR_B     : in  std_logic_vector (ADDR_WIDTH-1 downto 0);
					DOUT_A     : out std_logic_vector (DATA_WIDTH-1 downto 0);
					DOUT_B     : out std_logic_vector (DATA_WIDTH-1 downto 0));
	end component;

	component Xilinx_One_Port_ROM_Sync is
		generic (
					ADDR_WIDTH : natural := 8;
					DATA_WIDTH : natural := 8);
		port    (
					CLK        : in  std_logic;
					ADDR       : in  std_logic_vector (ADDR_WIDTH-1 downto 0);
					DATA       : out std_logic_vector (DATA_WIDTH-1 downto 0));
	end component;
	
	component Xilinx_One_Port_RAM_Async is
		generic (
					ADDR_WIDTH : integer := 8;
					DATA_WIDTH : integer := 8);
		port    (
					CLK        : in  std_logic;
					WE         : in  std_logic;
					ADDR       : in  std_logic_vector (ADDR_WIDTH-1 downto 0);
					DIN        : in  std_logic_vector (DATA_WIDTH-1 downto 0);
					DOUT       : out std_logic_vector (DATA_WIDTH-1 downto 0));
	end component;
	
	---------- Signals ----------
	
	-- Generic Constants
	constant indx_width : integer := 8;
	constant addr_width : integer := 16;
	constant tour_width : integer := 32;

begin

	---------- Instantiations ----------

	Bit_C_Eq: Bit_Comp_Eq
		port map (
					A  => open,
					B  => open,
					EQ => open);
	
	Bit_FF_D_Sync: Bit_Flipflop_D_Sync
		port map (
					CLK   => open,
					RESET => open,
					D_IN  => open,
					D_OUT => open);

	Gen_DM1_4: Gen_Demux1_4
		generic map (
						DATA_WIDTH => indx_width)
		port map    (
						S          => open,
						D          => open,
						D0         => open,
						D1         => open,
						D2         => open,
						D3         => open);
	Dual_Port_ROM_Sync: Xilinx_Dual_Port_ROM_Sync
		generic map (
						ADDR_WIDTH => addr_width,
						DATA_WIDTH => indx_width)
		port map   (
						CLK        => open,
						ADDR_A     => open,
						ADDR_B     => open,
						DOUT_A     => open,
						DOUT_B     => open);

	One_Port_ROM_Sync: Xilinx_One_Port_ROM_Sync
		generic map (
						ADDR_WIDTH => addr_width,
						DATA_WIDTH => indx_width)
		port map   (
						CLK        => open,
						ADDR       => open,
						DATA       => open);
	
	One_Port_RAM_Async: Xilinx_One_Port_RAM_Async
		generic map (
						ADDR_WIDTH => addr_width,
						DATA_WIDTH => indx_width)
		port map   (
						CLK        => open,
						WE         => open,
						ADDR       => open,
						DIN        => open,
						DOUT       => open);

end Idle;