% ----------------------------------------------------------------------------------------------------
% Author        : Pourya Khodagholipour (P.KH)
% Project Name  : Implementation of Hardware Bee Algorithm (HBA) on FPGA for TSP (M.S. Thesis)
% File Name     : BCA_Evaluation.m
% Description   : Evaluates five Bee Colony Algorithms (BCAs) for solving the Traveling Salesperson
%                 Problem (TSP), including the following: BA, BCO, BCOi, CABC, and HBA.
% Creation Date : 2016/06
% Revision Date : 2025/03/05
% ----------------------------------------------------------------------------------------------------

% This script evaluates five Bee Colony Algorithms (BCAs) for solving the Traveling Salesperson
% Problem (TSP). The implemented algorithms include:
%   - BA   (Bee Algorithm)
%   - BCO  (Bee Colony Optimization): A constructive approach to build solutions.
%   - BCOi (Bee Colony Optimization improvement): An improving solution version of BCO.
%   - CABC (Combinatorial Artificial Bee Colony): A combinatorial adaptation of ABC.
%   - HBA  (Hardware Bee Algorithm): A novel algorithm proposed for hardware 
%                                    implementation (e.g., FPGA).
%
% The script allows customization of local optimization methods, visualization modes, TSP instances, 
% iteration limits, and BCO-specific backward pass methods. Results are displayed with the best
% tour, cost, and a comparison to the known optimal tour length.
%
% References:
% - BA:
%   Pham, D.T., Castellani, M., "The bee algorithm: modelling foraging behaviour to solve 
%   continuous optimization problems". Proceedings of the Institution of Mechanical Engineers,
%   Part C: Journal of Mechanical Engineering Science, Vol 223 Issue 12, pp. 2919-2938, 2009.
% - BCO & BCOi:
%   Davidović, T., Teodorović, D., & Šelmić, M., "Bee Colony Optimization Part I:
%   The Algorithm Overview", Yugoslav Journal of Operations Research, 25(1), pp 33–56, 2015.
% - BCOi:
%   Davidovic T., Ramljak D., Selmic M., Teodorovic D., "Bee colony optimization for the pp-center
%   problem". Computers & Operations Research. Volume 38, Issue 10, pp. 1367–1376 2011.
% - CABC:
%   Karaboga D., Gorkemli B., "A combinatorial artificial bee colony algorithm for traveling
%   salesman problem”, International Symposium on Innovations in Intelligent Systems and 
%   Applications (INISTA), pp. 50-53, 2011.

clearvars; close all; clc

% ------------------------------ Select Bee Colony Algorithm (BCA) ------------------------------

% Choose the BCA to evaluate from the following options:
% 'BA'   : Bee Algorithm
% 'BCO'  : Bee Colony Optimization (Constructive)
% 'BCOi' : Bee Colony Optimization improvement
% 'CABC' : Combinatorial Artificial Bee Colony
% 'HBA'  : Hardware Bee Algorithm (Proposed for hardware implementation)
bca_algorithm = 'CABC'; % Options: 'BA', 'BCO', 'BCOi', 'CABC', 'HBA'

% ------------------------------ Select Local Optimization Method ------------------------------

% Define the local optimization method to improve solutions:
% '2OPT': 2-Opt algorithm, improves tours by eliminating edge crossings.
% 'GSTM': Greedy Sub-Tour Mutation, enhances tours through greedy sub-tour modifications.
local_opt_method = '2OPT'; % Options: 'GSTM', '2OPT'

% ------------------------------ Select Visualization Progress Mode ------------------------------

% Set the visualization mode for the algorithm's execution:
% 'skip': Disables visualization during execution; only final results are shown.
% 'disp': Enables real-time plotting of the tour and cost progression at each iteration.
visual_mode = 'skip'; % Options: 'skip', 'disp'

% ------------------------------ Select TSP Instance ------------------------------

tsp_instance_name = 'st70'; % Set the TSP instance name

