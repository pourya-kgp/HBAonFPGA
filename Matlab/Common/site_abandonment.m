% ----------------------------------------------------------------------------------------------------
% Author        : Pourya Khodagholipour (P.KH)
% Project Name  : Implementation of Hardware Bee Algorithm (HBA) on FPGA for TSP (M.S. Thesis)
% File Name     : site_abandonment.m
% Description   : Checks if a site should be abandoned and reinitialized
% Creation Date : 2016/06
% Revision Date : 2025/03/03
% ----------------------------------------------------------------------------------------------------

function [bee_struct, start_city] = site_abandonment(city_xy, stlim, start_city, bee_struct)
    
% SITE_ABANDONMENT checks if a site should be abandoned and reinitialized.
%
% This function checks each bee’s trial counter against a stagnation limit (stlim). If a bee’s
% tour has not improved for too long (trial >= stlim) and additional starting cities are
% available, it abandons the current tour and assigns a new Nearest Neighbor tour starting
% from the next city, resetting the trial counter.
%
% Inputs:
% - city_xy    : 2D matrix of TSP city coordinates
%                - First row : X-coordinates of the cities.
%                - Second row: Y-coordinates of the cities.
%                - Number of columns equals the number of cities (nodes).
% - stlim      : Stagnation limit (maximum trials before abandonment, integer).
% - start_city : Current starting city index for NN tours (integer).
% - bee_struct : Structure array of bees with fields: tour, cost, trial.
%
% Outputs:
% - bee_struct : Updated structure array with reinitialized tours if applicable.
% - start_city : Updated starting city index after reassignments.
%
% Notes:
% - Requires external functions: nn_tour, compute_tour_distances.
% - Only reinitializes if start_city < nodes to avoid redundant tours.

% Total number of cities (nodes) in the TSP instance
nodes = length(city_xy);

for i = 1:length(bee_struct)
    if bee_struct(i).trial >= stlim && start_city < nodes
        start_city = start_city + 1;
        bee_struct(i).tour = nn_tour(city_xy, 1, start_city);
        bee_struct(i).cost = compute_tour_distances(city_xy, 'full_tour', bee_struct(i).tour);
        bee_struct(i).trial = 0; % Reset trial counter
    end
end
end