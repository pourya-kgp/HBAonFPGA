% ----------------------------------------------------------------------------------------------------
% Author        : Pourya Khodagholipour (P.KH)
% Project Name  : Implementation of Hardware Bee Algorithm (HBA) on FPGA for TSP (M.S. Thesis)
% File Name     : read_fortran_tsp_instance.m
% Description   : Reads TSP instance data from Fortran-based files, extracting city coordinates
%                 and optimal tours (if available).
% Creation Date : 2025/02/22
% Revision Date : 2025/02/26
% ----------------------------------------------------------------------------------------------------

function [city_xy, opt_tour, opt_tour_length, opt_tour_length_calculated] = ...
          read_fortran_tsp_instance(tsp_instance_name, mode)

% READ_FORTRAN_TSP_INSTANCE reads TSP instance data from Fortran-based files, extracting city coordinates
% and optimal tours (if available).
% Supports different processing modes for displaying, saving separately, or consolidating TSP instances.
% Only supports TSP instances that use Euclidean distance.
% Additionally, logs the process in 'save' and 'comb' modes.
%
% Inputs:
% - mode:
%   - 'skip' : Extracts data without displaying or saving.
%   - 'disp' : Extracts and displays data in the command window.
%   - 'save' : Extracts and saves each instance's data in separate TXT files.
%   - 'comb' : Extracts and saves all instances' data in a single TXT file.
%   - 'list' : Lists all available TSP instance names.
%
% The function allows independent execution for extracting or displaying data for a single 
% instance ('skip' or 'disp' mode) and can also be used for batch processing in 'save' and 'comb' modes.
%
% - tsp_instance_name : Name of the TSP instance to process.
%
% Outputs:
% - city_xy                    : 2D matrix of TSP city coordinates
%                                - First row : X-coordinates of the cities.
%                                - Second row: Y-coordinates of the cities.
%                                - Number of columns equals the number of cities (nodes).
% - opt_tour                   : The optimal tour (if available).
% - opt_tour_length            : The extracted optimum tour length.
% - opt_tour_length_calculated : The optimum tour length calculated from the optimal tour (if available).

% ------------------------------ Mode Validation ------------------------------

if  nargin < 2 && strcmp(tsp_instance_name, 'list')
    mode = 'list'; % Only 'list' is specified as an argument
elseif nargin < 2
    mode = 'skip'; % Default mode if not specified
else
    % Ensure the provided mode is valid before proceeding
    valid_modes = {'skip', 'disp', 'save', 'comb', 'list'};
    if ~ismember(mode, valid_modes)
        error('Invalid mode: "%s". Mode must be one of the following: %s', ...
               mode, strjoin(valid_modes, ', '));
    end
end

% ------------------------------ Determine Script's Location ------------------------------

% Automatically set the script's location as the default directory
script_path = mfilename('fullpath'); % Get the full path of the current script
script_dir = fileparts(script_path); % Extract the folder path

% ------------------------------ Get a List of All TSP Instances ------------------------------
        
tsp_coordinate_dir = '\TSPLIB95\Database.tsp\'; % Subdirectory containing TSP files
dir_path_coordinates = fullfile(script_dir, tsp_coordinate_dir); % Construct the full path

% Get a list of all .tsp files in the specified directory
file_list = dir(fullfile(dir_path_coordinates, '*.tsp'));

instance_names = {file_list.name}; % Extract the names from the directory listing into a cell array
instance_names = cellfun(@(x) x(1:end-4), instance_names, 'UniformOutput', false); % Remove the .tsp extension

% ------------------------------ Initialize Outputs ------------------------------

city_xy = [];
opt_tour = [];
opt_tour_length = [];
opt_tour_length_calculated = [];

% ------------------------------ List TSP Instance Names ------------------------------

% List the available TSP instance names if mode is 'list'
if strcmp(mode, 'list')
    last_line = 99;
    list_tsp_names(instance_names, last_line);
    return;
end

% ------------------------------ Instance Name Validation ------------------------------

if ~ismember(tsp_instance_name, instance_names)
    error('Incorrect TSP name. The instance "%s" is not available.', tsp_instance_name);
end

% ------------------------------ Specify the Number of Cities ------------------------------

% Find the natural number in the TSP instance name, which is the TSP instance city number
number_str = regexp(tsp_instance_name, '\d+', 'match');

% Convert the extracted natural number string to a numeric value
num_cities = str2double(number_str{1});

% Determine the number of digits in the extracted natural number
cities_digits = length(number_str{1});

% ------------------------------ Define the File Paths ------------------------------

