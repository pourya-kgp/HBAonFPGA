% ----------------------------------------------------------------------------------------------------
% Author        : Pourya Khodagholipour (P.KH)
% Project Name  : Implementation of Hardware Bee Algorithm (HBA) on FPGA for TSP (M.S. Thesis)
% File Name     : HBA.m
% Description   : Implements the Hardware Bee Algorithm (HBA) for solving the Traveling Salesperson
%                 Problem (TSP)
% Creation Date : 2016/06
% Revision Date : 2025/03/04
% ----------------------------------------------------------------------------------------------------

function [best_tour, best_cost_iter] = HBA(city_xy, local_opt_method, visual_mode, max_iter)

% HBA implements the Hardware Bee Algorithm (HBA) to solve the Traveling Salesperson Problem (TSP).
%
% This function applies a modified Bee Algorithm (BA), tailored for hardware implementation, 
% to find near-optimal solutions to the TSP. Inspired by bee foraging behavior, the algorithm 
% initializes a population of onlooker bees with Nearest Neighbor tours and iteratively improves 
% them through local search phases for elite and selected (onlooker) bees using the same number
% of recruiters (configurable). A single scout bee, selected from the onlooker bees with the worst
% cost function, is reinitialized after a specified number of iterations to maintain diversity.
% Tours are sorted and the best results are saved after each iteration. This design optimizes the
% algorithm for FPGA deployment by reducing scout bee overhead and the ability to unify local
% search operations.
%
% Inputs:
% - city_xy          : 2D matrix of TSP city coordinates
%                      - First row : X-coordinates of the cities.
%                      - Second row: Y-coordinates of the cities.
%                      - Number of columns equals the number of cities (nodes).
% - local_opt_method : Local optimization method:
%                      - '2OPT' : 2-Opt for edge exchange.
%                      - 'GSTM' : Greedy Sub-Tour Mutation.
% - visual_mode      : Visualization mode:
%                      - 'skip' : Disable visualization.
%                      - 'disp' : Visualize progress.
% - max_iter         : Maximum number of iterations for the algorithm.
%
% Outputs:
% - best_tour      : Optimal tour (sequence of city indices) found by the algorithm.
% - best_cost_iter : Vector containing the best tour cost at each iteration.
%
% Parameters:
% - nb    : Number of onlooker bees (search sites).
% - ne    : Number of elite sites (subset of onlooker bees).
% - nrb   : Number of recruited bees for onlooker (non-elite) sites.
% - nre   : Number of recruited bees for elite sites (set equal to nrb, but configurable).
% - ns    : Position of the scout bee (only one scout bee is used).
% - is    : Number of iterations to reinitialize the scout bee 
%           (the onlooker bee with the worst cost function).
% - stlim : Stagnation limit for site abandonment.
% 
% Notes:
% - Optimized for FPGA by reducing scout bees to one and the ability to unify elite/selected 
%   bee local search.
% - The algorithm plots the best tour and cost progression if visual_mode is set to 'disp'.
% - Requires external functions: nn_tour_assign, recruited_local_search, site_abandonment,
%                                visualize_progress.

% Total number of cities (nodes) in the TSP instance
nodes = length(city_xy);

% ------------------------------ Algorithm Parameters ------------------------------

nb  = 10;                          % Number of onlooker bees (search sites)
ne = round(nb/5);                  % Number of elite sites (subset of onlooker bees)
nrb = 2;                           % Number of recruited bees for onlooker (non-elite) sites
nre = nrb;                         % Number of recruited bees for elite sites (set equal to nrb)
ns  = 10;                          % Position of the scout bee (only one scout bee is used)
is = round(max_iter/(nodes-nb+1)); % Number of iterations to reinitialize the scout bee
stlim = round(nb*nodes/3);         % Stagnation limit: maximum cycles before abandoning a site

% ------------------------------ Initialization ------------------------------

% Initialize a structure array to store bee information:
% - 'tour' : Sequence of cities visited by the bee.
% - 'cost' : Total distance of the tour.
% - 'trial': Number of iterations without improvement (used for site abandonment).
bee = repmat(struct('tour', [], 'cost', [], 'trial', []), nb, 1);

% Array to store the best cost found at each iteration
best_tour = inf(1, nodes);

% Array to store the best cost found in each iteration
best_cost_iter = inf(1, max_iter);

% ------------------------------ Assign Nearest Neighbor Tour to Bees & Sort ------------------------------

% Assign initial tours to onlooker bees using the Nearest Neighbor heuristic
bee = nn_tour_assign(city_xy, 1, bee);
start_city = nb; % Track the starting city for subsequent Nearest Neighbor assignments

% Sort bees by their tour cost (ascending order)
[~, idx] = sort([bee.cost]);
bee = bee(idx);

% ------------------------------ Main Algorithm Loop ------------------------------

for i = 1:max_iter
    
    % =============== Elite Bees Phase ===============
    % Perform local search on elite bees (ne) with nre recruited bees
    bee(1:ne) = recruited_local_search(city_xy, local_opt_method, nre, bee(1:ne));
    % Check for site abandonment and reinitialize if needed
    [bee(1:ne), start_city] = site_abandonment(city_xy, stlim, start_city, bee(1:ne));
    
    % =============== Remaining onlooker Bees Phase ===============
    % Perform local search on remaining onlooker bees (nb-ne) with nrb recruited bees
    bee(ne+1:nb) = recruited_local_search(city_xy, local_opt_method, nrb, bee(ne+1:nb));
    % Check for site abandonment and reinitialize if needed
    [bee(ne+1:nb), start_city] = site_abandonment(city_xy, stlim, start_city, bee(ne+1:nb));
    
    % =============== Sorting Phase =============== 
    % Re-rank bees by their tour costs (ascending order)
    [~, idx] = sort([bee.cost]);
    bee = bee(idx);
    
    % =============== Saving Phase ===============
    % Update the best tour and cost if a better solution is found
    if i==1 || bee(1).cost < best_cost_iter(i-1)
        best_tour = bee(1).tour;
        best_cost_iter(i) = bee(1).cost;
    else
        best_cost_iter(i) = best_cost_iter(i-1);
    end
    
    % =============== Scout Bees Phase (Global Search) ===============
    % Assign new tour to the scout bee using Nearest Neighbor
    if mod(i,is) == 0 && start_city < nodes
        start_city = start_city + 1;
        bee(ns) = nn_tour_assign(city_xy, start_city, bee(ns));
    end
    
    % =============== Visualize Progress ===============
    visualize_progress(city_xy, best_tour, best_cost_iter(1:i), max_iter, visual_mode);
    
end % End of main loop
end