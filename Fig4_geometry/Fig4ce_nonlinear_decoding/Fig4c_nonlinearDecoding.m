% in this code, we decode pure choice. 
% then we decode RL vs GR, RR vs GL
% for 5 simultaneous recording days


clear; close all; clc

addpath('../../utils/')


% choose area: ('pfc': DLPFC; 'pmd': PMd)
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

%% train the decoder
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


    %% decode RL & GR

    trials = allBinFR(dayn).trials;
    taskLabels = allBinFR(dayn).taskLabels;


    RLtrials = find(taskLabels == 0);  
    
    GRtrials = find(taskLabels == 3);
    
    select = [RLtrials(1:minTrials), GRtrials(1:minTrials)];
        
    train_x = trials(select,:,:);
    train_y = taskLabels(select)';



    accuracy(dayn).RLGR_acc = binaryDecode(train_x, train_y);


    %% decode RR & GL


    trials = allBinFR(dayn).trials;
    taskLabels = allBinFR(dayn).taskLabels;

    RRtrials = find(taskLabels == 1);  
    
    GLtrials = find(taskLabels == 2);
    
    select = [RRtrials(1:minTrials), GLtrials(1:minTrials)];
        
    train_x = trials(select,:,:);
    train_y = taskLabels(select)';


    accuracy(dayn).RRGL_acc = binaryDecode(train_x, train_y);


    fprintf("dayn: %d finished \n", dayn);

end

% save('pmdAcc_npix_equalTrials.mat', 'accuracy');


%% load pretrained results and plot 



pfcAcc = load('pfcAcc_npix_equalTrials.mat').accuracy;
[pTest, pSignrank] =  plotAccuracy(pfcAcc)
title('Fig3c: DLPFCAcc')


pmdAcc = load('pmdAcc_npix_equalTrials.mat').accuracy;
[pTest, pSignrank] =  plotAccuracy(pmdAcc)
title('Fig3c: PMdAcc')



function [pTtest, pSignrank] = plotAccuracy(accuracy)

    %   Inputs:
    %       accuracy : struct with choiceAcc, RLGRAcc, and RRGLAcc
    %
    %   Outputs:
    %       pTtest    : 1 x time t-test p-values
    %       pSignrank : 1 x time sign-rank p-values

    time = linspace(-100, 300, length(accuracy(1).choiceAcc));

    choiceAcc = [];
    RLGR_acc  = [];
    RRGL_acc  = [];
    for ip = 1:length(accuracy)
        choiceAcc(:, ip) = accuracy(ip).choiceAcc;
        RLGR_acc(:, ip)  = accuracy(ip).RLGR_acc;
        RRGL_acc(:, ip)  = accuracy(ip).RRGL_acc;
    end

    nlinrChoice = (RLGR_acc + RRGL_acc) ./ 2;

    % --- Plot ---
    figure('Position', [10 10 900 500]); hold on;

    options.handle     = gcf;
    options.error      = 'sem';
    options.alpha      = 0.5;
    options.line_width = 2;
    options.x_axis     = time;

    options.color_area = [243 169 114]./255;
    options.color_line = [236 112  22]./255;
    plot_areaerrorbar(choiceAcc', options);

    options.color_area = [128 193 219]./255;
    options.color_line = [ 52 148 186]./255;
    plot_areaerrorbar(nlinrChoice', options);

    ylim([0.45 0.8]); xlim([-50 300]);

    % --- T-test ---
    pTtest = zeros(1, size(choiceAcc, 1));
    for ii = 1:size(choiceAcc, 1)
        [~, pTtest(ii)] = ttest(choiceAcc(ii,:), nlinrChoice(ii,:), 'alpha', 0.01);
    end
    plot(time, 0.8.*(pTtest < 0.01), '*');

    % --- Sign-rank ---
    pSignrank = zeros(1, size(choiceAcc, 1));
    for ii = 1:size(choiceAcc, 1)
        pSignrank(ii) = signrank(choiceAcc(ii,:), nlinrChoice(ii,:), 'alpha', 0.01);
    end
    plot(time, 0.8.*(pSignrank < 0.01), '*');   

end