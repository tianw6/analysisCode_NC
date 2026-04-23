% Switching Linear Dynamical System - Fit to Condition-Averaged Data
% After DPCA on condition-averaged firing rates
% Inputs: context {+1,-1} and color {+1,-1} (2D, just like your toy model!)
% Goal: Fit J1 and J2 for two contexts

%% YOUR DATA INPUTS
% You need to provide:
% - y_avg: [N_neurons x N_timepoints x 4] condition-averaged firing rates
%          Conditions: [T1-Red, T1-Green, T2-Red, T2-Green]
% - U_dpca: [N_neurons x N_latent] projection matrix from DPCA
% - V_dpca: [N_neurons x N_latent] reconstruction matrix from DPCA  
% - T_color_onset: time when color stimulus appears
% - dt: time step (e.g., 1 ms)
% - tau: time constant (e.g., 50 ms)
a = load('/Volumes/TianSSD/TiberiusNpix/checkerboardAligned/DLPFCtotalDataframeC.mat').totalDataframe;
b = load('/Volumes/TianSSD/VinnieNpix/checkerboardAligned/DLPFCtotalDataframeC.mat').totalDataframe;

firingRatesAverage = [a(:,:,:,1:1300); b(:,:,:,1:1300)];

processedFR = preprocess(firingRatesAverage, 1);


%% 

frAverage = [];
fr = [];
for ii = 1:4
    frAverage(:,:,ii) = processedFR(:,(1:1300) + (ii-1).*1300);
end

fr(:,1,1,:) = processedFR(:,1:1300);
fr(:,1,2,:) = processedFR(:,(1:1300) + 1300);
fr(:,2,1,:) = processedFR(:,(1:1300) + 1300*2);
fr(:,2,2,:) = processedFR(:,(1:1300) + 1300*3);



addpath("/Users/tianwang/Documents/MATLAB/ChandLab/dPCA/matlab");

combinedParams = {{1, [1 3]}, {2, [2 3]}, {3}, {[1 2], [1 2 3]}};
margNames = {'Stimulus', 'Decision', 'Condition-independent', 'S/D Interaction'};

% margNames = {'SC', 'Configuration', 'Condition-independent', 'C/D Interaction'};

margColours = [23 100 171; 187 20 25; 150 150 150; 114 97 171]/256;

% time of combined T and C data
time = linspace(-0.8, 0.5, size(fr, 4));
timeEvents = [-0.7, 0];

tic
[W,V,whichMarg] = dpca(fr, 30, ...
    'combinedParams', combinedParams);
toc

explVar = dpca_explainedVariance(fr, W, V, ...
    'combinedParams', combinedParams);

z = dpca_plot(fr, W, V, @dpca_plot_default, ...
    'explainedVar', explVar, ...
    'marginalizationNames', margNames, ...
    'marginalizationColours', margColours, ...
    'whichMarg', whichMarg,                 ...
    'time', time,                        ...
    'timeEvents', timeEvents,               ...
    'timeMarginalization', 3, ...
    'legendSubplot', 16, ...
    'numCompToShow', 20);

%% For demo, create example data (REPLACE with your real data)
N_neurons = size(processedFR,1);
N_latent = 10;
N_time = 1300;
dt = 1;
tau = 10;
T_color_onset = 800;
T_cxt_onset = 100;
fprintf('=== Switching LDS: Condition-Averaged Fitting ===\n\n');

rng(42);
% Create example DPCA matrices (replace with your real ones)
U_dpca = W(:,1:N_latent);
V_dpca = V(:,1:N_latent);

% Create example condition-averaged data (replace with your real data)
% Order: [T1-Red, T2-Red, T2-Green, T1-Green]
y_avg = frAverage;

fprintf('Data dimensions:\n');
fprintf('  Neurons: %d\n', N_neurons);
fprintf('  Timepoints: %d\n', N_time);
fprintf('  Conditions: 4 (T1-Red, T2-Red, T2-Green, T1-Green)\n');
fprintf('  Latent dimensions: %d\n\n', N_latent);

%% Project to latent space
% x = U' * y for each condition

X_latent = zeros(N_latent, N_time, 4);
for cond = 1:4
    X_latent(:, :, cond) = U_dpca' * y_avg(:, :, cond);
end

fprintf('Projected to %dD latent space\n\n', N_latent);


%% plot x_latent

for ii = 1:10
    figure; hold on
    plot(X_latent(ii,:,1), 'r-');
    plot(X_latent(ii,:,2), 'r--');
    plot(X_latent(ii,:,3), 'g-'  );
    plot(X_latent(ii,:,4), 'g--');  
    pause;
    close;
end
%% Define inputs (exactly like your toy model!)
% Context: [+1, -1, -1, +1] for [T1-Red, T2-Red, T2-Green, T1-Green]
% Color:   [+1, +1, -1, -1] starting at T_color_onset

