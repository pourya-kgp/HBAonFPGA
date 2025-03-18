% ----------------------------------------------------------------------------------------------------
% Author        : Pourya Khodagholipour (P.KH)
% Project Name  : Implementation of Hardware Bee Algorithm (HBA) on FPGA for TSP (M.S. Thesis)
% File Name     : visualize_progress.m
% Description   : Displays and visualizes the progress of an optimization algorithm for solving 
%                 the Traveling Salesperson Problem (TSP).
% Creation Date : 2016/06
% Revision Date : 2025/03/03
% ----------------------------------------------------------------------------------------------------

function visualize_progress(city_xy, best_tour, best_cost_iter, max_iter, visual_mode)
 
% Visualizes the progress of an optimization algorithm by displaying the current iteration's 
% best tour length and, optionally, plotting the best tour and cost progression.
%
% This function provides real-time feedback on the optimization process, printing the iteration 
% number and best tour cost to the command window and, if visualization is enabled, generating 
% a graphical representation of the current best tour and cost history. It is designed to work 
% with algorithms solving the Traveling Salesperson Problem (TSP).
%
% Inputs:
% - city_xy        : 2D matrix of TSP city coordinates
%                    - First row : X-coordinates of the cities.
%                    - Second row: Y-coordinates of the cities.
%                    - Number of columns equals the number of cities (nodes).
% - best_tour      : Current best tour (sequence of city indices).
% - best_cost_iter : Vector of best tour costs up to the current iteration.
% - max_iter       : Maximum number of iterations for the algorithm (for plot scaling).
% - visual_mode    : Visualization mode:
%                    - 'skip' : Disable visualization.
%                    - 'disp' : Visualize progress.
%
% Outputs:
% - None (function produces console output and optional graphical plots).
%
% Notes:
% - Console output is sent to the command window (file_id = 1) by default.
% - If visual_mode is 'disp', a new figure is created at the first iteration,
%   and subsequent calls update the plot using the external function result_figure.
%
% Dependencies:
% - result_figure: External function to generate the plot of the tour and cost progression.

iteration = numel(best_cost_iter);

file_id = 1; % Default output to command window
% Print the iteration number and the best tour length found so far
fprintf(file_id, 'Iteration = %4d ==> Tour Length = %g\n', iteration, best_cost_iter(iteration));

% If visualization mode is enabled, plot the current best tour and cost progression
if strcmp(visual_mode, 'disp')
    if iteration == 1, figure; end
    result_figure(city_xy, best_tour, best_cost_iter, max_iter);
end
end