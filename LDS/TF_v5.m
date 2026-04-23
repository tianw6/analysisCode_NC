% XOR Model - Two Linear Dynamical Systems (No Cheating!)
% Context switches between two different J matrices
% Each J has its own color→choice mapping

%% Parameters
N = 100;
tau = 50;
dt = 1;
T_total = 700;
T_color_onset = 200;

%% Build base dynamics

[Q, ~] = qr(randn(N, N));

Lambda_base = zeros(N, N);
Lambda_base(1,1) = 0.2;  % Context - moderately stable (will decay slowly)
Lambda_base(2,2) = 0.2;  % Color (transient)
Lambda_base(3,3) = 0.6;  % Choice (most stable)
for i = 4:N
    Lambda_base(i,i) = 0.1*rand();
end

J_base = Q * Lambda_base * Q';

%% Add nonnormality for transient amplification

% Add off-diagonal terms to create nonnormal structure
% This allows transient growth even with stable eigenvalues
nonnormal_strength = 0.1;

% Create nonnormal coupling in the 3D subspace
J_nonnormal = zeros(N, N);

% Context can transiently drive color (context→color)
J_nonnormal(2,1) = nonnormal_strength;

% Color can transiently drive context back (color→context)  
J_nonnormal(1,2) = -nonnormal_strength * 0.5;

% Choice can feed back to color (choice→color)
J_nonnormal(2,3) = nonnormal_strength * 0.3;

% Transform to neural space
J_nonnormal_full = Q * J_nonnormal * Q';
J_base = J_base + J_nonnormal_full;

fprintf('Added nonnormal dynamics for transient amplification\n');

%% Build two different systems with different color→choice coupling

coupling_strength = .8;  % Strong coupling amplifies choice