context_input = [1, -1, -1, 1];
color_input = [1, 1, -1, -1];

time = (0:N_time-1) * dt;

% Build input matrices for each condition (2 x N_time x 4)
U_input = zeros(2, N_time, 4);  % [context; color]

for cond = 1:4
    % Context is always on
    U_input(1, time >= T_cxt_onset, cond) = context_input(cond);
    
    % Color turns on at T_color_onset
    U_input(2, time >= T_color_onset, cond) = color_input(cond);
end

fprintf('Input structure (like toy model):\n');
fprintf('  Context: [+1, -1, -1, +1]\n');
fprintf('  Color:   [+1, +1, -1, -1] (onset at t=%d)\n\n', T_color_onset);

%% Method 1: Fit J1 and J2 separately using least squares
% Model: dx/dt = (1/tau) * (-x + J*x + B*u)
% Discrete: x(t+1) = alpha*x(t) + beta*(J*x(t) + B*u(t))
% where alpha = (1 - dt/tau), beta = dt/tau

alpha = 1 - dt/tau;
beta = dt/tau;

fprintf('Fitting context-dependent dynamics...\n');
fprintf('Time constant tau = %.1f ms\n', tau);
fprintf('alpha = %.3f, beta = %.3f\n\n', alpha, beta);

% Separate conditions by context
ctx1_conds = [1, 4];  % T1-Red, T1-Green
ctx2_conds = [2, 3];  % T2-Red, T2-Green

% Regularization parameter (tune this!)
lambda_reg = 0.1;  % Start with 0.01, increase if unstable

% Fit J1 for context 1
[J1, B1, fit_error1] = fit_dynamics_with_input(X_latent, U_input, ...
    ctx1_conds, alpha, beta, lambda_reg);

% Fit J2 for context 2  
[J2, B2, fit_error2] = fit_dynamics_with_input(X_latent, U_input, ...
    ctx2_conds, alpha, beta, lambda_reg);

fprintf('Context 1 (T1): Fit error = %.4f\n', fit_error1);
fprintf('Context 2 (T2): Fit error = %.4f\n\n', fit_error2);




%% 

% After fitting J1, J2
J1 = enforce_stability(J1, alpha);
J2 = enforce_stability(J2, alpha);



%% Check stability
eigs1 = eig(J1);
eigs2 = eig(J2);

fprintf('Stability check:\n');
fprintf('  J1: max |eigenvalue| = %.3f ', max(abs(eigs1)));
if max(abs(eigs1)) < 1/alpha
    fprintf('(stable)\n');
else
    fprintf('(unstable!)\n');
end

fprintf('  J2: max |eigenvalue| = %.3f ', max(abs(eigs2)));
if max(abs(eigs2)) < 1/alpha
    fprintf('(stable)\n');
else
    fprintf('(unstable!)\n');
end
fprintf('\n');

%% Analyze difference between J1 and J2
J_diff = J2 - J1;
fprintf('Dynamics difference (J2 - J1):\n');
fprintf('  Frobenius norm: ||J2-J1|| = %.3f\n', norm(J_diff, 'fro'));
fprintf('  Relative to J1: %.1f%%\n', 100*norm(J_diff,'fro')/norm(J1,'fro'));

[~, S_diff, ~] = svd(J_diff);
fprintf('  Top 3 singular values: [%.3f, %.3f, %.3f]\n\n', ...
    S_diff(1,1), S_diff(2,2), S_diff(3,3));

% Also check input matrices
B_diff = B2 - B1;
fprintf('Input coupling difference (B2 - B1):\n');
fprintf('  Frobenius norm: ||B2-B1|| = %.3f\n\n', norm(B_diff, 'fro'));

%% Simulate forward with fitted dynamics
fprintf('Simulating fitted dynamics...\n');

X_pred = zeros(N_latent, N_time, 4);

for cond = 1:4
    % Select which J and B to use based on context
    if context_input(cond) == 1
        J = J1; B = B1;
        fprintf('  Cond %d: Using J1, B1 (Context T1)\n', cond);
    else
        J = J2; B = B2;
        fprintf('  Cond %d: Using J2, B2 (Context T2)\n', cond);
    end
    
    % Initial condition
    x_t = X_latent(:, 1, cond);
    X_pred(:, 1, cond) = x_t;
    
    % Simulate forward
    for t = 1:(N_time-1)
        u_t = U_input(:, t, cond);
        
        % dx/dt = (1/tau) * (-x + J*x + B*u)
        dx = beta * (-x_t + J*x_t + B*u_t);
        x_t = x_t + dx;
        
        X_pred(:, t+1, cond) = x_t;
    end
end
fprintf('\n');

