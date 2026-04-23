% T: -100:400
% C: -200:300
% M: -200:300




% legacy anova results with 20 bin step
% pmdC = [load('OlafPMDVprobeC.mat').results, load('TibsPMDVprobeC.mat').results, load('TibsPMDNpixC.mat').results];
% dlpfcC = [load('TibsDLPFCVprobeC.mat').results, load('TibsDLPFCNpixC.mat').results, load('VinnieVprobeC.mat').results, load('VinnieNpixC.mat').results];
% 
% pmdT = [load('OlafPMDVprobeT.mat').results, load('TibsPMDVprobeT.mat').results, load('TibsPMDNpixT.mat').results];
% dlpfcT = [load('TibsDLPFCVprobeT.mat').results, load('TibsDLPFCNpixT.mat').results, load('VinnieVprobeT.mat').results, load('VinnieNpixT.mat').results];
% 
% pmdM = [load('OlafPMDVprobeM.mat').results, load('TibsPMDVprobeM.mat').results, load('TibsPMDNpixM.mat').results];
% dlpfcM = [load('TibsDLPFCVprobeM.mat').results, load('TibsDLPFCNpixM.mat').results, load('VinnieVprobeM.mat').results, load('VinnieNpixM.mat').results];


%%
addpath('../../utils/')



dlpfcC = load('ESresultsDLPFC').results;
pmdC = load('ESresultsPMD').results;
dlpfcT = load('ESresultsDLPFCT').results;
pmdT = load('ESresultsPMDT').results;

%% 


% Which threshold should I set?
figure('Position', [10 10 900 600]);


[TsigPerPFC, TmixPPFC, TsigPPFC] = plotAnova(dlpfcT, subplot(2,2,1), [-100 500], [0.4 0.7]);
[CsigPerPFC, CmixPPFC, CsigPPFC] = plotAnova(dlpfcC, subplot(2,2,2), [-100 500], [0.4 0.7]);

plotAnova(dlpfcT, subplot(2,2,3), [-100 500], [0 0.3]);
plotAnova(dlpfcC, subplot(2,2,4), [-100 500], [0 0.3]);

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig2_s/', 'dlpfcAnovaBreak_new', '.eps']);


figure('Position', [10 10 900 600]);


[TsigPerPMd, TmixPPMd, TsigPPMD] = plotAnova(pmdT, subplot(2,2,1), [-100 500], [0.4 0.7]);
[CsigPerPMd, CmixPPMd, CsigPPMD] = plotAnova(pmdC, subplot(2,2,2), [-100 500], [0.4 0.7]);
plotAnova(pmdT, subplot(2,2,3), [-100 500], [0 0.3]);
plotAnova(pmdC, subplot(2,2,4), [-100 500], [0 0.3]);

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig2_s/', 'pmdAnovaBreak_new', '.eps']);


%% plot bar graph: modulated to how many variables

% alignd to C: [150:400]
% align to T: [100:300]

Ctime = dlpfcC.time;

Clim = [150, 250]; 


select = Ctime >= Clim(1) & Ctime <= Clim(2);
CPFC = squeeze(sum(CsigPPFC(:,select,:), 1));
CPMD = squeeze(sum(CsigPPMD(:,select,:), 1));

a = mean(CPFC,1);
b = mean(CPMD,1);

meanMix = [mean(a); mean(b)];

stmMix = [std(a)./sqrt(length(a)); std(b)./sqrt(length(b))];

options.categorySpacing = 2; 
options.barWidth   = 0.5;   % how "wide" each group is

plotBar(meanMix, stmMix, options)



a = squeeze(sum(CsigPPFC([3 1],:,:),1)) > 1;
b = squeeze(sum(CsigPPMD([3 1],:,:),1)) > 1;

figure; hold on
plot(Ctime, sum(a,2)./size(a,2));
plot(Ctime, sum(b,2)./size(b,2));





%% plot bar graph: percentage of units modulated to units 

% alignd to C: [150:400]
% align to T: [100:300]

Ttime = dlpfcT.time;
Ctime = dlpfcC.time;

Clim = [150, 400]; 
Tlim = [100,300];

TPFC = TsigPerPFC(3,Ttime >= Tlim(1) & Ttime <= Tlim(2));
TPMd = TsigPerPMd(3,Ttime >= Tlim(1) & Ttime <= Tlim(2));

figure;
bar([mean(TPFC), mean(TPMd)], 0.3)
ylim([0 0.1])

title(['tar' num2str(Tlim)])
% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig2_s/', 'bar_tar_new', '.eps']);

c = CsigPerPFC(:,Ctime >= Clim(1) & Ctime <= Clim(2));
d = CsigPerPMd(:,Ctime >= Clim(1) & Ctime <= Clim(2));


e = CmixPPFC(Ctime >= Clim(1) & Ctime <= Clim(2));
f = CmixPPMd(Ctime >= Clim(1) & Ctime <= Clim(2));

CallPFC = [c;e'];
CallPMd = [d;f'];

figure; 
bar([mean(CallPFC,2), mean(CallPMd,2)])
title(['cue' num2str(Clim)])
% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig2_s/', 'bar_cue_new', '.eps']);

