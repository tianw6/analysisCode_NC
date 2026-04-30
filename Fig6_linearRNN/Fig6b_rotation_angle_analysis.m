%%%%%%%%%%%%%%%%%%%%
% This code plots Fig 6d
% Sweep rotation angles for rotating_input_symmetric model
% Calculate color and action variance explained from dpca


clear; close all;

%% Setup
rotation_angles = 0:5:360;  % Sweep from 0 to 360 in 10-degree steps
n_angles = length(rotation_angles);

% Storage for results (dPCA marginalizations)
var_stimulus = zeros(n_angles, 1);    % Stimulus 
var_decision = zeros(n_angles, 1);    % Decision 
var_ci = zeros(n_angles, 1);          % C.I.
var_interaction = zeros(n_angles, 1); % S/D interacation

%% dPCA parameters (same as in XORModel3.dPCA method)
combinedParams = {{1, [1 3]}, {2, [2 3]}, {3}, {[1 2], [1 2 3]}};

%% Sweep through rotation angles
for i = 1:n_angles
    angle = rotation_angles(i);
    
    fprintf('Testing angle: %.0f degrees (%d/%d)\n', angle, i, n_angles);
    
    % Create model with rotating_input_symmetric at this angle
    model = XORModel3('rotating_input_symmetric', angle);
    
    % Simulate
    model.simulate();
    
    % Prepare data in dPCA format
    N = model.N;
    n_time = length(model.time);
    firingRatesAverage = zeros(N, 2, 2, n_time);
    

    firingRatesAverage(:,1,1,:) = model.all_x(:,:,1);  % RL
    firingRatesAverage(:,2,2,:) = model.all_x(:,:,2);  % RR
    firingRatesAverage(:,1,2,:) = model.all_x(:,:,3);  % GL
    firingRatesAverage(:,2,1,:) = model.all_x(:,:,4);  % GR
    
    % Add small noise to avoid numerical issues
    firingRatesAverage = firingRatesAverage + 0.001*randn(size(firingRatesAverage));
    
    % Run dPCA
    [W, V, whichMarg] = dpca(firingRatesAverage, 10, ...
        'combinedParams', combinedParams);
    
    % Compute explained variance
    explVar = dpca_explainedVariance(firingRatesAverage, W, V, ...
        'combinedParams', combinedParams);
    
    % Store results
    var_stimulus(i) = explVar.totalMarginalizedVar(1) / explVar.totalVar*100;      % Stimulus 
    var_decision(i) = explVar.totalMarginalizedVar(2) / explVar.totalVar*100;      % Decision 
    var_ci(i) = explVar.totalMarginalizedVar(3) / explVar.totalVar*100;            % Condition-independent
    var_interaction(i) = explVar.totalMarginalizedVar(4) / explVar.totalVar*100;   % S/D Interaction

end

fprintf('\nSweep complete!\n');


%% 

figure('Position', [10 10 800 450]); hold on

plot(rotation_angles, var_stimulus, 'm')
plot(rotation_angles, var_decision, 'b')
legend('stimulus', 'choice')
xline(65)
xlim([0 90])
% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig6/', 'rotation_angle_variance', '.eps']);
