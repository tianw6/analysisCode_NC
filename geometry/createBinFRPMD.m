

clear all; close all; clc


binSize = 50;
stepSize = 5;

alignment = 'C';

switch alignment
    case 'T'
%         dataDir = '/Volumes/TianSSD/PMd/PMdData/Olaf/OlafPMdT1.mat';
        dataDir = '/Volumes/TianSSD/PMd/PMdData/Tiberius/TibsPMdT1.mat';
        
        load(dataDir);
        tStart = -400;
        tEnd = 2000;
        timeAxis = [tStart+binSize:stepSize:tEnd];
        tSelected = timeAxis >= -200 & timeAxis <= 700;        
    case 'C'
%         dataDir = '/Volumes/TianSSD/PMd/PMdData/Olaf/OlafPMdC1.mat';
        dataDir = '/Volumes/TianSSD/PMd/PMdData/Tiberius/TibsPMdC1.mat';
        
        load(dataDir);
        tStart = -1000;
        tEnd = 1000;  
        timeAxis = [tStart+binSize:stepSize:tEnd];
        tSelected = timeAxis >= -200 & timeAxis <= 500;
    case 'M'
        dataDir = '/Volumes/TianSSD/PMd/PMdData/Olaf/OlafPMdM1.mat';
%         dataDir = '/Volumes/TianSSD/PMd/PMdData/Tiberius/TibsPMdM1.mat';
        
        load(dataDir);
        tStart = -1000;
        tEnd = 1000;
        timeAxis = [tStart+binSize:stepSize:tEnd];
        tSelected = timeAxis >= -600 & timeAxis <= 300;
end



%% 


allBinFR = struct;

binFR = [];


tic
for dayn = 1:length(dataframe)


    data = dataframe(dayn);



    % extract the reaching direction for each trial 
    perf = [data.behavior];
    left = [perf.chosenSide] == 1;
    right = [perf.chosenSide] == 2;

    % extract chosen color (need trial outcome)
    perfTable = struct2table(perf);
    a = perfTable(:,{'TrialOutcome'});
    b = table2cell(a);    
    correct = strcmp(b, 'Correct Choice')';
    

    
    red = [perf.CentralCuenSquares] > 112 & correct == 1 | [perf.CentralCuenSquares] < 112 & correct == 0;
    green = ~red;


% extract target configuration
    % target configuration 1: GL&RR; target configureation 2: GR&RL
    config1 = [perf.LeftTargetColor] == 2;
    config2 = [perf.LeftTargetColor] == 3;  


    behavior = struct;
    behavior.chosenRed = red;
    behavior.config1 = config1';
    behavior.cue = [perf.CentralCuenSquares]';
    behavior.chosenLeft = left;
    behavior.RT = [perf.moveRT]';
    behavior.correctness = correct;    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    spikeStruct = struct;
    spikes = data.spikes;
    for is = 1:size(spikes,2)
        spikeStruct(is).spikes = squeeze(double(spikes(:,is,:)))';
    end  

    trials = slideBins_mat(spikeStruct, binSize,stepSize);    

    trials = trials(:,:,tSelected);


        RL = (red&left);
        RR = (red&~left).*2;
        GL = (~red&left).*3;
        GR = (~red&~left).*4;

        taskLabels = RL+RR+GL+GR - 1;


        allBinFR(dayn).name = dataframe(dayn).date;
        allBinFR(dayn).trials = trials;
        allBinFR(dayn).taskLabels = taskLabels;
        allBinFR(dayn).time = timeAxis(tSelected);
        allBinFR(dayn).behavior = behavior;        

    
        
        
        fprintf("dayn %d finished \n", dayn)
        

end


%%

% save('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/checkerboardAligned/allBinFRvprobePMD.mat', 'allBinFR', '-v7.3')
