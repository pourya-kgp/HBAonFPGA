% ----------------------------------------------------------------------------------------------------
% Author        : Pourya Khodagholipour (P.KH)
% Project Name  : Implementation of Hardware Bee Algorithm (HBA) on FPGA for TSP (M.S. Thesis)
% File Name     : vhdl_data_constructor.m
% Description   : Constructs output files required for FPGA test benches and VHDL ROM cores 
%                 for various Traveling Salesperson Problem (TSP) instances.
% Creation Date : 2016/06
% Revision Date : 2025/02/22
% ----------------------------------------------------------------------------------------------------

% This script constructs output files required for FPGA test benches and VHDL ROM cores
% for various Traveling Salesperson Problem (TSP) instances. 
%
% The script allows users to:
% 1. Select a TSP instance from a predefined set.
% 2. Choose which type of data file to construct:
%    - X and Y coordinates of the TSP instance in TXT format for test benches.
%    - X and Y coordinates in VHD format for ROM core generation in VHDL.
%    - Heuristic distance matrix in TXT and VHD formats (only the upper triangular matrix is
%      stored for ROM capacity optimization).
%    - All nearest neighbor tours in binary format.
%    - Tour path lengths for all nearest neighbor tours, stored according to the order of tours.
%
% The constructed files can be used in hardware implementations, particularly for FPGA-based 
% acceleration of TSP algorithms.
%
% Features:
% - Supports flexible file output in both text and VHDL formats.
% - Allows ROM size customization based on user-defined address digit length.
% - Uses coefficient scaling to remove decimal points for FPGA compatibility.

clearvars; close all; clc

% ------------------------------ Choose the TSP instance ------------------------------

tsp_instance_name = 'eil51'; % Set the TSP instance name

% ==================================================================================================
% Supported TSP Instance Names:
% a280     | d18512   | fl1577   | kroB150  | p654     | pr152    | rat783   | rl5934   | u2319    | 
% berlin52 | d198     | fl3795   | kroB200  | pcb1173  | pr226    | rat99    | st70     | u574     | 
% bier127  | d2103    | fl417    | kroC100  | pcb3038  | pr2392   | rd100    | ts225    | u724     | 
% brd14051 | d493     | fnl4461  | kroD100  | pcb442   | pr264    | rd400    | tsp225   | usa13509 | 
% ch130    | d657     | gil262   | kroE100  | pr1002   | pr299    | rl11849  | u1060    | vm1084   | 
% ch150    | eil101   | kroA100  | lin105   | pr107    | pr439    | rl1304   | u1432    | vm1748   | 
% d1291    | eil51    | kroA150  | lin318   | pr124    | pr76     | rl1323   | u159     |          | 
% d15112   | eil76    | kroA200  | linhp318 | pr136    | rat195   | rl1889   | u1817    |          | 
% d1655    | fl1400   | kroB100  | nrw1379  | pr144    | rat575   | rl5915   | u2152    |          | 
% ==================================================================================================

% ------------------------------ Choose the desired process ------------------------------

process = 'coord_x_txt'; % Select the type of data file to construct

% ====================================================================================================
% Available options:
% 'coord_x_txt'     : Binary X-coordinates in TXT format for FPGA test benches.
% 'coord_y_txt'     : Binary Y-coordinates in TXT format for FPGA test benches.
% 'coord_x_vhd'     : Binary X-coordinates in VHD format for ROM core generation.
% 'coord_y_vhd'     : Binary Y-coordinates in VHD format for ROM core generation.
% 'dist_mat_txt'    : Binary upper-triangular heuristic distance matrix in TXT format for FPGA test benches.
% 'dist_mat_vhd'    : Binary upper-triangular heuristic distance matrix in VHD format for ROM core generation.
% 'nn_tours'        : Binary nearest neighbor tours in TXT format for FPGA test benches.
% 'nn_tour_lengths' : Binary nearest neighbor tours' lengths in TXT format for FPGA test benches.
% ====================================================================================================

% ------------------------------ Define parameters for data formatting ------------------------------

coefficient = 1000;   % Scaling factor for eliminating decimal points in FPGA
tour_index_bits = 8;  % Number of binary digits for tour indices
coordinate_bits = 24; % Number of binary digits for X and Y coordinates
distance_bits   = 32; % Number of binary digits for distances
length_bits     = 32; % Number of binary digits for tour lengths

% ROM Address digit length for coordinates/tour indices
rom_tour_addr_bits = 8;

% Set how to determine ROM address digits for heuristic distance matrix
rom_dist_addr_mode = 'minimum'; % Options: 'minimum', 'digits'
if strcmp(rom_dist_addr_mode, 'digits')
    rom_addr_bits = 16; % User-defined ROM address length if 'digits' is selected
