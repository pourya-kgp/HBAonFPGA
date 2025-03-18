% ----------------------------------------------------------------------------------------------------
% Author        : Pourya Khodagholipour (P.KH)
% Project Name  : Implementation of Hardware Bee Algorithm (HBA) on FPGA for TSP (M.S. Thesis)
% File Name     : tsp_instance_info.m
% Description   : Provides detailed information about a TSP instance and visualizes its optimal tour
% Creation Date : 2025/03/02
% Revision Date : 2025/03/02
% ----------------------------------------------------------------------------------------------------

function tsp_instance_info(tsp_instance_name)

% TSP_INSTANCE_INFO provides detailed information about a TSP instance and visualizes its optimal
% tour (if available).
% The script extracts key data such as:
% - Number of cities (nodes) in the instance
% - Minimum and maximum distances between cities
% - Known optimal tour length
% Additionally, if an optimal tour exists, the function visualizes it graphically
% and prints the calculated optimal tour length to the command window.
%
% Special Case:
% If 'list' is passed as the input instead of a TSP instance name, the function lists all 
% available instances.
%
% Inputs:
% - tsp_instance_name : String specifying the name of the TSP instance 
%   (e.g., 'berlin52') or 'list' to display available instances.
%
% Outputs:
% - Displays the extracted TSP information in the command window.
% - If the optimal tour exists, a figure is generated to visualize it.
%
% Dependencies:
% - Requires `tsp_instance.m` or `read_fortran_tsp_instance.m` for data extraction.
% - Uses `compute_tour_distances.m` to compute the heuristic distance matrix.
% - Uses `result_figure.m` for visualization.
%
% Example Usage:
% tsp_instance_info('berlin52'); % Displays berlin52 instance information
% tsp_instance_info('list');     % Lists all available TSP instances

% ------------------------------ Load TSP Instance Data ------------------------------
    
% Extract TSP instance details (coordinates, optimal tour, and tour lengths)
[city_xy, opt_tour, opt_tour_len, opt_tour_len_calc] = tsp_instance(tsp_instance_name);
% Alternative data extraction (if using Fortran-based TSP instance reader)
%[city_xy, opt_tour, opt_tour_len, opt_tour_len_calc] = read_fortran_tsp_instance(tsp_instance_name);
    
% ------------------------------ Handle 'list' Mode ------------------------------

% If 'list' is selected, tsp_instance()/read_fortran_tsp_instance() already handles the display, so exit the function.
% If tsp_instance() is used, only Euclidean distance based TSP instances are listed.
% If read_fortran_tsp_instance() is used, all available TSP instances are listed.
if strcmp(tsp_instance_name, 'list')
    return;
end

% ------------------------------ Compute Distance Matrix ------------------------------

% Compute the heuristic distance matrix for all city pairs
dist_mat = compute_tour_distances(city_xy, 'dist_mat', []);
% Replace Inf values (self-distances) with NaN
dist_mat(dist_mat==Inf) = NaN;

% ------------------------------ Display TSP Instance Information ------------------------------

file_id = 1; % Print to the command window
fprintf(file_id, 'TSP Instance Name: "%s"\n', tsp_instance_name);
fprintf(file_id, 'Number of Cities/Nodes: %d\n\n', length(city_xy));
fprintf(file_id, 'Minimum Distance Between Cities/Nodes = %g\n', min(dist_mat, [], "all"));
fprintf(file_id, 'Maximum Distance Between Cities/Nodes = %g\n\n', max(dist_mat, [], "all"));

fprintf(file_id, 'Known Optimal Tour Length = %d\n', opt_tour_len);

% ------------------------------ Display and Visualize Optimal Tour ------------------------------

if ~isempty(opt_tour)
    fprintf(file_id, 'Calculated Optimal Tour Length = %g\n', opt_tour_len_calc);
    % Plot the optimal tour if available
    result_figure(city_xy, opt_tour);
else
    fprintf(file_id, 'Optimal tour data not available.\n');
end

end