%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% path of all dpca core code %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath("/Users/tianwang/Documents/MATLAB/ChandLab/dPCA/matlab");


% load PMD data:
load('/Volumes/TianSSD/PMd/PMd_PCA_Trajectories.mat');

firingRatesAverageT = summarizedData.choiceandcolor.targets.FR;
firingRatesAverageC = summarizedData.choiceandcolor.check.FR;

% aligned with target (-100 to 367)
segT = firingRatesAverageT(:,:,:,201:367+300);
% aligned with checkerboard(-368 to 465)
segC = firingRatesAverageC(:,:,:,233:601+464);
firingRatesAverage =  cat(4, segT, segC);

size(firingRatesAverage)

% current 2nd dimension: decision; 3rd dimension: stimulus
% swap 2nd and 3rd dimension

firingRatesAverage2 = zeros(size(firingRatesAverage));

for ii = 1:size(firingRatesAverage, 2)
    temp = firingRatesAverage(:,ii,:,:);
    firingRatesAverage2(:,:,ii,:) = temp;
end

firingRatesAverage = firingRatesAverage2;
      
%% 

combinedParams = {{1, [1 3]}, {2, [2 3]}, {3}, {[1 2], [1 2 3]}};
margNames = {'Color', 'Direction', 'Condition-independent', 'Configuration'};
margColours = [23 100 171; 187 20 25; 150 150 150; 114 97 171]/256;

% time of time restretching target aligned
time = linspace(-0.1, 1.2, size(firingRatesAverage, 4));
timeEvents = [0 0.735];


%% Step 1: PCA of the dataset

X = firingRatesAverage(:,:);
X = bsxfun(@minus, X, mean(X,2));

[W,~,~] = svd(X, 'econ');
W = W(:,1:20);

% minimal plotting
% dpca_plot(firingRatesAverage, W, W, @dpca_plot_default);

% computing explained variance
explVar = dpca_explainedVariance(firingRatesAverage, W, W, ...
    'combinedParams', combinedParams);

% a bit more informative plotting
dpca_plot(firingRatesAverage, W, W, @dpca_plot_default, ...
    'explainedVar', explVar, ...
    'time', time,                        ...
    'timeEvents', timeEvents,               ...
    'marginalizationNames', margNames, ...
    'marginalizationColours', margColours);

% print('-painters','-depsc',['~/Documents/MATLAB/ChandLab/DLPFC_analysis/resultFigures/DLPFC_pca/', 'pcaAll','.eps'], '-r300');
% savefig(['~/Documents/MATLAB/ChandLab/DLPFC_analysis/resultFigures/DLPFC_pca/', 'pcaAll','.fig']);

%% 


[W,V,whichMarg] = dpca(firingRatesAverage, 30, ...
    'combinedParams', combinedParams);

explVar = dpca_explainedVariance(firingRatesAverage, W, V, ...
    'combinedParams', combinedParams);

dpca_plot(firingRatesAverage, W, V, @dpca_plot_default, ...
    'explainedVar', explVar, ...
    'marginalizationNames', margNames, ...
    'marginalizationColours', margColours, ...
    'whichMarg', whichMarg,                 ...
    'time', time,                        ...
    'timeEvents', timeEvents,               ...
    'timeMarginalization', 3, ...
    'legendSubplot', 16, ...
    'numCompToShow', 20);

% print('-painters','-depsc',['~/Desktop/', 'dpca_PMD','.eps'], '-r300');