end

% ------------------------------ Define default output folder ------------------------------

% Automatically set output directory to the script's location
script_path = mfilename('fullpath'); % Get the full path of the current script
script_dir = fileparts(script_path); % Extract the folder path

% ------------------------------ Define file name based on process ------------------------------

% Generate appropriate file name depending on the selected process
switch process
    case {'coord_x_txt', 'coord_y_txt', 'coord_x_vhd', 'coord_y_vhd'}
        file_name = sprintf('%s%c.%s', tsp_instance_name, upper(process(end-4)), process(end-2:end));
    case {'dist_mat_txt', 'dist_mat_vhd'}
        file_name = sprintf('%sDist.%s', tsp_instance_name, process(end-2:end));
    case 'nn_tours'
        file_name = sprintf('%sNNTour.txt', tsp_instance_name);
    case 'nn_tour_lengths'
        file_name = sprintf('%sNNTourLength.txt', tsp_instance_name);
    otherwise
        error('Invalid process selected. Please choose a valid process type.');
end

% ------------------------------ File creation ------------------------------

% Construct the complete path to save the output file
file_path = fullfile(script_dir, file_name);

% Open the file for writing ('w' mode creates a new file or overwrites an existing one)
file_id = fopen(file_path, 'w');
        
% Check if file creation was successful
if file_id == -1
    error('File creation failed. Check write permissions or file path.');
end

% ------------------------------ Load TSP Instance Data ------------------------------

% Load city coordinates for the selected TSP instance
[city_xy, ~, ~, ~] = tsp_instance(tsp_instance_name);
% Alternative data extraction (if using Fortran-based TSP instance reader)
%[city_xy, ~, ~, ~] = read_fortran_tsp_instance(tsp_instance_name);

city_x = city_xy(1,:); % X coordinates
city_y = city_xy(2,:); % Y coordinates
num_cities = length(city_xy); % Total number of cities in the instance

% ------------------------------ Process and Write Data ------------------------------

