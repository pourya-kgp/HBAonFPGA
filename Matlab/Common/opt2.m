% ----------------------------------------------------------------------------------------------------
% Author        : Pourya Khodagholipour (P.KH)
% Project Name  : Implementation of Hardware Bee Algorithm (HBA) on FPGA for TSP (M.S. Thesis)
% File Name     : opt2.m
% Description   : Performs a single iteration of the 2-Opt optimization for TSP
% Creation Date : 2016/06
% Revision Date : 2025/02/19
% ----------------------------------------------------------------------------------------------------

function tour_out = opt2(city_xy, tour_in)

% OPT_2 performs a single iteration of the 2-Opt optimization for TSP.
%
% This function selects two random cities in the tour and identifies the four 
% corresponding edges. It then assesses whether swapping the intermediate segment 
% results in a shorter tour. If the swap reduces the total distance, the new tour 
% is accepted; otherwise, the original tour remains unchanged.
%
% Inputs:
% - city_xy  : 2D matrix of TSP city coordinates
%              - First row : X-coordinates of the cities.
%              - Second row: Y-coordinates of the cities.
%              - Number of columns equals the number of cities (nodes).
% - tour_in  : Vector representing the current tour (sequence of city indices).
%
% Output:
% - tour_out : Updated tour after a possible 2-Opt swap.

if length(tour_in) ~= length(city_xy)
    error('The size of tour_in must match the number of city coordinates.')
end

% ------------------------------ Step 1: Initialization ------------------------------

city_x = city_xy(1,:); % X coordinates
city_y = city_xy(2,:); % Y coordinates
num_cities = numel(tour_in); % Total number of cities in the instance

% 2-Opt parameters
l_min = 3;              % Minimum separation between two swap points
l_max = num_cities - 1; % Maximum separation to prevent full reversal

% ------------------------------ Step 2: Randomly Select Two Swap Points ------------------------------

r1 = randi(num_cities); % Select the first city randomly
r2 = r1;

% Ensure r2 is within valid swap range
while abs(r2-r1) < l_min || abs(r2-r1) > l_max
    r2 = randi(num_cities);
end

% Ensure r1 < r2 for consistent indexing
if r1 > r2
    [r1, r2] = deal(r2, r1);
end
    
% ------------------------------ Step 3: Compute Distances ------------------------------

% Precompute city coordinates for the tour
tour_x = city_x(tour_in);
tour_y = city_y(tour_in);

% Compute the two original distances
% The two original edges: (A → B) and (C → D)
ab_dist = sqrt((tour_x(r1) - tour_x(r1+1))^2 + (tour_y(r1) - tour_y(r1+1))^2);
cd_dist = sqrt((tour_x(r2) - tour_x(r2-1))^2 + (tour_y(r2) - tour_y(r2-1))^2);
original_distance = ab_dist + cd_dist;

% Compute the potential swapped distances
% The new edges after the swap: (A → C) and (B → D)  
ac_dist = sqrt((tour_x(r1) - tour_x(r2-1))^2 + (tour_y(r1) - tour_y(r2-1))^2);
bd_dist = sqrt((tour_x(r2) - tour_x(r1+1))^2 + (tour_y(r2) - tour_y(r1+1))^2);
new_distance = ac_dist + bd_dist;

% --------------------------- Step 4: Swap If Beneficial ------------------------------

if new_distance < original_distance
    % Perform the swap (reverse the segment between r1 and r2)
    tour_out = [tour_in(1:r1), flip(tour_in(r1+1:r2-1)), tour_in(r2:end)]; 
else
    % No improvement, return the original tour
    tour_out = tour_in;
end

end