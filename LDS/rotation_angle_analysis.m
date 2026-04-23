% Sweep rotation angles for rotating_input_symmetric model
% Calculate variance explained by context, color, and choice using dPCA
%
% Rotation scheme:
%   Context 1: +theta rotation -> color input = [cos(θ), sin(θ)]
%   Context 2: -theta rotation -> color input = [cos(θ), -sin(θ)]
%   At θ=0° or 180°: sin(θ)=0, so NO choice variance explained

clear; close all;

%% Setup
rotation_angles = 0:5:360;  % Sweep from 0 to 360 in 10-degree steps
n_angles = length(rotation_angles);

% Storage for results (dPCA marginalizations)
var_stimulus = zeros(n_angles, 1);    % Color variance
var_decision = zeros(n_angles, 1);    % Choice variance
var_ci = zeros(n_angles, 1);          % Context-independent
var_interaction = zeros(n_angles, 1); % Stimulus/Decision interaction

%% dPCA parameters (same as in XORModel3.dPCA method)
combinedParams = {{1, [1 3]}, {2, [2 3]}, {3}, {[1 2], [1 2 3]}};

%% Sweep through rotation angles
fprintf('Sweeping rotation angles from 0 to 360 degrees using dPCA...\n');
fprintf('Context 1: +theta rotation, Context 2: -theta rotation\n');
fprintf('Expected: Zero decision (choice) variance at theta = 0, 180, 360 degrees\n\n');

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
    
    % Map conditions to dPCA format
    % Condition 1: T1-Red-L
    % Condition 2: T1-Grn-R  
    % Condition 3: T2-Red-R
    % Condition 4: T2-Grn-L
    firingRatesAverage(:,1,1,:) = model.all_x(:,:,1);  % T1-Red-L
    firingRatesAverage(:,2,2,:) = model.all_x(:,:,2);  % T1-Grn-R
    firingRatesAverage(:,1,2,:) = model.all_x(:,:,3);  % T2-Red-R
    firingRatesAverage(:,2,1,:) = model.all_x(:,:,4);  % T2-Grn-L
    
    % Add small noise to avoid numerical issues
    firingRatesAverage = firingRatesAverage + 0.001*randn(size(firingRatesAverage));
    
    % Run dPCA
    [W, V, whichMarg] = dpca(firingRatesAverage, 10, ...
        'combinedParams', combinedParams);
    
    % Compute explained variance
    explVar = dpca_explainedVariance(firingRatesAverage, W, V, ...
        'combinedParams', combinedParams);
    
    % Store results
    var_stimulus(i) = explVar.totalMarginalizedVar(1) / explVar.totalVar*100;      % Stimulus (Color)
    var_decision(i) = explVar.totalMarginalizedVar(2) / explVar.totalVar*100;      % Decision (Choice)
    var_ci(i) = explVar.totalMarginalizedVar(3) / explVar.totalVar*100;            % Condition-independent
    var_interaction(i) = explVar.totalMarginalizedVar(4) / explVar.totalVar*100;   % S/D Interaction
    
%     fprintf('  -> Stimulus: %.2f%%, Decision: %.2f%%, CI: %.2f%%, Interaction: %.2f%%\n', ...
%         var_stimulus(i), var_decision(i), var_ci(i), var_interaction(i));
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

% plot in polar coordinates
theta = deg2rad(rotation_angles);

% Polar plot
figure; 
polarplot(theta, var_stimulus, 'm-')
hold on
polarplot(theta, var_decision, 'b-')


legend('stimulus', 'choice')
