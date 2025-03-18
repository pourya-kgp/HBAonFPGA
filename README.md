# HBAonFPGA
Implementation of Hardware Bee Algorithm (HBA) on FPGA for solving the Traveling Salesperson Problem (TSP) (M.S. Thesis)
****************************************************************************************************
## Overview
This project implements a Hardware Bee Algorithm on FPGA for solving the Traveling Salesperson Problem (TSP).
The system followed these main steps:

1. **Algorithm Implementation**
   The project implements several well-known bee colony algorithms as faithfully as possible: 
   - **BA (Bee Algorithm)**
   - **BCO (Bee Colony Optimization - Constructive)**
   - **BCOi (Bee Colony Optimization improvement)**
   - **CABC (Combinatorial Artificial Bee Colony)**
   Each algorithm supports two different local optimization methods:
   - **2-Opt** : 2-Opt for edge exchange.
   - **GSTM**  : Greedy Sub-Tour Mutation.  
   For the BCOs algorithm, two types of backward pass methods are available:
   - **Nonloyal** : Recruitment based on fitness probabilities.
   - **Loyal**    : Loyalty-based recruitment with probabilistic retention.
   Additionally, the project includes scripts to extract TSP data from the original Fortran-based database,
   as well as scripts to load TSP instance data from a MAT-file (which is extremely faster than Fortran-based extraction).
2. **Algorithm Evaluation**  
   Each algorithm is evaluated to determine its advantages and disadvantages.
3. **Algorithm Selection**  
   The best algorithm is selected for hardware implementation, which, in this project, is the Bee Algorithm (BA).
4. **Hardware Bee Algorithm (HBA) Proposal**  
   Based on FPGA constraints, the project proposes an HBA that is compatible and optimized for hardware. The implementation
   aims to minimize hardware area while maximizing speed. This is achieved with behavioral-level and structural-level modeling.
   The implementation process is designed to facilitate testing of different TSP instances.
5. **HDL Implementation**  
   The project implements the required HDL in VHDL.
6. **MATLAB Support Scripts**  
   MATLAB scripts necessary for implementation and test benches are developed.
7. **Documentation**  
   Comprehensive thesis documentation is provided.
****************************************************************************************************
## Included Documents

### 1. Thesis (Persian/Farsi)
- Title      : Implementation of Hardware Bee Algorithm (HBA) on FPGA for Travelling Salesman Problem
- Authors    : Pourya Khodagholipour, Fardad Farokhi, Reza Sabbaghi Nadoushan
- Link       : https://github.com/pourya-kgp/HBAonFPGA/blob/main/Docs/Thesis_2016.pdf

### 2. VHDL Cores Details
- Title      : RTL_TB (Details of RTLs and Test Bench Files)
- Authors    : Pourya Khodagholipour
- Link       : https://github.com/pourya-kgp/HBAonFPGA/blob/main/Docs/RTL_TB.pdf
****************************************************************************************************
## M-Files & MAT-file Overview

### Bee Colony Algorithms (BCAs)
- `BCA_Evaluation.m`            : Evaluates five Bee Colony Algorithms (BCAs) for solving the TSP, 
								  including BA, BCO, BCOi, CABC, and HBA.
- `BA.m`                        : Implements the Bee Algorithm (BA) for solving the TSP.
- `BCO.m`                       : Implements the Constructive Bee Colony Optimization algorithm (BCO) for the TSP.
- `BCOi.m`                      : Implements the Bee Colony Optimization improvement algorithm (BCOi) for the TSP.
- `CABC.m`                      : Implements the Combinatorial Artificial Bee Colony algorithm (CABC) for the TSP.
- `HBA.m`                       : Implements the Hardware Bee Algorithm (HBA) for the TSP.

