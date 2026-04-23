% created by Tian on Jan 26th, 2025. Create pca data with correct and wrong
% trajectories

clear all; close all; clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% the directory where the data is saved to %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dataSaveDir = '/Volumes/TianSSD/TiberiusNpix/checkerboardAligned/';
folder = dir([dataSaveDir '202*DLPFC*.mat']);


% give a name of the data to be saved
dataName = 'DLPFCtotalDataframeC_CR';
g = normpdf([-0.1:0.001:0.1],0,0.025);
chopTime = 200;

selectCoh = {[11 45], [67,78], [90 101 108], [117 124 135], [147 158], [180 214]};


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
    cue = [perf.CueV];
    
    
    
    perfTable = struct2table(perf);
    choiceTable = perfTable(:,{'ChosenSide'});
    choiceCell = table2cell(choiceTable);
    right = strcmp(choiceCell, 'right')';

    params = [allData.DLparams];
    cxt1 = [params.LeftTargetColor] == 3;


    cxt = cxt1 + 1;
    choice = right+1;
    
    coh = zeros(length(allData),1);
    for iSC = 1:length(selectCoh)
        a = selectCoh{iSC};
        b = ismember(cue, a)';
        coh = coh+b.*iSC;
    end
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

    
    for icxt = 1:2
        for icoh = 1:6
            for idir = 1:2
                
                iselect = (cxt == icxt) & (coh' == icoh) & (choice == idir);
                
                if (sum(iselect)~= 0)
                    FRselect = FRmatrix(:,:,iselect);
                    FRaverage(:,icxt,icoh,idir,:) = squeeze(mean(FRselect,3));

                else
                    FRselect = NaN(size(FRmatrix,1), size(FRmatrix,2));
                    FRaverage(:,icxt,icoh,idir,:) = FRselect;

                end

                FRselect = [];



            end
        end
    

    
    end
    
    

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


