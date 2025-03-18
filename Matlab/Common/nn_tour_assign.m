% ----------------------------------------------------------------------------------------------------
% Author        : Pourya Khodagholipour (P.KH)
% Project Name  : Implementation of Hardware Bee Algorithm (HBA) on FPGA for TSP (M.S. Thesis)
% File Name     : nn_tour_assign.m
% Description   : Initializes a bee structure using the Nearest Neighbor algorithm
% Creation Date : 2016/06
% Revision Date : 2025/03/03
% ----------------------------------------------------------------------------------------------------

function bee_struct = nn_tour_assign(city_xy, start_city, bee_struct)

% NN_TOUR_ASSIGN initializes bee structure using the Nearest Neighbor algorithm.
%
% This function assigns Nearest Neighbor tours to each bee in the Bee structure, starting from
% a specified city. It reinitializes the tours and resets the trial counters for all bees.
%
% Inputs:
% - city_xy    : 2D matrix of TSP city coordinates
%                - First row : X-coordinates of the cities.
%                - Second row: Y-coordinates of the cities.
%                - Number of columns equals the number of cities (nodes).
% - start_city : Current starting city index for NN tours (integer).
% - bee_struct : Structure array of bees with fields: tour, cost, trial.
%
% Outputs:
% - bee_struct : Updated structure array with assigned tours, computed costs, 
%                and reset trial counters.
% Notes:
% - Requires external functions: nn_tour, compute_tour_distances.
   
num_tours = length(bee_struct);
% Generate Nearest Neighbor tours and compute their costs
nn_tours = nn_tour(city_xy, num_tours, start_city);
nn_costs = compute_tour_distances(city_xy, 'full_tour', nn_tours);

% Populate bee structure with tours and costs
for i = 1:num_tours
    bee_struct(i).tour = nn_tours(i,:);
    bee_struct(i).cost = nn_costs(i);
    bee_struct(i).trial = 0; % Initialize trial counter
end
end