% ==================================================================================================
% Supported TSP Instance Names:
% a280     | d18512   | fl1577   | kroB150  | p654     | pr152    | rat783   | rl5934   | u2319    | 
% berlin52 | d198     | fl3795   | kroB200  | pcb1173  | pr226    | rat99    | st70     | u574     | 
% bier127  | d2103    | fl417    | kroC100  | pcb3038  | pr2392   | rd100    | ts225    | u724     | 
% brd14051 | d493     | fnl4461  | kroD100  | pcb442   | pr264    | rd400    | tsp225   | usa13509 | 
% ch130    | d657     | gil262   | kroE100  | pr1002   | pr299    | rl11849  | u1060    | vm1084   | 
% ch150    | eil101   | kroA100  | lin105   | pr107    | pr439    | rl1304   | u1432    | vm1748   | 
% d1291    | eil51    | kroA150  | lin318   | pr124    | pr76     | rl1323   | u159     |          | 
% d15112   | eil76    | kroA200  | linhp318 | pr136    | rat195   | rl1889   | u1817    |          | 
% d1655    | fl1400   | kroB100  | nrw1379  | pr144    | rat575   | rl5915   | u2152    |          | 
% ==================================================================================================

% ------------------------------ Select Algorithm Parameters ------------------------------

% Maximum number of iterations for the algorithm
max_iter = 3000;

% Backward pass method for BCO and BCOi algorithms:
% 'nonloyal': Random recruitment of bees.
% 'loyal'   : Recruitment based on loyalty to previous solutions.
backward_pass_method = 'loyal'; % Options: 'nonloyal', 'loyal'

% ------------------------------ Load TSP Data ------------------------------

% Load city coordinates for the selected TSP instance
[city_xy, ~, opt_tour_length, ~] = tsp_instance(tsp_instance_name);
% Alternative: Use Fortran-based TSP instance reader (uncomment if needed)
%[city_xy, ~, opt_tour_length, ~] = read_fortran_tsp_instance(tsp_instance_name);

% ------------------------------ Execute Bee Colony Algorithm (BCA) ------------------------------

switch bca_algorithm
    case 'BA'
        [best_tour, best_cost_iter] = ...
            BA(city_xy, local_opt_method, visual_mode, max_iter);
    case 'BCO' % Constructive approach
        [best_tour, best_cost_iter] = ...
            BCO(city_xy, backward_pass_method, visual_mode, max_iter);
    case 'BCOi'
        [best_tour, best_cost_iter] = ...
            BCOi(city_xy, backward_pass_method, local_opt_method, visual_mode, max_iter);
    case 'CABC'
        [best_tour, best_cost_iter] = ...
            CABC(city_xy, local_opt_method, visual_mode, max_iter);
    case 'HBA'
        [best_tour, best_cost_iter] = ...
            HBA(city_xy, local_opt_method, visual_mode, max_iter);
    otherwise
        error('Invalid algorithm name. Choose from: "BA", "BCO", "BCOi", "CABC", "HBA".');
end

% ------------------------------ Display Final Results ------------------------------

% Print the best tour obtained and its corresponding tour length (truncated for readability)
fprintf('\nAlgorithm: %s, Local Optimization Method: %s, TSP: %s ==>\n\n', ...
         bca_algorithm, local_opt_method, tsp_instance_name);
fprintf('Best Obtained Tour  = [%s ... ] (1×%d)\n', num2str(best_tour(1:10)), numel(best_tour));
fprintf('Least Obtained Cost = %g\n\n', best_cost_iter(end));
fprintf('Known Optimal Tour Length = %d\n', opt_tour_length);

% Plot the final best tour and cost progression, regardless of visualization mode
% result_figure(city_xy, best_tour, best_cost_iter, max_iter);

% Cleanup unused variables, retaining key results
clearvars -except best_tour best_cost_iter opt_tour_length tsp_instance_name