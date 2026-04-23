% Switching Linear Dynamical System for Neural Firing Rates
% Model: x(t) = J * x(t-1) + B * u(t) + noise
%        y(t) = C * x(t) + d + noise
% Fit to trial-averaged data with 4 conditions

%% Load your data
% Assuming you have:
% Y_data: [num_units x 1300 x 4] - neural firing rates for 4 conditions
%         Condition 1: T1-Red
%         Condition 2: T2-Red  
%         Condition 3: T2-Green
%         Condition 4: T1-Green

a = load('/Volumes/TianSSD/TiberiusNpix/checkerboardAligned/DLPFCtotalDataframeC.mat').totalDataframe;
b = load('/Volumes/TianSSD/VinnieNpix/checkerboardAligned/DLPFCtotalDataframeC.mat').totalDataframe;

firingRatesAverage = [a(:,:,:,1:1300); b(:,:,:,1:1300)];

processedFR = preprocess(firingRatesAverage, 1);


Y_data = [];
fr = [];
for ii = 1:4
    Y_data(:,:,ii) = processedFR(:,(1:1300) + (ii-1).*1300);
end
% Y_data = your_neural_data; % [num_units x 1300 x 4]

%% Create input matrix for each condition
T = 1300;
U = create_input_matrix(T);

%% Prepare data for fitting
% Reshape data: each condition becomes a separate trial
num_conditions = 4;
Y = cell(num_conditions, 1);
U_cell = cell(num_conditions, 1);

for cond = 1:num_conditions
    Y{cond} = Y_data(:, :, cond)'; % [T x num_units]
    U_cell{cond} = U{cond}';        % [T x 2]
end

%% Set model parameters
latent_dim = 10;           % Latent state dimensionality (tune this)
obs_dim = size(Y_data,1);       % Number of neurons
input_dim = 2;             % Context and color inputs
num_states = 2;            % 2 states: T1 (state 1) vs T2 (state 2)

%% Initialize parameters
params = initialize_params(latent_dim, obs_dim, input_dim, num_states);

%% Fit model with 2 states based on context (T1 vs T2)
states = cell(num_conditions, 1);
states{1} = ones(T, 1);     % Condition 1: T1-Red -> State 1 (T1)
states{2} = 2*ones(T, 1);   % Condition 2: T2-Red -> State 2 (T2)
states{3} = 2*ones(T, 1);   % Condition 3: T2-Green -> State 2 (T2)
states{4} = ones(T, 1);     % Condition 4: T1-Green -> State 1 (T1)

num_iterations = 100;
learning_rate = 0.001;

fprintf('Fitting switching LDS model...\n');
[params, loss_history] = fit_switching_lds(Y, U_cell, states, params, num_iterations, learning_rate);

%% Extract latent states
X_latent = cell(num_conditions, 1);
for cond = 1:num_conditions
    X_latent{cond} = infer_latent_states(Y{cond}, U_cell{cond}, states{cond}, params);
end

%% Visualize results
visualize_results(Y, X_latent, params, states);

%% Compute reconstruction quality
compute_reconstruction_quality(Y, U_cell, states, params);

%% ============ FUNCTIONS ============

%% Create input matrix for each condition
function U = create_input_matrix(T)
    % Create 4 input patterns for 4 conditions
    % Input 1: context (T1=1, T2=0 or T1=0, T2=1)
    % Input 2: color (Red=1, Green=0 or Red=0, Green=1)
    
    U = cell(4, 1);
    
    % Condition 1: T1-Red
    U{1} = zeros(2, T);
    U{1}(1, 100:end) = 1;  % Context T1 starts at t=100
    U{1}(2, 800:end) = 1;  % Color Red starts at t=800
    
    % Condition 2: T2-Red
    U{2} = zeros(2, T);
    U{2}(1, 100:end) = -1; % Context T2 (use -1 or separate encoding)
    U{2}(2, 800:end) = 1;  % Color Red starts at t=800
    
    % Condition 3: T2-Green
    U{3} = zeros(2, T);
    U{3}(1, 100:end) = -1; % Context T2
    U{3}(2, 800:end) = -1; % Color Green (use -1 or separate encoding)
    
    % Condition 4: T1-Green
    U{4} = zeros(2, T);
    U{4}(1, 100:end) = 1;  % Context T1
    U{4}(2, 800:end) = -1; % Color Green
