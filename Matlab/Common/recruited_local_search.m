% ----------------------------------------------------------------------------------------------------
% Author        : Pourya Khodagholipour (P.KH)
% Project Name  : Implementation of Hardware Bee Algorithm (HBA) on FPGA for TSP (M.S. Thesis)
% File Name     : recruited_local_search.m
% Description   : Applies local optimization to a bee structure
% Creation Date : 2016/06
% Revision Date : 2025/03/03
% ----------------------------------------------------------------------------------------------------

function bee_struct = recruited_local_search(city_xy, local_opt_method, num_recruited, bee_struct)
    
% RECRUITED_LOCAL_SEARCH applies local optimization to a bee structure.
%
% This function performs local search on a subset of bee solutions (tours) using either
% the 2-Opt or Greedy Sub-Tour Mutation (GSTM) method. It simulates recruited bees exploring
% the neighborhood of each tour, updating the tour and cost if an improvement is found, and
% adjusts the trial counter to track stagnation.
%
% Inputs:
% - city_xy          : 2D matrix of TSP city coordinates
%                      - First row : X-coordinates of the cities.
%                      - Second row: Y-coordinates of the cities.
%                      - Number of columns equals the number of cities (nodes).
% - local_opt_method : Local optimization method:
%                      - '2OPT' : 2-Opt for edge exchange.
%                      - 'GSTM' : Greedy Sub-Tour Mutation.
% - num_recruited    : Number of local search attempts per bee (integer).
% - bee_struct       : Structure array of bees with fields: tour, cost, trial.
%
% Outputs:
% - bee_struct : Updated structure array with improved tours, costs, and trial counters.
%
% Notes:
% - Requires external functions: opt2 (for 2OPT), gstm (for GSTM), compute_tour_distances.
% - Trial counter resets to 0 on improvement, increments otherwise.

switch local_opt_method
    case '2OPT'
        local_search = @(tour) opt2(city_xy, tour); % 2-Opt method
    case 'GSTM'
        local_search = @(tour) gstm(city_xy, tour); % GSTM method
    otherwise
        error('Incorrect local optimization method name. Supported types are: "2-OPT", "GSTM"');
end

% Perform local search for each bee
for i = 1:length(bee_struct)
    improved_flag = false;
    for j = 1:num_recruited
        tour = local_search(bee_struct(i).tour);
        cost = compute_tour_distances(city_xy, 'full_tour', tour);
        if cost < bee_struct(i).cost
            [bee_struct(i).tour, bee_struct(i).cost] = deal(tour, cost);
            improved_flag = true;
        end
    end
    % Update trial counter based on improvement
    if improved_flag
        bee_struct(i).trial = 0;
    else
        bee_struct(i).trial = bee_struct(i).trial + 1;
    end
end
end