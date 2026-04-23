% create binned FR with all neuropixel data
% created dataset: allBinFR: 3 fields: 
% name: name
% trialLabels: each trial label, one of RL, RR, GL, GR
% trials: binned FR to 50ms aligned to checkerboard

clear all; close all; clc

totalAccuracy = [];

binSize = 50;
stepSize = 5;

alignment = 'C';

switch alignment
    case 'T'
        dataDir = '/Volumes/TianSSD/TiberiusNpix/targetAligned/';
        files = dir(fullfile(dataDir, '202*DLPFC*.mat'));
        tStart = -400;
        tEnd = 2000;
        timeAxis = [tStart+binSize:stepSize:tEnd];
        tSelected = timeAxis >= 0 & timeAxis <= 400;        
    case 'C'
        dataDir = '/Volumes/TianSSD/VinnieNpix/checkerboardAligned/';
        files = dir(fullfile(dataDir, '202*DLPFC*.mat'));
        tStart = -1000;
        tEnd = 1000;  
        timeAxis = [tStart+binSize:stepSize:tEnd];
        tSelected = timeAxis > -100 & timeAxis <= 300;
    case 'M'
        dataDir = '/Volumes/TianSSD/TiberiusNpix/movementAligned/';
        files = dir(fullfile(dataDir, '202*DLPFC*.mat'));
        tStart = -1000;
        tEnd = 1000;
        timeAxis = [tStart+binSize:stepSize:tEnd];
        tSelected = timeAxis >= -600 & timeAxis <= 300;
end


load('~/Desktop/allBinFR_V50_5.mat');

%% 

 
tic
for dayn = 1:length(files)


data = load([dataDir files(dayn).name]).allData;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% choose only correct trials
data = data([data.correctness] == 1);


% extract the reaching direction for each trial 
perf = [data.DLperformance];
perfTable = struct2table(perf);
a = perfTable(:,{'ChosenSide'});
b = table2cell(a);
left = strcmp(b, 'left')';
right = strcmp(b, 'right')';

% extract color
a = perfTable(:,{'ChosenColor'});
b = table2cell(a);
red = strcmp(b, 'red')';
green = strcmp(b, 'green')';

% extract chosen color (need trial outcome)
a = perfTable(:,{'TrialOutcome'});
b = table2cell(a);    
correct = strcmp(b, 'Correct Choice')';

% extract target configuration

 % target configuration 1: GL&RR; target configureation 2: GR&RL
dataParams = [data.DLparams];
leftColor = [dataParams.LeftTargetColor];
rightColor = [dataParams.RightTargetColor];

config1 = leftColor == 2 & rightColor == 3;
config2 = leftColor == 3 & rightColor == 2;  

behavior.chosenRed = red;
behavior.config1 = config1;
behavior.cue = [perf.CueV];
behavior.chosenLeft = left;
behavior.RT = [perf.RT];
behavior.correctness = correct;

allBinFR(dayn).behavior = behavior;

fprintf("dayn %d finiished \n", dayn)
end


%% 

% save('~/Desktop/allBinFR_V50_5.mat', 'allBinFR')
