clear all; close all; clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% the directory where the data is saved to %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dataSaveDir = '/Volumes/TianSSD/TiberiusNpix/targetAligned/';
folder = dir([dataSaveDir '202*PMD*.mat']);

% dataSaveDir = '/Volumes/ZiggySSD/VinnieDLPFCRaster/';
% folder = dir([dataSaveDir '202*.mat']);

% give a name of the data to be saved
dataName = 'PMDtotalDataframeTcxt';
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
    params = [allData.DLparams];
    cxt1 = [params.LeftTargetColor] == 2;


    

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


    rFR_LR = mean(FRmatrix(:,:,cxt1),3);
    rFR_RR = mean(FRmatrix(:,:,~cxt1),3);
    


    FRaverage(:,1,1,:) = rFR_LR;
    FRaverage(:,1,2,:) = rFR_RR;
    FRaverage(:,2,1,:) = nan(size(rFR_LR));
    FRaverage(:,2,2,:) = nan(size(rFR_RR));
    
    

    totalDataframe = [totalDataframe; FRaverage];



    fprintf('Up to Day %d, total units are %d \n', dayn, size(totalDataframe, 1));
end

% save([dataSaveDir dataName '.mat'],'totalDataframe');



%% 
count = 0;
check = [];
for dayn = 1:length(database)
    allData = load([folder(dayn).folder '/' folder(dayn).name]).dataframe;

    check(dayn) = size(allData(1).rasterT,1) == length(database(dayn).unitID);
    
    
end

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


