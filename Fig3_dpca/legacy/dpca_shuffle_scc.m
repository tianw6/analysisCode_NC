% dpca shuffle of Tian's whole TF data
% choose 450 DLPFC and 450 pmd units to combine a dataset
% then compare the 2 combined dataset pairs variancce explained difference

clear all; close all; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% path of all dpca core code %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath("/usr3/graduate/tianw/Documents/dPCA/matlab");

dlpfcFR_average = load('dlpfcFR.mat').firingRatesAverage;
pmdFR_average = load('pmdFR.mat').firingRatesAverage;


%% specify time points and parameters

combinedParams = {{1, [1 3]}, {2, [2 3]}, {3}, {[1 2], [1 2 3]}};
margNames = {'Color', 'Direction', 'Condition-independent', 'Configuration'};
margColours = [23 100 171; 187 20 25; 150 150 150; 114 97 171]/256;

% time of time restretching target aligned
time = linspace(-0.1, 1.2, size(dlpfcFR_average, 4));
timeEvents = [0 0.7];



%% create 100 shuffled 


shuffledVar = struct;

numEach = 800;

tic
parfor ii = 1:100
    %% create shuffled data

    % shuffle: create a shuffled dataset containing 1000 neurons: 50% from DLPFC;
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
% save(['./shuffledVar.mat'], 'shuffledVar','-v7.3','-nocompression');



%% load 100 shuffled variance pair (calculated at BU scc)

% load('shuffledVar.mat');

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


%% calculate real variance 
pfcVar = dpcaCalVar(dlpfcFR_average, combinedParams);
pmdVar = dpcaCalVar(pmdFR_average, combinedParams);


%% compared DLPFC-PMd difference with shuffled pairs

var_diff = (dlpfcVar - pmdVar);
shuffledVarArr = varDS1 - varDS2;


figure('Position',[300 300 1400 400])
subplot(1,3,1); hold on
histogram(shuffledVarArr(:,1), 'BinWidth', 0.1)
histogram(var_diff(:,1), 'BinWidth', 0.1)
% xline(pfcVar(:,1) - pmdVar(:,1), 'r', 'linewidth', 2)

title(margNames{1})

sum((shuffledVarArr(:,1) > median(var_diff(:,1))))/100
p = ranksum(shuffledVarArr(:,1),var_diff(:,1), 'alpha', 0.01, 'tail', 'left')

subplot(1,3,2); hold on
histogram(shuffledVarArr(:,2), 'BinWidth', 1)
histogram(var_diff(:,2), 'BinWidth', 1)
% xline(pfcVar(:,2) - pmdVar(:,2), 'r', 'linewidth', 2)

title(margNames{2})

sum((shuffledVarArr(:,2) > median(var_diff(:,2))))/100
p = ranksum(shuffledVarArr(:,2),var_diff(:,2), 'alpha', 0.01, 'tail', 'right')


subplot(1,3,3); hold on
histogram(shuffledVarArr(:,4), 'BinWidth', 0.4)
histogram(var_diff(:,4), 'BinWidth', 0.4)
% xline(pfcVar(:,4) - pmdVar(:,4), 'r', 'linewidth', 2)

title(margNames{4})

sum((shuffledVarArr(:,4) > median(var_diff(:,4))))/100
p = ranksum(shuffledVarArr(:,4),var_diff(:,4), 'alpha', 0.01, 'tail', 'left')

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig3_s/', 'dpca_shuffle','.eps'], '-r300');

