% created by Tian on Feb 4th 2025
% same as dlpfc_pmd_shuffle_dpca but also calculate the explained variance
% of 500 dlpfc and pmd randomly selected units, respectively.


%% on Tian's laptop 
clear all; close all; clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% path of all dpca core code %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath("/Users/tianwang/Documents/MATLAB/ChandLab/dPCA/matlab");

% load DLPFC data:
% time restretching aligned to target (-0.4:2)
dlpfcFR_average = load('/Volumes/TianSSD/TiberiusDLPFCforDPCA/all_new/totalDataframeA.mat').totalDataframe;
dlpfcFR_average = dlpfcFR_average(:,:,:,301:1600);


% load PMD data:
load('/Volumes/TianSSD/PMd/PMd_PCA_Trajectories.mat');

pmdFRT = summarizedData.choiceandcolor.targets.FR;
pmdFRC = summarizedData.choiceandcolor.check.FR;

% aligned with target (-100 to 367)
segT = pmdFRT(:,:,:,201:367+300);
% aligned with checkerboard(-368 to 465)
segC = pmdFRC(:,:,:,233:601+464);
pmdFR_average =  cat(4, segT, segC);


% current 2nd dimension: decision; 3rd dimension: stimulus
% swap 2nd and 3rd dimension
pmdFR_average2 = zeros(size(pmdFR_average));

for ii = 1:size(pmdFR_average, 2)
    temp = pmdFR_average(:,ii,:,:);
    pmdFR_average2(:,:,ii,:) = temp;
end

pmdFR_average = pmdFR_average2;


%% or SCC

clear; close all; clc

addpath('~/Documents/dPCA/matlab/');
% load DLPFC data:
% time restretching aligned to target (-0.1:1.2)
load('dlpfcFR_average.mat');

% load PMD data:
load('pmdFR_average.mat');


%% specify time points and parameters

combinedParams = {{1, [1 3]}, {2, [2 3]}, {3}, {[1 2], [1 2 3]}};
margNames = {'Color', 'Direction', 'Condition-independent', 'Configuration'};
margColours = [23 100 171; 187 20 25; 150 150 150; 114 97 171]/256;

% time of time restretching target aligned
time = linspace(-0.1, 1.2, size(dlpfcFR_average, 4));
timeEvents = [0 0.735];



%% create 100 shuffled 


shuffledVar = struct;

numEach = 500;

tic
parfor ii = 1:2
    %% create shuffled data

    % shuffle: craete a shuffled dataset containing 1000 neurons: 50% from DLPFC;
    % 50% from pMd. 

    permuteNum1 = randperm(size(dlpfcFR_average,1));
    dlpfcSelect = permuteNum1(1:numEach);
    permuteNum2 = randperm(size(pmdFR_average,1));
    pmdSelect = permuteNum2(1:numEach);


    dlpfc_FR500 = dlpfcFR_average(dlpfcSelect,:,:,:);
    pmd_FR500 = pmdFR_average(pmdSelect,:,:,:); 
    
    firingRatesAverage = [dlpfcFR_average(dlpfcSelect,:,:,:); pmdFR_average(pmdSelect,:,:,:)];


    
    %% mix the firingRatesAverage data and split the data in half

     permuteNum3 = randperm(size(firingRatesAverage,1));

     shuffle1DS = firingRatesAverage(permuteNum3(1:numEach),:,:,:);
     shuffle2DS = firingRatesAverage(permuteNum3(numEach+1:end),:,:,:);
     
     
    %% dpca of combiend shuffled

%     [W,V,whichMarg] = dpca(shuffle1DS, 30, ...
%         'combinedParams', combinedParams);
%     explVar = dpca_explainedVariance(shuffle1DS, W, V, ...
%         'combinedParams', combinedParams);
%     varDS1 = explVar.totalMarginalizedVar / explVar.totalVar * 100;

    varDS1 = dpcaCalVar(shuffle1DS, combinedParams);
    varDS2 = dpcaCalVar(shuffle2DS, combinedParams);
    
