% ----------------------------------------------------------------------------------------------------
% Author        : Pourya Khodagholipour (P.KH)
% Project Name  : Implementation of Hardware Bee Algorithm (HBA) on FPGA for TSP (M.S. Thesis)
% File Name     : result_figure.m
% Description   : Plots the TSP tour and, optionally, the best tour length over iterations
% Creation Date : 2016/06
% Revision Date : 2025/02/17
% ----------------------------------------------------------------------------------------------------

function result_figure(city_xy, best_tour, best_min, max_iter)

% RESULT_FIG plots the TSP tour and, optionally, the best tour length over iterations.
%
% This function visualizes the TSP solution by plotting the tour of the cities. 
% If the 4th and 5th input arguments (best_min and max_iter) are provided, 
% the function creates a figure with two subplots: 
% - Left  subplot : The best tour path found.
% - Right subplot : The tour length progression over iterations.
%
% Inputs:
% - city_xy             : 2D matrix of TSP city coordinates
%                         - First row : X-coordinates of the cities.
%                         - Second row: Y-coordinates of the cities.
%                         - Number of columns equals the number of cities (nodes).
% - best_tour           : The sequence of city indices representing the best tour.
% - best_min (optional) : Array containing the best tour length at each iteration.
% - max_iter (optional) : Maximum number of iterations.
%
% Example Usage:
% result_fig(city_xy, best_tour);                % Plots only the tour
% result_fig(city_xy, best_tour, best_min, 100); % Plots tour & optimization progress

% Extract x and y coordinates of cities from the coordinates matrix
city_x = city_xy(1,:); % X coordinates
city_y = city_xy(2,:); % Y coordinates

% Create a new figure window and clear previous content
figure_number = gcf().Number;
figure(figure_number); clf;

% Determine whether to use only one figure or a figure containing two subplots based on input arguments
if nargin > 3
    subplot(1,2,1);
end    

hold on
% Plot city locations
plot(city_x, city_y, 'r*') % Cities marked in red (*)
plot(city_x, city_y, 'bo') % Additional blue markers

% Constructing the best tour path
pathx = [city_x(best_tour) city_x(best_tour(1))]; % Append first city to complete loop
pathy = [city_y(best_tour) city_y(best_tour(1))]; % Append first city to complete loop
plot(pathx, pathy, 'b-', 'LineWidth', 1) % Draw tour path

% Set labels and figure properties
xlabel('X-Coordinate')
ylabel('Y-Coordinate')
title('Tour')
axis square
hold off

% Plot the best tour length evolution if best_min is provided
if nargin > 3
    subplot(1,2,2) % Create the second subplot
    plot(best_min, 'b.', 'MarkerSize', 8) % Plot with blue dots & connecting line
    xlabel('Iteration Number')
    ylabel('Tour Length')
    title('Optimization Progress')
    axis square
    xlim([0 max_iter])
    ylim([0 best_min(1)]) % Ensures the plot range includes best initial tour length
end

end