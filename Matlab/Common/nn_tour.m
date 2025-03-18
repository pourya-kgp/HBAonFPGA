% ----------------------------------------------------------------------------------------------------
% Author        : Pourya Khodagholipour (P.KH)
% Project Name  : Implementation of Hardware Bee Algorithm (HBA) on FPGA for TSP (M.S. Thesis)
% File Name     : nn_tour.m
% Description   : Constructs nearest neighbor tours for the TSP using an optimized approach.
%                 Generates multiple nearest neighbor tours starting from given or default cities.
% Creation Date : 2016/06
% Revision Date : 2025/02/18
% ----------------------------------------------------------------------------------------------------

function tours = nn_tour(city_xy, num_tours, start_city)

% NN_TOUR constructs nearest neighbor tours for the given TSP instance.
%
% Inputs:
% - city_xy    : 2D matrix of TSP city coordinates
%                - First row : X-coordinates of the cities.
%                - Second row: Y-coordinates of the cities.
%                - Number of columns equals the number of cities (nodes).
% - num_tours  : Number of tours to generate.
% - start_city : (Optional) Starting city index for the first tour; increments for each tour.
%
% Outputs:
% - tours      : A matrix where each row represents a nearest neighbor tour.

% ------------------------------ Input Validation ------------------------------

if nargin < 2
    num_tours = 1; % Default: One tour
end

if nargin < 3    
    start_city = 1; % Default: Start from city 1
end

% ------------------------------ Initialization ------------------------------

city_x = city_xy(1,:); % X coordinates
city_y = city_xy(2,:); % Y coordinates
num_cities = length(city_xy); % Total number of cities in the instance
tours = repmat(1:num_cities, [num_tours, 1]); % Initialize tours with city indices

% ------------------------------ Nearest Neighbor Tour Construction ------------------------------

for i = 1:num_tours
    
    % Ensure start_city does not exceed available cities
    if start_city > num_cities
        start_city = 1;
    end
    
    % Swap the first city in the row with the starting city
    [tours(i,1), tours(i,start_city)] = deal(tours(i,start_city), tours(i,1));
    
    % Increment start_city for the next nearest neighbor tour
    start_city = start_city + 1;
    
    % Construct the nearest neighbor tour
    for j = 1:num_cities-2 % Last city is automatically placed
        % Compute distances
        distances(j:num_cities-1) = sqrt((city_x(tours(i,j)) - city_x(tours(i,j+1:end))).^2 + ...
                                         (city_y(tours(i,j)) - city_y(tours(i,j+1:end))).^2);
        
        % Find the nearest neighbor
        [~, index] = min(distances(j:end));
        
        % Swap the closest city into the next position
        [tours(i,j+1), tours(i,j+index)] = deal(tours(i,j+index), tours(i,j+1));
    end
end

end