% Handle different processes based on user selection
switch process
    case {'coord_x_txt', 'coord_y_txt', 'coord_x_vhd', 'coord_y_vhd'}
    % --------------- Handle X and Y coordinate data for both TXT and VHDL formats ---------------

        % ---------- Part 1: X/Y Coordinate Data
        switch process
            case {'coord_x_txt', 'coord_x_vhd'}
                % Convert X-coordinates to binary format
                bin_x = dec2bin(city_x*coefficient, coordinate_bits);
                % Write to file
                for i = 1:num_cities
                    save_binary_data(file_id, process, bin_x(i,:), i-1);
                end
            otherwise
                % Convert Y-coordinates to binary format
                bin_y = dec2bin(city_y*coefficient, coordinate_bits);
                % Write to file
                for i = 1:num_cities
                    save_binary_data(file_id, process, bin_y(i,:), i-1);
                end
        end
        
        % ---------- Part 2: Padding with Zeros
        bin_0 = dec2bin(0, coordinate_bits); % Binary zeros for unused ROM slots
        if num_cities <= 2^rom_tour_addr_bits-2
            for i = num_cities : 2^rom_tour_addr_bits-2
                save_binary_data(file_id, process, bin_0, i); % Write to file
            end
        end
        
        % ---------- Part 3: Final Line
        save_binary_data_last_line(file_id, process, bin_0, i+1); % Write to file
        
    case {'dist_mat_txt', 'dist_mat_vhd'}
    % --------------- Handle distance matrix ---------------
    
        % Compute the heuristic distance matrix
        distances = compute_tour_distances(city_xy, 'dist_mat', []);
        
        % Constants
        bin_0 = dec2bin(0                , distance_bits); % Binary zeros for unused ROM slots
        bin_1 = dec2bin(2^distance_bits-1, distance_bits); % Binary ones for maximum value
        
        % Convert matrix elements to binary and write the upper triangular matrix

        % ---------- Part 1: First address (all 1s for initialization)
        save_binary_data(file_id, process, bin_1, 0); % Write to file
        
        % ---------- Part 2: Write upper triangle of the distance matrix
        for i = 1:num_cities
            for j = i+1:num_cities
                bin_dist = dec2bin(round(distances(i,j)*coefficient), distance_bits);
                % Write to file
                save_binary_data(file_id, process, bin_dist, (i-1)*num_cities + j - ((i+1)*i/2));
            end
        end
        
        % ---------- Determine the Last ROM Address
        last_upper_dist_mat_addr = (num_cities^2 - num_cities)/2;
        if strcmp(rom_dist_addr_mode, 'minimum')
            last_rom_addr = 2^ceil(log2(last_upper_dist_mat_addr))-1;
        else
            last_rom_addr = 2^rom_addr_bits-1;
        end
        
        % ---------- Part 3: Padding with Zeros
        if last_upper_dist_mat_addr+1 <= last_rom_addr-1
            for i = last_upper_dist_mat_addr+1 : last_rom_addr-1
                save_binary_data(file_id, process, bin_0, i); % Write to file
            end
        else
            i = last_upper_dist_mat_addr;
        end
        
        % ---------- Part 4: Final Line
        save_binary_data_last_line(file_id, process, bin_0, i+1); % Write to file

    case 'nn_tours'
    % --------------- Handle nearest neighbor tours ---------------
        
        % Generate nearest neighbor tours
        tours = nn_tour(city_xy, num_cities, 1);
        
        % Convert tour indices to binary format
        % Each tour is written consecutively in the columns,  
        % arranged from top to bottom in the text file.
        bin_nnt = dec2bin(tours', tour_index_bits);
        
        % Write to file
        save_binary_data_nn_tour(file_id, bin_nnt, num_cities^2);
    
    case 'nn_tour_lengths'
    % --------------- Handle nearest neighbor tour lengths ---------------
        
        % Generate nearest neighbor tours
        tours = nn_tour(city_xy, num_cities, 1);
        
        % Compute distances for nearest neighbor tours
        
        % Rotate tours to compute distances between consecutive nodes
        tours_rotated  = [tours(:,2:end), tours(:,1)]; % Cycling the first column to the end
        % Compute Euclidean distances between consecutive nodes
        node_to_node_distances = sqrt((city_x(tours) - city_x(tours_rotated)).^2 + ...
                                      (city_y(tours) - city_y(tours_rotated)).^2);
        % Every node to node's distance multiplied and rounded
        node_to_node_distances = round(node_to_node_distances*coefficient);
        nn_distances_set = sum(node_to_node_distances, 2);
        
        % Note: 
        % Using the function compute_tour_distances(city_xy, 'full_tour', tours) is another approach.
        % However, in the FPGA, the heuristic distance matrix is multiplied by the coefficient and rounded 
        % before computing the nearest neighbor tour length. Therefore, if the distance matrix is obtained 
        % using the function and then multiplied by the coefficient and rounded in MATLAB, it does not yield 
        % the same results as the FPGA implementation.
        
        % Convert lengths to binary
        bin_nnt_length = dec2bin(nn_distances_set, length_bits);
        
        % Write to file
        save_binary_data_nn_tour(file_id, bin_nnt_length, num_cities);
end

% ------------------------------ Close the file and display success message ------------------------------

fclose(file_id); % Close the file after writing
fprintf('Results saved to %s.\n', file_name); % Display confirmation

% ========================================= Local Functions =========================================

function save_binary_data(file_id, process, bin_data, rom_address)
    % This function saves the binary data into the file in either TXT or VHDL format, 
    % depending on the process type.
    %
    % Inputs:
    % - file_id     : File identifier to write to.
    % - process     : Process type to determine output format.
    % - bin_data    : The binary data string to save.
    % - rom_address : The ROM address (used in VHDL format).

    if contains(process, 'txt')
        fprintf(file_id, '%s\n', bin_data); % TXT format output
    else
        fprintf(file_id, '"%s" , -- ADDR %d\n', bin_data, rom_address); % VHDL format output
    end
end

function save_binary_data_last_line(file_id, process, bin_data, rom_address)
    % This function handles saving the last line of the data without adding
    % a newline or comma at the end for VHDL files.
    %
    % Inputs:
    % - file_id     : File identifier to write to.
    % - process     : Process type to determine output format.
    % - bin_data    : The binary data string to save.
    % - rom_address : The ROM address (used in VHDL format).

    if contains(process, 'txt')
        fprintf(file_id, '%s', bin_data); % TXT format
    else
        fprintf(file_id, '"%s"   -- ADDR %d', bin_data, rom_address); % VHD format
    end
end

function save_binary_data_nn_tour(file_id, bin_data, loop_num)
    % This function saves the nearest neighbor tour indices/lengths data in binary format.
    % It writes each tour indices/lengths consecutively in the file, with no newline on 
    % the last line.
    %
    % Inputs:
    % - file_id  : File identifier to write to.
    % - bin_data : Matrix of binary strings to save.
    % - loop_num : Number of lines to save.

    for i = 1:loop_num-1
        fprintf(file_id, '%s\n', bin_data(i,:)); % TXT format
    end
    fprintf(file_id, '%s', bin_data(i+1,:)); % Last line without newline
end