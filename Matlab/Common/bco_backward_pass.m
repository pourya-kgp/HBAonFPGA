% ----------------------------------------------------------------------------------------------------
% Author        : Pourya Khodagholipour (P.KH)
% Project Name  : Implementation of Hardware Bee Algorithm (HBA) on FPGA for TSP (M.S. Thesis)
% File Name     : bco_backward_pass.m
% Description   : Performs the backward pass phase of the Bee Colony Optimization algorithm (BCO)
% Creation Date : 2016/06
% Revision Date : 2025/03/05
% ----------------------------------------------------------------------------------------------------

function bees_idx = bco_backward_pass(backward_pass_method, cost_vector, num_forward_pass)

% BCO_BACKWARD_PASS performs the backward pass phase of the Bee Colony Optimization algorithm (BCO).
%
% This function implements the backward pass of the Bee Colony Optimization algorithm.
% It determines which bees' solutions are retained or recruited based on their cost,
% using either a 'nonloyal' or 'loyal' method.
%
% Inputs:
% - backward_pass_method : Backward pass method:
%                          - 'nonloyal': Random recruitment based on fitness probabilities.
%                          - 'loyal'   : Loyalty-based recruitment with probabilistic retention.
% - cost_vector          : Vector of costs for each bee.
% - num_forward_pass     : Number of completed forward passes.
%
% Output:
% - bees_idx : Indices of selected bees for the next iteration.
%
% Reference:
% - Davidović, T., Teodorović, D., & Šelmić, M. (2015). Bee Colony Optimization Part I:
%   The Algorithm Overview. Yugoslav Journal of Operations Research, 25(1), 33–56, 2015.

num_bees = numel(cost_vector);
bees_idx = zeros(size(cost_vector)); % Preallocate indices of selected bees

switch backward_pass_method
    case 'nonloyal'
        % Nonloyal method: All bees recruit randomly based on fitness
        fitness = 1 ./ cost_vector; % Convert cost to fitness (maximization)
        probability = fitness ./ sum(fitness);

        % Select bees using roulette wheel selection
        for i = 1:num_bees 
            bees_idx(i) = roulette_wheel(probability);
        end

    case 'loyal'
        % Loyal method: Some bees remain loyal to their solutions, others recruit
        % Compute normalized fitness based on costs
        fitness = (max(cost_vector) - cost_vector) ./ (max(cost_vector) - min(cost_vector));
        
        % Calculate loyalty probability (decreases with more forward passes)
        prob_loyalty = exp(-(max(fitness) - fitness) ./ num_forward_pass); 
        
        % Determine which bees remain loyal
        committed_bees = (rand(size(cost_vector)) <= prob_loyalty);
        num_committed_bees = sum(committed_bees);
        bees_idx(1:num_committed_bees) = find(committed_bees);
        
        % Recruit remaining bees from committed ones
        fitness_committed = fitness .* committed_bees;
        probability_committed = fitness_committed ./ sum(fitness_committed);

        % Select remaining bees using roulette wheel
        for i = num_committed_bees+1 : num_bees
            bees_idx(i) = roulette_wheel(probability_committed);
        end
        
    otherwise
        error('Incorrect backward pass name. Supported options are: "nonloyal", "loyal".');
end
end