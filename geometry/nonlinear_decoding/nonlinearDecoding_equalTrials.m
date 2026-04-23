% in this code, we decode pure choice. 
% then we decode RL vs GR, RR vs GL
% for 5 simultaneous recording days

clear; close all; clc

addpath('..')

%% load dlpfc
load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/checkerboardAligned/allBinFRnpix.mat');


temp = allBinFR;

temp(18).trials = cat(2, temp(18).trials, temp(19).trials);
temp(19) = [];

allBinFR = temp;


a = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Vinnie/checkerboardAligned/allBinFRnpix.mat').allBinFR;

allBinFR = [allBinFR, a];


% load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Vinnie/checkerboardAligned/allBinFRnpix.mat');

%% load pmd

load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/checkerboardAligned/allBinFRnpixPMD.mat');

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

    % 
    % for t = 1:size(trials,3)
    %     t1 = squeeze(trials(:,:,t));
    % 
    % 
    % %     md1 = fitcsvm(t1, train_y,  'KFold', 5, 'KernelFunction','linear');
    %     md1 = fitclinear(t1, train_y, 'learner', 'logistic', 'KFold', 5);
    % 
    % 
    %     error = kfoldLoss(md1);
    %     accuracy = 1 - error;
    %     fprintf('time: %d, accuracy: %.2f', time(t), accuracy);
    %     fprintf('\n')    
    % end





    %% decode RL & GR

    trials = allBinFR(dayn).trials;
    taskLabels = allBinFR(dayn).taskLabels;


    RLtrials = find(taskLabels == 0);  
    
    GRtrials = find(taskLabels == 3);
    
    select = [RLtrials(1:minTrials), GRtrials(1:minTrials)];
        
    train_x = trials(select,:,:);
    train_y = taskLabels(select)';



    accuracy(dayn).RLGR_acc = binaryDecode(train_x, train_y);


    % for t = 1:size(trials,3)
    %     t1 = squeeze(trials(:,:,t));
    % 
    % 
    % %     md1 = fitcsvm(t1, train_y,  'KFold', 5, 'KernelFunction','linear');
    %     md1 = fitclinear(t1, train_y, 'learner', 'logistic', 'KFold', 5);
    % 
    % 
    %     error = kfoldLoss(md1);
    %     accuracy = 1 - error;
    %     fprintf('time: %d, accuracy: %.2f', time(t), accuracy);
    %     fprintf('\n')    
    % end


    %% decode RR & GL


    trials = allBinFR(dayn).trials;
    taskLabels = allBinFR(dayn).taskLabels;

    RRtrials = find(taskLabels == 1);  
    
    GLtrials = find(taskLabels == 2);
    
    select = [RRtrials(1:minTrials), GLtrials(1:minTrials)];
        
    train_x = trials(select,:,:);
    train_y = taskLabels(select)';


    accuracy(dayn).RRGL_acc = binaryDecode(train_x, train_y);


    % for t = 1:size(trials,3)
    %     t1 = squeeze(trials(:,:,t));
    % 
    % 
    % %     md1 = fitcsvm(t1, train_y,  'KFold', 5, 'KernelFunction','linear');
    %     md1 = fitclinear(t1, train_y, 'learner', 'logistic', 'KFold', 5);
    % 
    % 
    %     error = kfoldLoss(md1);
    %     accuracy = 1 - error;
    %     fprintf('time: %d, accuracy: %.2f', time(t), accuracy);
    %     fprintf('\n')    
    % end



    fprintf("dayn: %d finished \n", dayn);

end

% save('pmdAcc_npix_equalTrials.mat', 'accuracy');



%% plot results

load('pfcAcc_npix_equalTrials.mat')


time = linspace(-100,300,81);


choiceAcc = [];
RLGR_acc = [];
RRGL_acc = [];
for ip = 1:length(accuracy)
    
    choiceAcc(:,ip) = accuracy(ip).choiceAcc;
    RLGR_acc(:,ip) = accuracy(ip).RLGR_acc;
    RRGL_acc(:,ip) = accuracy(ip).RRGL_acc;
    
end



%%
a = figure('Position', [10 10 900 500]);

options.handle = gcf;
options.error = 'sem';
options.color_area = [243 169 114]./255;    % Orange theme
options.color_line = [236 112  22]./255;
options.alpha      = 0.5;
options.line_width = 2;
options.x_axis = time;
plot_areaerrorbar(choiceAcc', options)


nlinrChoice = (RLGR_acc + RRGL_acc)./2;
options.color_area = [128 193 219]./255;    % Blue theme
options.color_line = [ 52 148 186]./255;
plot_areaerrorbar(nlinrChoice', options)
% % 
% options.color_area = [128 193 219]./255;    % Blue theme
% options.color_line = [ 52 148 186]./255;
% plot_areaerrorbar(RLGR_acc', options)

% 
% options.color_area = [0 193 219]./255;    % green theme
% options.color_line = [ 0 148 186]./255;
% plot_areaerrorbar(RRGL_acc', options)

ylim([0.45 0.8])
xlim([-50, 300])


%% t test 

p = [];
for ii = 1:size(choiceAcc,1)
    x = choiceAcc(ii,:);
    y = nlinrChoice(ii,:);
    [~, p(ii)] = ttest(x, y, 'alpha', 0.01);
end


plot(time, 0.8.*(p<0.01), '*')

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig4/', 'pmdNlinDecoder', '.eps']);


%% sign rank test 

p = [];
for ii = 1:size(choiceAcc,1)
    x = choiceAcc(ii,:);
    y = nlinrChoice(ii,:);
    p(ii) = signrank(x, y, 'alpha', 0.01);
end


plot(time, 0.8.*(p<0.01), '*')