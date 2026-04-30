%%%%%%%%%%%%%%%%%%%%
% This code plots Fig 6d-e: dpca and pca of 3 models 


clear all; clc; close all

addpath(genpath("../utils/dPCA/"))


modelName = 'rotating_input_symmetric';


switch modelName
    case {'rotating_input_symmetric'}
        model = XORModel3('rotating_input_symmetric', 65);

        model.simulate();
        model.analyze();
        model.dPCA();
        viewAngle = [39,-18];
    
    case {'switching'}
        model = XORModel3('switching');

        model.simulate();
        model.analyze();
        model.dPCA();
        viewAngle = [133,-5];    
        
    case {'flipping_input'}
        model = XORModel3('flipping_input');

        model.simulate();
        model.analyze();
        model.dPCA();
        viewAngle = [171, 47];       
        
end

visualize(model, viewAngle)

%% pca 


function visualize(model, viewAngle)

    addpath('../utils/')
    
    x = model.all_x;

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

    set(gcf, 'Color', 'w');
    axis off; 
    axis tight;
    set(gca, 'LooseInset', [ 0 0 0 0 ]);
    xlabel('PC1');
    ylabel('PC2');
    zlabel('PC3');
    axis vis3d;
    axis equal


    % view([39 -18])
    view([133 -5])
    
    view(viewAngle)

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

end
