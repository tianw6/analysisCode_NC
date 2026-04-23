%% Session Alignment for wrongTrials struct

% Parameters
num_sessions = length(wrongTrials);
num_conditions = 4; % conditions 0,1,2,3

%% Step 1: Compute condition-averaged responses for each session
Ybar_cell = cell(num_sessions, 1);
mu_cell = cell(num_sessions, 1); % store means for later

for sess = 1:num_sessions
    trials_data = wrongTrials(sess).trials; % trials x units x time
    labels = wrongTrials(sess).labels; % 1 x trials
    
    [num_trials, num_units, num_time] = size(trials_data);
    
    % Reshape to units x (time * trials) for easier processing
    data_reshaped = permute(trials_data, [2, 3, 1]); % units x time x trials
    data_reshaped = reshape(data_reshaped, num_units, num_time * num_trials);
    
    % Compute and subtract row means (mean across all time and trials)
    mu = mean(data_reshaped, 2); % units x 1
    mu_cell{sess} = mu;
    data_centered = data_reshaped - mu; % mean-center each unit
    
    % Reshape back to units x time x trials
    data_centered = reshape(data_centered, num_units, num_time, num_trials);
    
    % Compute condition averages
    Ybar_cond = zeros(num_units, num_time, num_conditions);
    for cond = 0:(num_conditions-1)
        cond_trials = (labels == cond);
        if sum(cond_trials) > 0
            Ybar_cond(:, :, cond+1) = mean(data_centered(:, :, cond_trials), 3);
        end
    end
    
    % Reshape to units x (time * conditions) as required
    Ybar_cell{sess} = reshape(Ybar_cond, num_units, num_time * num_conditions);
end

%% Step 2: Create joint condition-average matrix (block concatenation)
% Stack all Ybar matrices vertically
Ybar_joint = [];
session_sizes = zeros(num_sessions, 1); % track number of units per session

for sess = 1:num_sessions
    Ybar_joint = [Ybar_joint; Ybar_cell{sess}];
    session_sizes(sess) = size(Ybar_cell{sess}, 1);
end

%% Step 3: Perform SVD
[U, S, V] = svd(Ybar_joint, 'econ');

%% Step 4: Extract blocks and orthogonalize to get aligned basis for each session
M = 20; % number of aligned modes (as in paper)
U_perp_cell = cell(num_sessions, 1);

start_idx = 1;
for sess = 1:num_sessions
    end_idx = start_idx + session_sizes(sess) - 1;
    
    % Extract the block for this session
    U_block = U(start_idx:end_idx, :);
    
    % Take first M columns
    U_block_M = U_block(:, 1:M);
    
    % Orthogonalize using QR decomposition
    [Q, R] = qr(U_block_M, 0);
    U_perp_cell{sess} = Q; % This is U_perp_{i,M}
    
    start_idx = end_idx + 1;
end

%% Step 5: Project single trials into aligned space
aligned_data = cell(num_sessions, 1);

for sess = 1:num_sessions
    trials_data = wrongTrials(sess).trials; % trials x units x time
    [num_trials, num_units, num_time] = size(trials_data);
    
    % Get the aligned basis and mean for this session
    U_perp = U_perp_cell{sess}; % units x M
    mu = mu_cell{sess}; % units x 1
    
    % Initialize aligned data: M x time x trials
    z_aligned = zeros(M, num_time, num_trials);
    
    % Project each trial at each time point
    for trial = 1:num_trials
        for t = 1:num_time
            % Get population vector at this time: units x 1
            y_t = squeeze(trials_data(trial, :, t))'; % make it column vector
            
            % Mean-center and project
            z_aligned(:, t, trial) = U_perp' * (y_t - mu);
        end
    end
    
    aligned_data{sess} = z_aligned; % Store M x time x trials
end

%% Step 6: Calculate variance explained for each session
variance_explained = zeros(num_sessions, 1);

for sess = 1:num_sessions
    Ybar = Ybar_cell{sess}; % units x (time * conditions), already mean-centered
    U_perp = U_perp_cell{sess}; % units x M
    
    % Reconstruct from M dimensions
    Ybar_reconstructed = U_perp * (U_perp' * Ybar);
    
    % Calculate variance
    var_residual = sum((Ybar - Ybar_reconstructed).^2, 'all');
    var_total = sum(Ybar.^2, 'all');
    
    variance_explained(sess) = 1 - (var_residual / var_total);
end

%% Display results
% fprintf('Session alignment complete!\n');
% fprintf('Number of sessions: %d\n', num_sessions);
% fprintf('Number of aligned dimensions: %d\n', M);
% fprintf('\nVariance explained per session:\n');
% for sess = 1:num_sessions
%     fprintf('  Session %d: %.2f%%\n', sess, variance_explained(sess)*100);
% end
% fprintf('Mean variance explained: %.2f%%\n', mean(variance_explained)*100);
