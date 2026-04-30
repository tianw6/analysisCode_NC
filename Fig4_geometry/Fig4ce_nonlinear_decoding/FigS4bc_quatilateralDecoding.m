% created by Tian on Sep 21th 
% decode all 6 conditions


clear; close all; clc

addpath('../../utils/')

area = 'pfc';

switch area
    case {'pfc'}
        % load dlpfc
        load('../../../analysisData_NC/Fig4/Tiberius/checkerboardAligned/allBinFRnpix.mat');


        temp = allBinFR;

        temp(18).trials = cat(2, temp(18).trials, temp(19).trials);
        temp(19) = [];

        allBinFR = temp;


        a = load('../../../analysisData_NC/Fig4/Vinnie/checkerboardAligned/allBinFRnpix.mat').allBinFR;

        allBinFR = [allBinFR, a];


    case {'pmd'}
    % load pmd

    load('../../../analysisData_NC/Fig4/Tiberius/checkerboardAligned/allBinFRnpixPMD.mat');

end
%%
allTime = allBinFR(1).time;

tStart = -100;
tEnd = 300; 
tSelected = allTime >= tStart & allTime <= tEnd;

time = allTime(tSelected);

for ii = 1:length(allBinFR)
    
    allBinFR(ii).trials = allBinFR(ii).trials(:,:,tSelected);
    allBinFR(ii).time = allBinFR(ii).time(tSelected);

end

%%
parfor dayn = 1:length(allBinFR)
    
    
    %% binary decoding (choice)
    
    trials = allBinFR(dayn).trials;
    taskLabels = allBinFR(dayn).taskLabels;

    minTrials = min([sum(taskLabels == 0), sum(taskLabels == 1),sum(taskLabels == 2),sum(taskLabels == 3)]);
    
    

    Ltrials = find(taskLabels == 0 | taskLabels == 2);  
    
    Rtrials = find(taskLabels == 1 | taskLabels == 3);
    
    select = [Ltrials(1:minTrials), Rtrials(1:minTrials)];
    
    
    train_y = taskLabels(select)';
    train_y = (train_y == 0 | train_y == 2);
    train_x = trials(select,:,:);

    accuracy(dayn).choiceAcc = binaryDecode(train_x, train_y);

    %% decode RL & RR
    
    trials = allBinFR(dayn).trials;
    taskLabels = allBinFR(dayn).taskLabels;


    RLtrials = find(taskLabels == 0);  
    
    RRtrials = find(taskLabels == 1);
    
    select = [RLtrials(1:minTrials), RRtrials(1:minTrials)];
        
    train_x = trials(select,:,:);
    train_y = taskLabels(select)';



    accuracy(dayn).RLRR_acc = binaryDecode(train_x, train_y);    

    
    %% decode RL & GL
    
    trials = allBinFR(dayn).trials;
    taskLabels = allBinFR(dayn).taskLabels;


    RLtrials = find(taskLabels == 0);  
    
    GLtrials = find(taskLabels == 2);
    
    select = [RLtrials(1:minTrials), GLtrials(1:minTrials)];
        
    train_x = trials(select,:,:);
    train_y = taskLabels(select)';



    accuracy(dayn).RLGL_acc = binaryDecode(train_x, train_y);    
    %% decode RL & GR

    trials = allBinFR(dayn).trials;
    taskLabels = allBinFR(dayn).taskLabels;


    RLtrials = find(taskLabels == 0);  
    
    GRtrials = find(taskLabels == 3);
    
    select = [RLtrials(1:minTrials), GRtrials(1:minTrials)];
        
    train_x = trials(select,:,:);
    train_y = taskLabels(select)';



    accuracy(dayn).RLGR_acc = binaryDecode(train_x, train_y);

    
    %% decode RR & GR


    trials = allBinFR(dayn).trials;
    taskLabels = allBinFR(dayn).taskLabels;

    RRtrials = find(taskLabels == 1);  
    
    GRtrials = find(taskLabels == 3);
    
    select = [RRtrials(1:minTrials), GRtrials(1:minTrials)];
        
    train_x = trials(select,:,:);
    train_y = taskLabels(select)';


    accuracy(dayn).RRGR_acc = binaryDecode(train_x, train_y);

    

    %% decode RR & GL


    trials = allBinFR(dayn).trials;
    taskLabels = allBinFR(dayn).taskLabels;

    RRtrials = find(taskLabels == 1);  
    
    GLtrials = find(taskLabels == 2);
    
    select = [RRtrials(1:minTrials), GLtrials(1:minTrials)];
        
    train_x = trials(select,:,:);
    train_y = taskLabels(select)';

    accuracy(dayn).RRGL_acc = binaryDecode(train_x, train_y);

    %% decode GL & GR


    trials = allBinFR(dayn).trials;
    taskLabels = allBinFR(dayn).taskLabels;

    GRtrials = find(taskLabels == 3);  
    
    GLtrials = find(taskLabels == 2);
    
    select = [GRtrials(1:minTrials), GLtrials(1:minTrials)];
        
    train_x = trials(select,:,:);
    train_y = taskLabels(select)';

    accuracy(dayn).GRGL_acc = binaryDecode(train_x, train_y);



    fprintf("dayn: %d finished \n", dayn);