### Common Functions Directory
- `bco_backward_pass.m`         : Performs the backward pass phase of the Bee Colony Optimization algorithm (BCO/BCOi).
- `compute_tour_distances.m`    : Computes the Euclidean distances for various scenarios in a TSP.
- `gstm.m`                      : Implements the Greedy Sub-Tour Mutation (GSTM) for TSP optimization.
- `opt2.m`                      : Performs a single iteration of the 2-Opt optimization for TSP.
- `nn_tour.m`                   : Constructs nearest neighbor tours for the TSP.
- `nn_tour_assign.m`            : Initializes a bee structure using the Nearest Neighbor algorithm.
- `recruited_local_search.m`    : Applies local optimization to a bee structure.
- `site_abandonment.m`          : Checks if a site should be abandoned and reinitialized.
- `roulette_wheel.m`            : Implements the Roulette Wheel Selection method.
- `result_figure.m`             : Plots the TSP tour and, optionally, the best tour length over iterations.
- `visualize_progress.m`        : Displays and visualizes the progress of the optimization algorithm for solving the TSP.

### Database Directory
- `list_tsp_names.m`            : Displays a list of TSP instance names in a structured format.
- `read_fortran_tsp_data.m`     : Reads and processes TSP instance data from Fortran-based files.
- `read_fortran_tsp_instance.m` : Reads TSP instance data from Fortran-based files, extracting city 
                                  coordinates, optimal tour, and optimal tour lengths (if available).
- `tsp_instance.m`              : Extracts city coordinates, optimal tour, and optimal tour lengths 
                                  for a given TSP instance from a MAT-file.
- `tsp_data.m`                  : Saves multiple TSP instances in a MAT-file.
- `tsp_data.mat`                : Contains multiple TSP instances.
- `tsp_instance_info.m`         : Provides detailed information about a TSP instance and visualizes 
                                  its optimal tour (if available).
### VHDL Directory
- `vhdl_data_constructor.m`     : Constructs output files required for FPGA test benches and VHDL ROM
                                  cores for various TSP instances.
****************************************************************************************************
## VHDL
This repository contains 88 VHDL files, including synthesizable and test bench files. The full details are provided
in **RTL_TB.pdf**.

HBA for TSP implements the Hardware Bee Algorithm on FPGA for solving the TSP. The local optimization method used is 
**2-Opt**, and all distance/path/tour calculations utilize a heuristic distance matrix. This implementation utilizes 
FPGA block RAMs. To reduce block RAM usage, an alternative approach is proposed where TSP city coordinates are stored 
in FPGA block RAMs, and the heuristic distance matrix is constructed at startup on external RAM. This process is 
described in the “Distance Matrix Constructor on RAM” section.

Key VHDL files and their corresponding schematic/FSM charts are detailed below:

### HBA for TSP (Hardware Bee Algorithm for the Traveling Salesperson Problem)
- `Gen_HBA.vhd`    : HBA top module generic core for solving the TSP.
- `Gen_HBA_TB.vhd` : Test bench for the HBA core.
	Related Figures:
	- https://github.com/pourya-kgp/HBAonFPGA/blob/main/Figures/01_HBA_Schematic.jpg
	- https://github.com/pourya-kgp/HBAonFPGA/blob/main/Figures/02_HBA_Semi-FSM_Chart.jpg
	- https://github.com/pourya-kgp/HBAonFPGA/blob/main/Figures/03_HBA_Main_Modules.jpg
	- https://github.com/pourya-kgp/HBAonFPGA/blob/main/Figures/04_Sorting_Structure_and_Connections.jpg
	- https://github.com/pourya-kgp/HBAonFPGA/blob/main/Figures/05_Simplified_Sorting_Permitions_Structure.jpg
- `Gen_Sort_Permit.vhd`    : Generic core for sorting permissions.
- `Gen_Sort_Permit_TB.vhd` : Test bench for the sorting permissions core.
	Related Figures:
	- https://github.com/pourya-kgp/HBAonFPGA/blob/main/Figures/06_Sorting_Permitions_Structures.jpg
- `Gen_Bee_Sync.vhd` : Generic core simulating honeybee behavior, holding and modifying the TSP path.
- `Gen_Bee_TB.vhd`   : Test bench for the honeybee behavior simulation core.
	Related Figures:
	- https://github.com/pourya-kgp/HBAonFPGA/blob/main/Figures/07_Bee_Semi-FSM_Chart.jpg
