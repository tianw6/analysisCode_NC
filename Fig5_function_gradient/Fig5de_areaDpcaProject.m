%%%%%%%%%%%%%%%%%%%%
% This code plots Fig 5d-e: covariance ellipsis and average dpc loading of task modulation in each area

clear;clc 

load('areaUnitNums');
area8 = areaUnitNums.area8;
dlpfcD = areaUnitNums.dlpfcD;
dlpfcV = areaUnitNums.dlpfcV;
dlpfcA = areaUnitNums.dlpfcA;
pmd = areaUnitNums.pmd;

%% 

a = load('../../analysisData_NC/Fig4/Tiberius/checkerboardAligned/allBinFRvprobe.mat').allBinFR;
b = load('../../analysisData_NC/Fig4/Vinnie/checkerboardAligned/allBinFRvprobe.mat').allBinFR;
c = load('../../analysisData_NC/Fig4/Ziggy/checkerboardAligned/allBinFRvprobe.mat').allBinFR;

d = load('../../analysisData_NC/Fig4/Vinnie/checkerboardAligned/allBinFRnpix.mat').allBinFR;
e = load('../../analysisData_NC/Fig4/Tiberius/checkerboardAligned/allBinFRnpix.mat').allBinFR;
f = load('../../analysisData_NC/Fig4/Tiberius/checkerboardAligned/allBinFRnpixPMD.mat').allBinFR;




binFRpfc = [a,b,c, d,e, f];

allTime = binFRpfc(1).time;

tStart = -100;
tEnd = 400; 
tSelected = allTime >= tStart & allTime <= tEnd;

time = allTime(tSelected);

for ii = 1:length(binFRpfc)
    
    binFRpfc(ii).trials = binFRpfc(ii).trials(:,:,tSelected);
    binFRpfc(ii).time = binFRpfc(ii).time(tSelected);

end

% normalize firing rates
normalizeData = 1;
[firingRatesAverage] = prepareFRaverage(binFRpfc, normalizeData);

% perform dpca

combinedParams = {{1, [1 3]}, {2, [2 3]}, {3}, {[1 2], [1 2 3]}};
margNames = {'Stimulus', 'Decision', 'Condition-independent', 'S/D Interaction'};

% margNames = {'SC', 'Configuration', 'Condition-independent', 'C/D Interaction'};

margColours = [23 100 171; 187 20 25; 150 150 150; 114 97 171]/256;

% time of combined T and C data
timeEvents = [0];



tic
[W,V,whichMarg] = dpca(firingRatesAverage, 30, ...
    'combinedParams', combinedParams, 'lambda', 1e-9);
toc

explVar = dpca_explainedVariance(firingRatesAverage, W, V, ...
    'combinedParams', combinedParams);

z = dpca_plot(firingRatesAverage, W, V, @dpca_plot_default, ...
    'explainedVar', explVar, ...
    'marginalizationNames', margNames, ...
    'marginalizationColours', margColours, ...
    'whichMarg', whichMarg,                 ...
    'time', time,                        ...
    'timeEvents', timeEvents,               ...
    'timeMarginalization', 3, ...
    'legendSubplot', 16, ...
    'numCompToShow', 20);


choiceLoad = V(:,3);
cxtLoad = V(:,5);
colorLoad = V(:,7);

allLoad = V(:,[3,5,7]);

%% Fig5d or FigS5g: plot covariance ellipsis 

% choose 2 dpc loadings to plot: ('Fig5d' or 'FigS5g')
% 'Fig5d': plot each units dpc loadings on interaction and color
% 'FigS5g': plot each units dpc loadings on action and color


FigHandle = 'Fig5d';

switch FigHandle
    case{'Fig5d'}

        d1 = 2;
        d2 = 3;

    case{'FigS5g'}
        d1 = 1;
        d2 = 3;
        
end

        
figure('Position', [10 10 1400 600])
% area 8
c22 = cov(allLoad(area8,[d1 d2]));
subplot(2,4,3); hold on
plot(allLoad(area8,d1), allLoad(area8,d2), 'k.')
[~, a8] = error_ellipse(c22,'conf',0.99);
ylim([-0.1 0.1])
xlim([-0.1 0.1])
title('area 8')


% dlpfcD
c22 = cov(allLoad(dlpfcD,[d1 d2]));
subplot(2,4,2); hold on
plot(allLoad(dlpfcD,d1), allLoad(dlpfcD,d2), 'k.')
[~, aD] = error_ellipse(c22,'conf',0.99);
ylim([-0.1 0.1])
xlim([-0.1 0.1])
title('dlpfcD')

