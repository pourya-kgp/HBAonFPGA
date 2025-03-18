% ----------------------------------------------------------------------------------------------------
% Author        : Pourya Khodagholipour (P.KH)
% Project Name  : Implementation of Hardware Bee Algorithm (HBA) on FPGA for TSP (M.S. Thesis)
% File Name     : roulette_wheel.m
% Description   : Implements the Roulette Wheel Selection method
% Creation Date : 2016/06
% Revision Date : 2025/02/17
% ----------------------------------------------------------------------------------------------------

function index = roulette_wheel(prob_dist)

% ROULETTE_WHEEL implements the Roulette Wheel Selection method.
%
% It selects an index based on the probability distribution PROB_DIST,
% which represents the selection probabilities.
%
% Input:
% - prob_dist : A probability vector where each element represents the probability of
%               selecting that index. The sum of all elements in prob_dist must be 1.
%
% Output:
% - index     : The selected index based on the roulette wheel mechanism.
%
% Algorithm:
% 1. Randomly select a starting position on the probability wheel.
% 2. Generate a random threshold to determine the selection.
% 3. Traverse through the probability vector, accumulating values until the threshold is reached.
%
% Example:
% prob_dist = [0.1, 0.3, 0.4, 0.2]; 
% index = roulette_wheel(prob_dist);
% This randomly selects an index based on the given probabilities.

% ------------------------------ Step 1: Random Start ------------------------------

index = randi(numel(prob_dist));  % Choose a random starting index
sum_prob_dist = prob_dist(index); % Initialize sum with the chosen probability
threshold = rand;                 % Generate a random threshold in [0,1]

% ------------------------------ Step 2: Spin the Wheel ------------------------------

while sum_prob_dist < threshold
    if index < numel(prob_dist)
        index = index + 1; % Move to the next index
    else
        index = 1; % Wrap around to the beginning
    end
    sum_prob_dist = sum_prob_dist + prob_dist(index); % Accumulate probability
end

end