- `Gen_Local_Search.vhd`    : Generic core for 2-Opt local search.
- `Gen_Local_Search_TB.vhd` : Test bench for the 2-Opt local search core.
	Related Figures:
	- https://github.com/pourya-kgp/HBAonFPGA/blob/main/Figures/08_2-Opt_Local_Optimization_Semi-FSM_Chart.jpg
	- https://github.com/pourya-kgp/HBAonFPGA/blob/main/Figures/09_Bee_and_Local_Optimization_Units_Connections.jpg
- `Gen_RNG_City_Set.vhd`    : Generic core for generating two pseudo-random cities' indexes.
- `Gen_RNG_City_Set_TB.vhd` : Test bench for generating two pseudo-random cities' indexes.
	Related Figures: 
	- https://github.com/pourya-kgp/HBAonFPGA/blob/main/Figures/10_Random_Address_Generator_Unit_for_Two_Cities_Indexes_Semi-FSM_Chart.jpg
- `Gen_LFSR.vhd`    : Generic core for an 8-bit Linear Feedback Shift Register (LFSR).
- `Gen_LFSR_TB.vhd` : Test bench for the 8-bit LFSR core.
	Related Figures:
	- https://github.com/pourya-kgp/HBAonFPGA/blob/main/Figures/11_Random_Address_Generator_Unit_within_the_Range_of_the_Cities_Number_Structure.jpg
- `Gen_Update_Tour_V1.vhd` : Generic core to update the TSP tour after a successful local 2-Opt search (Version 1).
- `Gen_Update_Tour_V2.vhd` : Generic core to update the TSP tour after a successful local 2-Opt search (Version 2).
- `Gen_Update_Tour_TB.vhd` : Test bench for the tour update core.
	Related Figures:
	- https://github.com/pourya-kgp/HBAonFPGA/blob/main/Figures/12_Local_Optimization_Update_and_Bee_Modules_Connections.jpg
	- https://github.com/pourya-kgp/HBAonFPGA/blob/main/Figures/13_Update_Unit_V1_V2_Semi-FSM_Chart.jpg
	- https://github.com/pourya-kgp/HBAonFPGA/blob/main/Figures/14_Update_Unit_V1_V2_Full-FSM_Chart.jpg
	- https://github.com/pourya-kgp/HBAonFPGA/blob/main/Figures/15_Rotation_Procedure_for_a_Sub-Tour_in_the_2-Opt_Method.jpg
- `Gen_Nearest_Neighbor_Tour.vhd`    : Generic core for determining the Nearest Neighbor tour for the TSP.
- `Gen_Nearest_Neighbor_Tour_TB.vhd` : Test bench for the Nearest Neighbor tour core.
	Related Figures:
	- https://github.com/pourya-kgp/HBAonFPGA/blob/main/Figures/16_Nearest_Neighbor_Tour_Unit_Semi-FSM_Chart.jpg
	- https://github.com/pourya-kgp/HBAonFPGA/blob/main/Figures/17_Nearest_Neighbor_Tour_Unit_Modules1.jpg
	- https://github.com/pourya-kgp/HBAonFPGA/blob/main/Figures/18_Nearest_Neighbor_Tour_Unit_Modules2.jpg
- `Gen_Nearest_Neighbor.vhd`    : Generic core for specifying the nearest neighbor from the current city.
- `Gen_Nearest_Neighbor_TB.vhd` : Test bench for the nearest neighbor specification core.
	Related Figures:
	- https://github.com/pourya-kgp/HBAonFPGA/blob/main/Figures/19_Nearest_Neighbor_Unit_Structure.jpg
	- https://github.com/pourya-kgp/HBAonFPGA/blob/main/Figures/20_Nearest_Neighbor_Unit_Structure_and_Signals.jpg
- `Gen_Nearest_City.vhd`    : Generic core for specifying and saving the nearest city from the current city in the NN search.
- `Gen_Nearest_City_TB.vhd` : Test bench for the nearest city specification core.
	Related Figures:
	- https://github.com/pourya-kgp/HBAonFPGA/blob/main/Figures/21_Nearest_City_Unit_Structure.jpg
- `Gen_Tour_Sync.vhd` : Generic core to hold and update the TSP path.
- `Gen_Tour_TB.vhd`   : Test bench for the TSP path and update core.
	Related Figures:
	- https://github.com/pourya-kgp/HBAonFPGA/blob/main/Figures/22_Tour_Unit_Semi-FSM_Chart.jpg
