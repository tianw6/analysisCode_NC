%%%%%%%%%%%%%%%%%%%%
% This code plots Fig 3c: DLPFC dpca 


clear all; close all; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% path of all dpca core code %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath("../utils/dPCA/");




% load DLPFC data
a = load('../../analysisData_NC/Fig3/TiberiusNpix/DLPFC_T_ColorCxtCorrect.mat').totalDataframe;
b = load('../../analysisData_NC/Fig3/TiberiusNpix/DLPFC_C_ColorCxtCorrect.mat').totalDataframe;

c = load('../../analysisData_NC/Fig3/TiberiusVprobe/DLPFC_T_ColorCxtCorrect.mat').totalDataframe;
d = load('../../analysisData_NC/Fig3/TiberiusVprobe/DLPFC_C_ColorCxtCorrect.mat').totalDataframe;

e = load('../../analysisData_NC/Fig3/VinnieNpix/DLPFC_T_ColorCxtCorrect.mat').totalDataframe;
f = load('../../analysisData_NC/Fig3/VinnieNpix/DLPFC_C_ColorCxtCorrect.mat').totalDataframe;

g = load('../../analysisData_NC/Fig3/VinnieVprobe/DLPFC_T_ColorCxtCorrect.mat').totalDataframe;
h = load('../../analysisData_NC/Fig3/VinnieVprobe/DLPFC_C_ColorCxtCorrect.mat').totalDataframe;



frTN = cat(4, a(:,:,:,101:900), b(:,:,:,801:1300));

frTV = cat(4, c(:,:,:,301:1100), d(:,:,:,801:1300));

frVN = cat(4, e(:,:,:,101:900), f(:,:,:,801:1300));

frVV = cat(4, g(:,:,:,301:1100), h(:,:,:,801:1300));

firingRatesAverage = [frTN; frTV; frVN; frVV];




combinedParams = {{1, [1 3]}, {2, [2 3]}, {3}, {[1 2], [1 2 3]}};
margNames = {'Stimulus', 'Decision', 'Condition-independent', 'S/D Interaction'};

margColours = [23 100 171; 187 20 25; 150 150 150; 114 97 171]/256;


% time of combined T and C data
time = linspace(-0.1, 1.2, size(firingRatesAverage, 4));
timeEvents = [0, 0.7];


%% Fig3c: DLPFC dpca

% This is the core function.
% W is the decoder, V is the encoder (ordered by explained variance),
% whichMarg is an array that tells you which component comes from which
% marginalization

tic
[W,V,whichMarg] = dpca(firingRatesAverage, 30, ...
    'combinedParams', combinedParams);
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

% print('-painters','-depsc',['~/Desktop/', 'dpca_pfc_colorcxt','.eps'], '-r300');



%% print explained variance for each task variable

(explVar.totalMarginalizedVar)./(explVar.totalVar)

