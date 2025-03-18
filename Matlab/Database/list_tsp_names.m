% ----------------------------------------------------------------------------------------------------
% Author        : Pourya Khodagholipour (P.KH)
% Project Name  : Implementation of Hardware Bee Algorithm (HBA) on FPGA for TSP (M.S. Thesis)
% File Name     : list_tsp_names.m
% Description   : Displays a list of TSP instance names in a structured format
% Creation Date : 2025/02/25
% Revision Date : 2025/02/26
% ----------------------------------------------------------------------------------------------------

function list_tsp_names(instance_names, last_line)
    
% LIST_TSP_NAMES displays a list of TSP instance names in a structured format.
%
% This function takes a cell array of TSP instance names and prints them in a column-wise arrangement.
% It ensures that names are sorted alphabetically and aligned based on the longest name.
%
% Inputs:
% - instance_names : A cell array containing the TSP instance names.
% - last_line      : The maximum number of characters allowed in a single line.

if nargin < 2
    last_line = 99; % Default width if not provided
end

% Validate input
if ~iscell(instance_names) || ~isnumeric(last_line) || last_line <= 0
    error(['Invalid input: instance_names must be a cell array, ' ...
           'and last_line must be a positive number.']);
end

% Sort the TSP instance names alphabetically
instance_names = sort(instance_names);

% ------------------------------ Parameters for Output Style ------------------------------

instance_names_length = length(instance_names); % Total number of instance names
names_lengths = cellfun(@length, instance_names); % Length of each name
names_lengths_max = max(names_lengths, [], 'all'); % Maximum name length

% Calculate how many instance names can be printed per line
% Formula = (Maximum allowed characters per line) / (Longest name + " | ")
names_per_line = fix((last_line) / (names_lengths_max + 3));

% ------------------------------ Arrange Names in Column Format ------------------------------

name_per_rows = ceil(instance_names_length/names_per_line); % Number of rows needed
reshape_size = name_per_rows*names_per_line; % Total number of required elements for reshaping
instance_names(instance_names_length+1 : reshape_size) = {' '}; % Fill empty slots with a space
instance_names_reshaped = reshape(instance_names, name_per_rows, names_per_line)'; % Reshape and transpose

% ------------------------------ Print the Output ------------------------------

% Print the header
visual_separator = repmat('=', 1, last_line); % Create a visual separator line
fprintf('%% %s\n', visual_separator);
fprintf('%% Supported TSP Instance Names:\n%% ');

% Loop through reshaped names and print them in column-wise order
for i = 1:reshape_size
    if mod(i,names_per_line) == 1 && i ~= 1
        fprintf('\n%% '); % Start a new line after a fixed number of names
    end

    % Print the instance name
    fprintf('%s', instance_names_reshaped{i});

    % Determine the character count for proper spacing
    char_count = length(instance_names_reshaped{i});
    fprintf('%s', repmat(' ', 1, names_lengths_max - char_count)); % Align numbers with spaces
    fprintf(' | '); % Separator
end

% Print footer
fprintf('\n%% %s\n', visual_separator);

end