% System 1 (T1): Red→Left, Green→Right
% Color drives choice NEGATIVELY
J1_coupling = zeros(N, N);
% When color is positive (Red), choice goes negative (Left)
% When color is negative (Green), choice goes positive (Right)
color_dir = Q(:,2);
choice_dir = Q(:,3);
J1_coupling_matrix = -coupling_strength * (choice_dir * color_dir');
J1 = J_base + J1_coupling_matrix;

% System 2 (T2): Red→Right, Green→Left  
% Color drives choice POSITIVELY
J2_coupling_matrix = +coupling_strength * (choice_dir * color_dir');
J2 = J_base + J2_coupling_matrix;

fprintf('Built two linear systems:\n');
fprintf('  J1 (T1): Color → -Choice (Red→Left, Green→Right)\n');
fprintf('  J2 (T2): Color → +Choice (Red→Right, Green→Left)\n');

%% Build inputs

B_context = Q(:,1);
B_color = Q(:,2);

I0_context = 1.0;  % Weak context input
I0_color = 1.0;    % Weak color input
% Choice becomes strong through recurrent amplification via coupling!

%% Simulate - Context selects which J!

time = 0:dt:T_total;
n_time = length(time);

configs = [1, 1, -1, -1];
colors = [1, -1, 1, -1];
all_x = zeros(N, n_time, 4);

fprintf('\nSimulating with context-dependent dynamics...\n');

for cond = 1:4
    context_sign = configs(cond);
    color_sign = colors(cond);
    
    % KEY: Select which dynamical system based on context
    if context_sign == 1
        J = J1;  % T1 system
        fprintf('Cond %d: Using J1 (T1 dynamics)\n', cond);
    else
        J = J2;  % T2 system
        fprintf('Cond %d: Using J2 (T2 dynamics)\n', cond);
    end
    
    x = zeros(N, n_time);
    x(:,1) = 0.01*randn(N,1);
    
    for t = 1:(n_time-1)
        current_time = time(t);
        
        % Inputs (same for both systems)
        input = context_sign * B_context * I0_context;
        
        if current_time >= T_color_onset
            input = input + color_sign * B_color * I0_color;
        end
        
        % Update with context-selected dynamics
        dx = (1/tau) * (-x(:,t) + J*x(:,t) + input);
        x(:,t+1) = x(:,t) + dt*dx;
    end
    
    all_x(:,:,cond) = x;
end

%% Mean-subtract
mean_traj = mean(all_x, 3);
all_x_centered = all_x - repmat(mean_traj, [1, 1, 4]);

fprintf('\nSubtracted condition-independent signal\n');

%% PCA
data_pca = [];
for cond = 1:4
    data_pca = [data_pca; all_x_centered(:,:,cond)'];
end
[coeff, ~, ~, ~, explained] = pca(data_pca);

fprintf('\nPCA Variance:\n');
for i = 1:5
    fprintf('  PC%d: %.1f%%\n', i, explained(i));
end

pc1 = zeros(n_time, 4);
pc2 = zeros(n_time, 4);
pc3 = zeros(n_time, 4);
for cond = 1:4
    proj = all_x_centered(:,:,cond)' * coeff(:,1:3);
    pc1(:,cond) = proj(:,1);
    pc2(:,cond) = proj(:,2);
    pc3(:,cond) = proj(:,3);
end

%% Visualize
labels = {'T1-Red-L', 'T1-Grn-R', 'T2-Red-R', 'T2-Grn-L'};
cols = [0.8,0.2,0.2; 0.2,0.7,0.2; 0.8,0.2,0.2; 0.2,0.7,0.2];
styles = {'-', '--', '--', '-'};

figure('Position', [100,100,1600,900]);

subplot(2,3,1);
for c = 1:4
    plot(pc1(:,c), pc2(:,c), styles{c}, 'Color', cols(c,:), 'LineWidth', 2.5);
    hold on;
    plot(pc1(end,c), pc2(end,c), 'd', 'MarkerSize', 14, ...
        'MarkerFaceColor', cols(c,:), 'MarkerEdgeColor', 'k', 'LineWidth', 2);
end
xlabel('PC1', 'FontSize', 13, 'FontWeight', 'bold');
ylabel('PC2', 'FontSize', 13, 'FontWeight', 'bold');
title(sprintf('PC1 (%.0f%%) vs PC2 (%.0f%%)', explained(1), explained(2)));
grid on; axis equal;

subplot(2,3,2);
for c = 1:4
    plot(pc1(:,c), pc3(:,c), styles{c}, 'Color', cols(c,:), 'LineWidth', 2.5);
    hold on;
    plot(pc1(end,c), pc3(end,c), 'd', 'MarkerSize', 14, ...
        'MarkerFaceColor', cols(c,:), 'MarkerEdgeColor', 'k', 'LineWidth', 2);
end
xlabel('PC1', 'FontSize', 13, 'FontWeight', 'bold');
ylabel('PC3', 'FontSize', 13, 'FontWeight', 'bold');
title(sprintf('PC1 vs PC3 (%.0f%%)', explained(3)));
grid on; axis equal;

subplot(2,3,3);
for c = 1:4
    plot(pc2(:,c), pc3(:,c), styles{c}, 'Color', cols(c,:), 'LineWidth', 2.5);
    hold on;
    plot(pc2(end,c), pc3(end,c), 'd', 'MarkerSize', 14, ...
        'MarkerFaceColor', cols(c,:), 'MarkerEdgeColor', 'k', 'LineWidth', 2);
end
xlabel('PC2', 'FontSize', 13, 'FontWeight', 'bold');
ylabel('PC3', 'FontSize', 13, 'FontWeight', 'bold');
title('PC2 vs PC3');
grid on; axis equal;

subplot(2,3,4);
for c = 1:4
    plot(time, pc1(:,c), styles{c}, 'Color', cols(c,:), 'LineWidth', 2);
    hold on;
end
xline(T_color_onset, 'k--', 'LineWidth', 2);
xlabel('Time (ms)'); ylabel('PC1');
title('PC1 Time Course');
grid on;

subplot(2,3,5);
for c = 1:4
    plot(time, pc2(:,c), styles{c}, 'Color', cols(c,:), 'LineWidth', 2);
    hold on;
end
xline(T_color_onset, 'k--', 'LineWidth', 2);
xlabel('Time (ms)'); ylabel('PC2');
title('PC2 Time Course');
grid on;

subplot(2,3,6);
for c = 1:4
    plot(time, pc3(:,c), styles{c}, 'Color', cols(c,:), 'LineWidth', 2);
    hold on;
end
xline(T_color_onset, 'k--', 'LineWidth', 2);
xlabel('Time (ms)'); ylabel('PC3');
title('PC3 Time Course');
grid on;

sgtitle('XOR: Two Linear Dynamical Systems', 'FontSize', 16, 'FontWeight', 'bold');

%% Analysis
fprintf('\nFinal PC values [T1-Red-L, T1-Grn-R, T2-Red-R, T2-Grn-L]:\n');
fprintf('  PC1: [%6.1f, %6.1f, %6.1f, %6.1f]\n', pc1(end,1), pc1(end,2), pc1(end,3), pc1(end,4));
fprintf('  PC2: [%6.1f, %6.1f, %6.1f, %6.1f]\n', pc2(end,1), pc2(end,2), pc2(end,3), pc2(end,4));
fprintf('  PC3: [%6.1f, %6.1f, %6.1f, %6.1f]\n', pc3(end,1), pc3(end,2), pc3(end,3), pc3(end,4));

fprintf('\nExpected:\n');
fprintf('  Context: [+, +, -, -]\n');
fprintf('  Color:   [+, -, +, -]\n');
fprintf('  Choice:  [-, +, +, -]\n');

ctx_pattern = [1, 1, -1, -1];
col_pattern = [1, -1, 1, -1];
cho_pattern = [-1, 1, 1, -1];

pc1_vals = [pc1(end,1), pc1(end,2), pc1(end,3), pc1(end,4)];
pc2_vals = [pc2(end,1), pc2(end,2), pc2(end,3), pc2(end,4)];
pc3_vals = [pc3(end,1), pc3(end,2), pc3(end,3), pc3(end,4)];

fprintf('\nCorrelations:\n');
fprintf('PC1: ctx=%.3f, col=%.3f, cho=%.3f\n', ...
    corr(pc1_vals', ctx_pattern'), corr(pc1_vals', col_pattern'), corr(pc1_vals', cho_pattern'));
fprintf('PC2: ctx=%.3f, col=%.3f, cho=%.3f\n', ...
    corr(pc2_vals', ctx_pattern'), corr(pc2_vals', col_pattern'), corr(pc2_vals', cho_pattern'));
fprintf('PC3: ctx=%.3f, col=%.3f, cho=%.3f\n', ...
    corr(pc3_vals', ctx_pattern'), corr(pc3_vals', col_pattern'), corr(pc3_vals', cho_pattern'));

fprintf('\n=== TRUE XOR IMPLEMENTATION ===\n');
fprintf('Two LINEAR dynamical systems J1 and J2\n');
fprintf('  J1: Has coupling Color → -Choice (for T1)\n');
fprintf('  J2: Has coupling Color → +Choice (for T2)\n');
fprintf('Context input selects which J is active\n');
fprintf('Nonlinearity = switching between linear systems\n');
fprintf('No sign() function or mathematical cheating!\n');

%%

%% Add 3D trajectory plot
figure('Position', [100, 100, 800, 700]);

for c = 1:4
    plot3(pc1(:,c), pc2(:,c), pc3(:,c), styles{c}, ...
        'Color', cols(c,:), 'LineWidth', 2.5);
    hold on;
    
    % Start marker
    plot3(pc1(1,c), pc2(1,c), pc3(1,c), 'o', 'MarkerSize', 10, ...
        'MarkerFaceColor', cols(c,:), 'MarkerEdgeColor', 'k', 'LineWidth', 2);
    
    % Color onset marker
    t_onset = round(T_color_onset/dt);
    plot3(pc1(t_onset,c), pc2(t_onset,c), pc3(t_onset,c), 'o', 'MarkerSize', 8, ...
        'MarkerFaceColor', [0.6,0.2,0.6], 'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
    
    % End marker
    plot3(pc1(end,c), pc2(end,c), pc3(end,c), 'd', 'MarkerSize', 14, ...
        'MarkerFaceColor', cols(c,:), 'MarkerEdgeColor', 'k', 'LineWidth', 2);
end