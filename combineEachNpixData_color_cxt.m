clear all; close all; clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% the directory where the data is saved to %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

onlyCorrect = 1;

alignment = 'T';

% give a name of the data to be saved
dataName = ['PMD_' alignment '_ColorCxtCorrect'];
g = normpdf([-0.1:0.001:0.1],0,0.025);


switch alignment
    case 'T'
        dataDir = '/Volumes/TianSSD/TiberiusNpix/targetAligned/';
        files = dir(fullfile(dataDir, '202*PMD*.mat'));
        tStart = -400;
        tEnd = 2000-1;
        timeAxis = [tStart:tEnd];
        tSelected = timeAxis >= -200 & timeAxis < 1200;        
    case 'C'
        dataDir = '/Volumes/TianSSD/TiberiusNpix/checkerboardAligned/';
        files = dir(fullfile(dataDir, '202*PMD*.mat'));
        tStart = -1000;
        tEnd = 1000-1;  
        timeAxis = [tStart:tEnd];
        tSelected = timeAxis >= -800 & timeAxis < 800;
    case 'M'
%         dataDir = '/Volumes/TianSSD/TiberiusNpix/movementAligned/';
        dataDir = '/Volumes/TianSSD/VinnieNpix/movementAligned/';
        
        files = dir(fullfile(dataDir, '202*PMD*.mat'));
        tStart = -1000;
        tEnd = 1000-1;
        timeAxis = [tStart:tEnd];
        tSelected = timeAxis >= -800 & timeAxis < 800;
end





totalDataframe = [];

%%
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

    RC1 = red & config1;
    RC2 = red & config2;
    GC1 = green & config1;
    GC2 = green & config2;

    

    %% create FR_matrix


    FRmatrix = zeros([size(data(1).rasterT,1), sum(tSelected), length(data)]);
    FRaverage = [];
    for im = 1:length(data)
        raster = data(im).rasterT;

        for in = 1:size(raster,1)
            FR = conv(raster(in,:), g, 'same');
            FRmatrix(in,:,im) = FR(tSelected);
        end
    end


    rFR_RC1 = squeeze(mean(FRmatrix(:,:,RC1),3));
    rFR_RC2 = squeeze(mean(FRmatrix(:,:,RC2),3));
    rFR_GC1 = squeeze(mean(FRmatrix(:,:,GC1),3));
    rFR_GC2 = squeeze(mean(FRmatrix(:,:,GC2),3));

    FRaverage(:,1,1,:) = rFR_RC1;
    FRaverage(:,1,2,:) = rFR_RC2;
    FRaverage(:,2,1,:) = rFR_GC1;
    FRaverage(:,2,2,:) = rFR_GC2;
    
    
    

    totalDataframe = [totalDataframe; FRaverage];



    fprintf('Up to Day %d, total units are %d \n', dayn, size(totalDataframe, 1));
end

save([dataDir dataName '.mat'],'totalDataframe');





%% Sanity check: check for nan 
% will display # neuron which has nan 
for ii = 1 : size(totalDataframe, 1)
    if sum(isnan(totalDataframe(ii,:,:,:)), 'All') ~= 0
        fprintf('Nan neurons: %d \n', ii)
    end
end


%% Sanity check: locate the date of nan data

% choose 1 output number (represent number of neurons which has Nan)
% print out the date which contains this Nan activity neuron
wrongNum = 1908;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Structure to store all well modulated units %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dataInfo = load("/Users/tianwang/Documents/MATLAB/ChandLab/DLPFC_analysis/createDataInfo/DLPFC_neurons.mat").database;

count = 0;
for jj = 1 : length(dataInfo)
    count = count + length(dataInfo(jj).channelID);
    if (count > wrongNum | count == wrongNum)
        disp(dataInfo(jj).name)
        break
    end
    
end

% after find out the date, go to createTotalDaaTian.m, run that day
% generate a dataframe and plot the dataframe to locate the wrong neuron


