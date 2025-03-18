% ----------------------------------------------------------------------------------------------------
% Author        : Pourya Khodagholipour (P.KH)
% Project Name  : Implementation of Hardware Bee Algorithm (HBA) on FPGA for TSP (M.S. Thesis)
% File Name     : gstm.m
% Description   : Implements the Greedy Sub-Tour Mutation (GSTM) for TSP optimization
% Creation Date : 2016/06
% Revision Date : 2025/02/20
% ----------------------------------------------------------------------------------------------------

function tour_out = gstm(city_xy, tour_in)

% GSTM implements the Greedy Sub-Tour Mutation (GSTM) for TSP optimization.
%
% This function selects a random sub-tour and attempts to reconnect it to the
% main tour using a combination of greedy or correction & perturbation strategies.
% The greedy reconnection process was modified from the original GSTM method by using
% midpoints of edges instead of evaluating every possible insertion position.
% This modification reduces execution time while maintaining competitive results.
%
% Inputs:
% - city_xy  : 2D matrix of TSP city coordinates
%              - First row : X-coordinates of the cities.
%              - Second row: Y-coordinates of the cities.
%              - Number of columns equals the number of cities (nodes).
% - tour_in  : Vector representing the current tour (sequence of city indices).
%
% Output:
% - tour_out : Updated tour after applying the GSTM mutation.
%
% References:
% Albayrak, M., Allahverdi, N., "Development of a new mutation operator
% to solve the Traveling Salesman Problem by aid of Genetic Algorithms."
% Expert Systems with Applications, vol. 38, no. 3, pp. 1313-1320, 2011.

% Validate input dimensions
if length(tour_in) ~= length(city_xy)
    error('The size of tour_in must match the number of city coordinates.')
end

% ------------------------------ Step 1: Initialization ------------------------------

city_x = city_xy(1,:); % X coordinates
city_y = city_xy(2,:); % Y coordinates
num_cities = numel(tour_in); % Total number of cities in the instance

% GSTM parameters
p_rc = 0.5; % Reconnection probability
p_cp = 0.8; % Correction & perturbation probability
p_l  = 0.2; % Linearity probability
nl_max = 5; % Neighborhood list size
l_min = 2;  % Minimum sub-tour length
l_max = round(sqrt(num_cities)); % Maximum sub-tour length

% ------------------------------ Step 2: Select a random sub-tour ------------------------------

r1 = randi(num_cities); % Randomly select starting city (R1)
r2 = r1;

% Ensure R2 is within the valid range of sub-tour length
while abs(r2-r1) < l_min || abs(r2-r1) > l_max
    r2 = randi(num_cities); % Randomly select the ending city (R2)
end

% Ensure R1 < R2 for consistent indexing
if r1 > r2
    [r1, r2] = deal(r2, r1);
end

% ------------------------------ Step 3: Decide reconnecting type ------------------------------

% Precompute city coordinates for the entire tour to avoid redundant indexing later
city_x_tour = city_x(tour_in); % X coordinates of the cities in the current tour
city_y_tour = city_y(tour_in); % Y coordinates of the cities in the current tour

% Extract the sub-tour
sub_tour = tour_in(r1:r2);

if rand <= p_rc % Reconnection using the modified greedy approach
    
    % Remove the selected sub-tour
    closed_tour = tour_in;   % Create a copy of the original tour
    closed_tour(r1:r2) = []; % Remove the selected sub-tour (between R1 and R2) from the tour
    
    % Convert tour to a closed cycle by appending the first city at the end
    closed_tour = [closed_tour, closed_tour(1)];
        
    % Compute midpoints for all edges in the closed tour
    city_x_medians = (city_x(closed_tour(1:end-1)) + city_x(closed_tour(2:end)))./2; % X coordinates of midpoints
    city_y_medians = (city_y(closed_tour(1:end-1)) + city_y(closed_tour(2:end)))./2; % Y coordinates of midpoints
    
    % Compute distances from R1 and R2 to all midpoints
    dist2r1 = sqrt((city_x_tour(r1) - city_x_medians).^2 + (city_y_tour(r1) - city_y_medians).^2); % Distances to R1
    dist2r2 = sqrt((city_x_tour(r2) - city_x_medians).^2 + (city_y_tour(r2) - city_y_medians).^2); % Distances to R2
    
    % Select the insertion point based on the minimum combined distance
    [~, ind] = min(dist2r1 + dist2r2);
    
    % Insert the sub-tour at the best location found
    tour_out = [closed_tour(1:ind), sub_tour, closed_tour(ind+1:end-1)];

