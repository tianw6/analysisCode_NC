% in this code, we decode pure choice. 
% then we decode RL vs GR (color in context1) then test on RR vs GL (color in context2)
% this is the cross condition color generalization analysis
% might use this to differentiate switching dynamics vs rotating input

clear; close all; clc

addpath('..')

%% load dlpfc
load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/checkerboardAligned/allBinFRnpix.mat');


% load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/movementAligned/allBinFRnpix.mat');




temp = allBinFR;

temp(18).trials = cat(2, temp(18).trials, temp(19).trials);
temp(19) = [];

allBinFR = temp;


a = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Vinnie/checkerboardAligned/allBinFRnpix.mat').allBinFR;

allBinFR = [allBinFR, a];



c = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/checkerboardAligned/allBinFRvprobe.mat').allBinFR;

d = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Vinnie/checkerboardAligned/allBinFRvprobe.mat').allBinFR;

allBinFR = [a, d];


% a=load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Vinnie/movementAligned/allBinFRnpix.mat').allBinFR;


%% only vinnie
a = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Vinnie/checkerboardAligned/allBinFRnpix.mat').allBinFR;

d = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Vinnie/checkerboardAligned/allBinFRvprobe.mat').allBinFR;

allBinFR = [a, d];


%% only tiberius 
load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/checkerboardAligned/allBinFRnpix.mat');

temp = allBinFR;

temp(18).trials = cat(2, temp(18).trials, temp(19).trials);
temp(19) = [];

allBinFR = temp;


c = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/checkerboardAligned/allBinFRvprobe.mat').allBinFR;

allBinFR = [allBinFR, c(65:end)];



%% load pmd

% load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/checkerboardAligned/allBinFRnpixPMD.mat');


%%
allTime = allBinFR(1).time;

tStart = 0;
tEnd = 400; 

tSelected = allTime >= tStart & allTime <= tEnd;

time = allTime(tSelected);

for ii = 1:length(allBinFR)
    
    allBinFR(ii).trials = allBinFR(ii).trials(:,:,tSelected);
    allBinFR(ii).time = allBinFR(ii).time(tSelected);

end


accuracy = struct;
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
    
%%  binary decoding (color)
    
    trials = allBinFR(dayn).trials;
    taskLabels = allBinFR(dayn).taskLabels;

    minTrials = min([sum(taskLabels == 0), sum(taskLabels == 1),sum(taskLabels == 2),sum(taskLabels == 3)]);
    
    

    Rtrials = find(taskLabels == 0 | taskLabels == 1);  
    
    Gtrials = find(taskLabels == 2 | taskLabels == 3);
    
    select = [Rtrials(1:minTrials), Gtrials(1:minTrials)];
    
    
    train_y = taskLabels(select)';
    train_y = (train_y == 0 | train_y == 1);
    train_x = trials(select,:,:);

    accuracy(dayn).colorAcc = binaryDecode(train_x, train_y);
    
    %% decode RL & GR

    trials = allBinFR(dayn).trials;
    taskLabels = allBinFR(dayn).taskLabels;


    RLtrials = find(taskLabels == 0);  
    
    GRtrials = find(taskLabels == 3);
    
    trainSelect = [RLtrials(1:minTrials), GRtrials(1:minTrials)];
        
    train_x = trials(trainSelect,:,:);
    train_y = taskLabels(trainSelect)';
    train_y(train_y == 3) = 1;


    RRtrials = find(taskLabels == 1);  
    
    GLtrials = find(taskLabels == 2);
    
    testSelect = [RRtrials(1:minTrials), GLtrials(1:minTrials)];
        
    test_x = trials(testSelect,:,:);
    test_y = taskLabels(testSelect)';
    test_y(test_y == 2) = 0;
    test_y = ~test_y;
    
    RLGR_acc = [];
    RRGL_acc = [];
    test_RRGL = [];
    test_RLGR = [];
    
    for t = 1:size(trials,3)
        t1 = squeeze(train_x(:,:,t));
        t2 = squeeze(test_x(:,:,t));
        
        % train on train data, test on test data    
        md1 = fitclinear(t1, train_y, 'learner', 'logistic', 'KFold', 5);
        error = kfoldLoss(md1);
        RLGR_acc(t) = 1 - error;  % This is your CV estimate

        % Then train final model on all data and test set:
        finalMd1 = fitclinear(t1, train_y, 'learner', 'logistic');
        testPred = predict(finalMd1, t2);
        test_RRGL(t) = sum(testPred == test_y) / length(test_y); 
        
        % train on test data, test on train data
        md2 = fitclinear(t2, test_y, 'learner', 'logistic', 'KFold', 5);
        error = kfoldLoss(md2);
        RRGL_acc(t) = 1 - error;  % This is your CV estimate

        % Then train final model on all data and test set:
        finalMd2 = fitclinear(t2, test_y, 'learner', 'logistic');
        testPred = predict(finalMd2, t1);
        test_RLGR(t) = sum(testPred == train_y) / length(train_y);         
        
        
    end
    
    accuracy(dayn).RLGR_acc = RLGR_acc;
    accuracy(dayn).test_RRGL = test_RRGL;
    accuracy(dayn).RRGL_acc = RRGL_acc;
    accuracy(dayn).test_RLGR = test_RLGR;   



    %% decode RR & GL

