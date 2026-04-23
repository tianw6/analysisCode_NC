classdef XORModelAll < handle
    % XORModel - Class for XOR task models with different mechanisms
    %
    % Model types:
    %   'switching'                  - Context switches between J1 and J2 (default)
    %   'rotating_input'             - Context rotates color input direction (180°)
    %   'rotating_input_imperfect'   - Context rotates color input (adjustable angle)
    %   'rotating_input_symmetric'   - Context rotates in OPPOSITE directions (±angle)
    %   'gain_modulation_input'      - Context modulates instantaneous color INPUT
    %   'gain_modulation_state'      - Context modulates accumulated color STATE
    %
    % Usage:
    %   model = XORModel3('switching');
    %   model = XORModel3('rotating_input_imperfect', 150);  % 150° rotation
    %   model = XORModel3('rotating_input_symmetric', 60);   % ±60° symmetric rotation
    %   model.simulate();
    %   model.analyze();
    %   model.visualize();
    
    properties
        % Model parameters
        N = 100                 % Number of neurons
        tau = 50                % Time constant (ms)
        dt = 1                  % Time step (ms)
        T_total = 700           % Total trial time (ms)
        T_color_onset = 200     % Color onset time (ms)
        
        % Model type
        model_type              % 'switching', 'rotating_input', 'gain_modulation'
        rotation_angle = 180    % Rotation angle in degrees (for rotating_input_imperfect)
        rotated_color_component = 0    % Temporary storage for rotated color signal
        rotated_choice_component = 0   % Temporary storage for choice component of rotation
        
        % Network structure
        Q                       % Orthonormal basis
        Lambda_base             % Eigenvalues
        J_base                  % Base connectivity
        J1                      % System 1 (for switching model)
        J2                      % System 2 (for switching model)
        J                       % Fixed J (for rotating/gain models)
        
        % Input structure
        B_context               % Context input weights
        B_color                 % Color input weights
        B_ci                    % Condition-independent input
        
        I0_context = 1          % Context input strength
        I0_color = 0.8          % Color input strength
        I0_ci = 7.0             % CI input strength
        
        % Coupling parameters
        coupling_strength = 1   % Color->Choice coupling
        
        % Simulation results
        all_x = []                  % Neural activity [N x time x 4conditions]
        all_x_centered = []         % Mean-subtracted activity
        time = []                   % Time vector
        
        % Analysis results
        coeff = []                  % PCA coefficients
        explained = []              % Variance explained
        pc1 = []
        pc2 = []
        pc3 = []                    % PC projections
    end
    
    methods
        function obj = XORModel3(model_type, rotation_angle)
            % Constructor
            if nargin < 1
                model_type = 'switching';
            end
            if nargin >= 2
                obj.rotation_angle = rotation_angle;
            end
            obj.model_type = model_type;
            
            % Build network
            obj = obj.build_network();
            obj = obj.build_inputs();
            
            if strcmp(model_type, 'rotating_input_imperfect')
                fprintf('Created XORModel: %s (%.0f degrees)\n', obj.model_type, obj.rotation_angle);
            elseif strcmp(model_type, 'rotating_input_symmetric')
                fprintf('Created XORModel: %s (±%.0f degrees)\n', obj.model_type, obj.rotation_angle);
            else
                fprintf('Created XORModel: %s\n', obj.model_type);
            end
        end
        
        function obj = build_network(obj)
            % Build network structure based on model type
            
            % Create orthonormal basis
            rng(42); % For reproducibility            
            rN = randn(obj.N, obj.N);
            [obj.Q, ~] = qr(rN);
            
            % Define eigenvalues
            obj.Lambda_base = zeros(obj.N, obj.N);
            obj.Lambda_base(1,1) = 0.05;  % Context - weak
            obj.Lambda_base(2,2) = 0.1;   % Color - transient
            obj.Lambda_base(3,3) = 0.8;  % Choice - stable
            obj.Lambda_base(4,4) = 0.75;   % CI - stable
            for i = 5:obj.N
                obj.Lambda_base(i,i) = 0.6 + 0.2*rand();
            end
            
            % Build base dynamics
            J_start = obj.Q * obj.Lambda_base * obj.Q';
            
            % Add nonnormality
            d = 4;
            nonnormal_strength = 0.01;
            J_nonnormal = nonnormal_strength * randn(obj.N, obj.N);
            J_nonnormal(1:d, :) = 0;
            J_nonnormal(:, 1:d) = 0;
            
            % Task-specific nonnormality
            J_nonnormal(1, 3) = 0.2;  % Choice -> Context
            J_nonnormal(2, 3) = 0.2;  % Choice -> Color
            J_nonnormal(4, 1:3) = 0.01 * randn(1, 3);  % CI receives from task
            
            obj.J_base = J_start + J_nonnormal;
            
            % Build coupling based on model type
            color_dir = obj.Q(:,2);
            choice_dir = obj.Q(:,3);
            
            switch obj.model_type
                case 'switching'
                    % Two different J matrices
                    J1_coupling = -obj.coupling_strength * (choice_dir * color_dir');
                    J2_coupling = +obj.coupling_strength * (choice_dir * color_dir');
                    obj.J1 = obj.J_base + J1_coupling;
                    obj.J2 = obj.J_base + J2_coupling;
                    fprintf('  Built J1 and J2 (switching)\n');
                    
                case {'rotating_input', 'rotating_input_imperfect', 'rotating_input_symmetric'}
                    % One fixed J matrix with coupling
                    J_coupling = obj.coupling_strength * (choice_dir * color_dir');
                    obj.J = obj.J_base + J_coupling;
                    fprintf('  Built fixed J with coupling (rotating input)\n');
                    
                case {'gain_modulation_input', 'gain_modulation_state'}
                    % No fixed coupling - all coupling via gain modulation
                    obj.J = obj.J_base;
                    fprintf('  Built fixed J without coupling (gain modulation only)\n');
            end
        end
        
        function obj = build_inputs(obj)
            % Build input structure
            
            % Heterogeneous tuning
            context_tuning = abs(randn(obj.N, 1));
            context_tuning = context_tuning / mean(context_tuning);
            
            color_tuning = abs(randn(obj.N, 1));
            color_tuning = color_tuning / mean(color_tuning);
            
            ci_tuning = abs(randn(obj.N, 1));
            ci_tuning = ci_tuning / mean(ci_tuning);
            
            % Build input weights
            obj.B_context = obj.Q(:,1) .* context_tuning;
            obj.B_ci = obj.Q(:,4) .* ci_tuning;
            obj.B_color = obj.Q(:,2) .* color_tuning;
        end
        
        function obj = simulate(obj)
            % Simulate all 4 conditions
            
            obj.time = 0:obj.dt:obj.T_total;
            n_time = length(obj.time);
            
            configs = [1, 1, -1, -1];  % T1, T1, T2, T2
            colors = [1, -1, 1, -1];   % Red, Green, Red, Green
            obj.all_x = zeros(obj.N, n_time, 4);
            
            fprintf('Simulating %s model...\n', obj.model_type);
            
            for cond = 1:4
                context_sign = configs(cond);
                color_sign = colors(cond);
                
                % Select dynamics based on model type
                J_active = obj.select_dynamics(context_sign);
                
                % For rotating input models, modify the color sign based on rotation
                if strcmp(obj.model_type, 'rotating_input')
                    % Perfect 180° rotation: flip sign for T2
                    if context_sign == -1
                        color_sign_rotated = -color_sign;
                    else
                        color_sign_rotated = color_sign;
                    end
                elseif strcmp(obj.model_type, 'rotating_input_imperfect')
                    % Imperfect rotation: project onto rotated axes
                    color_sign_rotated = obj.rotate_color_signal(color_sign, context_sign);
                elseif strcmp(obj.model_type, 'rotating_input_symmetric')
                    % Symmetric rotation: rotate in opposite directions
                    color_sign_rotated = obj.rotate_color_signal_symmetric(color_sign, context_sign);
                else
                    color_sign_rotated = color_sign;
                end
                
                % Simulate
                x = zeros(obj.N, n_time);
                x(:,1) = 0.01*randn(obj.N,1);
                
                for t = 1:(n_time-1)
                    current_time = obj.time(t);
                    
                    % Compute input
                    input = obj.compute_input(x(:,t), context_sign, color_sign_rotated, ...
                                             current_time);
                    
                    % Update
                    dx = (1/obj.tau) * (-x(:,t) + J_active*x(:,t) + input);
                    x(:,t+1) = x(:,t) + obj.dt*dx;
                end
                
                obj.all_x(:,:,cond) = x;
            end
            
            % Mean-subtract
            mean_traj = mean(obj.all_x, 3);
            obj.all_x_centered = obj.all_x - repmat(mean_traj, [1, 1, 4]);
            
            fprintf('Simulation complete\n');
        end
        
        function J = select_dynamics(obj, context_sign)
            % Select appropriate J matrix based on model and context
            
            switch obj.model_type
                case 'switching'
                    if context_sign == 1
                        J = obj.J1;
                    else
                        J = obj.J2;
                    end
                case {'rotating_input', 'rotating_input_imperfect', 'rotating_input_symmetric', 'gain_modulation_input', 'gain_modulation_state'}
                    J = obj.J;
            end
        end
        
        function color_sign_rotated = rotate_color_signal(obj, color_sign, context_sign)
            % Rotate color signal for imperfect rotation model
            % Returns: [color_component, choice_component] for the rotated signal
            
            if context_sign == 1
                % No rotation for T1
                color_sign_rotated = color_sign;
            else
                % For T2: rotate the color signal in color-choice space
                theta = deg2rad(obj.rotation_angle);
                
                % Original signal is purely in color dimension: [color_sign, 0]
                % After rotation: [cos(θ)*color_sign, -sin(θ)*color_sign]
                obj.rotated_color_component = cos(theta) * color_sign;
                obj.rotated_choice_component = -sin(theta) * color_sign;
                
                % Return the color component
                color_sign_rotated = obj.rotated_color_component;
            end
        end
        
        function color_sign_rotated = rotate_color_signal_symmetric(obj, color_sign, context_sign)
            % Rotate color signal SYMMETRICALLY for both contexts
            % T1: rotates by +rotation_angle
            % T2: rotates by -rotation_angle
            % Both inputs are non-orthogonal to choice, but mirror images
            
            if context_sign == 1
                % T1: rotate by +alpha (toward choice axis)
                theta = deg2rad(obj.rotation_angle);
            else
                % T2: rotate by -alpha (away from choice axis)
                theta = deg2rad(-obj.rotation_angle);
            end
            
            % Rotate the color signal in color-choice space
            % Original signal: [color_sign, 0] (along color axis)
            % After rotation: [cos(θ)*color_sign, sin(θ)*color_sign]
            obj.rotated_color_component = cos(theta) * color_sign;
            obj.rotated_choice_component = sin(theta) * color_sign;
            
            % Return the color component
            color_sign_rotated = obj.rotated_color_component;
        end
        
        function input = compute_input(obj, x_t, context_sign, color_sign_rotated, current_time)
            % Compute total input at current time
            
            % Base inputs
            input = context_sign * obj.B_context * obj.I0_context;
            
            % Condition-independent ramping
            ramp_strength = 0.8 * (current_time / obj.T_total);
            input = input + ramp_strength * obj.B_ci * obj.I0_ci;
            
            % Color input (after onset)
            if current_time >= obj.T_color_onset + 30
                
                % Gain modulation variants
                if strcmp(obj.model_type, 'gain_modulation_input')
                    % Variant 1: Modulate INSTANTANEOUS color input
                    context_state = obj.Q(:,1)' * x_t;
                    gain = context_state;
                    color_input_strength = color_sign_rotated * obj.I0_color;
                    gain_mod_input = -gain * color_input_strength * obj.coupling_strength * obj.Q(:,3);
                    input = input + gain_mod_input;
                    
                elseif strcmp(obj.model_type, 'gain_modulation_state')
                    % Variant 2: Modulate ACCUMULATED color state
                    input = input + color_sign_rotated * obj.B_color * obj.I0_color;
                    
                    context_state = obj.Q(:,1)' * x_t;
                    color_state = obj.Q(:,2)' * x_t;
                    gain = context_state;
                    gain_mod_input = -gain * color_state * obj.coupling_strength * obj.Q(:,3);
                    input = input + gain_mod_input;
                    
                elseif strcmp(obj.model_type, 'rotating_input_imperfect') || strcmp(obj.model_type, 'rotating_input_symmetric')
                    % Rotated input: add both color and choice components
                    % For imperfect: only T2 is rotated (rotated_choice_component=0 for T1)
                    % For symmetric: both T1 and T2 are rotated
                    input = input + obj.rotated_color_component * obj.B_color * obj.I0_color;
                    input = input + obj.rotated_choice_component * obj.Q(:,3) * obj.I0_color;
                    
                else
                    % All other models: standard color input (switching, rotating_input)
                    input = input + color_sign_rotated * obj.B_color * obj.I0_color;
                end
            end
        end
        
        function obj = analyze(obj)
            % Perform PCA analysis
            
            if isempty(obj.all_x_centered)
                error('Run simulate() first');
            end
            
            % Concatenate data for PCA
            data_pca = [];
            for cond = 1:4
                data_pca = [data_pca; obj.all_x_centered(:,:,cond)'];
            end
            
            % PCA
            [obj.coeff, ~, ~, ~, obj.explained] = pca(data_pca);
            
            % Project onto PCs
            n_time = length(obj.time);
            obj.pc1 = zeros(n_time, 4);
            obj.pc2 = zeros(n_time, 4);
            obj.pc3 = zeros(n_time, 4);
            
            for cond = 1:4
                proj = obj.all_x_centered(:,:,cond)' * obj.coeff(:,1:3);
                obj.pc1(:,cond) = proj(:,1);
                obj.pc2(:,cond) = proj(:,2);
                obj.pc3(:,cond) = proj(:,3);
            end
            
            fprintf('\nPCA Variance Explained:\n');
            for i = 1:5
                fprintf('  PC%d: %.1f%%\n', i, obj.explained(i));
            end
            
            % Compute correlations
            obj.compute_correlations();
        end
        
        function compute_correlations(obj)
            % Compute correlations with expected patterns
            
            ctx_pattern = [1, 1, -1, -1];
            col_pattern = [1, -1, 1, -1];
            cho_pattern = [-1, 1, 1, -1];
            
            pc1_vals = [obj.pc1(end,1), obj.pc1(end,2), obj.pc1(end,3), obj.pc1(end,4)];
            pc2_vals = [obj.pc2(end,1), obj.pc2(end,2), obj.pc2(end,3), obj.pc2(end,4)];
            pc3_vals = [obj.pc3(end,1), obj.pc3(end,2), obj.pc3(end,3), obj.pc3(end,4)];
            
            fprintf('\nCorrelations with expected patterns:\n');
            fprintf('PC1: ctx=%.3f, col=%.3f, cho=%.3f\n', ...
                corr(pc1_vals', ctx_pattern'), corr(pc1_vals', col_pattern'), corr(pc1_vals', cho_pattern'));
            fprintf('PC2: ctx=%.3f, col=%.3f, cho=%.3f\n', ...
                corr(pc2_vals', ctx_pattern'), corr(pc2_vals', col_pattern'), corr(pc2_vals', cho_pattern'));
            fprintf('PC3: ctx=%.3f, col=%.3f, cho=%.3f\n', ...
                corr(pc3_vals', ctx_pattern'), corr(pc3_vals', col_pattern'), corr(pc3_vals', cho_pattern'));
        end
        
        function dPCA(obj)
            % Perform demixed PCA analysis
            
            if isempty(obj.all_x)
                error('Run simulate() first');
            end
            
            % Prepare data in dPCA format
            firingRatesAverage = zeros(obj.N, 2, 2, length(obj.time));
            
            % Map conditions to dPCA format
            firingRatesAverage(:,1,1,:) = obj.all_x(:,:,1);  % T1-Red-L
            firingRatesAverage(:,2,2,:) = obj.all_x(:,:,2);  % T1-Grn-R
            firingRatesAverage(:,1,2,:) = obj.all_x(:,:,3);  % T2-Red-R
            firingRatesAverage(:,2,1,:) = obj.all_x(:,:,4);  % T2-Grn-L
            
            % Add small noise to avoid numerical issues
            firingRatesAverage = firingRatesAverage + 0.001*randn(size(firingRatesAverage));
            
            % dPCA parameters
            combinedParams = {{1, [1 3]}, {2, [2 3]}, {3}, {[1 2], [1 2 3]}};
            margNames = {'Stimulus', 'Decision', 'Condition-independent', 'S/D Interaction'};
            margColours = [23 100 171; 187 20 25; 150 150 150; 114 97 171]/256;
            
            % Time vector (shifted to start at -T_color_onset)
            time_dpca = obj.time - obj.T_color_onset;
            timeEvents = 0;
            
            fprintf('\nRunning dPCA...\n');
            tic
            [W, V, whichMarg] = dpca(firingRatesAverage, 10, ...
                'combinedParams', combinedParams);
            toc
            
            % Compute explained variance
            explVar = dpca_explainedVariance(firingRatesAverage, W, V, ...
                'combinedParams', combinedParams);
            
            % Plot
            dpca_plot(firingRatesAverage, W, V, @dpca_plot_default, ...
                'explainedVar', explVar, ...
                'marginalizationNames', margNames, ...
                'marginalizationColours', margColours, ...
                'whichMarg', whichMarg, ...
                'time', time_dpca, ...
                'timeEvents', timeEvents, ...
                'timeMarginalization', 3, ...
                'legendSubplot', 16);
            
            % Add title
            sgtitle(sprintf('dPCA: %s model', obj.model_type), ...
                'FontSize', 14, 'FontWeight', 'bold');
            
            fprintf('dPCA complete\n');
            fprintf('\nExplained variance by marginalization:\n');
            fprintf('  Stimulus: %.1f%%\n', explVar.margVar(1));
            fprintf('  Decision: %.1f%%\n', explVar.margVar(2));
            fprintf('  Condition-independent: %.1f%%\n', explVar.margVar(3));
            fprintf('  S/D Interaction: %.1f%%\n', explVar.margVar(4));
        end
        
        function visualize(obj)
            % Create simplified visualization: 3D trajectories + PC time courses
            
            if isempty(obj.pc1)
                error('Run analyze() first');
            end
            
            labels = {'T1-Red-L', 'T1-Grn-R', 'T2-Red-R', 'T2-Grn-L'};
            cols = [0.8,0.2,0.2; 0.2,0.7,0.2; 0.8,0.2,0.2; 0.2,0.7,0.2];
            styles = {'-', '--', '--', '-'};
            
            figure('Position', [100,100,1400,600]);
            
            % 3D Trajectories
            subplot(1,4,1);
            for c = 1:4
                plot3(obj.pc1(:,c), obj.pc2(:,c), obj.pc3(:,c), styles{c}, ...
                    'Color', cols(c,:), 'LineWidth', 2.5);
                hold on;
                
                % Start marker
                plot3(obj.pc1(1,c), obj.pc2(1,c), obj.pc3(1,c), 'o', 'MarkerSize', 8, ...
                    'MarkerFaceColor', cols(c,:), 'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
                
                % Color onset marker
                t_onset = round(obj.T_color_onset/obj.dt);
                plot3(obj.pc1(t_onset,c), obj.pc2(t_onset,c), obj.pc3(t_onset,c), 'o', ...
                    'MarkerSize', 6, 'MarkerFaceColor', [0.6,0.2,0.6], ...
                    'MarkerEdgeColor', 'k', 'LineWidth', 1);
                
                % End marker
                plot3(obj.pc1(end,c), obj.pc2(end,c), obj.pc3(end,c), 'd', 'MarkerSize', 10, ...
                    'MarkerFaceColor', cols(c,:), 'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
            end
            
            xlabel('PC1', 'FontSize', 11, 'FontWeight', 'bold');
            ylabel('PC2', 'FontSize', 11, 'FontWeight', 'bold');
            zlabel('PC3', 'FontSize', 11, 'FontWeight', 'bold');
            title('3D Trajectories', 'FontSize', 12, 'FontWeight', 'bold');
            grid on; view(45, 30);
            
            % PC Time courses
            subplot(1,4,2);
            for c = 1:4
                plot(obj.time, obj.pc1(:,c), styles{c}, 'Color', cols(c,:), 'LineWidth', 2);
                hold on;
            end
            xline(obj.T_color_onset, 'k--', 'LineWidth', 1.5);
            xlabel('Time (ms)', 'FontSize', 11);
            ylabel('PC1', 'FontSize', 11, 'FontWeight', 'bold');
            title(sprintf('PC1 (%.0f%%)', obj.explained(1)), 'FontSize', 12);
            grid on;
            
            subplot(1,4,3);
            for c = 1:4
                plot(obj.time, obj.pc2(:,c), styles{c}, 'Color', cols(c,:), 'LineWidth', 2);
                hold on;
            end
            xline(obj.T_color_onset, 'k--', 'LineWidth', 1.5);
            xlabel('Time (ms)', 'FontSize', 11);
            ylabel('PC2', 'FontSize', 11, 'FontWeight', 'bold');
            title(sprintf('PC2 (%.0f%%)', obj.explained(2)), 'FontSize', 12);
            grid on;
            
            subplot(1,4,4);
            for c = 1:4
                plot(obj.time, obj.pc3(:,c), styles{c}, 'Color', cols(c,:), 'LineWidth', 2);
                hold on;
            end
            xline(obj.T_color_onset, 'k--', 'LineWidth', 1.5);
            xlabel('Time (ms)', 'FontSize', 11);
            ylabel('PC3', 'FontSize', 11, 'FontWeight', 'bold');
            title(sprintf('PC3 (%.0f%%)', obj.explained(3)), 'FontSize', 12);
            grid on;
            legend(labels, 'Location', 'best', 'FontSize', 9);
            
            sgtitle(sprintf('XOR Model: %s', obj.model_type), 'FontSize', 14, 'FontWeight', 'bold');
        end
    end
end