% Define subfolder paths relative to the script directory
tsp_opt_tour_dir   = '\TSPLIB95\Database.tour\';
tsp_txt_dir        = '\TSPLIB95\Database.txt\';
tsp_data_dir       = '\TSPLIB95\';

% Define the filenames for the different types of data
file_name_coordinates = sprintf('%s.tsp', tsp_instance_name);
file_name_opt_tour    = sprintf('%s.opt.tour', tsp_instance_name);
file_name_txt         = sprintf('%s.txt', tsp_instance_name);
file_name_comb        = 'tsp_data.txt';
file_name_tour_length = 'Known_Optimal_Tour_Lengths.txt';

% Construct the complete file paths
file_path_coordinates = fullfile(script_dir, tsp_coordinate_dir, file_name_coordinates);
file_path_opt_tour    = fullfile(script_dir, tsp_opt_tour_dir, file_name_opt_tour);
file_path_txt         = fullfile(script_dir, tsp_txt_dir, file_name_txt);
file_path_comb        = fullfile(script_dir, tsp_data_dir, file_name_comb);
file_path_tour_length = fullfile(script_dir, tsp_data_dir, file_name_tour_length);

% Select file path based on the process mode
switch mode
    case {'skip', 'disp'}
        file_path = [];
        file_name = [];
    case 'save'
        file_path = file_path_txt;
        file_name = file_name_txt;
    case 'comb'
        file_path = file_path_comb;
        file_name = file_name_comb;
end

% ============================================= Coordinates =============================================

% ------------------------------ Open & Read the Coordinates File ------------------------------

% Open the coordinate file for reading
file_id = fopen(file_path_coordinates, 'r');

% Check if the file opened successfully
if file_id == -1
    fprintf('Could not open file %s.\n', file_name_coordinates);
    return;
end

% Predefine variables to store coordinate data and associated formatting info
coordinates = inf(num_cities,2);        % The coordinates of the TSP instance
coordinate_lengths = inf(num_cities,2); % The length of the corresponding coordinate strings
decimal_places = cell(num_cities,2);    % The index (placement) of the decimal point in corresponding coordinates
exponent_places = cell(num_cities,2);   % The index (placement) of the scientific symbol (e/E) in corresponding coordinates
exponents= cell(num_cities,2);          % The exponential part extracted from scientific notation
tsp_comment = [];                       % To store the comment part of the file
start_flag = false;                     % Flag to indicate when the coordinate section begins