end

%% Initialize parameters
function params = initialize_params(latent_dim, obs_dim, input_dim, num_states)
    params.latent_dim = latent_dim;
    params.obs_dim = obs_dim;
    params.input_dim = input_dim;
    params.num_states = num_states;
    
    % Initialize dynamics for each state
    params.J = cell(num_states, 1);
    params.B = cell(num_states, 1);
    for s = 1:num_states
        % Initialize with small random values for stability
        params.J{s} = randn(latent_dim, latent_dim) * 0.1 / sqrt(latent_dim);
        params.B{s} = randn(latent_dim, input_dim) * 0.1;
    end
    
    % Shared observation parameters
    params.C = randn(obs_dim, latent_dim) * 0.1 / sqrt(latent_dim);
    params.d = zeros(obs_dim, 1);
    
    % Noise covariances (diagonal for simplicity)
    params.Q = eye(latent_dim) * 0.01;
    params.R = eye(obs_dim) * 0.1;
end

%% Fit switching LDS with known states
function [params, loss_history] = fit_switching_lds(Y, U, states, params, num_iterations, learning_rate)
    num_trials = length(Y);
    T_list = cellfun(@(y) size(y, 1), Y);
    loss_history = zeros(num_iterations, 1);
    
    for iter = 1:num_iterations
        % E-step: Infer latent states given parameters
        X = cell(num_trials, 1);
        for trial = 1:num_trials
            X{trial} = infer_latent_states(Y{trial}, U{trial}, states{trial}, params);
        end
        
        % M-step: Update parameters given latent states
        params = update_parameters(Y, U, X, states, params, learning_rate);
        
        % Compute loss (negative log-likelihood)
        loss = 0;
        for trial = 1:num_trials
            Y_pred = X{trial} * params.C' + repmat(params.d', size(X{trial}, 1), 1);
            loss = loss + sum(sum((Y{trial} - Y_pred).^2));
            
            % Add dynamics loss
            for t = 2:T_list(trial)
                s = states{trial}(t);
                x_pred = X{trial}(t-1, :) * params.J{s}' + U{trial}(t, :) * params.B{s}';
                loss = loss + sum((X{trial}(t, :) - x_pred).^2) * 0.1;
            end
        end
        loss_history(iter) = loss;
        
        if mod(iter, 10) == 0
            fprintf('Iteration %d/%d, Loss: %.4f\n', iter, num_iterations, loss);
        end
    end
end