% 
%     trials = allBinFR(dayn).trials;
%     taskLabels = allBinFR(dayn).taskLabels;
% 
%     RRtrials = find(taskLabels == 1);  
%     
%     GLtrials = find(taskLabels == 2);
%     
%     select = [RRtrials(1:minTrials), GLtrials(1:minTrials)];
%         
%     train_x = trials(select,:,:);
%     train_y = taskLabels(select)';
% 
% 
%     accuracy(dayn).RRGL_acc = binaryDecode(train_x, train_y);
% 
% 
% 
     fprintf("dayn: %d finished \n", dayn);

end

save('vinnieCCGP_color.mat', 'accuracy');

%%

% load('tibsCCGP_color.mat.mat')


colorAcc = [];
choiceAcc = [];
RLGR_acc = [];
RRGL_acc = [];
test_RLGR = [];
test_RRGL = [];

for ip = 1:length(accuracy)
    
    colorAcc(:,ip) = accuracy(ip).colorAcc;
    choiceAcc(:,ip) = accuracy(ip).choiceAcc;
    RLGR_acc(:,ip) = accuracy(ip).RLGR_acc;
    RRGL_acc(:,ip) = accuracy(ip).RRGL_acc;
    test_RLGR(:,ip) = accuracy(ip).test_RLGR;
    test_RRGL(:,ip) = accuracy(ip).test_RRGL;
    
end
%%
time = -0:5:400;

a = figure('Position', [10 10 900 500]);

options.handle = gcf;
options.error = 'sem';
options.color_area = [200,200,200]./255;    % black theme
options.color_line = [100,100,100]./255;
options.alpha      = 0.5;
options.line_width = 2;
options.x_axis = time;
plot_areaerrorbar(choiceAcc', options)

options.color_area = [240 200 220]./255;    % megenta theme
options.color_line = [200 160 180]./255;
plot_areaerrorbar(colorAcc', options)

nlinrChoice = (RLGR_acc + RRGL_acc)./2;
% nlinrChoice = RLGR_acc;
% nlinrChoice = RRGL_acc;
options.color_area = [243 169 114]./255;    % Orange theme
options.color_line = [236 112  22]./255;
plot_areaerrorbar(nlinrChoice', options)


generalizeChoice = (test_RLGR + test_RRGL)./2;
% generalizeChoice = test_RRGL;
% generalizeChoice = test_RLGR;
options.color_area = [128 193 219]./255;    % Blue theme
options.color_line = [ 52 148 186]./255;
plot_areaerrorbar(generalizeChoice', options)



xlim([0, 200])
ylim([0.48, 0.6])

% print('-painters','-depsc',['~/Documents/chandlab/dissertation/figures/Aim2/', 'VinnieCCGP_color', '.eps']);

%% difference between cross-context color decoding

a = figure('Position', [10 10 900 500]);

options.handle = gcf;
options.error = 'sem';
options.alpha      = 0.5;
options.line_width = 2;
options.x_axis = time;
aa = RRGL_acc - test_RRGL;
% nlinrChoice = RLGR_acc;
% nlinrChoice = RRGL_acc;
options.color_area = [243 169 114]./255;    % Orange theme
options.color_line = [236 112  22]./255;
plot_areaerrorbar(aa', options)


%% 

plot(time, aa(:,20:23)')
