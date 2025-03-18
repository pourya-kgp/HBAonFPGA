% ----------------------------------------------------------------------------------------------------
% Author        : Pourya Khodagholipour (P.KH)
% Project Name  : Implementation of Hardware Bee Algorithm (HBA) on FPGA for TSP (M.S. Thesis)
% File Name     : BCOi.m
% Description   : Implements the Bee Colony Optimization improvement algorithm (BCOi) for solving 
%                 the Traveling Salesperson Problem (TSP)
% Creation Date : 2016/06
% Revision Date : 2025/03/05
% ----------------------------------------------------------------------------------------------------

function [best_tour, best_cost_iter] = ...
            BCOi(city_xy, backward_pass_method, local_opt_method, visual_mode, max_iter)

% Implements the Bee Colony Optimization improvement Algorithm (BCOi) for solving 
% the Traveling Salesperson Problem (TSP).
% 
% This function implements an enhanced version of the BCOi (Bee Colony Optimization improvement),
% designed to solve the Traveling Salesperson Problem (TSP). Inspired by the foraging behavior
% of bees, BCOi integrates forward and backward passes with local optimization techniques and
% introduces a global search mechanism using a scout bee strategy. The algorithm builds upon
% foundational BCOi concepts while addressing limitations in global exploration.
%
% Key Features:
% - Initialization: Uses Nearest Neighbor (NN) heuristic to assign initial tours to bees.
% - Local Search: Employs either 2-Opt or Greedy Sub-Tour Mutation (GSTM) for tour improvement.
% - Backward Pass: Supports 'nonloyal' (random recruitment) or 'loyal' (loyalty-based recruitment)
%   strategies to retain or reassign bee solutions.
% - Global Search (Novel Contribution): Introduces a scout bee mechanism where the bee with the
%   worst cost is replaced by a new Nearest Neighbor solution in each iteration, systematically
%   exploring all available NN starting points until exhausted.
% - Visualization: Optional real-time plotting of the best tour and cost progression.
%
% Inputs:
% - city_xy              : 2D matrix of TSP city coordinates
%                          - First row : X-coordinates of the cities.
%                          - Second row: Y-coordinates of the cities.
%                          - Number of columns equals the number of cities (nodes).
% - backward_pass_method : Backward pass method:
%                          - 'nonloyal': Random recruitment based on fitness probabilities.
%                          - 'loyal'   : Loyalty-based recruitment with probabilistic retention.
% - local_opt_method     : Local optimization method:
%                          - '2OPT' : 2-Opt for edge exchange.
%                          - 'GSTM' : Greedy Sub-Tour Mutation.
% - visual_mode          : Visualization mode:
%                          - 'skip' : Disable visualization.
%                          - 'disp' : Visualize progress.
% - max_iter             : Maximum number of iterations for the algorithm.
%
% Outputs:
% - best_tour      : Optimal tour (sequence of city indices) found by the algorithm.
% - best_cost_iter : Vector containing the best tour cost at each iteration.
%
% Parameters:
% - bees : Number of artificial bees in the hive.
% - nfp  : Number of forward passes per iteration.
%
% Notes:
% - The scout bee global search enhances exploration by systematically substituting the
%   worst-performing bee with a new NN solution, addressing the lack of global search.
% - The algorithm plots the best tour and cost progression if visual_mode set to 'disp'.
% - Requires external functions: nn_tour_assign, recruited_local_search, bco_backward_pass, 
%                                visualize_progress.
%
% References:
% - Davidović, T., Teodorović, D., & Šelmić, M., "Bee Colony Optimization Part I:
%   The Algorithm Overview", Yugoslav Journal of Operations Research, 25(1), pp 33–56, 2015.
% - Davidović, T., Ramljak, D., Šelmić, M., & Teodorović, D., "Bee Colony Optimization for the 
%   p-Center Problem", Computers & Operations Research, Volume 38, Issue 10, pp. 1367–1376, 2011.

% Total number of cities (nodes) in the TSP instance
nodes = length(city_xy);

% ------------------------------ Algorithm Parameters ------------------------------

bees = 10; % Number of artificial bees in the hive
nfp = 2;   % Number of forward passes per iteration

% ------------------------------ Initialization ------------------------------

% Initialize a structure array to store bee information:
% - 'tour' : Sequence of cities visited by the bee.
% - 'cost' : Total distance of the tour.
% - 'trial': Number of iterations without improvement (used for site abandonment).
bee = repmat(struct('tour', [], 'cost', [], 'trial', []), bees, 1);

% Initialize the best tour with infinite values
best_tour = inf(1, nodes);

% Array to store the best cost found at each iteration
best_cost_iter = inf(1, max_iter);

% ------------------------------ Assign Nearest Neighbor Tours to Bees ------------------------------

% Assign initial tours to bees using the Nearest Neighbor heuristic
bee = nn_tour_assign(city_xy, 1, bee);
start_city = bees; % Track the starting city for subsequent Nearest Neighbor assignments

% ------------------------------ Main Algorithm Loop ------------------------------

for i = 1:max_iter
    
    % =============== Forward & Backward Passes Phase ===============
    for forward_pass_counter = 1:nfp 
        % =============== Forward Pass Phase ===============
        % Perform a local search to improve each bee's tour
        bee = recruited_local_search(city_xy, local_opt_method, 1, bee);
        
        % =============== Backward Pass Phase ===============
        % Determine which bees to retain/recruit based on backward pass method
        bees_idx = bco_backward_pass(backward_pass_method, [bee.cost], forward_pass_counter);
        % Update bees based on recruitment results
        bee = bee(bees_idx);
    end
    
    % =============== Scout Bee Phase (Global Search) ===============
    % Replace the worst-performing bee's tour with a new Nearest Neighbor tour
    if start_city < nodes % Prevent repetition of global search
        [~, idx] = max([bee.cost]); % Find the bee with the highest (worst) cost (tour length)
        start_city = start_city + 1; % Increment starting city
        bee(idx(1)) = nn_tour_assign(city_xy, start_city, bee(idx(1)));
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