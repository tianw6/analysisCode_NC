%%%%%%%%%%%%%%%%%%%%
% This code plots Fig S2i-j: percentage of units modulated to task variables based on anova 


%%
addpath('../../utils/')



dlpfcC = load('ESresultsDLPFC').results;
pmdC = load('ESresultsPMD').results;
dlpfcT = load('ESresultsDLPFCT').results;
pmdT = load('ESresultsPMDT').results;

%% FigS2i-j: Percentage of units modulated to task variables 

figure('Position', [10 10 900 600]);


[TsigPerPFC, TmixPPFC, TsigPPFC] = plotAnova(dlpfcT, subplot(2,2,1), [-100 500], [0.4 0.7]);
[CsigPerPFC, CmixPPFC, CsigPPFC] = plotAnova(dlpfcC, subplot(2,2,2), [-100 500], [0.4 0.7]);

plotAnova(dlpfcT, subplot(2,2,3), [-100 500], [0 0.3]);
plotAnova(dlpfcC, subplot(2,2,4), [-100 500], [0 0.3]);

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig2_s/', 'dlpfcAnovaBreak_new', '.eps']);
sgtitle('FigS2i: DLPFC units modulation percentage')

figure('Position', [10 10 900 600]);


[TsigPerPMd, TmixPPMd, TsigPPMD] = plotAnova(pmdT, subplot(2,2,1), [-100 500], [0.4 0.7]);
[CsigPerPMd, CmixPPMd, CsigPPMD] = plotAnova(pmdC, subplot(2,2,2), [-100 500], [0.4 0.7]);
plotAnova(pmdT, subplot(2,2,3), [-100 500], [0 0.3]);
plotAnova(pmdC, subplot(2,2,4), [-100 500], [0 0.3]);

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig2_s/', 'pmdAnovaBreak_new', '.eps']);
sgtitle('FigS2j: PMd units modulation percentage')


