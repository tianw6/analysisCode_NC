clear all; close all; clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% the directory where the data is saved to %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dataSaveDir = '/Volumes/TianSSD/TiberiusNpix/targetAligned/';
folder = dir([dataSaveDir '*DLPFC*.mat']);


% give a name of the data to be saved
dataName = 'DLPFCtotalDataframeT';
g = normpdf([-0.1:0.001:0.1],0,0.025);
chopTime = 200;


totalDataframe = [];

for dayn = 1:length(folder)
    
    allData = load([folder(dayn).folder '/' folder(dayn).name]).allData;

    
    % only choose correct trials?
    % dataTable = struct2table(allData);
    % outcomeTable = dataTable(:,{'TrialOutcome'});
    % outcomeCell = table2cell(outcomeTable);
    % correct = strcmp(outcomeCell, 'Correct Choice')';
    % allData = allData(correct);       


    % extract performances
    perf = [allData.DLperformance];

    perfTable = struct2table(perf);
    colorTable = perfTable(:,{'ChosenColor'});
    colorCell = table2cell(colorTable);
    red = strcmp(colorCell, 'red')';

    choiceTable = perfTable(:,{'ChosenSide'});
    choiceCell = table2cell(choiceTable);
    left = strcmp(choiceCell, 'left')';

    params = [allData.DLparams];
    cxt1 = [params.LeftTargetColor] == 2;

    RL = red & left;
    RR = red & ~left;
    GL = ~red & left;
    GR = ~red & ~left;

    

    %% create FR_matrix


    FRmatrix = zeros([size(allData(1).rasterT,1), size(allData(1).rasterT,2) - chopTime*2, length(allData)]);
    FRaverage = [];
    for im = 1:length(allData)
        raster = allData(im).rasterT;

        for in = 1:size(raster,1)
            FR = conv(raster(in,:), g, 'same');
            FRmatrix(in,:,im) = FR(chopTime+1:end-chopTime);
        end
    end


    rFR_LR = mean(squeeze(FRmatrix(:,:,RL)),3);
    rFR_RR = mean(squeeze(FRmatrix(:,:,RR)),3);
    rFR_LG = mean(squeeze(FRmatrix(:,:,GL)),3);
    rFR_RG = mean(squeeze(FRmatrix(:,:,GR)),3);

    FRaverage(:,1,1,:) = rFR_LR;
    FRaverage(:,1,2,:) = rFR_RR;
    FRaverage(:,2,1,:) = rFR_LG;
    FRaverage(:,2,2,:) = rFR_RG;
    
    

    totalDataframe = [totalDataframe; FRaverage];



    fprintf('Up to Day %d, total units are %d \n', dayn, size(totalDataframe, 1));
end

% save([dataSaveDir dataName '.mat'],'totalDataframe');





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