%     
%     [W,V,whichMarg] = dpca(shuffle2DS, 30, ...
%         'combinedParams', combinedParams);
%     explVar = dpca_explainedVariance(shuffle2DS, W, V, ...
%         'combinedParams', combinedParams);
%     varDS2 = explVar.totalMarginalizedVar / explVar.totalVar * 100;
%     
    
    %% dpca of 500 dlpfc units

%     [W,V,whichMarg] = dpca(dlpfc_FR500, 30, ...
%         'combinedParams', combinedParams);
%     dlpfcExplVar = dpca_explainedVariance(dlpfc_FR500, W, V, ...
%         'combinedParams', combinedParams);
%     dlpfcVar = dlpfcExplVar.totalMarginalizedVar / dlpfcExplVar.totalVar * 100;
%     
    
    dlpfcVar = dpcaCalVar(dlpfc_FR500, combinedParams);
    %% dpca of 500 pmd units

%     [W,V,whichMarg] = dpca(pmd_FR500, 30, ...
%         'combinedParams', combinedParams);
%     pmdExplVar = dpca_explainedVariance(pmd_FR500, W, V, ...
%         'combinedParams', combinedParams);
%     pmdVar = pmdExplVar.totalMarginalizedVar / pmdExplVar.totalVar * 100;

    pmdVar = dpcaCalVar(pmd_FR500, combinedParams);
    
    %% store variance explained to a structure

    shuffledVar(ii).margNames = margNames;
    shuffledVar(ii).varDS1 = varDS1;
    shuffledVar(ii).varDS2 = varDS2;
     
    shuffledVar(ii).dlpfcVarPercent500 = dlpfcVar;
    shuffledVar(ii).pmdVarPercent500 = pmdVar;
    
    fprintf("session %d finished \n", ii);
end

toc
%%
% save(['/projectnb/chandlab/tian/dPCA_shuffle/shuffledVar0204.mat'], 'shuffledVar','-v7.3','-nocompression');



%% load 100 shuffled variance pair (calculated at BU scc)

load('shuffledVar0204.mat');

margNames = {'Color', 'Direction', 'Condition-independent', 'Configuration'};



pmdVar = [];
dlpfcVar = [];
varDS1 = [];
varDS2 = [];

for kk = 1:length(shuffledVar)
    varDS1(kk,:) = shuffledVar(kk).varDS1;
    varDS2(kk,:) = shuffledVar(kk).varDS2;
    
    dlpfcVar(kk,:) = shuffledVar(kk).dlpfcVarPercent500;
    pmdVar(kk,:) = shuffledVar(kk).pmdVarPercent500;
    
end
%% compared DLPFC-PMd difference with shuffled pairs

var_diff = (dlpfcVar - pmdVar);
shuffledVarArr = varDS1 - varDS2;


figure('Position',[300 300 1400 400])
subplot(1,3,1); hold on
histogram(shuffledVarArr(:,1), 'BinWidth', 0.2)
histogram(var_diff(:,1), 'BinWidth', 0.2)
title(margNames{1})

sum((shuffedVarArr(:,1) > median(var_diff(:,1))))/100


subplot(1,3,2); hold on
histogram(shuffledVarArr(:,2), 'BinWidth', 1)
histogram(var_diff(:,2), 'BinWidth', 1)
title(margNames{2})

sum((shuffedVarArr(:,2) > median(var_diff(:,2))))/100


subplot(1,3,3); hold on
histogram(shuffledVarArr(:,4), 'BinWidth', 0.4)
histogram(var_diff(:,4), 'BinWidth', 0.4)
title(margNames{4})

sum((shuffedVarArr(:,4) > median(var_diff(:,4))))/100

% print('-painters','-depsc',['~/Desktop/', 'dpca_shuffle','.eps'], '-r300');


