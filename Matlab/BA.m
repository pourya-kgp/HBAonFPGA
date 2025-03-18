% ----------------------------------------------------------------------------------------------------
% Author        : Pourya Khodagholipour (P.KH)
% Project Name  : Implementation of Hardware Bee Algorithm (HBA) on FPGA for TSP (M.S. Thesis)
% File Name     : BA.m
% Description   : Implements the Bee Algorithm (BA) for solving the Traveling Salesperson Problem (TSP)
% Creation Date : 2016/06
% Revision Date : 2025/03/03
% ----------------------------------------------------------------------------------------------------

function [best_tour, best_cost_iter] = BA(city_xy, local_opt_method, visual_mode, max_iter)

% BA implements the Bee Algorithm (BA) to solve the Traveling Salesperson Problem (TSP).
%
% This script applies the Bee Algorithm, inspired by the foraging behavior of bees, to find
% near-optimal solutions to the TSP. The algorithm initializes a population of scout bees
% with Nearest Neighbor tours, iteratively improves them through elite and recruited bee
% phases using local optimization (2-Opt or GSTM), and employs site abandonment and global
% search to maintain diversity. The process tracks the best tour and visualizes progress.
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
% - ns    : Number of scout bees.
% - nb    : Number of selected sites.
% - ne    : Number of elite sites.
% - nrb   : Number of recruited bees for non-elite sites.
% - nre   : Number of recruited bees for elite sites.
% - stlim : Stagnation limit for site abandonment.
%
% Notes:
% - The algorithm plots the best tour and cost progression if visual_mode is set to 'disp'.
% - Requires external functions: nn_tour_assign, recruited_local_search, site_abandonment,
%                                visualize_progress.
%
% Reference:
% - Pham, D.T., Castellani, M., "The bee algorithm: modelling foraging behaviour to solve 
%   continuous optimization problems". Proceedings of the Institution of Mechanical Engineers,
%   Part C: Journal of Mechanical Engineering Science, Vol 223 Issue 12, pp. 2919-2938, 2009.

% Total number of cities (nodes) in the TSP instance
nodes = length(city_xy);

% ------------------------------ Algorithm Parameters ------------------------------

ns = 16;                   % Number of scout bees exploring the solution space
nb = round(ns/2);          % Number of selected sites (best tours) from scout bees (ns)
ne = round(nb/4);          % Number of elite sites (top-tier tours) from selected sites (nb)
nrb = round(ns/8);         % Number of recruited bees for remaining best sites (nb-ne)
nre = 2*nrb;               % Number of recruited bees for elite sites (ne)
stlim = round(ns*nodes/3); % Stagnation limit: maximum cycles before abandoning a site

% ------------------------------ Initialization ------------------------------

% Initialize a structure array to store bee information:
% - 'tour' : Sequence of cities visited by the bee.
% - 'cost' : Total distance of the tour.
% - 'trial': Number of iterations without improvement (used for site abandonment).
bee = repmat(struct('tour', [], 'cost', [], 'trial', []), ns, 1);

% Initialize the best tour with infinite values
best_tour = inf(1, nodes);

% Array to store the best cost found at each iteration
best_cost_iter = inf(1, max_iter);

% ------------------------------ Assign Nearest Neighbor Tour to Bees & Sort ------------------------------

% Assign initial tours to scout bees using the Nearest Neighbor heuristic
bee = nn_tour_assign(city_xy, 1, bee);
start_city = ns; % Track the starting city for subsequent Nearest Neighbor assignments

% Sort bees by their tour cost (ascending order)
[~, idx] = sort([bee.cost]);
bee = bee(idx);

% ------------------------------ Main Algorithm Loop ------------------------------

for i = 1:max_iter
        
    % =============== Elite Bees Phase ===============
    % Perform local search on elite bees (ne) with more recruited bees (nre)
    bee(1:ne) = recruited_local_search(city_xy, local_opt_method, nre, bee(1:ne));
    % Check for site abandonment and reinitialize if needed
    [bee(1:ne), start_city] = site_abandonment(city_xy, stlim, start_city, bee(1:ne));

    % =============== Remaining Selected Bees Phase ===============
    % Perform local search on remaining selected bees (nb-ne) with fewer recruited bees (nrb)
    bee(ne+1:nb) = recruited_local_search(city_xy, local_opt_method, nrb, bee(ne+1:nb));
    % Check for site abandonment and reinitialize if needed
    [bee(ne+1:nb), start_city] = site_abandonment(city_xy, stlim, start_city, bee(ne+1:nb));
    
    % =============== Scout Bees Phase (Global Search) ===============
    % Assign new tours to remaining scout bees using Nearest Neighbor
    if start_city < nodes % Prevent repetition of global search
        remain_nn_tour = nodes - start_city;
        last_bee = min(nb + remain_nn_tour, ns);
        start_city = start_city + 1;
        bee(nb+1:last_bee) = nn_tour_assign(city_xy, start_city, bee(nb+1:last_bee));
        start_city = start_city + last_bee - nb - 1;
    end
    
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
        
    % =============== Visualize Progress ===============
    visualize_progress(city_xy, best_tour, best_cost_iter(1:i), max_iter, visual_mode);
    
end % End of main loop
end