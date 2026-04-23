% create binned FR with all neuropixel data
% created dataset: allBinFR: 3 fields: 
% name: name
% trialLabels: each trial label, one of RL, RR, GL, GR
% trials: binned FR to 50ms aligned to checkerboard

clear all; close all; clc


onlyCorrect = 0;


binSize = 50;
stepSize = 5;

alignment = 'M';

switch alignment
    case 'T'
        dataDir = '/Volumes/TianSSD/VinnieNpix/targetAligned/';
        files = dir(fullfile(dataDir, '202*DLPFC*.mat'));
        tStart = -400;
        tEnd = 2000;
        timeAxis = [tStart+binSize:stepSize:tEnd];
        tSelected = timeAxis >= -200 & timeAxis <= 700;        
    case 'C'
        dataDir = '/Volumes/TianSSD/VinnieNpix/checkerboardAligned/';
        files = dir(fullfile(dataDir, '202*DLPFC*.mat'));
        tStart = -1000;
        tEnd = 1000;  
        timeAxis = [tStart+binSize:stepSize:tEnd];
        tSelected = timeAxis >= -200 & timeAxis <= 500;
    case 'M'
%         dataDir = '/Volumes/TianSSD/TiberiusNpix/movementAligned/';
        dataDir = '/Volumes/TianSSD/VinnieNpix/movementAligned/';
        
        files = dir(fullfile(dataDir, '202*DLPFC*.mat'));
        tStart = -1000;
        tEnd = 1000;
        timeAxis = [tStart+binSize:stepSize:tEnd];
        tSelected = timeAxis >= -300 & timeAxis <= 200;
end




%% 

allBinFR = struct;

binFR = [];
tic
for dayn = 1:length(files)


   
data = load([dataDir files(dayn).name]).allData;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% choose only correct trials

if (onlyCorrect == 1)
    data = data([data.correctness] == 1);
end


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

behavior = struct;
behavior.chosenRed = red;
behavior.config1 = config1;
behavior.cue = [perf.CueV];
behavior.chosenLeft = left;
behavior.RT = [perf.RT];
behavior.correctness = correct;


temp = struct2table(data);
spikeTable = temp(:,{'rasterT'});
spikeStruct = table2struct(spikeTable);

oldField = 'rasterT';
newField = 'spikes';

[spikeStruct.(newField)] = spikeStruct.(oldField);
spikeStruct = rmfield(spikeStruct,oldField);  

trials = slideBins_mat(spikeStruct, binSize,stepSize);    


trials = trials(:,:,tSelected);


RL = (red&left);
RR = (red&~left).*2;
GL = (~red&left).*3;
GR = (~red&~left).*4;

taskLabels = RL+RR+GL+GR - 1;


allBinFR(dayn).name = files(dayn).name;
allBinFR(dayn).trials = trials;
allBinFR(dayn).taskLabels = taskLabels;
allBinFR(dayn).time = timeAxis(tSelected);

allBinFR(dayn).behavior = behavior;




fprintf("dayn %d finished \n", dayn)
end


%% 

% save('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Vinnie/movementAligned/allBinFRnpix.mat', 'allBinFR')