%% Infer latent states using Kalman filtering/smoothing
function X = infer_latent_states(Y, U, states, params)
    T = size(Y, 1);
    latent_dim = params.latent_dim;
    X = zeros(T, latent_dim);
    
    % Forward pass (Kalman filter)
    x = zeros(latent_dim, 1);
    P = params.Q;
    
    X_filt = zeros(T, latent_dim);
    P_filt = zeros(latent_dim, latent_dim, T);
    
    for t = 1:T
        s = states(t);
        
        % Prediction
        if t == 1
            x_pred = params.B{s} * U(t, :)';
            P_pred = params.Q;
        else
            x_pred = params.J{s} * x + params.B{s} * U(t, :)';
            P_pred = params.J{s} * P * params.J{s}' + params.Q;
        end
        
        % Update
        y_pred = params.C * x_pred + params.d;
        innov = Y(t, :)' - y_pred;
        S = params.C * P_pred * params.C' + params.R;
        K = P_pred * params.C' / S;
        
        x = x_pred + K * innov;
        P = (eye(latent_dim) - K * params.C) * P_pred;
        
        X_filt(t, :) = x';
        P_filt(:, :, t) = P;
    end
    
    % Backward pass (RTS smoother)
    X(T, :) = X_filt(T, :);
    for t = T-1:-1:1
        s = states(t+1);
        J_t = P_filt(:, :, t) * params.J{s}' / (params.J{s} * P_filt(:, :, t) * params.J{s}' + params.Q);
        X(t, :) = X_filt(t, :) + (X(t+1, :) - (params.J{s} * X_filt(t, :)' + params.B{s} * U(t+1, :)')') * J_t';
    end
end

%% Update parameters (M-step)
function params = update_parameters(Y, U, X, states, params, learning_rate)
    num_trials = length(Y);
    num_states = params.num_states;
    
    % Update C and d (observation parameters) - shared across states
    Y_all = cat(1, Y{:});
    X_all = cat(1, X{:});
    
    % Regression: Y = X*C' + d
    C_new = (X_all' * X_all + 1e-6 * eye(params.latent_dim)) \ (X_all' * Y_all);
    params.C = params.C + learning_rate * (C_new' - params.C);
    params.d = params.d + learning_rate * (mean(Y_all - X_all * params.C', 1)' - params.d);
    
    % Update J and B for each state
    for s = 1:num_states
        X_prev = [];
        X_curr = [];
        U_curr = [];
        
        for trial = 1:num_trials
            T = size(X{trial}, 1);
            state_mask = (states{trial} == s);
            state_mask(1) = false; % Exclude first time point
            
            if sum(state_mask) > 0
                idx = find(state_mask);
                X_curr = [X_curr; X{trial}(idx, :)];
                X_prev = [X_prev; X{trial}(idx-1, :)];
                U_curr = [U_curr; U{trial}(idx, :)];
            end
        end
        
        if ~isempty(X_curr)
            % Regression: X_curr = X_prev*J' + U_curr*B'
            XU = [X_prev, U_curr];
            JB_new = (XU' * XU + 1e-6 * eye(size(XU, 2))) \ (XU' * X_curr);
            
            J_new = JB_new(1:params.latent_dim, :)';
            B_new = JB_new(params.latent_dim+1:end, :)';
            
            params.J{s} = params.J{s} + learning_rate * (J_new - params.J{s});
            params.B{s} = params.B{s} + learning_rate * (B_new - params.B{s});
        end
    end
end

%% Visualize results
function visualize_results(Y, X_latent, params, states)
    num_conditions = length(Y);
    
    figure('Position', [100, 100, 1200, 800]);
    
    % Plot latent states
    for cond = 1:num_conditions
        subplot(2, num_conditions, cond);
        plot(X_latent{cond}(:, 1:min(3, size(X_latent{cond}, 2))));
        title(sprintf('Condition %d: Latent States', cond));
        xlabel('Time');
        ylabel('Latent State');
        legend('Dim 1', 'Dim 2', 'Dim 3');
        grid on;
    end
    
    % Plot reconstruction
    for cond = 1:num_conditions
        subplot(2, num_conditions, num_conditions + cond);
        Y_recon = X_latent{cond} * params.C' + repmat(params.d', size(X_latent{cond}, 1), 1);
        
        % Plot a few example neurons
        plot(Y{cond}(:, 1:min(5, size(Y{cond}, 2))), '-', 'LineWidth', 1);
        hold on;
        plot(Y_recon(:, 1:min(5, size(Y_recon, 2))), '--', 'LineWidth', 1);
        title(sprintf('Condition %d: Reconstruction', cond));
        xlabel('Time');
        ylabel('Firing Rate');
        legend('True', 'Recon', 'Location', 'best');
        grid on;
    end
    
    sgtitle('Switching LDS Results');
end

%% Compute reconstruction quality
function compute_reconstruction_quality(Y, U, states, params)
    num_conditions = length(Y);
    
    fprintf('\n=== Reconstruction Quality ===\n');
    for cond = 1:num_conditions
        X_latent = infer_latent_states(Y{cond}, U{cond}, states{cond}, params);
        Y_recon = X_latent * params.C' + repmat(params.d', size(X_latent, 1), 1);
        
        % R^2 for each neuron
        SS_tot = sum((Y{cond} - mean(Y{cond})).^2);
        SS_res = sum((Y{cond} - Y_recon).^2);
        R2 = 1 - SS_res ./ SS_tot;
        
        fprintf('Condition %d: Mean R^2 = %.4f, Median R^2 = %.4f\n', ...
                cond, mean(R2), median(R2));
    end
end