- `Gen_Addr_Calc.vhd`    : Generic core to calculate the address for two cities' distance in the ROM (distance matrix).
- `Gen_Addr_Calc_TB.vhd` : Test bench for the address calculator core.
	Related Figures:
	- https://github.com/pourya-kgp/HBAonFPGA/blob/main/Figures/23_Address_Calculator_Unit_Structure.jpg
- `Gen_Addr_Formula.vhd` : Generic core to calculate the address for two cities' distance in the ROM (distance matrix).
	Related Figures:
	- https://github.com/pourya-kgp/HBAonFPGA/blob/main/Figures/24_Address_Formula_Calculator_Unit_Semi-FSM_Chart.jpg
	- https://github.com/pourya-kgp/HBAonFPGA/blob/main/Figures/25_Address_Formula_Calculator_Unit_Structure.jpg
	- https://github.com/pourya-kgp/HBAonFPGA/blob/main/Figures/26_TSP_Coding_and_Distance_Matrix.jpg
	- https://github.com/pourya-kgp/HBAonFPGA/blob/main/Figures/27_Upper_Triangular_Distance_Matrix_Structure_on_ROM.jpg
- `Gen_Index_ij_Behavioral.vhd` : Generic core for sequentially selecting two RAM addresses (complete cases).
- `Gen_Index_ij_Structural.vhd` : Generic core for sequentially selecting two RAM addresses, including a LAST_I case. (Gen_Index_ij + case LAST_I)
- `Gen_Index_ij.vhd`            : Generic core for sequentially selecting two RAM addresses.
- `Gen_Index_ij_TB.vhd`         : Test bench for sequentially selecting two RAM addresses.
	Related Figures:
	- https://github.com/pourya-kgp/HBAonFPGA/blob/main/Figures/28_Sequential_Address_Counting_for_Selecting_Two_Cities_Indexes.jpg
	- https://github.com/pourya-kgp/HBAonFPGA/blob/main/Figures/29_Sequential_Address_Generator_Unit_for_Selecting_Two_Cities_Indexes_Structure.jpg
	- https://github.com/pourya-kgp/HBAonFPGA/blob/main/Figures/30_Sequential_Address_Generator_Unit_for_Selecting_Two_Cities_Indexes_without_Returning_to_the_First_City_Structure.jpg
	- https://github.com/pourya-kgp/HBAonFPGA/blob/main/Figures/31_Sequential_Address_Generator_Unit_for_Selecting_Two_Cities_Indexes_without_Returning_to_the_First_City_Structure_and_Signals.jpg
	- https://github.com/pourya-kgp/HBAonFPGA/blob/main/Figures/32_Edge_Detector_Module_and_Structure.jpg
								  
### Distance Matrix Constructor on RAM
- `Gen_RAM_Heuristic_Data_Loader.vhd`    : Top module generic core to load an internal/external RAM with the distance matrix information.
- `Gen_RAM_Heuristic_Data_Loader_TB.vhd` : Test bench for loading an internal/external RAM with distance matrix information.
	Related Figures:
	- https://github.com/pourya-kgp/HBAonFPGA/blob/main/Figures/33_Distance_Matrix_Constructor_on_RAM_Semi-FSM_Chart.jpg
	- https://github.com/pourya-kgp/HBAonFPGA/blob/main/Figures/34_Distance_Matrix_Constructor_on_RAM_Modules.jpg
- `Gen_Heuristic_Data_Constructor_P1.vhd` : Generic core to construct the distance matrix on the RAM (RAM address and corresponding distance) utilizing synchronous single port ROMs
- `Gen_Heuristic_Data_Constructor_P2.vhd` : Generic core to construct the distance matrix on the RAM (RAM address and corresponding distance) utilizing synchronous dual port ROMs
- `Gen_Heuristic_Data_Constructor_TB.vhd` : Test bench for the distance matrix constructor on the RAM.
	Related Figures:
	- https://github.com/pourya-kgp/HBAonFPGA/blob/main/Figures/35_Distance_Matrix_Constructor_with_Dual-Port_ROMs_Structure.jpg
	- https://github.com/pourya-kgp/HBAonFPGA/blob/main/Figures/36_Distance_Matrix_Constructor_with_Dual-Port_ROMs_Structure_and_Signals.jpg
	- https://github.com/pourya-kgp/HBAonFPGA/blob/main/Figures/37_Distance_Matrix_Constructor_with_Single-Port_ROMs_Structure.jpg
	- https://github.com/pourya-kgp/HBAonFPGA/blob/main/Figures/38_Distance_Matrix_Constructor_with_Single-Port_ROMs_Structure_and_Signals.jpg
