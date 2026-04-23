model = XORModel3('rotating_input_symmetric', 65);
% model = XORModel3('rotating_input');
% model = XORModel3('switching');

model.simulate();
model.analyze();
model.visualize();
model.dPCA();
% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig6/', 'rotating_input_dpca', '.eps']);


%% 

visualize_flow_field_switching(model,false)
% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig6/', 'SD_fields', '.eps']);

%% 
visualize_flow_field_rotating(model, 65, false)
% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig6/', 'RI_fields', '.eps']);

%% 


x = model.all_x_centered;

dim = 5;

figure; hold on

plot(x(dim,:,1), 'r-')
plot(x(dim,:,2), 'g--')
plot(x(dim,:,3), 'r--')
plot(x(dim,:,4), 'g-')

%% 

% Create model with 60° separation
model = XORModel_RotatedChoice(10);
model.simulate();
model.analyze();
model.visualize();

% Analyze choice axes
model.compare_choice_axes();  % Shows geometry in Q(:,3)-Q(:,5) plane

% Sweep through angles
model.sweep_rotation_angles();  % Tests 0°, 15°, 30°, ... 90°

model.visualize_rotation_in_PC_space();  % New function!







%% pca 

x = model.all_x;

% for ii = 20:30
%     figure; hold on
%     plot(x(ii,:,1), 'r');
%     plot(x(ii,:,2), 'g--');
%     plot(x(ii,:,3), 'r--');
%     plot(x(ii,:,4), 'g-');
%     pause();
%     close; 
%     
% end
    

labels = {'T1-Red-L', 'T1-Grn-R', 'T2-Red-R', 'T2-Grn-L'};
cols = [0.8,0.2,0.2; 0.2,0.7,0.2; 0.8,0.2,0.2; 0.2,0.7,0.2];
styles = {'-', '--', '--', '-'};

figure;

% 3D Trajectories
for c = 1:4
    plot3(model.pc1(:,c), model.pc2(:,c), model.pc3(:,c), styles{c}, ...
        'Color', cols(c,:), 'LineWidth', 2.5);
    hold on;

    % Start marker
    plot3(model.pc1(1,c), model.pc2(1,c), model.pc3(1,c), 'o', 'MarkerSize', 8, ...
        'MarkerFaceColor', cols(c,:), 'MarkerEdgeColor', 'k', 'LineWidth', 1.5);

    % Color onset marker
    t_onset = round(model.T_color_onset/model.dt);
    plot3(model.pc1(t_onset,c), model.pc2(t_onset,c), model.pc3(t_onset,c), 'o', ...
        'MarkerSize', 6, 'MarkerFaceColor', [0.6,0.2,0.6], ...
        'MarkerEdgeColor', 'k', 'LineWidth', 1);

end

% xlabel('PC1', 'FontSize', 11, 'FontWeight', 'bold');
% ylabel('PC2', 'FontSize', 11, 'FontWeight', 'bold');
% zlabel('PC3', 'FontSize', 11, 'FontWeight', 'bold');
% title('3D Trajectories', 'FontSize', 12, 'FontWeight', 'bold');
% grid on; view(45, 30);




set(gcf, 'Color', 'w');
axis off; 
axis tight;
set(gca, 'LooseInset', [ 0 0 0 0 ]);
xlabel('PC1');
ylabel('PC2');
zlabel('PC3');
axis vis3d;
axis equal


% view([-24 -43])
view([133 -5])

tv = ThreeVector(gca);
tv.axisInset = [1 1]; % in cm [left bottom]
tv.vectorLength = 2; % in cm
tv.fontSize = 15; % font size used for axis labels
tv.fontColor = 'k'; % font color used for axis labels
tv.lineWidth = 3; % line width used for axis vectors
tv.lineColor = 'k'; % line color used for axis vectors
tv.update();
rotate3d on;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% very important: set ax.SortMethod = 'childorder' to solve the dash
%%%%%% line export error
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ax = gca;
ax.SortMethod = 'childorder';

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig6/', 'DIM_state_pca', '.eps']);



%% dpca
firingRatesAverage = zeros(size(x, 1), 2, 2, size(x,2));

% Map conditions to dPCA format
% Condition 1: T1-Red-L  → stimulus=1, decision=1
% Condition 2: T1-Grn-R  → stimulus=2, decision=2
% Condition 3: T2-Red-R  → stimulus=1, decision=2
% Condition 4: T2-Grn-L  → stimulus=2, decision=1
firingRatesAverage(:,1,1,:) = x(:,:,1);  % T1-Red-L
firingRatesAverage(:,2,2,:) = x(:,:,2);  % T1-Grn-R
firingRatesAverage(:,1,2,:) = x(:,:,3);  % T2-Red-R
firingRatesAverage(:,2,1,:) = x(:,:,4);  % T2-Grn-L

% Add small noise to avoid numerical issues
firingRatesAverage = firingRatesAverage + 0.001*randn(size(firingRatesAverage));

% dPCA parameters
combinedParams = {{1, [1 3]}, {2, [2 3]}, {3}, {[1 2], [1 2 3]}};
margNames = {'Stimulus', 'Decision', 'Condition-independent', 'S/D Interaction'};
margColours = [23 100 171; 187 20 25; 150 150 150; 114 97 171]/256;

% Time vector (shifted to start at -T_color_onset)
time_dpca = -200:1:500;
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



%% 


select = W(:,2);

pulseDiff = [];
for ii = 1:size(x,2)
    pulseDiff(ii) = (select')*x(:,ii,1) - (select')*x(:,ii,2);
end

figure;
plot(time_dpca, pulseDiff)
