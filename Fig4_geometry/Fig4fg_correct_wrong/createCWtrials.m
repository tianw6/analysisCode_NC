% in this code, we extract correct and wrong trials in npix recording days
% for the most 3 difficult levels

clear; close all; clc

addpath('..')

%% load dlpfc
load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/checkerboardAligned/allBinFRnpix.mat');


temp = allBinFR;

temp(18).trials = cat(2, temp(18).trials, temp(19).trials);
temp(19) = [];

allBinFR = temp;


a = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Vinnie/checkerboardAligned/allBinFRnpix.mat').allBinFR;


% b = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/movementAligned/allBinFRvprobe.mat').allBinFR;



% c = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Vinnie/movementAligned/allBinFRvprobe.mat').allBinFR;



% allBinFR = [allBinFR, a, b,c];
allBinFR = [allBinFR, a];


%% load pmd

% load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/checkerboardAligned/allBinFRnpixPMD.mat');


%%
allTime = allBinFR(1).time;

tStart = -50;
tEnd = 500; 
tSelected = allTime >= tStart & allTime <= tEnd;

time = allTime(tSelected);

for ii = 1:length(allBinFR)
    
    allBinFR(ii).trials = allBinFR(ii).trials(:,:,tSelected);
    allBinFR(ii).time = allBinFR(ii).time(tSelected);

end


% cueC = {[180 214] [147 158] [117 124 135] [90 101 108] [67 78] [11 45]};

cueC =  [117 124 135 90 101 108];

% cueC = [180 214 11 45];

% cueC = [147 158 67 78];

CorW = 'C';

%%

% d1 = allBinFR(1).trials;
% d3 = allBinFR(3).trials;
% 
% d1_pad = cat(2, d1, zeros(size(d1,1), 5, size(d1,3)));  % (10, 30, 111)
% 
% d4 = cat(1,d1_pad, d3);

%% 


wrongTrials = struct;
correctTrials = struct;

cnt = 1;
for dayn = 1:length(allBinFR)
    
    
        
    trials = allBinFR(dayn).trials;
    taskLabels = allBinFR(dayn).taskLabels;

    behavior = allBinFR(dayn).behavior;
    
    cue = [behavior.cue];    
    correct = [behavior.correctness];
 
    selectW = ismember(cue, cueC) & correct == 0;

    selectC = ismember(cue, cueC) & correct == 1;
     
    % select hardest trials correct and wrong
    Wtrials = trials(selectW,:,:);
    WtaskLabels = taskLabels(selectW);
    
    Ctrials = trials(selectC,:,:);
    CtaskLabels = taskLabels(selectC);
    
    
    
    minTrials = min([sum(WtaskLabels == 0), sum(WtaskLabels == 1), sum(WtaskLabels == 2), sum(WtaskLabels == 3)])
    
%     minTrials = min([sum(CtaskLabels == 0), sum(CtaskLabels == 1), sum(CtaskLabels == 2), sum(CtaskLabels == 3)]);
    
    trials1day = allBinFR(dayn).trials;
    
    
    if minTrials > 5 && size(trials1day,2) > 20
        
        switch CorW
            case 'W'

                a = find(WtaskLabels == 0);
                b = find(WtaskLabels == 1);
                c = find(WtaskLabels == 2);
                d = find(WtaskLabels == 3);




                Wequal = [a(1:minTrials), b(1:minTrials), c(1:minTrials), d(1:minTrials)];

    %             Wequal = [a,b,c,d];

                Strials = Wtrials(Wequal,:,:);
                StaskLabels = WtaskLabels(Wequal);

                wrongTrials(cnt).trials = Strials;
                wrongTrials(cnt).labels = StaskLabels;


            case 'C'

                a = find(CtaskLabels == 0);
                b = find(CtaskLabels == 1);
                c = find(CtaskLabels == 2);
                d = find(CtaskLabels == 3);


%                 Cequal = sort([a(1:minTrials), b(1:minTrials), c(1:minTrials), d(1:minTrials)]);

                Cequal = [a, b, c, d];

                Strials = Ctrials(Cequal,:,:);
                StaskLabels = CtaskLabels(Cequal);

                correctTrials(cnt).trials = Strials;
                correctTrials(cnt).labels = StaskLabels;       
        end

        cnt = cnt + 1;
        
    end
  
  
    
    %% decode RL & GR



    fprintf("dayn: %d finished \n", dayn);

end



% save('correctTrialsAll.mat', 'correctTrials')