clear all; close all; clc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Structure which store all well modulated units %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dataInfo = load("/Users/tianwang/Documents/MATLAB/ChandLab/DLPFC_analysis/createDataInfo/DLPFC_neurons.mat").database;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% the directory where the data is saved to %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dataSaveDir = ['/Users/tianwang/Documents/MATLAB/ChandLab/DLPFC_PMd/behavior/'];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% path to store allTrials data %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
baseDir = '/Volumes/TianSSD/TiberiusDLPFCAllTrials/';

a = load('Fig2_MonkeyT_data_old.mat').figTData;

figTData = struct;
figTData.monkey = 'T';
figTData.signedColorCoherence = a.signedColorCoherence;
figTData.params = a.params;

% raw data; combined

RT = zeros(length(dataInfo), 14);
pRed = zeros(length(dataInfo), 14);
combined = [];

%%
for dayn = 1:length(dataInfo)
    
    % date 
    date = dataInfo(dayn).date;
    % extract allTrials data  
    allTrials = load([baseDir 'TiberiusCOLGRID' date '.mat']).allTrials;
    

    perf = [allTrials.performance]; 
    
    perfTable = struct2table(perf);
    a = perfTable(:,{'ChosenColor'});
    b = table2cell(a);
    red = strcmp(b, 'red')';
    green = strcmp(b, 'green')';
    
    params = [allTrials.params];
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
figTData.rawdata = rawdata;
figTData.combined = combined;

save([dataSaveDir 'Fig2_MonkeyT_data_trials.mat'], 'figTData');



%% combine v-probe and npix data

a = load('Fig2_MonkeyT_data_trials.mat').figTData;
b = load('Fig2_MonkeyT_npixdata_trials.mat').figTData;
c = a;
c.rawdata.RT = [c.rawdata.RT; b.rawdata.RT];
c.rawdata.pRed = [c.rawdata.pRed; b.rawdata.pRed];

c.combined = [c.combined; b.combined];

figTData = c;

% save([dataSaveDir 'Fig2_MonkeyT_data_combined.mat'], 'figTData');

