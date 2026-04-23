% code to run 200 shuffle (100 shuffled pairs) on scc

clear all; close all; clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% path of all dpca core code %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

%% 200 shuffles 

shuffledPCA = struct;
parfor_progress(n);
parfor ii = 1:n
    %% create shuffled data

    % shuffle: craete a shuffled dataset containing 900 neurons: 50% from DLPFC;
    % 50% from pMd. 

    numEach = 450;

    permuteNum1 = randperm(size(dlpfcFR_average,1));
    dlpfcSelect = permuteNum1(1:numEach);
    permuteNum2 = randperm(size(pmdFR_average,1));
    pmdSelect = permuteNum2(1:numEach);


    firingRatesAverage = [dlpfcFR_average(dlpfcSelect,:,:,:); pmdFR_average(pmdSelect,:,:,:)];


    %% dpca


    [W,V,whichMarg] = dpca(firingRatesAverage, 30, ...
        'combinedParams', combinedParams);

    explVar = dpca_explainedVariance(firingRatesAverage, W, V, ...
        'combinedParams', combinedParams);

    d = explVar.totalMarginalizedVar / explVar.totalVar * 100;

    %% store variance explained to a structure
    shuffledPCA(ii).firingRatesAverage = firingRatesAverage;
    shuffledPCA(ii).whichMarg = whichMarg;
    shuffledPCA(ii).W = W;
    shuffledPCA(ii).V = V;
    shuffledPCA(ii).explVar = explVar;
    shuffledPCA(ii).margNames = margNames;
    shuffledPCA(ii).varPercent = d;

    fprintf("session %d finished \n", ii);
end

parfor_progress(0);

save(['/projectnb/chandlab/tian/dPCA_shuffle/shuffledPCA.mat'], 'shuffledPCA','-v7.3','-nocompression');
