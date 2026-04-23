% create binned FR with all neuropixel data
% created dataset: allBinFR: 3 fields: 
% name: name
% trialLabels: each trial label, one of RL, RR, GL, GR
% trials: binned FR to 50ms aligned to checkerboard

clear all; close all; clc

totalAccuracy = [];

binSize = 50;
stepSize = 5;

alignment = 'M';


onlyCorrect = 0;


switch alignment
    case 'T'
%         dataDir = '/Volumes/TianSSD/TiberiusDLPFCRaster/';
        dataDir = '/Volumes/ZiggySSD/VinnieDLPFCRaster/';
        
        files = dir(fullfile(dataDir, '202*.mat'));
        tStart = -800;
        tEnd = 2400;
        timeAxis = [tStart+binSize:stepSize:tEnd];
        tSelected = timeAxis >= -200 & timeAxis <= 700;        
    case 'C'
%         dataDir = '/Volumes/TianSSD/TiberiusDLPFCRaster/RasterC/';
%         dataDir = '/Volumes/ZiggySSD/VinnieDLPFCRaster/RasterC/';
        dataDir = '/Volumes/ZiggySSD/ZiggyDLPFCRaster/RasterC/';

        files = dir(fullfile(dataDir, '202*.mat'));
        tStart = -1000;
        tEnd = 1600;  
        timeAxis = [tStart+binSize:stepSize:tEnd];
        tSelected = timeAxis >= -200 & timeAxis <= 500;
    case 'M'
%         dataDir = '/Volumes/TianSSD/TiberiusDLPFCRaster/RasterM/';
        dataDir = '/Volumes/ZiggySSD/VinnieDLPFCRaster/RasterM/';

        files = dir(fullfile(dataDir, '202*.mat'));
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


    data = load([dataDir files(dayn).name]).dataframe;


            

        dataTable = struct2table(data);
        outcomeTable = dataTable(:,{'TrialOutcome'});
        outcomeCell = table2cell(outcomeTable);
        correct = strcmp(outcomeCell, 'Correct Choice')';

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % only choose correct trials            
        if onlyCorrect 
            
            data = data(correct); 
            correct = ones(length(data),1);

        end
        
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
        config2 = leftColor == 3 & rightColor == 2;    

        behavior = struct;
        behavior.chosenRed = red;
        behavior.config1 = config1';
        behavior.cue = [perf.CueV]';
        behavior.chosenLeft = left;
        behavior.RT = [perf.RT]';
        behavior.correctness = correct';

        
        
    switch alignment
        case 'C'
            temp = struct2table(data);
            spikeTable = temp(:,{'rasterC'});
            spikeStruct = table2struct(spikeTable);

            oldField = 'rasterC';
            newField = 'spikes';

            [spikeStruct.(newField)] = spikeStruct.(oldField);
            spikeStruct = rmfield(spikeStruct,oldField);  

            trials = slideBins_mat(spikeStruct, binSize,stepSize);    

            trials = trials(:,:,tSelected);
        case 'T'
            temp = struct2table(data);
            spikeTable = temp(:,{'rasterT'});
            spikeStruct = table2struct(spikeTable);

            oldField = 'rasterT';
            newField = 'spikes';

            [spikeStruct.(newField)] = spikeStruct.(oldField);
            spikeStruct = rmfield(spikeStruct,oldField);  

            trials = slideBins_mat(spikeStruct, binSize,stepSize);    

            trials = trials(:,:,tSelected);
        case 'M'
             temp = struct2table(data);
            spikeTable = temp(:,{'rasterM'});
            spikeStruct = table2struct(spikeTable);

            oldField = 'rasterM';
            newField = 'spikes';

            [spikeStruct.(newField)] = spikeStruct.(oldField);
            spikeStruct = rmfield(spikeStruct,oldField);  

            trials = slideBins_mat(spikeStruct, binSize,stepSize);    

            trials = trials(:,:,tSelected);
    end
    
    

        RL = (red&left);
        RR = (red&~left).*2;
        GL = (~red&left).*3;
        GR = (~red&~left).*4;

        taskLabels = RL+RR+GL+GR - 1;


        allBinFR(dayn).name = files(dayn).name;
        allBinFR(dayn).trials = trials;
        allBinFR(dayn).taskLabels = taskLabels';
        allBinFR(dayn).time = timeAxis(tSelected);
        allBinFR(dayn).behavior = behavior;        


        fprintf("dayn %d finished \n", dayn)
        
end



%% 

% save('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Vinnie/movementAligned/allBinFRvprobe.mat', 'allBinFR', '-v7.3')
