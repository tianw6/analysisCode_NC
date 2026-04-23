%% created by Tina on May 29th 


% combine pfc and pmd data and do dpca together

clear; clc; close all

addpath('..')


%% for dlpfc Data
a = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/checkerboardAligned/allBinFRnpix.mat').allBinFR;



b = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Vinnie/checkerboardAligned/allBinFRnpix.mat').allBinFR;
c = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/checkerboardAligned/allBinFRvprobe.mat').allBinFR;
d = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Vinnie/checkerboardAligned/allBinFRvprobe.mat').allBinFR;

binFRpfc = [c,a,d,b];

%% for pmd data
a = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/checkerboardAligned/allBinFRnpixPMD.mat').allBinFR;
b = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/checkerboardAligned/allBinFRvprobePMD.mat').allBinFR;
c = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Olaf/checkerboardAligned/allBinFRvprobePMD.mat').allBinFR;


binFRpmd = [a b c];

%%
allTime = binFRpfc(1).time;

tStart = -100;
tEnd = 400; 
tSelected = allTime >= tStart & allTime <= tEnd;

time = allTime(tSelected);



%% 


for ii = 1:length(binFRpfc)
    
    binFRpfc(ii).trials = binFRpfc(ii).trials(:,:,tSelected);
    binFRpfc(ii).time = binFRpfc(ii).time(tSelected);

end

for ii = 1:length(binFRpmd)
    

    binFRpmd(ii).trials = binFRpmd(ii).trials(:,:,tSelected);
    binFRpmd(ii).time = binFRpmd(ii).time(tSelected);
end


%%

% firingRatesAverage = [];
% for ii = 1:length(allBinFR)
%     
%     trials = allBinFR(ii).trials;
%     taskLabels = allBinFR(ii).taskLabels;
%     
%     RL = taskLabels == 0;
%     RR = taskLabels == 1;
%     GL = taskLabels == 2;
%     GR = taskLabels == 3;
%     
%     temp = [];
%     if size(trials, 2) ~= 1
%         temp(:,1,1,:) = squeeze(mean(trials(RL,:,:),1));
%         temp(:,1,2,:) = squeeze(mean(trials(RR,:,:),1));
%         temp(:,2,1,:) = squeeze(mean(trials(GL,:,:),1));
%         temp(:,2,2,:) = squeeze(mean(trials(GR,:,:),1));
%     else
% 
%         temp(:,1,1,:) = squeeze(mean(trials(RL,:,:),1))';
%         temp(:,1,2,:) = squeeze(mean(trials(RR,:,:),1))';
%         temp(:,2,1,:) = squeeze(mean(trials(GL,:,:),1))';
%         temp(:,2,2,:) = squeeze(mean(trials(GR,:,:),1))';        
%         
%     end
%     
%     firingRatesAverage = [firingRatesAverage; temp];
% end
% 
% processedFR = preprocess(firingRatesAverage);


%%

[processedFRpfc, frAvgPFC] = prepareData(binFRpfc);
[processedFRpmd, frAvgPMD] = prepareData(binFRpmd);

firingRatesAverage = [frAvgPFC; frAvgPMD];




%%

combinedParams = {{1, [1 3]}, {2, [2 3]}, {3}, {[1 2], [1 2 3]}};
margNames = {'Stimulus', 'Decision', 'Condition-independent', 'S/D Interaction'};

% margNames = {'SC', 'Configuration', 'Condition-independent', 'C/D Interaction'};

margColours = [23 100 171; 187 20 25; 150 150 150; 114 97 171]/256;

% For two parameters (e.g. stimulus and time, but no decision), we would have
% firingRates array of [N S T E] size (one dimension less, and only the following
% possible marginalizations:
%    1 - stimulus
%    2 - time
%    [1 2] - stimulus/time interaction
% They could be grouped as follows: 
%    combinedParams = {{1, [1 2]}, {2}};

% Time events of interest (e.g. stimulus onset/offset, cues etc.)
% They are marked on the plots with vertical lines


% time of combined T and C data
timeEvents = [0];

%%

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

%%

choiceLoad = W(:,3);
cxtLoad = W(:,5);
colorLoad = W(:,7);

%% 
select = [3 5 7];

fef = W(1:234, select);
d = W(235:1500,select);

v = W(1501:5570,select);
ant = W(5570-690:5570,select);

pmd = W(5571:end,select);


%% 

d1 = 1;
d2 = 2;

figure;
% plot( fef(:,2), fef(:,3), '.')
hold on
subplot(232)
hold on
c22 = cov(d(:,[d1 d2]));
error_ellipse(c22,'conf',0.99);


plot( d(:,d1), d(:,d2), 'bd')
hold on;
xline(prctile(d(:,d1),[1 99]));
yline(prctile(d(:,d2),[1 99]));
title('dorsal')



subplot(235);
hold on

c22 = cov(v(:,[d1 d2]));
error_ellipse(c22,'conf',0.99);

plot( v(:,d1), v(:,d2), 'gs','markerfacecolor',[0.8 0.8 0.8])
xline(prctile(v(:,d1),[1 99]));
yline(prctile(v(:,d2),[1 99]));
hold on;
title('ventral')


subplot(231);
hold on;
c22 = cov(ant(:,[d1 d2]));
error_ellipse(c22,'conf',0.99);
plot( ant(:,d1), ant(:,d2), 'm.')
xline(prctile(ant(:,d1),[1 99]));
yline(prctile(ant(:,d2),[1 99]));
title('anterior')

subplot(233);
hold on;
c22 = cov(pmd(:,[d1 d2]));
error_ellipse(c22,'conf',0.99);

plot(pmd(:,d1), pmd(:,d2), 'k.')
xline(prctile(pmd(:,d1),[1 99]));
yline(prctile(pmd(:,d2),[1 99]));
title('pmd')

for k=[1 2 3 5]
    subplot(2,3,k);
    xlim([-0.1 0.1]);
    ylim([-0.1 0.1]);
end


% xlabel('choice')
xlabel('color')
ylabel('choice')


% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig5/', 'ellipseColorChoice', '.eps']);

%%

c22 = cov(pmd(:,[1:3]));
h = error_ellipse(c22,'conf',0.99);
set(h,'linestyle','none');
axis equal;
hold on;

%%
hold on;
c22 = cov(v(:,[1:3]));
h = error_ellipse(c22,'conf',0.99);
set(h,'linestyle','none');
axis equal;

c22 = cov(d(:,[1:3]));
h = error_ellipse(c22,'conf',0.99);
set(h,'linestyle','none');


axis equal;

c22 = cov(ant(:,[1:3]));
h = error_ellipse(c22,'conf',0.99);
set(h,'linestyle','none');
