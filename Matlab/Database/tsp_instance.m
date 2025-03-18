% ----------------------------------------------------------------------------------------------------
% Author        : Pourya Khodagholipour (P.KH)
% Project Name  : Implementation of Hardware Bee Algorithm (HBA) on FPGA for TSP (M.S. Thesis)
% File Name     : tsp_instance.m
% Description   : Extracts city coordinates, optimal tour, and optimal tour lengths for a given 
%                 TSP instance from a MAT-file.
% Creation Date : 2016/06
% Revision Date : 2025/02/28
% ----------------------------------------------------------------------------------------------------
 
function [city_xy, opt_tour, opt_tour_length, opt_tour_length_calculated] = ...
          tsp_instance(tsp_instance_name, file_path)

% TSP_INSTANCE extracts city coordinates, optimal tour, and optimal tour lengths for a given TSP instance.
%
% This function retrieves the X and Y coordinates of cities for a specified
% Traveling Salesperson Problem (TSP) instance. If available, it also returns
% the optimal tour and its corresponding tour lengths.Additionally, if 'list' 
% is provided as the instance name, it displays all available TSP instances 
% that are based on Euclidean distance.
%
% Inputs:
% - tsp_instance_name          : Name of the chosen TSP (e.g., 'berlin52').
%                                Use 'list' to display available instances (Euclidean-based).
% - file_path (optional)       : Full path to the .mat file containing TSP data.
%                                If not provided, a default path is used.
%
% Outputs:
% - city_xy                    : 2D matrix of TSP city coordinates
%                                - First row : X-coordinates of the cities.
%                                - Second row: Y-coordinates of the cities.
%                                - Number of columns equals the number of cities (nodes).
% - opt_tour                   : Optimal tour (if available); otherwise, returns an empty array [].
% - opt_tour_length            : Officially known optimal tour length.
% - opt_tour_length_calculated : Optimal tour length computed from the optimal tour sequence (if available).
%
% Example Usage:
% [x, y, tour, tour_length, tour_length_calc] = tsp_instance('berlin52'); % Retrieve berlin52 data
% tsp_instance('list'); % Display available instances
%
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

% ------------------------------ Initialization ------------------------------

% Otuput initialization
city_xy = [];
opt_tour = [];
opt_tour_length = [];
opt_tour_length_calculated = [];

% File path initialization
% If file_path is not provided, automatically set the script's location as the default directory
if nargin < 2
    % Get the full path of the current script
    script_path = mfilename('fullpath');
    % Extract the folder path
    script_dir = fileparts(script_path);
    % The MAT-file name
    file_name = 'tsp_data.mat';
    % Construct the full file path in the same directory as the script
    file_path = fullfile(script_dir, file_name);
end

% ------------------------------ Ensure the Data File Exists ------------------------------

% Check if the .mat file exists; if not, create it using tsp_data function
if ~isfile(file_path)
    fprintf('TSP data file not found at:\n%s\nCreating it...\n', file_path);
    tsp_data(file_path);
end

% ------------------------------ List the Available TSP Instances ------------------------------

% Get the list of variables stored in the MAT-file
vars = who('-file', file_path);
% Eliminate the variable name associated with file_path
vars(cellfun(@(x) contains(x, 'file_path'), vars)) = [];

% Display all available TSP instances if the user requests 'list'
if strcmp(tsp_instance_name, 'list')
    tsp_names = vars(cellfun(@(x) ~contains(x, 'tour'), vars));
    list_tsp_names(tsp_names);
    return;
end

% ------------------------------ Load the Requested TSP Instance ------------------------------

% Check if the requested TSP instance exists in the MAT-file
if ~ismember(tsp_instance_name, vars)
    error('Incorrect TSP name. The instance "%s" is not available.', tsp_instance_name);
else % If it exists, load the data associated with the selected TSP instance
    
    % Generate full variable names for different optimal tour-related data
    opt_tour_sub_names = {'', '_length', '_length_calculated'}; 
    opt_tour_full_names = cellfun(@(x) sprintf('%s_opt_tour%s', tsp_instance_name, x), ...
                                  opt_tour_sub_names, 'UniformOutput', false);
    
    % Create a regular expression to load all variables related to the given TSP instance
    format_str = sprintf('^%s', tsp_instance_name);
    % Load all matching variables from the MAT file 
    tsp_inst = load(file_path, '-regexp', format_str);
    % Retrieve the names of all fields (variables) that were loaded from the MAT file
    field_names = fieldnames(tsp_inst);

    % Extract coordinates
    city_xy = tsp_inst.(tsp_instance_name);
    
    % Retrieve known optimal tour length
    opt_tour_length = tsp_inst.(opt_tour_full_names{2});
    
    % If a known optimal tour exists, retrieve it along with the optimal 
    % tour length calculated from it; otherwise, returns an empty array [].
    if length(field_names) > 2
        opt_tour = tsp_inst.(opt_tour_full_names{1});
        opt_tour_length_calculated = tsp_inst.(opt_tour_full_names{3});
    else
        opt_tour = [];
        opt_tour_length_calculated = [];
    end

end
end