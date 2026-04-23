

clear all; close all; clc


binSize = 50;
stepSize = 20;

alignment = 'C';

switch alignment
    case 'T'
%         dataDir = '/Volumes/TianSSD/PMd/PMdData/Olaf/OlafPMdT1.mat';
        dataDir = '/Volumes/TianSSD/PMd/PMdData/Tiberius/TibsPMdT1.mat';
        
        load(dataDir);
        tStart = -400;
        tEnd = 2000;
        timeAxis = [tStart+binSize:stepSize:tEnd];
        tSelected = timeAxis > -200 & timeAxis <= 800;        
    case 'C'
%         dataDir = '/Volumes/TianSSD/PMd/PMdData/Olaf/OlafPMdC1.mat';
        dataDir = '/Volumes/TianSSD/PMd/PMdData/Tiberius/TibsPMdC1.mat';
        
        load(dataDir);
        tStart = -1000;
        tEnd = 1000;  
        timeAxis = [tStart+binSize:stepSize:tEnd];
        tSelected = timeAxis > 50 & timeAxis <= 500;
    case 'M'
%         dataDir = '/Volumes/TianSSD/PMd/PMdData/Olaf/OlafPMdM1.mat';
        dataDir = '/Volumes/TianSSD/PMd/PMdData/Tiberius/TibsPMdM1.mat';
        
        load(dataDir);
        tStart = -1000;
        tEnd = 1000;
        timeAxis = [tStart+binSize:stepSize:tEnd];
        tSelected = timeAxis > -600 & timeAxis <= 300;
end


%% 

binFR = [];
tic
parfor dayn = 1:length(dataframe)


    data = dataframe(dayn);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    % extract the reaching direction for each trial 
    perf = [data.behavior];
    left = [perf.chosenSide] == 1;
    right = [perf.chosenSide] == 2;

    % extract color
    perf = [data.behavior];
    red = [perf.CentralCuenSquares] > 112 & [perf.CorrectResponse] == 1 | [perf.CentralCuenSquares] < 112 & [perf.CorrectResponse] == 2;
    green = ~red;


% extract target configuration
    % target configuration 1: GL&RR; target configureation 2: GR&RL
    perf = [data.behavior];
    config1 = [perf.LeftTargetColor] == 2;
    config2 = [perf.LeftTargetColor] == 3;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

spikeStruct = struct;
spikes = data.spikes;
for is = 1:size(spikes,2)
    spikeStruct(is).spikes = squeeze(double(spikes(:,is,:)))';
end  

trials = slideBins_mat(spikeStruct, binSize,stepSize);    

% choose -0.2 to 0.8 aligned with target
trials = trials(:,:,tSelected);



%% 
binFR1 = [];
RL = red & left;
RR = red & right;
GL = green & left;
GR = green & right;

if (size(trials,2) ~= 1)
    binFR1(:,:,1) = squeeze(mean(trials(RL,:,:),1));
    binFR1(:,:,2) = squeeze(mean(trials(RR,:,:),1));
    binFR1(:,:,3) = squeeze(mean(trials(GL,:,:),1));
    binFR1(:,:,4) = squeeze(mean(trials(GR,:,:),1));
else
    binFR1(:,:,1) = squeeze(mean(trials(RL,:,:),1))';
    binFR1(:,:,2) = squeeze(mean(trials(RR,:,:),1))';
    binFR1(:,:,3) = squeeze(mean(trials(GL,:,:),1))';
    binFR1(:,:,4) = squeeze(mean(trials(GR,:,:),1))';   
end

binFR = [binFR; binFR1]; 

fprintf("dayn %d finished \n", dayn)

end

%%
% save('TibsPMDVprobeBinFR.mat', 'binFR');