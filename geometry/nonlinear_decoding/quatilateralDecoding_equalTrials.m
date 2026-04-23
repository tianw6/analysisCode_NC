% created by Tian on Sep 21th 
% decode all 6 conditions


clear; close all; clc

addpath('..')

area = 'pfc';

switch area
    case {'pfc'}
        % load dlpfc
        load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/checkerboardAligned/allBinFRnpix.mat');


        temp = allBinFR;

        temp(18).trials = cat(2, temp(18).trials, temp(19).trials);
        temp(19) = [];

        allBinFR = temp;


        a = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Vinnie/checkerboardAligned/allBinFRnpix.mat').allBinFR;

        allBinFR = [allBinFR, a];


    case {'pmd'}
    % load pmd

    load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/checkerboardAligned/allBinFRnpixPMD.mat');

end
%%
allTime = allBinFR(1).time;

tStart = 100;
tEnd = 500; 
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



%% plot results

% load('pmdQuadAcc_npix_equalTrials.mat')


time = linspace(100,500,81);


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

figure; hold on

plot(time, mean(choiceAcc,2), 'r')
plot(time, mean(RLRR_acc,2), 'k')
plot(time, mean(RLGL_acc,2), 'b')
plot(time, mean(RLGR_acc,2), 'k')
plot(time, mean(RRGR_acc,2), 'b')
plot(time, mean(RRGL_acc,2), 'k')
plot(time, mean(GRGL_acc,2), 'k')


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

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig4_s/', 'pmd6Decoders_confusion', '.eps']);

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

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig4_s/', 'pfcQuadDecoder', '.eps']);

%% sign rank test 

p = [];
for ii = 1:size(choiceAcc,1)
    x = choiceAcc(ii,:);    
    y1 = RLRR_acc(ii,:);
    y2 = RLGL_acc(ii,:);
    y3 = RLGR_acc(ii,:);
    y4 = RRGR_acc(ii,:);
    y5 = RRGL_acc(ii,:);
    y6 = GRGL_acc(ii,:);   
    p(ii, 1) = signrank(x, y1, 'alpha', 0.01);
    p(ii, 2) = signrank(x, y2, 'alpha', 0.01);
    p(ii, 3) = signrank(x, y3, 'alpha', 0.01);
    p(ii, 4) = signrank(x, y4, 'alpha', 0.01);
    p(ii, 5) = signrank(x, y5, 'alpha', 0.01);
    p(ii, 6) = signrank(x, y6, 'alpha', 0.01);
    
    
end

plot(time, 0.8.*(sum(p < 0.01, 2) >=5), '*');
% plot(time, 0.8.*(p<0.01), '*')

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig4/', 'pmdNlinDecoder', '.eps']);

%% 

a = figure('Position', [10 10 900 500]);

options.handle = gcf;
options.error = 'sem';
options.alpha  = 0.3;
options.line_width = 2;
options.x_axis = time;

cmap = jet(6);

options.color_area = cmap(1,:);    % Blue theme
options.color_line = cmap(1,:);
plot_areaerrorbar(RLRR_acc', options)


options.color_area = cmap(2,:);    % green theme
options.color_line = cmap(2,:);
plot_areaerrorbar(RLGL_acc', options)


options.color_area = cmap(3,:);   % green theme
options.color_line = cmap(3,:);
plot_areaerrorbar(RLGR_acc', options)


options.color_area = cmap(4,:);   % green theme
options.color_line = cmap(4,:);
plot_areaerrorbar(RRGR_acc', options)


options.color_area = cmap(5,:);    % green theme
options.color_line = cmap(5,:);
plot_areaerrorbar(RRGL_acc', options)


options.color_area = cmap(6,:);   % green theme
options.color_line = cmap(6,:);
plot_areaerrorbar(GRGL_acc', options)


options.color_area = ones(1,3).*0.2;    % Orange theme
options.color_line = ones(1,3).*0.2;
plot_areaerrorbar(choiceAcc', options)

ylim([0.45 0.8])
xlim([-50, 300])

