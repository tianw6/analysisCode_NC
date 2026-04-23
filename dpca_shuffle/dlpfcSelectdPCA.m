% created by Tian on Feb 4th, 2025
% for dlpfc, select size of pmd for 200 times. Then do dpca; calculated
% variance. 

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

clear all; close all; clc

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

%% dlpfc dpca

pfcSelectdPCA = struct;
dlpfcSelectVar = struct;

% randomly choose 996 units from dlpfc pool; calculate explained variance 
numEach = size(pmdFR_average,1); 

tic
parfor ii = 1:100
    permuteNum1 = randperm(size(dlpfcFR_average,1));
    dlpfcSelect = permuteNum1(1:numEach);

    firingRatesAverage = dlpfcFR_average(dlpfcSelect,:,:,:);


    [W,V,whichMarg] = dpca(firingRatesAverage, 30, ...
        'combinedParams', combinedParams);

    explVar = dpca_explainedVariance(firingRatesAverage, W, V, ...
        'combinedParams', combinedParams);

    d = explVar.totalMarginalizedVar / explVar.totalVar * 100;


    %% store variance explained to a structure
    pfcSelectdPCA(ii).firingRatesAverage = firingRatesAverage;
    pfcSelectdPCA(ii).whichMarg = whichMarg;
    pfcSelectdPCA(ii).W = W;
    pfcSelectdPCA(ii).V = V;
    pfcSelectdPCA(ii).explVar = explVar;
    pfcSelectdPCA(ii).margNames = margNames;
    pfcSelectdPCA(ii).varPercent = d;

    dlpfcSelectVar(ii).margNames = margNames;
    dlpfcSelectVar(ii).varPercent = d;
    
    fprintf("session %d finished \n", ii);    
    
end

toc

%%
% save(['/projectnb/chandlab/tian/dPCA_shuffle/pfcSelectdPCA0204.mat'], 'pfcSelectdPCA','-v7.3','-nocompression');
% save(['/projectnb/chandlab/tian/dPCA_shuffle/dlpfcSelectVar0204.mat'], 'dlpfcSelectVar','-v7.3','-nocompression');

% save(['./pfcSelectdPCA0204.mat'], 'pfcSelectdPCA','-v7.3','-nocompression');
% save(['./dlpfcSelectVar0204.mat'], 'dlpfcSelectVar','-v7.3','-nocompression');

%% pmd dpca

[W,V,whichMarg] = dpca(pmdFR_average, 30, ...
    'combinedParams', combinedParams);

pmdExplVar = dpca_explainedVariance(pmdFR_average, W, V, ...
    'combinedParams', combinedParams);

pmdVar = pmdExplVar.totalMarginalizedVar / pmdExplVar.totalVar * 100;

%% plot difference between selected dlpfc and pmd 

load('dlpfcSelectVar0204.mat')

results = [];
for ip = 1:length(dlpfcSelectVar)
    results(:,ip) = dlpfcSelectVar(ip).varPercent - pmdVar;
end

figure('Position',[100 100 800 800])
subplot(2,2,1)
histogram(results(1,:), 20)
title('color')

subplot(2,2,2)
histogram(results(2,:), 20)
title('direction')

subplot(2,2,3)
histogram(results(3,:), 20)
title('CI')

subplot(2,2,4)
histogram(results(4,:), 20)
title('context')
