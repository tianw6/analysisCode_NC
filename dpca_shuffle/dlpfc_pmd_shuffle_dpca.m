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



%% specify time points and parameters

combinedParams = {{1, [1 3]}, {2, [2 3]}, {3}, {[1 2], [1 2 3]}};
margNames = {'Color', 'Direction', 'Condition-independent', 'Configuration'};
margColours = [23 100 171; 187 20 25; 150 150 150; 114 97 171]/256;

% time of time restretching target aligned
time = linspace(-0.1, 1.2, size(dlpfcFR_average, 4));
timeEvents = [0 0.735];

%% dlpfc dpca

[W,V,whichMarg] = dpca(dlpfcFR_average, 30, ...
    'combinedParams', combinedParams);

dlpfcExplVar = dpca_explainedVariance(dlpfcFR_average, W, V, ...
    'combinedParams', combinedParams);

dlpfcVar = dlpfcExplVar.totalMarginalizedVar / dlpfcExplVar.totalVar * 100;
%% pmd dpca

[W,V,whichMarg] = dpca(pmdFR_average, 30, ...
    'combinedParams', combinedParams);

pmdExplVar = dpca_explainedVariance(pmdFR_average, W, V, ...
    'combinedParams', combinedParams);

pmdVar = pmdExplVar.totalMarginalizedVar / pmdExplVar.totalVar * 100;


%% create 200 shuffled 
% shuffledPCA = struct;
% 
% for ii = 1:2
%     %% create shuffled data
% 
%     % shuffle: craete a shuffled dataset containing 900 neurons: 50% from DLPFC;
%     % 50% from pMd. 
% 
%     numEach = 450;
% 
%     permuteNum1 = randperm(size(dlpfcFR_average,1));
%     dlpfcSelect = permuteNum1(1:numEach);
%     permuteNum2 = randperm(size(pmdFR_average,1));
%     pmdSelect = permuteNum2(1:numEach);
% 
% 
%     firingRatesAverage = [dlpfcFR_average(dlpfcSelect,:,:,:); pmdFR_average(pmdSelect,:,:,:)];
% 
% 
%     %% dpca
% 
% 
%     [W,V,whichMarg] = dpca(firingRatesAverage, 30, ...
%         'combinedParams', combinedParams);
% 
%     explVar = dpca_explainedVariance(firingRatesAverage, W, V, ...
%         'combinedParams', combinedParams);
% 
%     d = explVar.totalMarginalizedVar / explVar.totalVar * 100;
% 
%     %% store variance explained to a structure
%     shuffledPCA(ii).firingRatesAverage = firingRatesAverage;
%     shuffledPCA(ii).whichMarg = whichMarg;
%     shuffledPCA(ii).W = W;
%     shuffledPCA(ii).V = V;
%     shuffledPCA(ii).explVar = explVar;
%     shuffledPCA(ii).margNames = margNames;
%     shuffledPCA(ii).varPercent = d;
% 
%     fprintf("session %d finished \n", ii);
% end
% 


%% load 100 shuffled variance pair (calculated at BU scc)

load('shuffledVar.mat');

shuffedVarArr = zeros(length(shuffledVar)/2, length(margNames));
cnt = 1;
for jj = 1:length(shuffledVar)/2
   shuffedVarArr(cnt,:) = abs(shuffledVar(jj*2-1).varPercent - shuffledVar(jj*2).varPercent); 
   cnt = cnt+1;
end


%% compared DLPFC-PMd difference with shuffled pairs

var_diff = abs(dlpfcVar - pmdVar);

figure; subplot(2,2,1); hold on
histogram(shuffedVarArr(:,1))
xline(var_diff(1), 'r-', 'linewidth', 2)
title(margNames{1})

subplot(2,2,2); hold on
histogram(shuffedVarArr(:,2))
xline(var_diff(2), 'r-', 'linewidth', 2)
title(margNames{2})

subplot(2,2,3); hold on
histogram(shuffedVarArr(:,3))
xline(var_diff(3), 'r-', 'linewidth', 2)
title(margNames{3})

subplot(2,2,4); hold on
histogram(shuffedVarArr(:,4))
xline(var_diff(4), 'r-', 'linewidth', 2)
title(margNames{4})

% print('-painters','-depsc',['~/Desktop/', 'dpca_shuffle','.eps'], '-r300');
