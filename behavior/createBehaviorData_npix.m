clear all; close all; clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% the directory where the data is saved to %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dataSaveDir = ['/Users/tianwang/Documents/MATLAB/ChandLab/DLPFC_PMd/behavior/'];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% path to store allTrials data %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
folder = dir('/Volumes/TianSSD/TiberiusNpix/targetAligned/*PMD.mat');


a = load('Fig2_MonkeyV_data_trials.mat').figVData;

figVData = struct;
figVData.monkey = 'V';
figVData.signedColorCoherence = a.signedColorCoherence;
figVData.params = a.params;

% raw data; combined

RT = zeros(length(folder), 14);
pRed = zeros(length(folder), 14);
combined = [];

%%
for dayn = 1:length(folder)
    
    % extract allTrials data  
    allTrials = load([folder(dayn).folder '/' folder(dayn).name]).allData;
    

    perf = [allTrials.DLperformance]; 
    
    perfTable = struct2table(perf);
    a = perfTable(:,{'ChosenColor'});
    b = table2cell(a);
    red = strcmp(b, 'red')';
    green = strcmp(b, 'green')';
    
    params = [allTrials.DLparams];
    leftTargetColor = [params.LeftTargetColor]';
    rightTargetColor = [params.RightTargetColor]';
    
    % coherence of each trial
    cueV = [perf.CueV];
    % categories of coherence
    coh = unique(cueV);  
    rt = [perf.RT];
    
    for ii  = 1 : length(coh)
        temp = cueV == coh(ii);
        RT(dayn, ii) = mean(rt(temp));
        
        pRed(dayn, ii) = 100*sum(red(temp))/sum(temp);
        
        
        comb = [];
        comb(:,1) = coh(ii).*ones(sum(temp),1);
        comb(:,2) = red(temp);
        comb(:,3) = rt(temp);

        comb(:,4) = leftTargetColor(temp);
        comb(:,5) = rightTargetColor(temp);
       
        comb(:,6) = dayn.*ones(sum(temp),1);
        
        combined = [combined;comb];
    end
    
    
    
    
        
    fprintf("Day %d finished\n", dayn);
end
%%
rawdata = struct;
rawdata.RT = RT;
rawdata.pRed = pRed;
figVData.rawdata = rawdata;
figVData.combined = combined;

% save([dataSaveDir 'Fig2_MonkeyV_npixdata_trials.mat'], 'figVData');