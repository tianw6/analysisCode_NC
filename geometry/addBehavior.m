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
%         dataDir = '/Volumes/TianSSD/TiberiusDLPFCRaster/';
        dataDir = '/Volumes/ZiggySSD/VinnieDLPFCRaster/';
        
        files = dir(fullfile(dataDir, '202*.mat'));
        tStart = -800;
        tEnd = 2400;
        timeAxis = [tStart+binSize:stepSize:tEnd];
        tSelected = timeAxis > -200 & timeAxis <= 800;        
    case 'C'
%         dataDir = '/Volumes/TianSSD/TiberiusDLPFCRaster/RasterC/';
        dataDir = '/Volumes/ZiggySSD/VinnieDLPFCRaster/RasterC/';

        files = dir(fullfile(dataDir, '202*.mat'));
        tStart = -1000;
        tEnd = 1600;  
        timeAxis = [tStart+binSize:stepSize:tEnd];
        tSelected = timeAxis > -100 & timeAxis <= 300;
    case 'M'
%         dataDir = '/Volumes/TianSSD/TiberiusDLPFCRaster/RasterM/';
        dataDir = '/Volumes/ZiggySSD/VinnieDLPFCRaster/RasterM/';

        files = dir(fullfile(dataDir, '202*.mat'));
        tStart = -1000;
        tEnd = 1000;
        timeAxis = [tStart+binSize:stepSize:tEnd];
        tSelected = timeAxis > -600 & timeAxis <= 300;
end




load('~/Desktop/allBinFR_V50_5_vprobe.mat');

%% 

 
tic
for dayn = 1:length(files)


    data = load([dataDir files(dayn).name]).dataframe;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % only choose correct trials
    dataTable = struct2table(data);
    outcomeTable = dataTable(:,{'TrialOutcome'});
    outcomeCell = table2cell(outcomeTable);
    correct = strcmp(outcomeCell, 'Correct Choice')';
    data = data(correct); 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % extract the reaching direction for each trial 
    perf = [data.performance];
    perfTable = struct2table(perf);
    a = perfTable(:,{'ChosenSide'});
    b = table2cell(a);
    left = strcmp(b, 'left');
    right = strcmp(b, 'right');


    % extract color
    a = perfTable(:,{'ChosenColor'});
    b = table2cell(a);
    red = strcmp(b, 'red');
    green = strcmp(b, 'green');


    % extract target configuration

    %target configuration 1: GL&RR; target configureation 2: GR&RL
    dataParams = [data.params];
    leftColor = [dataParams.LeftTargetColor];
    rightColor = [dataParams.RightTargetColor];

    config1 = leftColor == 2 & rightColor == 3;
    config1 = leftColor == 3 & rightColor == 2;    



    behavior.chosenRed = red;
    behavior.config1 = config1';
    behavior.cue = [perf.CueV]';
    behavior.chosenLeft = left;
    behavior.RT = [perf.RT]';
    behavior.correctness = ones(length(data),1);

    allBinFR(dayn).behavior = behavior;

    fprintf("dayn %d finiished \n", dayn)
end


%% 

% save('./allBinFR_Vvprobe.mat', 'allBinFR')