% Read and process the file line by line
line_num = 1;    % Initialize a line counter
matrix_line = 1; % Initialize the coordinate matrix line counter
while ~feof(file_id) % Loop until the end of the file
    line = fgetl(file_id); % Read one line at a time
    if ischar(line)
        if start_flag && matrix_line <= num_cities
            
            % Reads numbers in the string (integer & floating point numbers in regular or scientific format)
            number_str = regexp(line, '[-+]?(?:\d+(\.\d+)?|\.\d+)([eE][-+]?\d+)?', 'match');
            % Determine the length of the coordinate strings
            coordinate_lengths(matrix_line,:) = cellfun(@length, number_str(2:3));
            % Find the location of the decimal point, if available
            decimal_places(matrix_line,:) = cellfun(@(x) find(x == '.', 1), number_str(2:3), 'UniformOutput', false);
            % Find the location of the scientific symbol (e/E), if available
            exponent_places(matrix_line,:) = cellfun(@(x) find(ismember(x,['e','E']), 1), number_str(2:3), 'UniformOutput', false);
            % Extract the exponential part (the substring after e/E), if available
            exponents(matrix_line,:) = cellfun(@(x) x(find(ismember(x,['e','E'])) + 1:end), number_str(2:3), 'UniformOutput', false);
            
            % Convert the extracted number strings to a numeric array
            numbers = str2double(number_str);
            % Assign the X and Y coordinates from the extracted numbers
            coordinates(matrix_line,:) = numbers(2:3);
            
            % Increment the coordinate matrix line counter
            matrix_line = matrix_line + 1;

        elseif contains(line, 'NAME')
            % Extract the TSP instance name from the file (starting from the 7th character)
            tsp_name = line(7:end);
        elseif contains(line, 'COMMENT')
            % Extract the TSP instance comment from the file (starting from the 10th character)
            tsp_comment = line(10:end);
        elseif contains(line, 'EDGE_WEIGHT_TYPE')
            % Check if the TSP instance uses 2D Euclidean distances
            if ~contains(line, 'EUC_2D')
                fprintf('The %s instance is not based on 2D Euclidean distances.\n', file_name_coordinates');
                return;
            end
        elseif contains(line, 'NODE_COORD_SECTION')
            % Mark the beginning of the coordinate section
            start_flag = true;
        end
        line_num = line_num + 1; % Increment the overall line counter
    end
end

% Close the coordinates file
fclose(file_id);

% Set function output for coordinates (transpose)
city_xy = coordinates';

% ------------------------------ Parameters for Output Style ------------------------------

% Replace empty cells in formatting variables with 0 and convert to matrices
decimal_places(cellfun(@isempty, decimal_places)) = {0}; % Assign 0 if no decimal point is found
decimal_places_mat = cell2mat(decimal_places);           % Convert cell array to matrix

exponent_places(cellfun(@isempty, exponent_places)) = {0}; % Assign 0 if no scientific symbol is found
exponent_places_mat = cell2mat(exponent_places);           % Convert to matrix

exponents(cellfun(@isempty, exponents)) = {'0'}; % Assign '0' if no exponential part is found
exponents_mat = cellfun(@str2double, exponents); % Convert to numeric matrix

% Determine maximum placements for decimals and exponent positions
decimal_place_max = max(decimal_places_mat, [], 'all');
exponent_place_max = max(exponent_places_mat, [], 'all');

if exponent_place_max > 0 % If coordinates are in scientific format
    coordinate_digits = exponent_places_mat - 1;
else
    coordinate_digits = coordinate_lengths;
end
coordinate_digits_max = max(coordinate_digits, [], 'all');
decimal_digits = coordinate_digits - decimal_places_mat - exponents_mat;

last_line = 99;
% Calculate how many coordinate values can be printed per line in the output
% Formula = (Desired last line column - "    [" - "...") / (coordinate digits + ", ")
coord_per_line = fix((last_line - 5 - 3) / (coordinate_digits_max + 2));

% Calculate how many tour indices can be printed per line in the output
% Formula = (Desired last line column - "    [" - "...") / (Cities number digits + ", ")
tour_per_line = fix((last_line - 5 - 3) / (cities_digits + 2));

% ------------------------------ Format and Output X & Y Coordinates ------------------------------

if ~strcmp(mode, 'skip')
    
    % Select the appropriate output process based on mode ('w' for new file or overwrites an existing one)
    file_id = mode_selection(mode, file_path, file_name, 'w');
    
    % Print header information with a visual separator
    visual_separator = repmat('-', 1, 45);
    fprintf(file_id, '\n');
    fprintf(file_id, '%% %s %s %s\n\n', visual_separator, tsp_instance_name, visual_separator);
    fprintf(file_id, '%% Name: %s ==> %s\n', tsp_name, tsp_comment);
    
    % Print coordinates as a single matrix with two rows and num_cities columns
    % X coordinates first, then Y coordinates
    XY = 'XY';
    for coord = 1:2
        % Print header for each coordinate
        fprintf(file_id, '%s(%d,:) = ... %% %c-Coordinates\n', tsp_instance_name, coord, XY(coord));
        fprintf(file_id, '    [');
        
        % Divide the tour coordinates into chunks of N values for easier readability
        for i = 1:num_cities
            if mod(i,coord_per_line) == 1 && i ~= 1
                fprintf(file_id, '...\n     '); % New line after a fixed number of values
            end
            
            % Print each coordinate value with dynamic formatting if decimals are present
            if decimal_place_max > 0 % If coordinates contain a decimal point
                % Create format string dynamically based on the required decimal precision
                format_str = sprintf('%%.%df', decimal_digits(i,coord));
                fprintf(file_id, format_str, coordinates(i,coord));
            else
                fprintf(file_id, '%d', coordinates(i,coord));
            end
            
            if i ~= num_cities
                if coordinate_digits(i,coord) < coordinate_digits_max
                    % Add spaces for alignment based on the maximum digit length
                    fprintf(file_id, '%s', repmat(' ', 1, coordinate_digits_max - coordinate_digits(i,coord)));
                end
                fprintf(file_id, ', '); % Comma separator between values
            else
                fprintf(file_id, '];\n'); % End of coordinate array
            end
        end
    end
    
    % Close output file and display confirmation if mode is 'save' or 'comb'
    if ismember(mode, {'save', 'comb'})
        fclose(file_id);
        fprintf('Coordinates of %s saved to %s\n', tsp_instance_name, file_name);
    end
end

% ============================================= Process Optimal Tour =============================================

% ------------------------------ Open & Read the Optimum Tour File ------------------------------

% Check if the optimum tour file exists
if ~isfile(file_path_opt_tour)
    opt_tour_length = opt_tour_lengths(mode, file_path, file_name, file_path_tour_length, ...
                                       tsp_instance_name, opt_tour_length_calculated);
    fprintf('%s optimum tour file does not exist.\n', tsp_name);
    return; % Exit if the file does not exist
end

% Open the optimum tour file for reading
file_id = fopen(file_path_opt_tour, 'r');

% Check if the file opened successfully
if file_id == -1
    fprintf('Could not open file %s.\n', file_name_opt_tour);
    return;
end

% Predefine variables for optimum tour extraction
opt_tour = inf(1,num_cities); % Initialize the optimum tour array
start_flag = false;           % Flag to indicate start of the tour section

% Read and process the optimum tour file line by line.
line_num = 1;    % Initialize a line counter
matrix_line = 1; % Initialize the counter for tour indices
while ~feof(file_id) % Loop until the end of the file
    line = fgetl(file_id); % Read one line at a time
    if ischar(line)
        if start_flag && matrix_line <= num_cities
            % Extract integer numbers from the line
            number_str = regexp(line, '\d+', 'match');
            % Convert the extracted strings to a numeric array
            numbers = str2double(number_str);
            % Determine the number of indices extracted from this line
            elements = numel(numbers);
            % Assign the extracted numbers to the optimum tour array
            opt_tour(matrix_line : matrix_line+elements-1) = numbers;
            % Increment the tour indices counter
            matrix_line = matrix_line + elements;
        elseif contains(line, 'COMMENT')
            % Extract the optimum tour length from the comment line
            number_str = regexp(line, '\d+', 'match');
            opt_tour_length = str2double(number_str{end});
        elseif contains(line, 'TOUR_SECTION')
            % Mark the beginning of the tour section
            start_flag = true;
        end
        line_num = line_num + 1; % Increment the overall line counter
    end
end

% Calculate the optimum tour length using the coordinates and the extracted tour
opt_tour_length_calculated = compute_tour_distances(city_xy, 'full_tour', opt_tour);

% ------------------------------ Format and Output the Tour ------------------------------

if ~strcmp(mode, 'skip')
    
    % Select the appropriate output process based on mode ('a' appends data to the end of the existing file)
    file_id = mode_selection(mode, file_path, file_name, 'a');

    % Print tour header information including both extracted and calculated tour lengths
    fprintf(file_id, '%s_opt_tour = ... %% Known optimum tour\n', tsp_instance_name);
    fprintf(file_id, '    [');
    
    % Divide the tour indices into chunks of N values for easier readability
    for i = 1:num_cities
        if mod(i,tour_per_line) == 1 && i ~= 1
            fprintf(file_id, '...\n     '); % New line after a fixed number of indices
        end
        
        % Print each tour indices
        fprintf(file_id, '%d', opt_tour(i));
        
        if i ~= num_cities
            % Determine digit count for proper spacing
            num_str = num2str(opt_tour(i));
            digit_count = length(num_str);
            fprintf(file_id, '%s', repmat(' ', 1, cities_digits - digit_count)); % Align numbers with spaces
            fprintf(file_id, ', '); % Comma separator
        else
            fprintf(file_id, '];\n'); % Close the tour array
        end
    end

    % If mode is 'save' or 'comb', close the file and display confirmation
    if ismember(mode, {'save', 'comb'})
        fclose(file_id);
        fprintf('Optimum tour of %s saved to %s\n', tsp_instance_name, file_name);
    end
    
    % ------------------------------ Process Optimum Tour Length Output ------------------------------
    
    % Call the function to output the optimum tour lengths
    opt_tour_lengths(mode, file_path, file_name, file_path_tour_length, ...
                     tsp_instance_name, opt_tour_length_calculated);
end

end

% ============================================= Local Functions =============================================

function file_id = mode_selection(mode, file_path, file_name, permission)
    
    % MODE_SELECTION determines the file identifier based on the chosen process.
    %
    % Inputs:
    % - mode       : A string indicating the process mode ('disp', 'save', 'comb', or 'skip').
    % - file_path  : The complete file path for saving the output.
    % - file_name  : The name of the output file.
    % - permission : The file access mode ('w' for writing, 'a' for appending).
    %
    % Output:
    % - file_id    : The file identifier, or directs output to the Command Window if 'disp'.
    
    switch mode
        case 'disp'
            file_id = 1; % Direct output to the Command Window
        case 'save'
            % Open or create a new file for writing
            file_id = fopen(file_path, permission);
            % Check if the file opened successfully
            if file_id == -1
                fprintf('Could not open file %s.\n', file_name);
                return;
            end
        case 'comb'
            % Open or create a new file for appending data
            file_id = fopen(file_path, 'a');
            % Check if the file opened successfully
            if file_id == -1
                fprintf('Could not open file %s.\n', file_name);
                return;
            end
        otherwise % For process 'skip'
            file_id = -1; % Discard output
    end
end

% ------------------------------------------------------------------------------------------------  

function opt_tour_length = read_opt_tour(file_path, tsp_instance_name)
    
    % READ_OPT_TOUR extracts the optimum tour length for a given TSP instance from a file.
    %
    % This function searches for a specified TSP instance name in a given file,
    % extracts the numerical value associated with it, and returns it as the optimum tour length.
    %
    % Inputs:
    % - file_path         : The path to the file containing TSP instance data.
    % - tsp_instance_name : The name of the TSP instance to search for.
    %
    % Output:
    % - opt_tour_length   : The optimum tour length extracted from the file.
    %
    % The function assumes that the file contains a line with the instance name
    % followed by numerical values, and the last number in that line represents
    % the optimum tour length.
    
    % Read file as a string array (each line is stored as a separate string)
    lines = readlines(file_path);
    
    % Identify the line containing the specified TSP instance name
    idx = cellfun(@(x) contains(x, tsp_instance_name), lines);
    
    if any(idx)
        % If multiple lines contain the instance name
        if sum(idx) > 1
            fprintf('Multiple matches found for "%s". Using the first occurrence.', tsp_instance_name);
        end

        % Extract numerical values from the found line
        % If multiple lines contain the instance name, use the first occurrence
        number_str = regexp(lines{idx}, '\d+', 'match');
        
        % Convert the extracted strings to a numeric array
        % and return last value as the optimum tour length
        opt_tour_length = str2double(number_str{end});
    else
        opt_tour_length = []; % If the instance name is not found
    end
end

% ------------------------------------------------------------------------------------------------

function opt_tour_length = opt_tour_lengths(mode, file_path, file_name, file_path_tour_length, ...
                                            tsp_instance_name, opt_tour_length_calculated)

    % OPT_TOUR_LENGTHS extracts and records the optimum tour length for a TSP instance.
    %
    % This function retrieves the optimum tour length from a given text file. If the mode 
    % is not set to 'skip', the function either prints or saves both the extracted optimum 
    % tour length and a calculated tour length, if the optimum tour provided.
    %
    % Inputs:
    % - mode                       : Determines how the tour length is processed.
    % - file_path                  : Directory path where the output file is saved.
    % - file_name                  : Name of the output file.
    % - file_path_tour_length      : Path to the file containing optimum tour length data.
    % - tsp_instance_name          : Name of the TSP instance to process.
    % - opt_tour_length_calculated : Calculated length of the optimum tour.
    %
    % Output:
    % - opt_tour_length            : The optimum tour length extracted from the file.
    %
    % Modes:
    % - 'skip' : Only extracts the optimum tour length without printing or saving.
    % - 'disp' : Displays the extracted and calculated tour lengths in the command window.
    % - 'save' : Saves the tour lengths in a separate file for each instance.
    % - 'comb' : Saves the tour lengths in a common file for all instances.
    %
    % Dependencies:
    % - This function calls `read_opt_tour()` to extract the tour length from the file.
    % - It also calls `mode_selection()` to determine where to print/save the data.    
    
    if ~isfile(file_path_tour_length)
        fprintf('Optimum tour length file not found: %s\n', file_path_tour_length);
    end
    
    % Extract the optimum tour length from the specified file
    opt_tour_length = read_opt_tour(file_path_tour_length, tsp_instance_name);

    % If mode is not 'skip', print or save the tour lengths
    if ~strcmp(mode, 'skip')
        
        % Select the appropriate output process based on mode ('a' appends data to the end of the existing file)
        file_id = mode_selection(mode, file_path, file_name, 'a');
    
        % Print tour length information to file or console
        if ~isempty(opt_tour_length)
            fprintf(file_id, '%s_opt_tour_length = %d; %% Known optimum tour length\n', ...
                               tsp_instance_name, opt_tour_length);
        end
        if ~isempty(opt_tour_length_calculated)
            fprintf(file_id, '%s_opt_tour_length_calculated = %g; %% Calculated optimum tour length\n', ...
                               tsp_instance_name, opt_tour_length_calculated);
        end
        
        % If mode is 'save' or 'comb', close the file and display confirmation
        if ismember(mode, {'save', 'comb'})
            fclose(file_id);
            fprintf('Optimum tour lengths of %s saved to %s\n', ...
                     tsp_instance_name, file_name);
        end
    end
end