end

% save([area 'QuadAcc_npix_equalTrials.mat'], 'accuracy');



%% load pre-trained decoder to decode each color-action pair and plot traces & confusion matrix

pfcAcc = load('pfcQuadAcc_npix_equalTrials.mat').accuracy;
plotAccuracy(pfcAcc, 'pfc')

pmdAcc = load('pmdQuadAcc_npix_equalTrials.mat').accuracy;
plotAccuracy(pmdAcc, 'pmd')



function plotAccuracy(accuracy, area)

    %   Inputs:
    %       accuracy : struct with choiceAcc, RLGRAcc, and RRGLAcc
    %

    time = linspace(-100, 300, length(accuracy(1).choiceAcc));


    choiceAcc = [];
    RLGR_acc = [];
    RRGL_acc = [];
    for ip = 1:length(accuracy)

        choiceAcc(:,ip) = accuracy(ip).choiceAcc;
        RLRR_acc(:,ip) = accuracy(ip).RLRR_acc;
        RLGL_acc(:,ip) = accuracy(ip).RLGL_acc;
        RLGR_acc(:,ip) = accuracy(ip).RLGR_acc;

        RRGR_acc(:,ip) = accuracy(ip).RRGR_acc;
        RRGL_acc(:,ip) = accuracy(ip).RRGL_acc;
        GRGL_acc(:,ip) = accuracy(ip).GRGL_acc;


    end



    %%

    addpath('../../utils/')
    a = figure('Position', [10 10 900 500]);

    options.handle = gcf;
    options.error = 'sem';
    options.alpha  = 0.3;
    options.line_width = 2;
    options.x_axis = time;

    options.color_area = [0 193 219]./255;    % Blue theme
    options.color_line = [ 0 148 186]./255;
    plot_areaerrorbar(RLRR_acc', options)


    options.color_area = [0 193 219]./255;    % green theme
    options.color_line = [ 0 148 186]./255;
    plot_areaerrorbar(RLGL_acc', options)


    options.color_area = [0 193 219]./255;    % green theme
    options.color_line = [ 0 148 186]./255;
    plot_areaerrorbar(RLGR_acc', options)


    options.color_area = [0 193 219]./255;    % green theme
    options.color_line = [ 0 148 186]./255;
    plot_areaerrorbar(RRGR_acc', options)


    options.color_area = [0 193 219]./255;    % green theme
    options.color_line = [ 0 148 186]./255;
    plot_areaerrorbar(RRGL_acc', options)


    options.color_area = [0 193 219]./255;    % green theme
    options.color_line = [ 0 148 186]./255;
    plot_areaerrorbar(GRGL_acc', options)


    options.color_area = [243 169 114]./255;    % Orange theme
    options.color_line = [236 112  22]./255;
    plot_areaerrorbar(choiceAcc', options)

    ylim([0.45 0.8])
    xlim([-50, 300])

    title(['FigS4b-', area  ,' 6 combination pairs decoders'])

    %% plot confusion matrix 

    allResults = [mean(RLRR_acc,2), mean(RLGL_acc,2), mean(RLGR_acc,2),  mean(RRGL_acc,2), mean(RRGR_acc,2), mean(GRGL_acc,2)];
    R2mat = zeros(6,6);
    for i = 1:size(allResults,2)
        for j = i:size(allResults,2)
            r1 = allResults(:,i);
            r2 = allResults(:,j);

            mdl = fitlm(r1, r2);
            R2mat(i,j) = mdl.Rsquared.Ordinary;        
            if i == j
                R2mat(i,j) = 0;

            end
        end
    end

    figure;

    clims = [0 1];
    imagesc(R2mat,clims)
    colorbar
    
    title(['FigS4c-', area  ,' 6 combination pairs decoders'])
    

end