%% Compute prediction accuracy
pred_errors = zeros(1, 4);
for cond = 1:4
    pred_errors(cond) = norm(X_pred(:,:,cond) - X_latent(:,:,cond), 'fro') / ...
                        norm(X_latent(:,:,cond), 'fro');
end

fprintf('Prediction errors (relative):\n');
fprintf('  T1-Red:   %.4f\n', pred_errors(1));
fprintf('  T1-Green: %.4f\n', pred_errors(2));
fprintf('  T2-Red:   %.4f\n', pred_errors(3));
fprintf('  T2-Green: %.4f\n', pred_errors(4));
fprintf('  Mean:     %.4f\n\n', mean(pred_errors));


%% 

for ii = 1:10
    figure; hold on
    plot(X_pred(ii,:,1) + 1, 'r-');
    plot(X_pred(ii,:,2) + 2, 'r--');
    plot(X_pred(ii,:,3) + 3, 'g-');
    plot(X_pred(ii,:,4) + 4, 'g--');  
    pause;
    close;
end


%% 

figure; hold on
dim1 = 2;
dim2 = 3;
% plot(X_latent(dim1,:,1), X_latent(dim2,:,1), 'r-');
% plot(X_latent(dim1,:,2), X_latent(dim2,:,2), 'r--');
% plot(X_latent(dim1,:,3), X_latent(dim2,:,3), 'g-');
% plot(X_latent(dim1,:,4), X_latent(dim2,:,4), 'g--');

% pause;

plot(X_pred(dim1,:,1), X_pred(dim2,:,1), 'r-');
plot(X_pred(dim1,:,2), X_pred(dim2,:,2), 'r--');
plot(X_pred(dim1,:,3), X_pred(dim2,:,3), 'g-');
plot(X_pred(dim1,:,4), X_pred(dim2,:,4), 'g--');

%% Visualize: Latent dynamics
labels = {'T1-Red', 'T2-Red', 'T2-Green', 'T1-Green'};
cols = [0.8,0.2,0.2; 0.2,0.7,0.2; 0.8,0.2,0.2; 0.2,0.7,0.2];
styles = {'-', '-', '-', '-'};

figure('Position', [100, 100, 1600, 900]);

% Time courses of first 3 latent dimensions
for dim = 1:3
    subplot(2, 3, dim);
    for cond = 1:4
        plot(time, X_latent(dim, :, cond), styles{cond}, ...
            'Color', cols(cond,:), 'LineWidth', 2.5, 'DisplayName', labels{cond});
        hold on;
        plot(time, X_pred(dim, :, cond), '--', ...
            'Color', cols(cond,:)*0.7, 'LineWidth', 1.5, ...
            'DisplayName', [labels{cond} ' pred']);
    end
    xline(T_color_onset, 'k--', 'LineWidth', 2);
    xlabel('Time (ms)', 'FontSize', 11);
    ylabel(sprintf('Latent Dim %d', dim), 'FontSize', 11);
    title(sprintf('Latent Dimension %d', dim), 'FontSize', 12, 'FontWeight', 'bold');
    if dim == 1
        legend('Location', 'best', 'FontSize', 8);
    end
    grid on;
end

