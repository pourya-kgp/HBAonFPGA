% ----------------------------------------------------------------------------------------------------
% Author        : Pourya Khodagholipour (P.KH)
% Project Name  : Implementation of Hardware Bee Algorithm (HBA) on FPGA for TSP (M.S. Thesis)
% File Name     : BCO.m
% Description   : Implements the Constructive Bee Colony Optimization algorithm (BCO) for solving 
%                 the Traveling Salesperson Problem (TSP)
% Creation Date : 2016/06
% Revision Date : 2025/03/05
% ----------------------------------------------------------------------------------------------------

function [best_tour, best_cost_iter] = BCO(city_xy, backward_pass_method, visual_mode, max_iter)

% BCO implements the Constructive Bee Colony Optimization algorithm (BCO) for solving the Traveling
% Salesperson Problem (TSP).
%
% This function applies the Bee Colony Optimization (BCO) algorithm, inspired by the foraging 
% behavior of bees, to find an optimal tour for the Traveling Salesperson Problem. The algorithm
% employs artificial bees that iteratively construct candidate solutions through forward and 
% backward passes. In the forward pass, bees explore the solution space by selecting nodes based
% on distance-derived probabilities. In the backward pass, bees evaluate and refine their solutions
% using either loyalty-based retention or random recruitment methods, mimicking the waggle dance of
% bees to share information. The process continues until a maximum number of iterations is reached,
% aiming to minimize the total tour cost.
%
% Inputs:
% - city_xy              : 2D matrix of TSP city coordinates
%                          - First row : X-coordinates of the cities.
%                          - Second row: Y-coordinates of the cities.
%                          - Number of columns equals the number of cities (nodes).
% - backward_pass_method : Backward pass method:
%                          - 'nonloyal': Random recruitment based on fitness probabilities.
%                          - 'loyal'   : Loyalty-based recruitment with probabilistic retention.
% - visual_mode          : Visualization mode:
%                          - 'skip' : Disable visualization.
%                          - 'disp' : Visualize progress.
% - max_iter             : Maximum number of iterations for the algorithm.
%
% Outputs:
% - best_tour      : Optimal tour (sequence of city indices) found by the algorithm
% - best_cost_iter : Vector containing the best tour cost at each iteration
%
% Parameters:
% - bees : Number of artificial bees in the hive.
% - nc   : Number of nodes each bee explores in a single forward pass.
%
% Note:
% - The algorithm plots the best tour and cost progression if visual_mode is set to 'disp'.
% - Requires external functions: bco_backward_pass, compute_tour_distances, roulette_wheel, 
%                                visualize_progress.
%
% Reference:
% - Davidović, T., Teodorović, D., & Šelmić, M., "Bee Colony Optimization Part I:
%   The Algorithm Overview", Yugoslav Journal of Operations Research, 25(1), pp 33–56, 2015.

% Total number of cities (nodes) in the TSP instance
nodes = length(city_xy);

% ------------------------------ Algorithm Parameters ------------------------------

bees = 10; % Number of artificial bees in the hive
nc = 2;    % Number of nodes each bee explores in a single forward pass (node counter)

% ------------------------------ Initialization ------------------------------

% Initialize the best tour with infinite values
best_tour = inf(1, nodes);

% Array to store the best cost found at each iteration
best_cost_iter = inf(1, max_iter);

% All bees start with a random permutation of cities
tours = repmat(1:nodes, bees, 1);

% ------------------------------ Main Algorithm Loop ------------------------------

for i = 1:max_iter
    
    % =============== Forward & Backward Passes Phase ===============
    
    % --------------- Initialization ---------------
    % Assign random initial tours to all bees
    for j = 1:bees
        tours(j,:) = randperm(nodes);
    end
    % Distances between current node and remaining available nodes
    node_to_node_distances = inf(bees, nodes-1);
    % Probabilities for selecting the next node
    prob_next_node = inf(bees, nodes-1);
    % Counter for completed forward passes
    forward_pass_counter = 0;
    % Current position in the tour sequence
    current_node = 1;
    
    % --------------- Forward & Backward Passes Loop ---------------
    while current_node <= nodes-2 % Last node has no choice, hence nodes-2
        
        % =============== Forward Pass Phase ===============
        forward_pass_node_counter = 1;
        while forward_pass_node_counter <= nc && current_node <= nodes-2
            for j = 1:bees
                % Compute distances from current node to all remaining nodes
                node_to_node_distances(j, current_node:end) = ...
                    compute_tour_distances(city_xy, 'first_dist', tours(j, current_node:end));
    
                % Calculate selection probabilities (convert to maximization problem)
                prob_next_node(j, current_node:end) = 1 ./ node_to_node_distances(j, current_node:end);
                prob_next_node(j, current_node:end) = ...
                    prob_next_node(j, current_node:end) ./ sum(prob_next_node(j, current_node:end));
    
                % Select next node using roulette wheel selection
                idx = roulette_wheel(prob_next_node(j, current_node:end));
                
                % Swap selected node with the next position in the tour
                [tours(j, current_node+1), tours(j, current_node+idx)] = ...
                    deal(tours(j,current_node+idx), tours(j,current_node+1));
            end
            forward_pass_node_counter = forward_pass_node_counter + 1;
            current_node = current_node + 1 ;
        end % End of forward pass loop
        
        forward_pass_counter = forward_pass_counter + 1; % Increment forward pass counter

        % Compute partial tour distances up to current node
        path_lengths = compute_tour_distances(city_xy, 'tour_dist', tours(:, 1:current_node));
        
        % =============== Backward Pass Phase ===============
        % Determine which bees to retain/recruit based on backward pass method
        bees_idx = bco_backward_pass(backward_pass_method, path_lengths, forward_pass_counter);
        % Update tours based on recruitment results
        tours = tours(bees_idx,:);
    end % End of tour construction phase
    
    % =============== Saving Phase ===============
    % Compute full tour distances and update best solution
    tour_lengths = compute_tour_distances(city_xy, 'full_tour', tours);
    [min_length, idx] = min(tour_lengths);
    if i==1 || min_length < best_cost_iter(i-1)
        best_tour = tours(idx(1),:);
        best_cost_iter(i) = min_length;
    else
        best_cost_iter(i) = best_cost_iter(i-1);
    end

    % =============== Visualize Progress ===============
    visualize_progress(city_xy, best_tour, best_cost_iter(1:i), max_iter, visual_mode);

end % End of main loop
end