- `Gen_Index_ij_BRAM.vhd`    : Generic core for sequentially selecting two RAM addresses.
- `Gen_Index_ij_BRAM_TB.vhd` : Test bench for sequentially selecting two RAM addresses.
	Related Figures:
	- https://github.com/pourya-kgp/HBAonFPGA/blob/main/Figures/39_Sequential_Address_Generator_Unit_for_Two_Cities_Indexes_to_Utilize_for_Memory_Structure.jpg
	- https://github.com/pourya-kgp/HBAonFPGA/blob/main/Figures/40_Sequential_Address_Generator_Unit_for_Two_Cities_Indexes_to_Utilize_for_Memory_Structure_and_Signals.jpg
- `Gen_Euclidean_Distance_Xilinx.vhd` : Generic core to calculate the Euclidean distance between two points on a 2D plane (using Xilinx SQRT IP core).
- `Gen_Euclidean_Distance.vhd`        : Generic core to calculate the Euclidean distance between two points on a 2D plane (using Altera SQRT IP core).
- `Gen_Euclidean_Distance_TB.vhd`     : Test bench for the Euclidean distance calculator core.
	Related Figures:
	- https://github.com/pourya-kgp/HBAonFPGA/blob/main/Figures/41_Eclidean_Distance_Calculator_Unit_for_Xilinx_FPGAs_Semi-FSM_Chart.jpg
	- https://github.com/pourya-kgp/HBAonFPGA/blob/main/Figures/42_Eclidean_Distance_Calculator_Unit_for_Altera_FPGAs_Semi-FSM_Chart.jpg
	- https://github.com/pourya-kgp/HBAonFPGA/blob/main/Figures/43_Square_Root_IP_Core_Configurations_Xilinx.jpg
	- https://github.com/pourya-kgp/HBAonFPGA/blob/main/Figures/44_Square_Root_IP_Core_Configurations_Altera.jpg

### RAM/ROM
- `TSP_Dist_One_Port_ROM_Sync.vhd`    : Single-port ROM with synchronous read (Block RAM), containing the TSP distance matrix.
- `TSP_Dist_One_Port_ROM_Sync_TB.vhd` : Test bench for the single-port ROM with synchronous read.
- `TSP_X_One_Port_ROM_Sync.vhd`       : Single-port ROM with synchronous read (Block RAM) for TSP instance X Coordinates (24 Bit).
- `TSP_X_Dual_Port_ROM_Sync.vhd`      : Dual-port ROM with synchronous read (Block RAM) for TSP instance X Coordinates (24 Bit).
- `TSP_Y_One_Port_ROM_Sync.vhd`       : Single-port ROM with synchronous read (Block RAM) for TSP instance Y Coordinates (24 Bit).
- `TSP_Y_Dual_Port_ROM_Sync.vhd`      : Dual-port ROM with synchronous read (Block RAM) for TSP instance Y Coordinates (24 Bit).
- `Xilinx_One_Port_RAM_Sync.vhd`      : Single-port RAM with synchronous read (Block RAM).
- `Xilinx_Dual_Port_RAM_Sync.vhd`     : Dual-port RAM with synchronous read (Distributed RAM).
- `Xilinx_Dual_Port_RAM_TB.vhd`       : Test bench for dual-port RAM with synchronous/asynchronous read (Distributed RAM).
****************************************************************************************************
## VHDL Usage
To test different TSP instances, replace the `TSP_Dist_One_Port_ROM_Sync.vhd` file in the `/VHDL` directory with the desired TSP
instance `.vhd` file with the exact same name, which can be found in the `VHDL/TSP/<TSPInstanceName>` directory. Moreover, some
changes must be made in the `Gen_HBA.vhd` and `Gen_HBA_TB.vhd` files. These changes are:
- Change the generic `ADDR_WIDTH` in the `Gen_HBA.vhd` entity part. For instances with fewer than 65 cities, use 11 bits; 
  for instances with 65 to 91 cities, use 12 bits; and for instances with more cities up to 254, increase the address width accordingly.
