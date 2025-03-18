% ----------------------------------------------------------------------------------------------------
% Author        : Pourya Khodagholipour (P.KH)
% Project Name  : Implementation of Hardware Bee Algorithm (HBA) on FPGA for TSP (M.S. Thesis)
% File Name     : read_fortran_tsp_data.m
% Description   : Reads and processes TSP instance data from Fortran-based files.
% Creation Date : 2025/02/25
% Revision Date : 2025/02/26
% ----------------------------------------------------------------------------------------------------

% Reads and processes TSP instance data from Fortran-based .tsp & .opt.tour files.
% The script operates in five different modes: 'skip', 'disp', 'save', 'comb', and 'list'.
% It extracts and processes TSP coordinate data and, if available, the optimal tour.
% In 'save' and 'comb' modes, the data is saved to text files.
%
% Inputs:
% - mode:
%   - 'skip' : Extracts data without displaying or saving.
%   - 'disp' : Extracts and displays data in the command window.
%   - 'save' : Extracts and saves each instance's data in separate TXT files.
%   - 'comb' : Extracts and saves all instances' data in a single TXT file.
%   - 'list' : Lists all available TSP instance names.
%
% The script allows independent execution for extracting or displaying data for a single 
% instance ('skip' or 'disp' mode) and can also be used for batch processing in 'save' and 'comb' modes.
%
% - tsp_instance_name : Name of the TSP instance to process (used in 'skip' and 'disp' modes).
%                       In 'list', 'save, and 'comb' modes, this parameter is ignored.
%
% Outputs:
% - Extracted TSP instance data (coordinates and tour information).
% - In 'disp' mode, the results are displayed in the command window.
% - In 'save' and 'comb' modes, results are saved in text files.
%
% Dependencies:
% - Calls `read_fortran_tsp_instance()` to extract TSP instance data.

clearvars; close all; clc

% ------------------------------ Select Processing Mode ------------------------------

mode = 'list'; % Define the mode of operation

% ===============================================================================================
% Modes:
% - 'skip' : Extracts data without displaying or saving.
% - 'disp' : Extracts and displays data in the command window.
% - 'save' : Extracts and saves each instance's data in separate TXT files.
% - 'comb' : Extracts and saves all instances' data in a single TXT file.
% - 'list' : Lists all available TSP instance names.
% ===============================================================================================

% ------------------------------ Select TSP Instance ------------------------------

tsp_instance_name = 'berlin52'; % Set the TSP instance name

% ===============================================================================================
% Supported TSP Instance Names:
% a280      | d1291     | fl1577    | gr48      | lin318    | pr136     | rd400     | u1060     | 
% ali535    | d15112    | fl3795    | gr666     | linhp318  | pr144     | rl11849   | u1432     | 
% att48     | d1655     | fl417     | gr96      | nrw1379   | pr152     | rl1304    | u159      | 
% att532    | d18512    | fnl4461   | hk48      | p654      | pr226     | rl1323    | u1817     | 
% bayg29    | d198      | fri26     | kroA100   | pa561     | pr2392    | rl1889    | u2152     | 
% bays29    | d2103     | gil262    | kroA150   | pcb1173   | pr264     | rl5915    | u2319     | 
% berlin52  | d493      | gr120     | kroA200   | pcb3038   | pr299     | rl5934    | u574      | 
% bier127   | d657      | gr137     | kroB100   | pcb442    | pr439     | si1032    | u724      | 
% brazil58  | dantzig42 | gr17      | kroB150   | pla33810  | pr76      | si175     | ulysses16 | 
% brd14051  | dsj1000   | gr202     | kroB200   | pla7397   | rat195    | si535     | ulysses22 | 
% brg180    | eil101    | gr21      | kroC100   | pla85900  | rat575    | st70      | usa13509  | 
% burma14   | eil51     | gr229     | kroD100   | pr1002    | rat783    | swiss42   | vm1084    | 
% ch130     | eil76     | gr24      | kroE100   | pr107     | rat99     | ts225     | vm1748    | 
% ch150     | fl1400    | gr431     | lin105    | pr124     | rd100     | tsp225    |           | 
% ===============================================================================================

% ------------------------------ Define Default TSP Data Folder ------------------------------
        
% Automatically set the script's location as the default directory
script_path = mfilename('fullpath'); % Get full path of the current script
script_dir = fileparts(script_path); % Extract folder path
       
% ------------------------------ Get a List of All TSP Instances ------------------------------
        
tsp_coordinate_dir = '\TSPLIB95\Database.tsp\'; % Subdirectory containing TSP files
dir_path_coordinates = fullfile(script_dir, tsp_coordinate_dir); % Construct full path
                
% Get a list of all .tsp files in the specified directory
file_list = dir(fullfile(dir_path_coordinates, '*.tsp'));
num_instances = length(file_list); % Total number of TSP instances

% ------------------------------ Process TSP Data Based on Selected Mode ------------------------------

switch mode
    case {'skip', 'disp', 'list'}
        
        % Read and extract data without saving
        [city_xy, opt_tour, opt_tour_length, opt_tour_length_calculated] = ...
        read_fortran_tsp_instance(tsp_instance_name, mode);

    case {'save', 'comb'}
   
        % ------------------------------ Construct Output File for 'comb' Mode ------------------------------

        if strcmp(mode, 'comb')
            file_name_tsp_data = '\TSPLIB95\tsp_data.txt'; % Define output file name
            file_path_data = fullfile(script_dir, file_name_tsp_data); % Construct the full file path
            
            % If the file already exists, clear its contents
            if isfile(file_path_data)
                file_id = fopen(file_path_data, 'w');
                fclose(file_id);
            end
        end
        
        % ------------------------------ Process Each TSP Instance ------------------------------

        % Loop through each TSP instance file
        for i = 1:num_instances
            % Extract instance name from file name (removing the ".tsp" extension)
            tsp_instance_name = file_list(i).name(1:end-4);
            
            % Read and process TSP instance data
            %[city_xy, opt_tour, opt_tour_length, opt_tour_length_calculated] = ...
            read_fortran_tsp_instance(tsp_instance_name, mode);
        end
end

% ------------------------------ Cleanup Unused Variables ------------------------------

clearvars -except tsp_instance_name city_xy opt_tour opt_tour_length opt_tour_length_calculated