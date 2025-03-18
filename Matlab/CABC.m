% ----------------------------------------------------------------------------------------------------
% Author        : Pourya Khodagholipour (P.KH)
% Project Name  : Implementation of Hardware Bee Algorithm (HBA) on FPGA for TSP (M.S. Thesis)
% File Name     : CABC.m
% Description   : Implements the Combinatorial Artificial Bee Colony algorithm (CABC) for solving 
%                 the Traveling Salesperson Problem (TSP)
% Creation Date : 2016/06
% Revision Date : 2025/03/04
% ----------------------------------------------------------------------------------------------------

function [best_tour, best_cost_iter] = CABC(city_xy, local_opt_method, visual_mode, max_iter)

% CABC implements the Combinatorial Artificial Bee Colony algorithm (CABC) for solving the Traveling
% Salesperson Problem (TSP).
%
% This function implements the Combinatorial Artificial Bee Colony (CABC) algorithm to solve the 
% Traveling Salesperson Problem (TSP). The algorithm simulates the foraging behavior of honey bees, 
% utilizing employed bees, onlooker bees, and scout bees to iteratively optimize a tour across a set 
% of cities, minimizing the total travel distance. It integrates local optimization techniques to 
% enhance solution quality and employs a nearest neighbor heuristic for initialization.
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
% - cs    : Number of colony size (Employed bees + Onlooker bees).
% - ne    : Number of employed bees.
% - ns    : Number of scout bees (fixed at one scout bee in this implementation).
% - stlim : Stagnation limit for site abandonment (cycles before a solution is abandoned).
% 
% Notes:
% - The algorithm plots the best tour and cost progression if visual_mode is set to 'disp'.
% - Requires external functions: nn_tour_assign, recruited_local_search, site_abandonment,
%                                roulette_wheel, visualize_progress.
%   
% Reference:
% - Karaboga D., Gorkemli B., "A combinatorial artificial bee colony algorithm for traveling
%   salesman problem”, International Symposium on Innovations in Intelligent Systems and 
%   Applications (INISTA), pp. 50-53, 2011.

% Total number of cities (nodes) in the TSP instance
nodes = length(city_xy);

% ------------------------------ Algorithm Parameters ------------------------------

cs = 20;                   % Colony size: total number of employed and onlooker bees
ne = round(cs/2);          % Number of employed bees (half of colony size)
stlim = round(cs*nodes/3); % Stagnation limit: maximum cycles before abandoning a site

% ------------------------------ Initialization ------------------------------

% Initialize a structure array to store bee information:
% - 'tour' : Sequence of cities visited by the bee.
% - 'cost' : Total distance of the tour.
% - 'trial': Number of iterations without improvement (used for site abandonment).
bee = repmat(struct('tour', [], 'cost', [], 'trial', []), ne, 1);

% Initialize the best tour with infinite values
best_tour = inf(1, nodes);

% Array to store the best cost found at each iteration
best_cost_iter = inf(1, max_iter);

% ------------------------------ Assign Nearest Neighbor Tour to Bees ------------------------------

% Assign initial tours to employed bees using the Nearest Neighbor heuristic
bee = nn_tour_assign(city_xy, 1, bee);
start_city = ne; % Track the starting city for subsequent Nearest Neighbor assignments

% ------------------------------ Main Algorithm Loop ------------------------------

for i = 1:max_iter
    
    % =============== Employed Bees Phase ===============
    % Perform a local search to improve each employed bees (ne)
    bee = recruited_local_search(city_xy, local_opt_method, 1, bee);
    
    % =============== Fitness & Probability Calculation Phase ===============
    % Compute fitness values based on tour costs (higher fitness for lower costs)
    fitness = 1 ./ (1 + [bee.cost]);
    % Calculate selection probabilities for onlooker bees (normalized with a minimum of 0.1)
    probability = 0.9 .* fitness ./ max(fitness) + 0.1;
        
    % =============== Onlooker Bees Phase ===============
    for on_looker = ne+1:cs 
        % Select an employed bee using roulette-wheel selection based on probabilities
        selected_bee = roulette_wheel(probability);
        % Perform local search on the selected bee's tour
        bee(selected_bee) = recruited_local_search(city_xy, local_opt_method, 1, bee(selected_bee));
    end
    
    % =============== Site Abandonment Phase ===============
    % Check for stagnant solutions and replace them with new ones if the trial limit is exceeded
    [~, idx] = max([bee.trial]);
    if bee(idx(1)).trial >= stlim
        [bee(idx(1)), start_city] = site_abandonment(city_xy, stlim, start_city, bee(idx(1)));
    end

    % =============== Saving Phase ===============
    % Update the best tour and cost if a better solution is found
    [~, idx] = min([bee.cost]);
    if i==1 || bee(idx(1)).cost < best_cost_iter(i-1)
        best_tour = bee(idx(1)).tour;
        best_cost_iter(i) = bee(idx(1)).cost;
    else
        best_cost_iter(i) = best_cost_iter(i-1);
    end
     
    % =============== Visualize Progress ===============
    visualize_progress(city_xy, best_tour, best_cost_iter(1:i), max_iter, visual_mode);
    
end % End of main loop
end