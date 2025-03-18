% ----------------------------------------------------------------------------------------------------
% Author        : Pourya Khodagholipour (P.KH)
% Project Name  : Implementation of Hardware Bee Algorithm (HBA) on FPGA for TSP (M.S. Thesis)
% File Name     : compute_tour_distances.m
% Description   : Computes the Euclidean distances for various scenarios in a TSP
% Creation Date : 2016/06
% Revision Date : 2025/02/18
% ----------------------------------------------------------------------------------------------------

function distances = compute_tour_distances(city_xy, distance_type, tours)

% COMPUTE_TOUR_DISTANCES calculates Euclidean distances based on the specified type.
%
% Inputs:
% - city_xy        : 2D matrix of TSP city coordinates
%                    - First row : X-coordinates of the cities.
%                    - Second row: Y-coordinates of the cities.
%                    - Number of columns equals the number of cities (nodes).
% - tours          : Matrix where each row represents a sequence of city indices defining a tour.
% - distance_type  : Specifies the type of distance calculation. Possible values:
%   - 'first_dist' : Computes distances from the first city to all others in each tour.
%   - 'tour_dist'  : Computes the total Euclidean distance along the tour (excluding return to start).
%   - 'full_tour'  : Computes the total Euclidean distance along the complete tour (including return).
%   - 'dist_mat'   : Computes the heuristic distance matrix for all city pairs.
%
% Output:
% - distances      : A matrix or vector containing computed distances based on the selected type.

city_x = city_xy(1,:); % X coordinates
city_y = city_xy(2,:); % Y coordinates

switch distance_type
    case 'first_dist'
        % Preallocate distances matrix (each row represents distances from the first city in the tour)
        distances = zeros(size(tours,1), size(tours,2)-1);
        % Compute distances from the first city to all others in the tour
        for i = 1:size(distances,1)
            distances(i,:) = sqrt((city_x(tours(i,1)) - city_x(tours(i,2:end))).^2 + ...
                                  (city_y(tours(i,1)) - city_y(tours(i,2:end))).^2);
        end
        
    case 'tour_dist'
        % Compute the Euclidean distance between consecutive nodes in the tour
        node_to_node_distances = compute_pairwise_distances(city_x, city_y, tours);
        % Sum distances along the tour (excluding return to the starting city)
        distances = sum(node_to_node_distances(:,1:end-1),2);
    
    case 'full_tour'
        % Compute the Euclidean distance between consecutive nodes in the tour
        node_to_node_distances = compute_pairwise_distances(city_x, city_y, tours);
        % Sum distances along the complete tour (including return to start)
        distances = sum(node_to_node_distances,2);
    
    case 'dist_mat'
        % Compute the heuristic distance matrix
        distances = compute_distance_matrix(city_x, city_y);
        
    otherwise
        % Handle invalid input types
        error('Incorrect Type Name. Supported types: "first_dist", "tour_dist", "full_tour", "dist_mat".');
end

end

% ========================================= Local Functions =========================================

function node_to_node_distances = compute_pairwise_distances(city_x, city_y, tours)
    % COMPUTE_PAIRWISE_DISTANCES computes the Euclidean distance between consecutive nodes in a tour.
    %
    % Inputs:
    % - city_x : Vector of X coordinates of the cities.
    % - city_y : Vector of Y coordinates of the cities.
    % - tours  : Matrix where each row represents a sequence of city indices.
    %
    % Output:
    % - node_to_node_distances : Matrix where each row contains distances between consecutive cities in a tour.
    
    % Rotate tours to compute distances between consecutive nodes
    tours_rotated  = [tours(:,2:end) , tours(:,1)]; % Shift columns left, cycling the first column to the end
    % Compute Euclidean distances between consecutive nodes
    node_to_node_distances = sqrt((city_x(tours) - city_x(tours_rotated)).^2 + ...
                                  (city_y(tours) - city_y(tours_rotated)).^2);
end

function distance_matrix = compute_distance_matrix(city_x, city_y)
    % COMPUTE_DISTANCE_MATRIX computes the heuristic distance matrix between all cities.
    %
    % Inputs:
    % - city_x : Vector of X coordinates of the cities.
    % - city_y : Vector of Y coordinates of the cities.
    %
    % Output:
    % - distance_matrix : Square matrix where (i,j) represents the Euclidean distance between city i and city j.
    
    % Compute pairwise Euclidean distances
    [X1, X2] = meshgrid(city_x, city_x);
    [Y1, Y2] = meshgrid(city_y, city_y);
    distance_matrix = sqrt((X1 - X2).^2 + (Y1 - Y2).^2);
    distance_matrix(eye(size(distance_matrix))==1) = inf; % Set diagonal to infinity
end