classdef XORModel_RotatedChoice < handle
    % XORModel_RotatedChoice - XOR model with context-dependent choice axes
    %
    % This model implements "switching with rotated attractors" where:
    % - Each context uses a DIFFERENT choice axis (rotated in Q3-Q5 plane)
    % - Choice representations are context-dependent
    % - Cross-context decoding accuracy decreases with rotation angle
    %
    % Key difference from XORModel3:
    %   - J1 and J2 have opposite color->choice coupling (same as before)
    %   - BUT the "choice" direction itself is different in each context
    %   - choice_dir_1 and choice_dir_2 are rotated by ±(angle/2) from Q(:,3)
    %
    % Usage:
    %   model = XORModel_RotatedChoice(60);  % 60° total separation
    %   model.simulate();
    %   model.analyze();
    %   model.visualize();
    %   model.compare_choice_axes();
    
    properties
        % Model parameters
        N = 100                 % Number of neurons
        tau = 50                % Time constant (ms)
        dt = 1                  % Time step (ms)
        T_total = 700           % Total trial time (ms)
        T_color_onset = 200     % Color onset time (ms)
        
        % Choice axis rotation
        choice_rotation_angle = 60  % Total separation between choice axes (degrees)
        
        % Network structure
        Q                       % Orthonormal basis
        Lambda_base             % Eigenvalues
        J_base                  % Base connectivity
        J1                      % System 1 (Context T1)
        J2                      % System 2 (Context T2)
        
        % Choice directions (context-dependent)
        choice_dir_1            % Choice axis for T1
        choice_dir_2            % Choice axis for T2
        color_dir               % Color input direction
        
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
        all_x = []              % Neural activity [N x time x 4conditions]
        all_x_centered = []     % Mean-subtracted activity
        time = []               % Time vector
        
        % Analysis results
        coeff = []              % PCA coefficients
        explained = []          % Variance explained
        pc1 = []
        pc2 = []
        pc3 = []                % PC projections
    end
    
    methods
        function obj = XORModel_RotatedChoice(choice_rotation_angle)
            % Constructor
            if nargin >= 1
                obj.choice_rotation_angle = choice_rotation_angle;
            end
            
            fprintf('Creating XORModel with Rotated Choice Axes...\n');
            fprintf('  Total angular separation: %.0f degrees\n', obj.choice_rotation_angle);
            fprintf('  Each context rotates by: ±%.0f degrees from Q(:,3)\n', ...
                obj.choice_rotation_angle/2);
            
            % Build network
            obj = obj.build_network();
            obj = obj.build_inputs();
            
            fprintf('Model created successfully\n');
        end
        
        function obj = build_network(obj)
            % Build network structure with rotated choice axes
            
            % Create orthonormal basis
            rng(42); % For reproducibility
            rN = randn(obj.N, obj.N);
            [obj.Q, ~] = qr(rN);
            
            % Define eigenvalues
            obj.Lambda_base = zeros(obj.N, obj.N);
            obj.Lambda_base(1,1) = 0.05;  % Context - weak
            obj.Lambda_base(2,2) = 0.1;   % Color - transient
            obj.Lambda_base(3,3) = 0.8;   % Choice subspace (dim 3)
            obj.Lambda_base(4,4) = 0.75;  % CI - stable
            obj.Lambda_base(5,5) = 0.8;   % Choice subspace (dim 5) - only used if rotation > 0
            for i = 6:obj.N
                obj.Lambda_base(i,i) = 0.6 + 0.2*rand();
            end
            
            % Build base dynamics
            J_start = obj.Q * obj.Lambda_base * obj.Q';
            
            % Add nonnormality - match XORModel3 exactly
            rng(42); % Use SAME seed as Q generation for consistency
            d = 4; % Only dimensions 1-4 in task subspace (like XORModel3)
            nonnormal_strength = 0.01;
            J_nonnormal = nonnormal_strength * randn(obj.N, obj.N);
            J_nonnormal(1:d, :) = 0;
            J_nonnormal(:, 1:d) = 0;
            
            % Task-specific nonnormality - match XORModel3
            J_nonnormal(1, 3) = 0.2;  % Choice -> Context
            J_nonnormal(2, 3) = 0.2;  % Choice -> Color
            J_nonnormal(4, 1:3) = 0.01 * randn(1, 3);  % CI receives from task
            
            obj.J_base = J_start + J_nonnormal;
            
            % Define color direction
            obj.color_dir = obj.Q(:,2);
            
            % Define ROTATED choice directions (symmetric rotation)
            theta = deg2rad(obj.choice_rotation_angle / 2);
            
            % T1: rotates by +theta from Q(:,3) toward Q(:,5)
            obj.choice_dir_1 = cos(theta)*obj.Q(:,3) + sin(theta)*obj.Q(:,5);
            obj.choice_dir_1 = obj.choice_dir_1 / norm(obj.choice_dir_1);
            
            % T2: rotates by -theta from Q(:,3) (opposite direction)
            obj.choice_dir_2 = cos(theta)*obj.Q(:,3) - sin(theta)*obj.Q(:,5);
            obj.choice_dir_2 = obj.choice_dir_2 / norm(obj.choice_dir_2);
            
            % Verify orthogonality to color
            fprintf('  Choice axes defined:\n');
            fprintf('    angle(choice_dir_1, Q(:,3)) = %.1f degrees\n', ...
                rad2deg(acos(obj.choice_dir_1' * obj.Q(:,3))));
            fprintf('    angle(choice_dir_2, Q(:,3)) = %.1f degrees\n', ...
                rad2deg(acos(obj.choice_dir_2' * obj.Q(:,3))));
            fprintf('    angle(choice_dir_1, choice_dir_2) = %.1f degrees\n', ...
                rad2deg(acos(obj.choice_dir_1' * obj.choice_dir_2)));
            
            % Build couplings with ROTATED choice directions
            % J1: negative coupling (color->choice for T1)
            J1_coupling = -obj.coupling_strength * (obj.choice_dir_1 * obj.color_dir');
            obj.J1 = obj.J_base + J1_coupling;
            
            % J2: positive coupling (color->choice for T2)
            J2_coupling = +obj.coupling_strength * (obj.choice_dir_2 * obj.color_dir');
            obj.J2 = obj.J_base + J2_coupling;
            
            fprintf('  Built J1 and J2 with rotated choice axes\n');
        end
        
        function obj = build_inputs(obj)
            % Build input structure
            
            % Heterogeneous tuning - use same seed as XORModel3
            rng(42);
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
            
            fprintf('\nSimulating rotated choice model...\n');
            
            for cond = 1:4
                context_sign = configs(cond);
                color_sign = colors(cond);
                
                % Select dynamics based on context
                if context_sign == 1
                    J_active = obj.J1;
                else
                    J_active = obj.J2;
                end
                
                % Simulate
                x = zeros(obj.N, n_time);
                x(:,1) = 0.01*randn(obj.N,1);
                
                for t = 1:(n_time-1)
                    current_time = obj.time(t);
                    
                    % Compute input
                    input = obj.compute_input(context_sign, color_sign, current_time);
                    
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
        
        function input = compute_input(obj, context_sign, color_sign, current_time)
            % Compute total input at current time
            
            % Context input
            input = context_sign * obj.B_context * obj.I0_context;
            
            % Condition-independent ramping
            ramp_strength = 0.8 * (current_time / obj.T_total);
            input = input + ramp_strength * obj.B_ci * obj.I0_ci;
            
            % Color input (after onset)
            if current_time >= obj.T_color_onset + 30
                input = input + color_sign * obj.B_color * obj.I0_color;
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
        
        function compare_choice_axes(obj)
            % Analyze and visualize the relationship between choice axes
            
            if isempty(obj.all_x)
                error('Run simulate() first');
            end
            
            fprintf('\n=== Choice Axis Analysis ===\n');
            
            % 1. Geometric relationship
            cos_angle = obj.choice_dir_1' * obj.choice_dir_2;
            angle_between = rad2deg(acos(cos_angle));
            
            fprintf('\nGeometric properties:\n');
            fprintf('  Angle between choice axes: %.1f degrees\n', angle_between);
            fprintf('  Dot product: %.3f\n', cos_angle);
            fprintf('  Expected cross-context decoding: ~%.1f%%\n', 100*cos_angle^2);
            
            % 2. Project final states onto each choice axis
            fprintf('\nFinal state projections:\n');
            
            for cond = 1:4
                x_final = obj.all_x(:,end,cond);
                proj_1 = obj.choice_dir_1' * x_final;
                proj_2 = obj.choice_dir_2' * x_final;
                
                labels = {'T1-Red-L', 'T1-Grn-R', 'T2-Red-R', 'T2-Grn-L'};
                fprintf('  %s: choice_axis_1=%.2f, choice_axis_2=%.2f\n', ...
                    labels{cond}, proj_1, proj_2);
            end
            
            % 3. Components in Q(:,3) and Q(:,5)
            fprintf('\nChoice axis decomposition:\n');
            fprintf('  T1 axis: %.3f*Q(:,3) + %.3f*Q(:,5)\n', ...
                obj.choice_dir_1' * obj.Q(:,3), obj.choice_dir_1' * obj.Q(:,5));
            fprintf('  T2 axis: %.3f*Q(:,3) + %.3f*Q(:,5)\n', ...
                obj.choice_dir_2' * obj.Q(:,3), obj.choice_dir_2' * obj.Q(:,5));
            
            % 4. Visualize in Q3-Q5 plane
            figure('Position', [100, 100, 800, 600]);
            
            % Plot basis vectors
            quiver(0, 0, 1, 0, 'k', 'LineWidth', 2, 'MaxHeadSize', 0.5);
            hold on;
            quiver(0, 0, 0, 1, 'k', 'LineWidth', 2, 'MaxHeadSize', 0.5);
            text(1.1, 0, 'Q(:,3)', 'FontSize', 12, 'FontWeight', 'bold');
            text(0, 1.1, 'Q(:,5)', 'FontSize', 12, 'FontWeight', 'bold');
            
            % Plot choice axes
            choice1_q3 = obj.choice_dir_1' * obj.Q(:,3);
            choice1_q5 = obj.choice_dir_1' * obj.Q(:,5);
            choice2_q3 = obj.choice_dir_2' * obj.Q(:,3);
            choice2_q5 = obj.choice_dir_2' * obj.Q(:,5);
            
            quiver(0, 0, choice1_q3, choice1_q5, 'r', 'LineWidth', 3, 'MaxHeadSize', 0.3);
            quiver(0, 0, choice2_q3, choice2_q5, 'b', 'LineWidth', 3, 'MaxHeadSize', 0.3);
            
            text(choice1_q3*1.15, choice1_q5*1.15, 'T1 choice axis', ...
                'FontSize', 11, 'Color', 'r', 'FontWeight', 'bold');
            text(choice2_q3*1.15, choice2_q5*1.15, 'T2 choice axis', ...
                'FontSize', 11, 'Color', 'b', 'FontWeight', 'bold');
            
            % Formatting
            axis equal;
            xlim([-0.2, 1.3]);
            ylim([-0.2, 1.3]);
            grid on;
            xlabel('Q(:,3) component', 'FontSize', 12, 'FontWeight', 'bold');
            ylabel('Q(:,5) component', 'FontSize', 12, 'FontWeight', 'bold');
            title(sprintf('Choice Axes in Q(:,3)-Q(:,5) Plane (%.0f° separation)', ...
                angle_between), 'FontSize', 14, 'FontWeight', 'bold');
            legend('Q(:,3) basis', 'Q(:,5) basis', 'T1 choice', 'T2 choice', ...
                'Location', 'southeast');
        end
        
        function visualize_rotation_in_PC_space(obj)
            % Visualize how the rotation appears in PC space with detailed annotations
            
            if isempty(obj.pc1)
                error('Run analyze() first');
            end
            
            labels = {'T1-Red-L', 'T1-Grn-R', 'T2-Red-R', 'T2-Grn-L'};
            cols = [0.8,0.2,0.2; 0.2,0.7,0.2; 0.8,0.2,0.2; 0.2,0.7,0.2];
            
            figure('Position', [100, 100, 1600, 900]);
            
            % Panel 1: Original basis (Q3-Q5 plane)
            subplot(2,3,1);
            hold on;
            
            % Plot basis
            quiver(0, 0, 1, 0, 'k', 'LineWidth', 2.5, 'MaxHeadSize', 0.4);
            quiver(0, 0, 0, 1, 'k', 'LineWidth', 2.5, 'MaxHeadSize', 0.4);
            
            % Plot rotated choice axes
            theta = deg2rad(obj.choice_rotation_angle / 2);
            c1_q3 = cos(theta); c1_q5 = sin(theta);
            c2_q3 = cos(theta); c2_q5 = -sin(theta);
            
            quiver(0, 0, c1_q3, c1_q5, 'r', 'LineWidth', 3, 'MaxHeadSize', 0.3);
            quiver(0, 0, c2_q3, c2_q5, 'b', 'LineWidth', 3, 'MaxHeadSize', 0.3);
            
            text(1.1, 0, 'Q(:,3)', 'FontSize', 12, 'FontWeight', 'bold');
            text(0, 1.1, 'Q(:,5)', 'FontSize', 12, 'FontWeight', 'bold');
            text(c1_q3*1.15, c1_q5*1.15, 'T1', 'Color', 'r', 'FontSize', 11, 'FontWeight', 'bold');
            text(c2_q3*1.15, c2_q5*1.15, 'T2', 'Color', 'b', 'FontSize', 11, 'FontWeight', 'bold');
            
            axis equal; grid on;
            xlim([-0.2, 1.3]); ylim([-0.8, 0.8]);
            xlabel('Q(:,3)'); ylabel('Q(:,5)');
            title('Choice Axes in Original Basis', 'FontSize', 13, 'FontWeight', 'bold');
            
            % Panel 2: PC1-PC2 plane (final states only)
            subplot(2,3,2);
            hold on;
            
            % Plot final states
            for c = 1:4
                plot(obj.pc1(end,c), obj.pc2(end,c), 'o', 'MarkerSize', 16, ...
                    'MarkerFaceColor', cols(c,:), 'MarkerEdgeColor', 'k', 'LineWidth', 2);
            end
            
            % Draw lines connecting same-choice conditions
            plot([obj.pc1(end,1), obj.pc1(end,3)], [obj.pc2(end,1), obj.pc2(end,3)], ...
                'k--', 'LineWidth', 1.5); % Left choices
            plot([obj.pc1(end,2), obj.pc1(end,4)], [obj.pc2(end,2), obj.pc2(end,4)], ...
                'k--', 'LineWidth', 1.5); % Right choices
            
            % Annotate
            for c = 1:4
                text(obj.pc1(end,c)*1.1, obj.pc2(end,c)*1.1, labels{c}, ...
                    'FontSize', 10, 'FontWeight', 'bold');
            end
            
            grid on; axis equal;
            xlabel(sprintf('PC1 (%.0f%% var)', obj.explained(1)), 'FontSize', 11);
            ylabel(sprintf('PC2 (%.0f%% var)', obj.explained(2)), 'FontSize', 11);
            title('Final States in PC Space', 'FontSize', 13, 'FontWeight', 'bold');
            
            % Panel 3: PC1-PC2 with choice vectors
            subplot(2,3,3);
            hold on;
            
            % Plot final states
            for c = 1:4
                plot(obj.pc1(end,c), obj.pc2(end,c), 'o', 'MarkerSize', 16, ...
                    'MarkerFaceColor', cols(c,:), 'MarkerEdgeColor', 'k', 'LineWidth', 2);
            end
            
            % Compute T1 choice direction in PC space
            t1_left = [obj.pc1(end,1); obj.pc2(end,1)];
            t1_right = [obj.pc1(end,2); obj.pc2(end,2)];
            t1_choice_dir = (t1_right - t1_left) / norm(t1_right - t1_left);
            t1_center = (t1_left + t1_right) / 2;
            
            % Compute T2 choice direction in PC space
            t2_left = [obj.pc1(end,4); obj.pc2(end,4)];
            t2_right = [obj.pc1(end,3); obj.pc2(end,3)];
            t2_choice_dir = (t2_right - t2_left) / norm(t2_right - t2_left);
            t2_center = (t2_left + t2_right) / 2;
            
            % Plot choice vectors
            scale = 30;
            quiver(t1_center(1), t1_center(2), t1_choice_dir(1)*scale, t1_choice_dir(2)*scale, ...
                'r', 'LineWidth', 3, 'MaxHeadSize', 0.5, 'AutoScale', 'off');
            quiver(t2_center(1), t2_center(2), t2_choice_dir(1)*scale, t2_choice_dir(2)*scale, ...
                'b', 'LineWidth', 3, 'MaxHeadSize', 0.5, 'AutoScale', 'off');
            
            % Compute angle between choice directions
            angle_pc = rad2deg(acos(t1_choice_dir' * t2_choice_dir));
            text(0.05, 0.95, sprintf('Angle = %.1f°', angle_pc), ...
                'Units', 'normalized', 'FontSize', 11, 'FontWeight', 'bold', ...
                'BackgroundColor', 'w', 'EdgeColor', 'k');
            
            grid on; axis equal;
            xlabel(sprintf('PC1 (%.0f%% var)', obj.explained(1)), 'FontSize', 11);
            ylabel(sprintf('PC2 (%.0f%% var)', obj.explained(2)), 'FontSize', 11);
            title('Choice Directions in PC Space', 'FontSize', 13, 'FontWeight', 'bold');
            
            % Panel 4: PC1 time courses (T1 vs T2)
            subplot(2,3,4);
            hold on;
            
            % T1 conditions
            plot(obj.time, obj.pc1(:,1), '-', 'Color', cols(1,:), 'LineWidth', 2.5);
            plot(obj.time, obj.pc1(:,2), '--', 'Color', cols(2,:), 'LineWidth', 2.5);
            % T2 conditions
            plot(obj.time, obj.pc1(:,3), '--', 'Color', cols(3,:), 'LineWidth', 2.5);
            plot(obj.time, obj.pc1(:,4), '-', 'Color', cols(4,:), 'LineWidth', 2.5);
            
            xline(obj.T_color_onset, 'k--', 'LineWidth', 1.5);
            xlabel('Time (ms)', 'FontSize', 11);
            ylabel(sprintf('PC1 (%.0f%% var)', obj.explained(1)), 'FontSize', 11, 'FontWeight', 'bold');
            title('PC1: Shared Choice Component', 'FontSize', 13, 'FontWeight', 'bold');
            legend(labels, 'Location', 'best', 'FontSize', 9);
            grid on;
            
            % Panel 5: PC2 time courses (showing rotation)
            subplot(2,3,5);
            hold on;
            
            % T1 conditions
            plot(obj.time, obj.pc2(:,1), '-', 'Color', cols(1,:), 'LineWidth', 2.5);
            plot(obj.time, obj.pc2(:,2), '--', 'Color', cols(2,:), 'LineWidth', 2.5);
            % T2 conditions
            plot(obj.time, obj.pc2(:,3), '--', 'Color', cols(3,:), 'LineWidth', 2.5);
            plot(obj.time, obj.pc2(:,4), '-', 'Color', cols(4,:), 'LineWidth', 2.5);
            
            xline(obj.T_color_onset, 'k--', 'LineWidth', 1.5);
            xlabel('Time (ms)', 'FontSize', 11);
            ylabel(sprintf('PC2 (%.0f%% var)', obj.explained(2)), 'FontSize', 11, 'FontWeight', 'bold');
            title('PC2: Context-Specific Component (Q(:,5))', 'FontSize', 13, 'FontWeight', 'bold');
            legend(labels, 'Location', 'best', 'FontSize', 9);
            grid on;
            
            % Annotation for PC2
            text(0.5, 0.95, 'T1: positive PC2 for both choices', ...
                'Units', 'normalized', 'FontSize', 10, 'Color', 'r', ...
                'HorizontalAlignment', 'center', 'FontWeight', 'bold');
            text(0.5, 0.88, 'T2: negative PC2 for both choices', ...
                'Units', 'normalized', 'FontSize', 10, 'Color', 'b', ...
                'HorizontalAlignment', 'center', 'FontWeight', 'bold');
            
            % Panel 6: Schematic explanation
            subplot(2,3,6);
            axis off;
            
            % Draw schematic
            text(0.5, 0.95, 'How Rotation Works:', ...
                'FontSize', 13, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
            
            text(0.1, 0.80, sprintf('Original: choice_axis = Q(:,3)'), ...
                'FontSize', 11, 'Color', 'k');
            text(0.1, 0.70, sprintf('→ Left and Right differ only in PC1'), ...
                'FontSize', 10, 'Color', [0.5,0.5,0.5]);
            
            text(0.1, 0.55, sprintf('Rotated (%.0f°):', obj.choice_rotation_angle), ...
                'FontSize', 11, 'Color', 'k', 'FontWeight', 'bold');
            text(0.1, 0.45, 'T1: choice_axis = cos(θ)Q(:,3) + sin(θ)Q(:,5)', ...
                'FontSize', 10, 'Color', 'r');
            text(0.1, 0.38, '→ Left-Right separation has PC1 AND PC2', ...
                'FontSize', 9, 'Color', 'r');
            
            text(0.1, 0.28, 'T2: choice_axis = cos(θ)Q(:,3) - sin(θ)Q(:,5)', ...
                'FontSize', 10, 'Color', 'b');
            text(0.1, 0.21, '→ Left-Right separation has PC1 AND -PC2', ...
                'FontSize', 9, 'Color', 'b');
            
            text(0.1, 0.08, 'Result: Choice axes point in different', ...
                'FontSize', 11, 'FontWeight', 'bold');
            text(0.1, 0.01, 'directions in PC space!', ...
                'FontSize', 11, 'FontWeight', 'bold');
            
            sgtitle(sprintf('Visualizing Choice Axis Rotation (%.0f° separation)', ...
                obj.choice_rotation_angle), 'FontSize', 15, 'FontWeight', 'bold');
        end
        
        function visualize(obj)
            % Create visualization: 3D trajectories + PC time courses
            
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
            
            sgtitle(sprintf('Rotated Choice Model (%.0f° separation)', obj.choice_rotation_angle), ...
                'FontSize', 14, 'FontWeight', 'bold');
        end
        
        function analyze_choice_geometry(obj)
            % Comprehensive analysis to prove choice axes are different across contexts
            
            if isempty(obj.all_x)
                error('Run simulate() first');
            end
            
            fprintf('\n=== Choice Geometry Analysis ===\n');
            
            % Extract final states for each condition
            X_T1_left = obj.all_x(:, end, 1);   % T1-Red-L
            X_T1_right = obj.all_x(:, end, 2);  % T1-Grn-R
            X_T2_left = obj.all_x(:, end, 4);   % T2-Grn-L
            X_T2_right = obj.all_x(:, end, 3);  % T2-Red-R
            
            % 1. Compute empirical choice axes from data
            choice_axis_T1_empirical = (X_T1_right - X_T1_left) / norm(X_T1_right - X_T1_left);
            choice_axis_T2_empirical = (X_T2_right - X_T2_left) / norm(X_T2_right - X_T2_left);
            
            % 2. Compare to ground truth
            angle_empirical = rad2deg(acos(choice_axis_T1_empirical' * choice_axis_T2_empirical));
            angle_ground_truth = rad2deg(acos(obj.choice_dir_1' * obj.choice_dir_2));
            
            fprintf('\n1. CHOICE AXIS ANGLES:\n');
            fprintf('   Ground truth (model design): %.2f degrees\n', angle_ground_truth);
            fprintf('   Empirical (from final states): %.2f degrees\n', angle_empirical);
            fprintf('   Match: %s\n', iif(abs(angle_empirical - angle_ground_truth) < 5, 'YES ✓', 'NO ✗'));
            
            % 3. Project final states onto each context's choice axis
            fprintf('\n2. ATTRACTOR LOCATIONS:\n');
            fprintf('   Projections onto T1 choice axis:\n');
            fprintf('      T1-Left:  %.3f\n', choice_axis_T1_empirical' * X_T1_left);
            fprintf('      T1-Right: %.3f\n', choice_axis_T1_empirical' * X_T1_right);
            fprintf('      T2-Left:  %.3f\n', choice_axis_T1_empirical' * X_T2_left);
            fprintf('      T2-Right: %.3f\n', choice_axis_T1_empirical' * X_T2_right);
            
            fprintf('\n   Projections onto T2 choice axis:\n');
            fprintf('      T1-Left:  %.3f\n', choice_axis_T2_empirical' * X_T1_left);
            fprintf('      T1-Right: %.3f\n', choice_axis_T2_empirical' * X_T1_right);
            fprintf('      T2-Left:  %.3f\n', choice_axis_T2_empirical' * X_T2_left);
            fprintf('      T2-Right: %.3f\n', choice_axis_T2_empirical' * X_T2_right);
            
            % 4. Simulate cross-context decoding
            fprintf('\n3. CROSS-CONTEXT DECODING SIMULATION:\n');
            
            % Train on T1, test on T2
            decoder_T1 = choice_axis_T1_empirical;  % Simple linear decoder
            prediction_T2_left = sign(decoder_T1' * X_T2_left);
            prediction_T2_right = sign(decoder_T1' * X_T2_right);
            accuracy_1to2 = mean([prediction_T2_left < 0, prediction_T2_right > 0]) * 100;
            
            % Train on T2, test on T1
            decoder_T2 = choice_axis_T2_empirical;
            prediction_T1_left = sign(decoder_T2' * X_T1_left);
            prediction_T1_right = sign(decoder_T2' * X_T1_right);
            accuracy_2to1 = mean([prediction_T1_left < 0, prediction_T1_right > 0]) * 100;
            
            fprintf('   T1→T2 decoding accuracy: %.1f%%\n', accuracy_1to2);
            fprintf('   T2→T1 decoding accuracy: %.1f%%\n', accuracy_2to1);
            fprintf('   Average: %.1f%%\n', mean([accuracy_1to2, accuracy_2to1]));
            fprintf('   Expected from angle: %.1f%%\n', 100 * cosd(angle_empirical)^2);
            
            % 5. Decomposition into Q(:,3) and Q(:,5)
            fprintf('\n4. DECOMPOSITION INTO BASIS DIMENSIONS:\n');
            fprintf('   T1 choice axis: %.3f*Q(:,3) + %.3f*Q(:,5)\n', ...
                choice_axis_T1_empirical' * obj.Q(:,3), choice_axis_T1_empirical' * obj.Q(:,5));
            fprintf('   T2 choice axis: %.3f*Q(:,3) + %.3f*Q(:,5)\n', ...
                choice_axis_T2_empirical' * obj.Q(:,3), choice_axis_T2_empirical' * obj.Q(:,5));
            fprintf('   Shared Q(:,3) component: %.1f%%\n', ...
                100 * (choice_axis_T1_empirical' * obj.Q(:,3))^2);
            
            % 6. Create comprehensive visualization
            figure('Position', [50, 50, 1800, 1000]);
            
            % Panel A: Choice axes in Q3-Q5 plane
            subplot(2,4,1);
            hold on;
            quiver(0, 0, 1, 0, 'k', 'LineWidth', 2, 'MaxHeadSize', 0.5);
            quiver(0, 0, 0, 1, 'k', 'LineWidth', 2, 'MaxHeadSize', 0.5);
            text(1.1, 0, 'Q(:,3)', 'FontSize', 11, 'FontWeight', 'bold');
            text(0, 1.1, 'Q(:,5)', 'FontSize', 11, 'FontWeight', 'bold');
            
            % Ground truth
            c1_q3 = obj.choice_dir_1' * obj.Q(:,3);
            c1_q5 = obj.choice_dir_1' * obj.Q(:,5);
            c2_q3 = obj.choice_dir_2' * obj.Q(:,3);
            c2_q5 = obj.choice_dir_2' * obj.Q(:,5);
            quiver(0, 0, c1_q3, c1_q5, 'r', 'LineWidth', 3, 'MaxHeadSize', 0.3);
            quiver(0, 0, c2_q3, c2_q5, 'b', 'LineWidth', 3, 'MaxHeadSize', 0.3);
            
            axis equal; grid on;
            xlim([-0.2, 1.3]); ylim([-0.8, 0.8]);
            title(sprintf('Ground Truth\n(%.0f° separation)', angle_ground_truth), ...
                'FontSize', 12, 'FontWeight', 'bold');
            legend('Q(:,3)', 'Q(:,5)', 'T1 axis', 'T2 axis', 'Location', 'southeast');
            
            % Panel B: Empirical choice axes
            subplot(2,4,2);
            hold on;
            quiver(0, 0, 1, 0, 'k', 'LineWidth', 2, 'MaxHeadSize', 0.5);
            quiver(0, 0, 0, 1, 'k', 'LineWidth', 2, 'MaxHeadSize', 0.5);
            
            e1_q3 = choice_axis_T1_empirical' * obj.Q(:,3);
            e1_q5 = choice_axis_T1_empirical' * obj.Q(:,5);
            e2_q3 = choice_axis_T2_empirical' * obj.Q(:,3);
            e2_q5 = choice_axis_T2_empirical' * obj.Q(:,5);
            quiver(0, 0, e1_q3, e1_q5, 'r', 'LineWidth', 3, 'MaxHeadSize', 0.3);
            quiver(0, 0, e2_q3, e2_q5, 'b', 'LineWidth', 3, 'MaxHeadSize', 0.3);
            
            axis equal; grid on;
            xlim([-0.2, 1.3]); ylim([-0.8, 0.8]);
            title(sprintf('Empirical\n(%.0f° separation)', angle_empirical), ...
                'FontSize', 12, 'FontWeight', 'bold');
            
            % Panel C: Final states in full neural space (projected to Q3-Q5)
            subplot(2,4,3);
            hold on;
            
            % Project final states onto Q3-Q5 plane
            states_q3 = [X_T1_left, X_T1_right, X_T2_left, X_T2_right]' * obj.Q(:,3);
            states_q5 = [X_T1_left, X_T1_right, X_T2_left, X_T2_right]' * obj.Q(:,5);
            
            cols = [0.8,0.2,0.2; 0.2,0.7,0.2; 0.2,0.7,0.2; 0.8,0.2,0.2];
            labels = {'T1-L', 'T1-R', 'T2-L', 'T2-R'};
            for i = 1:4
                plot(states_q3(i), states_q5(i), 'o', 'MarkerSize', 14, ...
                    'MarkerFaceColor', cols(i,:), 'MarkerEdgeColor', 'k', 'LineWidth', 2);
                text(states_q3(i)*1.15, states_q5(i)*1.15, labels{i}, 'FontSize', 10);
            end
            
            % Draw choice axes through the states
            plot([states_q3(1), states_q3(2)], [states_q5(1), states_q5(2)], ...
                'r-', 'LineWidth', 2.5);
            plot([states_q3(3), states_q3(4)], [states_q5(3), states_q5(4)], ...
                'b-', 'LineWidth', 2.5);
            
            grid on; axis equal;
            xlabel('Q(:,3) projection');
            ylabel('Q(:,5) projection');
            title('Final States', 'FontSize', 12, 'FontWeight', 'bold');
            
            % Panel D: Cross-context decoding illustration
            subplot(2,4,4);
            hold on;
            
            % Show T1 decoder applied to T2 states
            x_range = linspace(min(states_q3)-20, max(states_q3)+20, 100);
            
            % T1 decoder (decision boundary perpendicular to T1 choice axis)
            if abs(e1_q5) > 0.01
                y_T1_boundary = -(e1_q3/e1_q5) * x_range;
                plot(x_range, y_T1_boundary, 'r--', 'LineWidth', 2);
            end
            
            % T2 decoder
            if abs(e2_q5) > 0.01
                y_T2_boundary = -(e2_q3/e2_q5) * x_range;
                plot(x_range, y_T2_boundary, 'b--', 'LineWidth', 2);
            end
            
            % Plot states
            for i = 1:4
                plot(states_q3(i), states_q5(i), 'o', 'MarkerSize', 14, ...
                    'MarkerFaceColor', cols(i,:), 'MarkerEdgeColor', 'k', 'LineWidth', 2);
            end
            
            grid on; axis equal;
            xlabel('Q(:,3) projection');
            ylabel('Q(:,5) projection');
            title('Decoding Boundaries', 'FontSize', 12, 'FontWeight', 'bold');
            legend('T1 decoder', 'T2 decoder', 'Location', 'best');
            
            % Panel E: Projection onto T1 choice axis
            subplot(2,4,5);
            projections_T1 = [choice_axis_T1_empirical' * X_T1_left, ...
                             choice_axis_T1_empirical' * X_T1_right, ...
                             choice_axis_T1_empirical' * X_T2_left, ...
                             choice_axis_T1_empirical' * X_T2_right];
            bar(projections_T1, 'FaceColor', 'flat', 'CData', cols);
            set(gca, 'XTickLabel', labels);
            ylabel('Projection onto T1 choice axis');
            title('T1 Decoder View', 'FontSize', 12, 'FontWeight', 'bold');
            grid on;
            yline(0, 'k--', 'LineWidth', 1.5);
            
            % Panel F: Projection onto T2 choice axis
            subplot(2,4,6);
            projections_T2 = [choice_axis_T2_empirical' * X_T1_left, ...
                             choice_axis_T2_empirical' * X_T1_right, ...
                             choice_axis_T2_empirical' * X_T2_left, ...
                             choice_axis_T2_empirical' * X_T2_right];
            bar(projections_T2, 'FaceColor', 'flat', 'CData', cols);
            set(gca, 'XTickLabel', labels);
            ylabel('Projection onto T2 choice axis');
            title('T2 Decoder View', 'FontSize', 12, 'FontWeight', 'bold');
            grid on;
            yline(0, 'k--', 'LineWidth', 1.5);
            
            % Panel G: Overlap matrix
            subplot(2,4,7);
            overlap = [choice_axis_T1_empirical' * choice_axis_T1_empirical, ...
                      choice_axis_T1_empirical' * choice_axis_T2_empirical; ...
                      choice_axis_T2_empirical' * choice_axis_T1_empirical, ...
                      choice_axis_T2_empirical' * choice_axis_T2_empirical];
            imagesc(overlap);
            colorbar;
            caxis([0, 1]);
            set(gca, 'XTick', 1:2, 'XTickLabel', {'T1', 'T2'}, ...
                    'YTick', 1:2, 'YTickLabel', {'T1', 'T2'});
            title('Choice Axis Overlap', 'FontSize', 12, 'FontWeight', 'bold');
            xlabel('Test Context');
            ylabel('Train Context');
            colormap(jet);
            
            % Add text annotations
            for i = 1:2
                for j = 1:2
                    text(j, i, sprintf('%.2f', overlap(i,j)), ...
                        'HorizontalAlignment', 'center', 'FontSize', 14, ...
                        'FontWeight', 'bold', 'Color', 'w');
                end
            end
            
            % Panel H: Summary metrics
            subplot(2,4,8);
            axis off;
            
            text(0.1, 0.9, 'SUMMARY METRICS:', 'FontSize', 13, 'FontWeight', 'bold');
            
            text(0.1, 0.75, sprintf('Rotation angle: %.1f°', angle_empirical), 'FontSize', 11);
            text(0.1, 0.65, sprintf('Cross-ctx accuracy: %.1f%%', mean([accuracy_1to2, accuracy_2to1])), ...
                'FontSize', 11, 'FontWeight', 'bold', ...
                'Color', iif(mean([accuracy_1to2, accuracy_2to1]) < 95, [0.8,0,0], [0,0.6,0]));
            
            text(0.1, 0.50, 'Interpretation:', 'FontSize', 11, 'FontWeight', 'bold');
            if angle_empirical < 5
                interp_text = 'SAME choice axis';
                interp_color = [0, 0.6, 0];
            elseif angle_empirical < 45
                interp_text = 'Moderately DIFFERENT';
                interp_color = [0.8, 0.5, 0];
            else
                interp_text = 'Strongly DIFFERENT';
                interp_color = [0.8, 0, 0];
            end
            text(0.1, 0.40, interp_text, 'FontSize', 11, 'Color', interp_color, 'FontWeight', 'bold');
            
            text(0.1, 0.25, 'Shared component:', 'FontSize', 11);
            text(0.1, 0.15, sprintf('  Q(:,3): %.1f%%', 100*(e1_q3^2 + e2_q3^2)/2), 'FontSize', 10);
            text(0.1, 0.05, sprintf('  Q(:,5): %.1f%%', 100*(e1_q5^2 + e2_q5^2)/2), 'FontSize', 10);
            
            sgtitle(sprintf('Choice Geometry Analysis: %.0f° Rotation Model', ...
                obj.choice_rotation_angle), 'FontSize', 15, 'FontWeight', 'bold');
        end
        
        function sweep_rotation_angles(obj)
            % Sweep through different rotation angles and compare
            
            angles = 0:15:90;
            n_angles = length(angles);
            
            cross_context_similarity = zeros(n_angles, 1);
            pc1_choice_corr = zeros(n_angles, 1);
            pc2_choice_corr = zeros(n_angles, 1);
            
            fprintf('\n=== Sweeping Rotation Angles ===\n');
            
            for i = 1:n_angles
                fprintf('\nTesting angle: %.0f degrees...\n', angles(i));
                
                % Create and run model
                test_model = XORModel_RotatedChoice(angles(i));
                test_model.simulate();
                test_model.analyze();
                
                % Compute cross-context similarity
                cos_angle = test_model.choice_dir_1' * test_model.choice_dir_2;
                cross_context_similarity(i) = cos_angle;
                
                % Compute choice correlation with PCs
                cho_pattern = [-1, 1, 1, -1];
                pc1_vals = [test_model.pc1(end,1), test_model.pc1(end,2), ...
                           test_model.pc1(end,3), test_model.pc1(end,4)];
                pc2_vals = [test_model.pc2(end,1), test_model.pc2(end,2), ...
                           test_model.pc2(end,3), test_model.pc2(end,4)];
                
                pc1_choice_corr(i) = abs(corr(pc1_vals', cho_pattern'));
                pc2_choice_corr(i) = abs(corr(pc2_vals', cho_pattern'));
            end
            
            % Plot results
            figure('Position', [100, 100, 1200, 400]);
            
            subplot(1,3,1);
            plot(angles, cross_context_similarity, 'o-', 'LineWidth', 2, 'MarkerSize', 8);
            xlabel('Rotation Angle (degrees)', 'FontSize', 11);
            ylabel('Dot Product (choice_dir_1, choice_dir_2)', 'FontSize', 11);
            title('Cross-Context Similarity', 'FontSize', 12, 'FontWeight', 'bold');
            grid on;
            
            subplot(1,3,2);
            plot(angles, 100*cross_context_similarity.^2, 'o-', 'LineWidth', 2, 'MarkerSize', 8);
            xlabel('Rotation Angle (degrees)', 'FontSize', 11);
            ylabel('Expected Decoding Accuracy (%)', 'FontSize', 11);
            title('Cross-Context Decoding', 'FontSize', 12, 'FontWeight', 'bold');
            grid on;
            ylim([0, 100]);
            
            subplot(1,3,3);
            plot(angles, pc1_choice_corr, 'o-', 'LineWidth', 2, 'MarkerSize', 8);
            hold on;
            plot(angles, pc2_choice_corr, 's-', 'LineWidth', 2, 'MarkerSize', 8);
            xlabel('Rotation Angle (degrees)', 'FontSize', 11);
            ylabel('|Correlation| with Choice', 'FontSize', 11);
            title('PC-Choice Relationship', 'FontSize', 12, 'FontWeight', 'bold');
            legend('PC1', 'PC2', 'Location', 'best');
            grid on;
            
            sgtitle('Effect of Choice Axis Rotation', 'FontSize', 14, 'FontWeight', 'bold');
        end
    end
end

% Helper function for inline if
function out = iif(condition, true_val, false_val)
    if condition
        out = true_val;
    else
        out = false_val;
    end
end