else
    if rand <= p_cp % Correction & Perturbation
        % Insert each element of the sub-tour into the tour,  
        % starting from position R1, using either rolling or mixing based on p_l probability.
        
        tour_out = tour_in;
        w = r1;
        while ~isempty(sub_tour)
            if rand <= p_l % Mixing strategy
                % Insert a randomly selected city from the sub-tour into position w of the tour
                idx = randi(length(sub_tour));
                tour_out(w) = sub_tour(idx);
                sub_tour(idx) = []; % Remove selected element
            else           % Rolling strategy
                % Insert the last city of the sub-tour into position w of the tour
                tour_out(w) = sub_tour(end);
                sub_tour(end) = []; % Remove last element
            end
            w = w + 1;
        end
    
    else % Swap Neighboring Elements in the Tour
        
        % Compute distances of all cities to R1 and R2
        dist2r1 = sqrt((city_x_tour(r1) - city_x_tour).^2 + (city_y_tour(r1) - city_y_tour).^2);
        dist2r1(r1) = inf;
        dist2r2 = sqrt((city_x_tour(r2) - city_x_tour).^2 + (city_y_tour(r2) - city_y_tour).^2);
        dist2r2(r2) = inf;
        
        % Sort and randomly select the nearest neighbors for R1 and R2 (NLR1 and NLR2).
        [~, idx1] = sort(dist2r1);
        [~, idx2] = sort(dist2r2);
        nl_r1 = idx1(randi(nl_max));
        nl_r2 = idx2(randi(nl_max));
        
        % Append the first element to the end to prevent indexing errors  
        % when R1, R2, NLR1, or NLR2 are the last elements in the tour.
        dist2r1 = [dist2r1, dist2r1(1)];
        dist2r2 = [dist2r2, dist2r2(1)];
        city_x_tour = [city_x_tour, city_x_tour(1)];
        city_y_tour = [city_y_tour, city_y_tour(1)];

        % Compute the gain of swapping neighbors
        gr1 = dist2r1(r1+1)  + sqrt((city_x_tour(nl_r1) - city_x_tour(nl_r1+1)).^2 + (city_y_tour(nl_r1) - city_y_tour(nl_r1+1)).^2) - ...
              dist2r1(nl_r1) - sqrt((city_x_tour(r1+1)  - city_x_tour(nl_r1+1)).^2 + (city_y_tour(r1+1)  - city_y_tour(nl_r1+1)).^2);
        gr2 = dist2r2(r2+1)  + sqrt((city_x_tour(nl_r2) - city_x_tour(nl_r2+1)).^2 + (city_y_tour(nl_r2) - city_y_tour(nl_r2+1)).^2) - ...
              dist2r2(nl_r2) - sqrt((city_x_tour(r2+1)  - city_x_tour(nl_r2+1)).^2 + (city_y_tour(r2+1)  - city_y_tour(nl_r2+1)).^2);
        
        % Apply inversion based on maximum gain
        if gr1 > gr2
            if nl_r1 < r1
                tour_out = [tour_in(1:nl_r1-1), flip(tour_in(nl_r1:r1-1)), tour_in(r1:end)];
            else
                tour_out = [tour_in(1:r1)     , flip(tour_in(r1+1:nl_r1)), tour_in(nl_r1+1:end)];
            end
        else
            if nl_r2 < r2
                tour_out = [tour_in(1:nl_r2-1), flip(tour_in(nl_r2:r2-1)), tour_in(r2:end)];
            else
                tour_out = [tour_in(1:r2)     , flip(tour_in(r2+1:nl_r2)), tour_in(nl_r2+1:end)];
            end
        end
    end
end
    
end