- Update the constant `Cities` to match the number of cities in the TSP instance.
- In the test bench file, the generic address width is named `addr_width` and the constant holding the number of cities is `city_num`;
  apply the same changes there.
With these modifications, TSP instances containing up to 254 cities can be tested. Furthermore, as in the BA (Bee Algorithm), the number
of elite and selected local searches can be set using the constants `Recruited_Bees_Elite` and `Recruited_Bees_Selected`, respectively. 
Additionally, the iteration count and local Search (is) parameters are specified using the constants `Iterations` and `Local_Iter`. 
All default configurations are set for the *eil51* instance and ready for testing.
****************************************************************************************************
## Directory Structure
This repository is organized as follows:

- `Docs/`                         – Contains the thesis file and detailed VHDL file descriptions (RTL_TB).
- `Figure/`                       – Contains schematics, FSM charts, module diagrams, and other figures that illustrate the FPGA implementation.
- `Matlab/`                       – Contains MATLAB scripts, MAT-file, and database-related files.
   - `~/Common/`                  – Contains common functions used by the BCAs (Bee Colony Algorithms) implementations.
   - `~/Database/`                – Contains MAT-files associated with the TSPLIB95 database.
        - `~/TSPLIB95/`           – Includes the TSP instance coordinations directory, optimal tour directory,
									and extracted TSP instance data (obtained from Fortran files and saved as text files).
			 - `~/Database.tour/` – Contains the Fortran `.tour.tsp` files with the TSP optimal tours.
             - `~/Database.tsp/`  – Contains the Fortran `.tsp` files with the TSP city coordinates.
             - `~/Database.txt/`  – Contains TSP instance data in separate text files for each instance.
			 - Known_Optimal_Tour_Lengths.txt
								  – A text file containing the optimal tour lengths for symmetric TSP instances.
			 - tsp_data.txt
								  – A text file containing all TSP instance data used to generate the `tsp_data.m` script.
   - `~/VHDL/`                    – Contains MATLAB files related to VHDL and FPGA implementation.
        - `~/Output/`             – Contains the constructed files that are used in the VHDL test benches and for ROM construction.
- `VHDL/`                         – Contains the main RTL and test bench files for implementing the HBA on the FPGA.
- `VHDL/Basics`                   – Contains basic HDL files for implementing fundamental digital components used in the structural-level design.
- `VHDL/RXM`                      – Contains various memory modules (RAM/ROM) for the FPGA. Some of these modules were used in the project,
									while others are provided for diversity.
- `VHDL/TSP`                      – Contains VHDL or text files related to TSP instances, which were used for implementation or in test benches
									for application verification.
****************************************************************************************************
## Databases
This project was evaluated using the TSPLIB95 database:

TSPLIB95 is a comprehensive library of sample instances for the Traveling Salesman Problem (TSP) and related 
combinatorial optimization problems. Originally compiled by Gerhard Reinelt at Heidelberg University, TSPLIB95
includes a wide range of instances from various sources, including both symmetric and asymmetric TSPs.

- Contains : 111 TSP instances (78 symmetric TSP instances based on 2D-Euclidean distances), 32 optimal tours.
- Format   : Fortran-based files (.tsp & .tour.tsp)
- Source   : http://comopt.ifi.uni-heidelberg.de/software/TSPLIB95/
****************************************************************************************************
## Final Thoughts
This project presents an implementation of the Hardware Bee Algorithm (HBA) on FPGA for solving the Traveling
Salesperson Problem. It includes MATLAB scripts for various Bee Colony Algorithms (BCAs) that support two local
search methods and can extract TSP instance data from both Fortran-based files and pre-saved MAT-files. The 
repository also includes VHDL files, comprehensive documentation, and references to ensure reproducibility and
to support further research.

Contributions and suggestions are welcome! 😊