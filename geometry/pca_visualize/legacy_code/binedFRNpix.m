

clear all; close all; clc


addpath('..')

totalAccuracy = [];

binSize = 50;
stepSize = 20;

alignment = 'T';

switch alignment
    case 'T'
        dataDir = '/Volumes/TianSSD/TiberiusNpix/targetAligned/';
        files = dir(fullfile(dataDir, '202*DLPFC*.mat'));
        tStart = -400;
        tEnd = 2000;
        timeAxis = [tStart+binSize:stepSize:tEnd];
        tSelected = timeAxis >= 0 & timeAxis <= 600;        
    case 'C'
        dataDir = '/Volumes/TianSSD/VinnieNpix/checkerboardAligned/';
        files = dir(fullfile(dataDir, '202*DLPFC*.mat'));
        tStart = -1000;
        tEnd = 1000;  
        timeAxis = [tStart+binSize:stepSize:tEnd];
        tSelected = timeAxis > 50 & timeAxis <= 500;
    case 'M'
        dataDir = '/Volumes/TianSSD/VinnieNpix/movementAligned/';
        files = dir(fullfile(dataDir, '202*DLPFC*.mat'));
        tStart = -1000;
        tEnd = 1000;
        timeAxis = [tStart+binSize:stepSize:tEnd];
        tSelected = timeAxis > -600 & timeAxis <= 300;
end




%% 

binFR = [];
tic
parfor dayn = 1:length(files)


data = load([dataDir files(dayn).name]).allData;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


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

% extract target configuration

 % target configuration 1: GL&RR; target configureation 2: GR&RL
dataParams = [data.DLparams];
leftColor = [dataParams.LeftTargetColor];
rightColor = [dataParams.RightTargetColor];

config1 = leftColor == 2 & rightColor == 3;
config2 = leftColor == 3 & rightColor == 2;  


temp = struct2table(data);
spikeTable = temp(:,{'rasterT'});
spikeStruct = table2struct(spikeTable);

oldField = 'rasterT';
newField = 'spikes';

[spikeStruct.(newField)] = spikeStruct.(oldField);
spikeStruct = rmfield(spikeStruct,oldField);  

trials = slideBins_mat(spikeStruct, binSize,stepSize);    


trials = trials(:,:,tSelected);




% trials = trials./50.*1000;

%% 
binFR1 = [];
RL = red & left;
RR = red & right;
GL = green & left;
GR = green & right;


binFR1(:,:,1) = squeeze(mean(trials(RL,:,:),1));
binFR1(:,:,2) = squeeze(mean(trials(RR,:,:),1));
binFR1(:,:,3) = squeeze(mean(trials(GL,:,:),1));
binFR1(:,:,4) = squeeze(mean(trials(GR,:,:),1));

binFR = [binFR; binFR1]; 

fprintf("dayn %d finished \n", dayn)

end

%%
% save('TibsTnpix.mat', 'binFR')