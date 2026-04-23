function visualize_flow_field_switching(obj, show_inputs)
    % Debug version to understand flow field differences in switching model
    
    normalizer = 0.01;
    baseSize = 0.7;
    
    if nargin < 2
        show_inputs = true;  % Set false to see pure J1 vs J2 dynamics
    end
    
    if ~strcmp(obj.model_type, 'switching')
        error('This visualization is for switching dynamics model only');
    end
    
    color_axis = obj.Q(:,2);  % Color dimension
    choice_axis = obj.Q(:,3); % Choice dimension
    
    % Create 2D grid in choice-color plane
    n_grid = 10;
    chLim = [-4 4];
    
    choice_range = linspace(chLim(1), chLim(2), n_grid);
    color_range = linspace(-2, 2, n_grid);
    [Choice_grid, Color_grid] = meshgrid(choice_range, color_range);
    
    figure('Position', [100, 100, 1400, 600]);
    
    % Context T1 (J1)
    subplot(1,2,1);
    hold on;
    
    context_sign = 1;
    color_sign = 1;  % Red
    
    if show_inputs
        % With inputs
        input_base = context_sign * obj.B_context * obj.I0_context + ...
                     0.5 * obj.B_ci * obj.I0_ci;
        input_color = color_sign * obj.B_color * obj.I0_color;
        total_input = input_base + input_color;
    else
        % No inputs - pure J1 dynamics
        total_input = zeros(obj.N, 1);
    end

    for i = 1:n_grid
        for j = 1:n_grid
            x_curr = Color_grid(i,j) * color_axis + ...
                    Choice_grid(i,j) * choice_axis;
            
            % Dynamics: dx/dt = -x + J1*x + input
            dx = (1/obj.tau) * (-x_curr + obj.J1 * x_curr + total_input);
            
            dx_choice = dot(dx, choice_axis);
            dx_color = dot(dx, color_axis);
            
            norm_dx = sqrt(dx_choice^2 + dx_color^2);
            if norm_dx > 0.001
                scale = baseSize / (norm_dx + normalizer);
                quiver(Choice_grid(i,j), Color_grid(i,j), ...
                       dx_choice*scale, dx_color*scale, 0, ...
                       'color', [0.6 0.6 0.6], 'LineWidth', 1.2, ...
                       'MaxHeadSize', 50);
            end
        end
    end
    
    % Show input vector if enabled
    if show_inputs
        input_choice = dot(total_input, choice_axis);
        input_color = dot(total_input, color_axis);
        quiver(0, 0, input_choice*0.5, input_color*0.5, 0, ...
               'm', 'LineWidth', 4, 'MaxHeadSize', 1.5);
        text(input_choice*0.3, input_color*0.3 + 0.3, ...
             sprintf('Input (ctx=%+d, col=%+d)', context_sign, color_sign), ...
             'Color', 'm', 'FontSize', 10);
    end
    
    % Overlay actual trajectory for T1-Red-Left
    if ~isempty(obj.all_x) && show_inputs
        traj = obj.all_x(:,:,1);
        traj_choice = traj' * choice_axis;
        traj_color = traj' * color_axis;
        plot(traj_choice, traj_color, 'r-', 'LineWidth', 3);
        plot(traj_choice(1), traj_color(1), 'go', 'MarkerSize', 10, ...
             'MarkerFaceColor', 'g', 'LineWidth', 2);
        plot(traj_choice(end), traj_color(end), 'rd', 'MarkerSize', 12, ...
             'MarkerFaceColor', 'r', 'LineWidth', 2);
    end
    
    xlabel('Choice axis', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Color axis', 'FontSize', 12, 'FontWeight', 'bold');
    axis equal; 
    xlim(chLim); ylim([-2 2]);
    xline(0, 'k--'); yline(0, 'k--');
    
    % Context T2 (J2)
    subplot(1,2,2);
    hold on;
    
    context_sign = -1;
    color_sign = 1;  % Red
    
    if show_inputs
        input_base = context_sign * obj.B_context * obj.I0_context + ...
                     0.5 * obj.B_ci * obj.I0_ci;
        input_color = color_sign * obj.B_color * obj.I0_color;
        total_input = input_base + input_color;
    else
        total_input = zeros(obj.N, 1);
    end
    
    for i = 1:n_grid
        for j = 1:n_grid
            x_curr = Color_grid(i,j) * color_axis + ...
                    Choice_grid(i,j) * choice_axis;
            
            % Dynamics with J2
            dx = (1/obj.tau) * (-x_curr + obj.J2 * x_curr + total_input);
            
            dx_choice = dot(dx, choice_axis);
            dx_color = dot(dx, color_axis);
            
            norm_dx = sqrt(dx_choice^2 + dx_color^2);
            if norm_dx > 0.001
                scale = baseSize / (norm_dx + normalizer);
                quiver(Choice_grid(i,j), Color_grid(i,j), ...
                       dx_choice*scale, dx_color*scale, 0, ...
                       'color', [0.6 0.6 0.6], 'LineWidth', 1.2, ...
                       'MaxHeadSize', 50);
            end
        end
    end
    
    if show_inputs
        input_choice = dot(total_input, choice_axis);
        input_color = dot(total_input, color_axis);
        quiver(0, 0, input_choice*0.5, input_color*0.5, 0, ...
               'm', 'LineWidth', 4, 'MaxHeadSize', 1.5);
        text(input_choice*0.3, input_color*0.3 - 0.3, ...
             sprintf('Input (ctx=%+d, col=%+d)', context_sign, color_sign), ...
             'Color', 'm', 'FontSize', 10);
    end
    
    % Overlay actual trajectory for T2-Red-Right
    if ~isempty(obj.all_x) && show_inputs
        traj = obj.all_x(:,:,3);
        traj_choice = traj' * choice_axis;
        traj_color = traj' * color_axis;
        plot(traj_choice, traj_color, 'r-', 'LineWidth', 3);
        plot(traj_choice(1), traj_color(1), 'go', 'MarkerSize', 10, ...
             'MarkerFaceColor', 'g', 'LineWidth', 2);
        plot(traj_choice(end), traj_color(end), 'rd', 'MarkerSize', 12, ...
             'MarkerFaceColor', 'r', 'LineWidth', 2);
    end
    
    xlabel('Choice axis', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Color axis', 'FontSize', 12, 'FontWeight', 'bold');
    axis equal; 
    xlim(chLim); ylim([-2 2]);
    xline(0, 'k--'); yline(0, 'k--');
    

end