% 2D projections
subplot(2, 3, 4);
for cond = 1:4
    plot(X_latent(1,:,cond), X_latent(2,:,cond), styles{cond}, ...
        'Color', cols(cond,:), 'LineWidth', 2.5);
    hold on;
    plot(X_pred(1,:,cond), X_pred(2,:,cond), '--', ...
        'Color', cols(cond,:)*0.7, 'LineWidth', 1.5);
    plot(X_latent(1,end,cond), X_latent(2,end,cond), 'o', ...
        'MarkerSize', 10, 'MarkerFaceColor', cols(cond,:), ...
        'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
end
xlabel('Latent Dim 1', 'FontSize', 11);
ylabel('Latent Dim 2', 'FontSize', 11);
title('Dim 1 vs Dim 2', 'FontSize', 12, 'FontWeight', 'bold');
grid on; axis equal;

subplot(2, 3, 5);
for cond = 1:4
    plot(X_latent(1,:,cond), X_latent(3,:,cond), styles{cond}, ...
        'Color', cols(cond,:), 'LineWidth', 2.5);
    hold on;
    plot(X_pred(1,:,cond), X_pred(3,:,cond), '--', ...
        'Color', cols(cond,:)*0.7, 'LineWidth', 1.5);
    plot(X_latent(1,end,cond), X_latent(3,end,cond), 'o', ...
        'MarkerSize', 10, 'MarkerFaceColor', cols(cond,:), ...
        'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
end
xlabel('Latent Dim 1', 'FontSize', 11);
ylabel('Latent Dim 3', 'FontSize', 11);
title('Dim 1 vs Dim 3', 'FontSize', 12, 'FontWeight', 'bold');
grid on; axis equal;

subplot(2, 3, 6);
for cond = 1:4
    plot(X_latent(2,:,cond), X_latent(3,:,cond), styles{cond}, ...
        'Color', cols(cond,:), 'LineWidth', 2.5);
    hold on;
    plot(X_pred(2,:,cond), X_pred(3,:,cond), '--', ...
        'Color', cols(cond,:)*0.7, 'LineWidth', 1.5);
    plot(X_latent(2,end,cond), X_latent(3,end,cond), 'o', ...
        'MarkerSize', 10, 'MarkerFaceColor', cols(cond,:), ...
        'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
end
xlabel('Latent Dim 2', 'FontSize', 11);
ylabel('Latent Dim 3', 'FontSize', 11);
title('Dim 2 vs Dim 3', 'FontSize', 12, 'FontWeight', 'bold');
grid on; axis equal;

sgtitle('Fitted Switching LDS: Latent Dynamics (solid=data, dashed=model)', ...
    'FontSize', 14, 'FontWeight', 'bold');

%% Visualize: Reconstructed neural activity
% y_pred = V * x_pred

Y_pred = zeros(N_neurons, N_time, 4);
for cond = 1:4
    Y_pred(:, :, cond) = V_dpca * X_pred(:, :, cond);
end

% Plot a few example neurons
figure('Position', [100, 100, 1600, 500]);
neurons_to_plot = [1, round(N_neurons/3), round(2*N_neurons/3)];

for i = 1:3
    neuron = neurons_to_plot(i);
    subplot(1, 3, i);
    
    for cond = 1:4
        plot(time, y_avg(neuron, :, cond), styles{cond}, ...
            'Color', cols(cond,:), 'LineWidth', 2.5, 'DisplayName', labels{cond});
        hold on;
        plot(time, Y_pred(neuron, :, cond), '--', ...
            'Color', cols(cond,:)*0.7, 'LineWidth', 1.5, ...
            'DisplayName', [labels{cond} ' pred']);
    end
    xline(T_color_onset, 'k--', 'LineWidth', 2);
    xlabel('Time (ms)', 'FontSize', 11);
    ylabel('Firing Rate', 'FontSize', 11);
    title(sprintf('Neuron %d', neuron), 'FontSize', 12, 'FontWeight', 'bold');
    if i == 1
        legend('Location', 'best', 'FontSize', 8);
    end
    grid on;
end

sgtitle('Reconstructed Neural Activity (solid=data, dashed=model)', ...
    'FontSize', 14, 'FontWeight', 'bold');

fprintf('Visualizations complete!\n');

%% ============ HELPER FUNCTIONS ============

function [J, B, fit_error] = fit_dynamics_with_input(X_latent, U_input, conditions, alpha, beta, lambda_reg)
    % Fit dynamics: x(t+1) = alpha*x(t) + beta*(J*x(t) + B*u(t))
    % With ridge regularization to prevent overfitting
    
    [N_latent, N_time, ~] = size(X_latent);
    N_input = size(U_input, 1);
    
    % Collect data from specified conditions
    Delta_X = [];  % x(t+1) - alpha*x(t), size: [N_latent x N_samples]
    XU = [];       % [x(t); u(t)], size: [(N_latent+N_input) x N_samples]
    
    for cond = conditions
        for t = 1:(N_time-1)
            x_t = X_latent(:, t, cond);
            x_next = X_latent(:, t+1, cond);
            u_t = U_input(:, t, cond);
            
            delta_x = x_next - alpha * x_t;
            
            % Concatenate as columns
            Delta_X = [Delta_X, delta_x];
            XU = [XU, [x_t; u_t]];
        end
    end
    
    % Solve with ridge regularization:
    % [J, B] = (1/beta) * Delta_X * XU' * (XU*XU' + lambda*I)^-1
    
    XU_XU = XU * XU';
    reg_matrix = XU_XU + lambda_reg * eye(size(XU_XU));
    
    JB = (1/beta) * (Delta_X * XU') / reg_matrix;
    
    % Extract J and B
    J = JB(:, 1:N_latent);
    B = JB(:, (N_latent+1):end);
    
    % Compute fit error
    predicted = beta * JB * XU;
    fit_error = norm(Delta_X - predicted, 'fro') / norm(Delta_X, 'fro');
end





function J_stable = enforce_stability(J, alpha)
    [V, D] = eig(J);
    eigs_vals = diag(D);
    
    % Clip eigenvalues to be stable
    max_allowed = 0.95 / alpha;  % Leave some margin
    eigs_vals(abs(eigs_vals) > max_allowed) = ...
        max_allowed * eigs_vals(abs(eigs_vals) > max_allowed) ./ abs(eigs_vals(abs(eigs_vals) > max_allowed));
    
    J_stable = real(V * diag(eigs_vals) / V);
end