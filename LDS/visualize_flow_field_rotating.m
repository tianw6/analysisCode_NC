function visualize_flow_field_rotating(obj, rotation_angle, show_inputs)
    % Debug version to understand flow field differences
    
    normalizer = 0.01;
    baseSize = 0.2;

    if nargin < 2
        rotation_angle = obj.rotation_angle;
    end
    if nargin < 3
        show_inputs = true;  % Set false to see pure dynamics
    end
    
    color_axis = obj.Q(:,2);
    choice_axis = obj.Q(:,3);
    
    n_grid = 15;
    choice_range = linspace(-2, 2, n_grid);
    color_range = linspace(-2, 2, n_grid);
    [Choice_grid, Color_grid] = meshgrid(choice_range, color_range);
    
    figure('Position', [100, 100, 1400, 600]);
    
    % T1
    subplot(1,2,1);
    hold on;
    
    context_sign = 1;
    theta_T1 = deg2rad(rotation_angle);
    
    if show_inputs
        % With inputs
        input_T1 = context_sign * obj.B_context * obj.I0_context + ...
                   0.5 * obj.B_ci * obj.I0_ci;
        % Rotated color input set to ZERO for debugging
        % rot_color_T1 = cos(theta_T1);
        % rot_choice_T1 = sin(theta_T1);
        % input_T1 = input_T1 + rot_color_T1 * obj.B_color * obj.I0_color + ...
        %            rot_choice_T1 * obj.B_choice * obj.I0_color;
    else
        % No inputs - pure dynamics
        input_T1 = zeros(obj.N, 1);
    end
    
    for i = 1:n_grid
        for j = 1:n_grid
            x_curr = Color_grid(i,j) * color_axis + Choice_grid(i,j) * choice_axis;
            dx = (1/obj.tau) * (-x_curr + obj.J * x_curr + input_T1);
            
            dx_choice = dot(dx, choice_axis);
            dx_color = dot(dx, color_axis);
            
            norm_dx = sqrt(dx_choice^2 + dx_color^2);
            if norm_dx > 0.001
                scale = baseSize / (norm_dx+normalizer);
                quiver(Choice_grid(i,j), Color_grid(i,j), ...
                       dx_choice*scale, dx_color*scale, 0, ...
                       'color',[0.6 0.6 0.6], 'LineWidth', 1.2, 'MaxHeadSize', 5);
            end
        end
    end
    
    % Reference axes
    quiver(0, 0, 0, 1.5, 0, 'k--', 'LineWidth', 2);
    text(0.1, 1.6, 'Color', 'FontSize', 10);
    quiver(0, 0, 1.5, 0, 0, 'k--', 'LineWidth', 2);
    text(1.6, 0.1, 'Choice', 'FontSize', 10);
    
    if show_inputs
        % Show total input vector
        input_choice_T1 = dot(input_T1, choice_axis);
        input_color_T1 = dot(input_T1, color_axis);
        quiver(0, 0, input_choice_T1*0.5, input_color_T1*0.5, 0, ...
               'm', 'LineWidth', 4, 'MaxHeadSize', 1.5);
        text(input_choice_T1*0.3, input_color_T1*0.3 + 0.2, ...
             sprintf('Input (ctx=%+d)', context_sign), 'Color', 'm', 'FontSize', 11);
    end
    
    xlabel('Choice axis', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Color axis', 'FontSize', 12, 'FontWeight', 'bold');
    axis equal; grid on;
    xlim([min(choice_range) max(choice_range)]); ylim([min(color_range) max(color_range)]);
    
    % T2
    subplot(1,2,2);
    hold on;
    
    context_sign = -1;
    
    if show_inputs
        input_T2 = context_sign * obj.B_context * obj.I0_context + ...
                   0.5 * obj.B_ci * obj.I0_ci;
    else
        input_T2 = zeros(obj.N, 1);
    end
    
    for i = 1:n_grid
        for j = 1:n_grid
            x_curr = Color_grid(i,j) * color_axis + Choice_grid(i,j) * choice_axis;
            dx = (1/obj.tau) * (-x_curr + obj.J * x_curr + input_T2);
            
            dx_choice = dot(dx, choice_axis);
            dx_color = dot(dx, color_axis);
            
            norm_dx = sqrt(dx_choice^2 + dx_color^2);
            if norm_dx > 0.001
                scale = baseSize /(norm_dx+normalizer);
                quiver(Choice_grid(i,j), Color_grid(i,j), ...
                       dx_choice*scale, dx_color*scale, 0, ...
                       'color',[0.6 0.6 0.6], 'LineWidth', 1.2, 'MaxHeadSize', 5);
            end
        end
    end
    
    quiver(0, 0, 0, 1.5, 0, 'k--', 'LineWidth', 2);
    text(0.1, 1.6, 'Color', 'FontSize', 10);
    quiver(0, 0, 1.5, 0, 0, 'k--', 'LineWidth', 2);
    text(1.6, 0.1, 'Choice', 'FontSize', 10);
    
    if show_inputs
        input_choice_T2 = dot(input_T2, choice_axis);
        input_color_T2 = dot(input_T2, color_axis);
        quiver(0, 0, input_choice_T2*0.5, input_color_T2*0.5, 0, ...
               'm', 'LineWidth', 4, 'MaxHeadSize', 1.5);
        text(input_choice_T2*0.3, input_color_T2*0.3 - 0.2, ...
             sprintf('Input (ctx=%+d)', context_sign), 'Color', 'm', 'FontSize', 11);
    end
    
    xlabel('Choice axis', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Color axis', 'FontSize', 12, 'FontWeight', 'bold');
    axis equal; grid on;
    xlim([min(choice_range) max(choice_range)]); ylim([min(color_range) max(color_range)]);
    
    sgtitle(sprintf('Rotating Input Model (θ=±%.0f°, color input = 0)', rotation_angle), ...
            'FontSize', 14);
end