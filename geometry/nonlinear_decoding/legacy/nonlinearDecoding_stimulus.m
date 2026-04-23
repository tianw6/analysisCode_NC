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


% cueC = {[180 214] [147 158] [117 124 135] [90 101 108] [67 78] [11 45]};

cueC = {[180 214] [147 158 135] [124 117] [101 108] [67 78 90] [11 45]};

%%
parfor dayn = 1:length(allBinFR)
    
    
    %% binary decoding (choice)
    

    
    
        
    trials = allBinFR(dayn).trials;
    taskLabels = allBinFR(dayn).taskLabels;

    behavior = allBinFR(dayn).behavior;
    cue = [behavior.cue];   
    
    
    %%%%%%%%%%%%%%%%%%% choose all correct trials 

    correct = [behavior.correctness] == 1;
    
    trials = trials(correct,:,:);
    taskLabels = taskLabels(correct);
    cue = cue(correct);
    %%%%%%%%%%%%%%%%%%
    
    
    for is = 1:length(cueC)/2
        select = ismember(cue, cueC{is}) | ismember(cue, cueC{length(cueC) + 1-is});
        
        Strials = trials(select,:,:);
        StaskLabels = taskLabels(select);
        
        
        Ctrain_y = (StaskLabels == 0 | StaskLabels == 2)';

        accuracy(dayn).choiceAcc(:,is) = binaryDecode(Strials, Ctrain_y)';       

        
        
        
        selectRLGR = (StaskLabels == 0 | StaskLabels == 3);

        RLGRtrials = Strials(selectRLGR,:,:);
        RLGRtrain_y = StaskLabels(selectRLGR)';
        
        accuracy(dayn).RLGR_acc(:,is) = binaryDecode(RLGRtrials, RLGRtrain_y)';
       
        
        
        selectRRGL = (StaskLabels == 1 | StaskLabels == 2);

        RRGLtrials = Strials(selectRRGL,:,:);
        RRGLtrain_y = StaskLabels(selectRRGL)';
        
        accuracy(dayn).RRGL_acc(:,is) = binaryDecode(RRGLtrials, RRGLtrain_y)';
               
        
        
    end
        
    
    %% decode RL & GR



    fprintf("dayn: %d finished \n", dayn);

end




%% plot results

% load('pfcAcc_5days.mat')


time = -100:5:300;

choiceAcc = [];
RLGR_acc = [];
RRGL_acc = [];

for ip = 1:length(accuracy)
    
    choiceAcc(:,1,ip) = accuracy(ip).choiceAcc(:,1);
    choiceAcc(:,2,ip) = accuracy(ip).choiceAcc(:,2);
    choiceAcc(:,3,ip) = accuracy(ip).choiceAcc(:,3);
    
    RLGR_acc(:,1,ip) = accuracy(ip).RLGR_acc(:,1);
    RLGR_acc(:,2,ip) = accuracy(ip).RLGR_acc(:,2);
    RLGR_acc(:,3,ip) = accuracy(ip).RLGR_acc(:,3);  
    
    RRGL_acc(:,1,ip) = accuracy(ip).RRGL_acc(:,1);
    RRGL_acc(:,2,ip) = accuracy(ip).RRGL_acc(:,2);
    RRGL_acc(:,3,ip) = accuracy(ip).RRGL_acc(:,3);    
    
end



%%
a = figure('Position', [10 10 900 500]);

options.handle = a;
options.error = 'sem';
options.color_area = [243 169 114]./255;    % Orange theme
options.color_line = [236 112  22]./255;
options.alpha      = 0.7;
options.line_width = 2;
options.x_axis = time;
plot_areaerrorbar(squeeze(choiceAcc(:,1,:))', options)

options.alpha      = 0.5;
plot_areaerrorbar(squeeze(choiceAcc(:,2,:))', options)

options.alpha      = 0.3;
plot_areaerrorbar(squeeze(choiceAcc(:,3,:))', options)

ylim([0.45 0.9])
xlim([-50, 300])

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig4/', 'pfcChoiceDecoder_cueCorrect', '.eps']);

%%

a = figure('Position', [10 10 900 500]);

options.handle = a;
options.error = 'sem';
options.line_width = 2;
options.x_axis = time;

nlinrChoice = (RLGR_acc + RRGL_acc)./2;
options.color_area = [128 193 219]./255;    % Blue theme
options.color_line = [ 52 148 186]./255;

options.alpha      = 0.7;
plot_areaerrorbar(squeeze(nlinrChoice(:,1,:))', options)

options.alpha      = 0.5;
plot_areaerrorbar(squeeze(nlinrChoice(:,2,:))', options)

options.alpha      = 0.3;
plot_areaerrorbar(squeeze(nlinrChoice(:,3,:))', options)


% options.color_area = [128 193 219]./255;    % Blue theme
% options.color_line = [ 52 148 186]./255;
% plot_areaerrorbar(RLGR_acc', options)
% 
% 
% options.color_area = [0 193 219]./255;    % green theme
% options.color_line = [ 0 148 186]./255;
% plot_areaerrorbar(RRGL_acc', options)


ylim([0.45 0.9])
xlim([-50, 300])

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig4/', 'pfcNlinrDecoder_cueCorrect', '.eps']);


%% 