% dlpfcV
c22 = cov(allLoad(dlpfcV,[d1 d2]));
subplot(2,4,6); hold on
plot(allLoad(dlpfcV,d1), allLoad(dlpfcV,d2), 'k.')
[~, aV] = error_ellipse(c22,'conf',0.99);
ylim([-0.1 0.1])
xlim([-0.1 0.1])
xlabel('cxt')
ylabel('color')
title('dlpfcV')

% dlpfcA
c22 = cov(allLoad(dlpfcA,[d1 d2]));
subplot(2,4,1); hold on
plot(allLoad(dlpfcA,d1), allLoad(dlpfcA,d2), 'k.')
[~, aA] = error_ellipse(c22,'conf',0.99);
ylim([-0.1 0.1])
xlim([-0.1 0.1])
title('dlpfcA')

% pmd
c22 = cov(allLoad(pmd,[d1 d2]));
subplot(2,4,4); hold on
plot(allLoad(pmd,d1), allLoad(pmd,d2), 'k.')
[~, aP] = error_ellipse(c22,'conf',0.99);
ylim([-0.1 0.1])
xlim([-0.1 0.1])
title('pmd')

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig5_s/', 'errorEllipse_dircxt', '.eps']);


% calculate relative area; aV is 1

a8/aV
aD/aV
aA/aV
aP/aV




%% Fig5e: bar graph of averaged dpc loading of task variables in each area

load8 = abs(allLoad(area8,:));
loadD = abs(allLoad(dlpfcD,:));
loadV = abs(allLoad(dlpfcV,:));
loadA = abs(allLoad(dlpfcA,:));
loadP = abs(allLoad(pmd,:));

std8 = std(load8,0, 1)./sqrt(size(load8,1));
stdD = std(loadD,0, 1)./sqrt(size(loadD,1));
stdV = std(loadV,0, 1)./sqrt(size(loadV,1));
stdA = std(loadA,0, 1)./sqrt(size(loadA,1));
stdP = std(loadP,0, 1)./sqrt(size(loadP,1));


y_all = [mean(loadA,1); mean(loadV,1); mean(loadD,1); mean(load8,1); mean(loadP,1)];
dataCI_all = [stdA; stdV; stdD; std8; stdP];



figure('position', [1000,1000,600,300]); hold on
plotBarFig5(y_all(:,1), dataCI_all(:,1))
title('Fig5e: area-averaged action dpc loadings')
% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig5/', 'loadingChoice_pn', '.eps']);

figure('position', [1000,1000,600,300]); hold on
plotBarFig5(y_all(:,2), dataCI_all(:,2))
title('Fig5e: area-averaged interaction dpc loadings')

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig5/', 'loadingInter_pn', '.eps']);

figure('position', [1000,1000,600,300]); hold on
plotBarFig5(y_all(:,3), dataCI_all(:,3))
title('Fig5e: area-averaged color dpc loadings')

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig5/', 'loadingColor_pn', '.eps']);


%% FigS5h: averaged mixed selectivity index of each area

vlRatio8 = calVLRatio(load8);
vlRatioD = calVLRatio(loadD);
vlRatioV = calVLRatio(loadV);
vlRatioA = calVLRatio(loadA);
vlRatioP = calVLRatio(loadP);

std8 = std(vlRatio8,0, 1)./sqrt(size(vlRatio8,1));
stdD = std(vlRatioD,0, 1)./sqrt(size(vlRatioD,1));
stdV = std(vlRatioV,0, 1)./sqrt(size(vlRatioV,1));
stdA = std(vlRatioA,0, 1)./sqrt(size(vlRatioA,1));
stdP = std(vlRatioP,0, 1)./sqrt(size(vlRatioP,1));


y_all = [mean(vlRatioA,1); mean(vlRatioV,1); mean(vlRatioD,1); mean(vlRatio8,1); mean(vlRatioP,1)];
dataCI_all = [stdA; stdV; stdD; std8; stdP];


figure('position', [1000,1000,600,300]); hold on
plotBarFig5(y_all, dataCI_all)
% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig5/', 'loadingMix_pn', '.eps']);

title('FigS5h: area-averaged mixed selectivity index')


function vlRatio = calVLRatio(load)


    maxLoad = max(load,[],2);

    volV = load(:,1).*load(:,2).*load(:,3);

    vlRatio = (volV./maxLoad);

end