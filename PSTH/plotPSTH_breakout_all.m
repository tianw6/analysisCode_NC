% for vprobe data
% code to plot PSTH from raster plots. 


clear all; close all; clc


% load allTrials data from TiberiusDLPFCAllTrials
baseDir = ['/Volumes/TianSSD/TiberiusDLPFCRaster/RasterC/'];
baseDirT = ['/Volumes/TianSSD/TiberiusDLPFCRaster/'];

date = '20220222';
recording = 'R2';

% load data
allData = load([baseDir  date recording '.mat']).dataframe;

allDataT = load([baseDirT  date recording '.mat']).dataframe;

% only choose correct trials?
% dataTable = struct2table(allData);
% outcomeTable = dataTable(:,{'TrialOutcome'});
% outcomeCell = table2cell(outcomeTable);
% correct = strcmp(outcomeCell, 'Correct Choice')';
% allData = allData(correct);       
    

% extract performances
perf = [allData.performance];

perfTable = struct2table(perf);
colorTable = perfTable(:,{'ChosenColor'});
colorCell = table2cell(colorTable);
red = strcmp(colorCell, 'red')';

choiceTable = perfTable(:,{'ChosenSide'});
choiceCell = table2cell(choiceTable);
left = strcmp(choiceCell, 'left')';

params = [allData.params];
cxt1 = [params.LeftTargetColor] == 2;

RL = red & left;
RR = red & ~left;
GL = ~red & left;
GR = ~red & ~left;


%% for npix data


clear all; close all; clc


% load allTrials data from TiberiusDLPFCAllTrials
baseDir = ['/Volumes/TianSSD/TiberiusNpix/checkerboardAligned/'];
baseDirT = ['/Volumes/TianSSD/TiberiusNpix/targetAligned/'];

date = '20240906';

% load data
allData = load([baseDir  date  'PMD.mat']).allData;

allDataT = load([baseDirT  date  'PMD.mat']).allData;

% only choose correct trials?
% dataTable = struct2table(allData);
% outcomeTable = dataTable(:,{'TrialOutcome'});
% outcomeCell = table2cell(outcomeTable);
% correct = strcmp(outcomeCell, 'Correct Choice')';
% allData = allData(correct);       
    

% extract performances
perf = [allData.DLperformance];

perfTable = struct2table(perf);
colorTable = perfTable(:,{'ChosenColor'});
colorCell = table2cell(colorTable);
red = strcmp(colorCell, 'red')';

choiceTable = perfTable(:,{'ChosenSide'});
choiceCell = table2cell(choiceTable);
left = strcmp(choiceCell, 'left')';

params = [allData.DLparams];
cxt1 = [params.LeftTargetColor] == 2;

RL = red & left;
RR = red & ~left;
GL = ~red & left;
GR = ~red & ~left;



%% create FR_matrix
g = normpdf([-0.1:0.001:0.1],0,0.025);
chopTime = 200;

FRmatrix = zeros([size(allData(1).rasterT,1), size(allData(1).rasterT,2) - chopTime*2, length(allData)]);

for im = 1:length(allData)
    raster = allData(im).rasterT;
    
    for id = 1:size(raster,1)
        FR = conv(raster(id,:), g, 'same');
        FRmatrix(id,:,im) = FR(chopTime+1:end-chopTime);
    end
end




pre = 0;
post = 0.8;
tSpan = linspace(-0.8, 0.8 - 0.001, size(FRmatrix,2));
% tSpan = linspace(-0.8, 1.4 - 0.001, size(FRmatrix,2));

tSelect = tSpan>=pre & tSpan <post;
FRmatrix = FRmatrix(:,tSelect,:);



FRmatrixT = zeros([size(allDataT(1).rasterT,1), size(allDataT(1).rasterT,2) - chopTime*2, length(allDataT)]);

for im = 1:length(allDataT)
    raster = allDataT(im).rasterT;
    
    for id = 1:size(raster,1)
        FR = conv(raster(id,:), g, 'same');
        FRmatrixT(id,:,im) = FR(chopTime+1:end-chopTime);
    end
end

preT = -0.2;
postT = 0.6;
tSpan = linspace(-0.2, 1.8-0.001, size(FRmatrixT,2));
% tSpan = linspace(-0.6, 2.2-0.001, size(FRmatrixT,2));

tSelect = tSpan>=preT & tSpan <postT;
FRmatrixT = FRmatrixT(:,tSelect,:);




%% 
%%%%%%%%%%%%%%%% for pmd data

clear all; close all; clc


% load allTrials data from TiberiusDLPFCAllTrials
baseDir = ['/Volumes/TianSSD/PMd/PMdData/Olaf/'];


allDataT = load([baseDir 'OlafPMdT1.mat']).dataframe;
allData = load([baseDir 'OlafPMdC1.mat']).dataframe;

%%
dayn = 73;
daynDataT = allDataT(dayn); 
daynDataC = allData(dayn);

perf = [daynDataC.behavior];
% chosen side
left = [perf.chosenSide] == 1;
% chosen color
perfTable = struct2table(perf);
a = perfTable(:,{'TrialOutcome'});
b = table2cell(a);    
correct = strcmp(b, 'Correct Choice')';

red = [perf.CentralCuenSquares] > 112 & correct == 1 | [perf.CentralCuenSquares] < 112 & correct == 0;


cxt1 = [perf.LeftTargetColor] == 2;
RL = red & left;
RR = red & ~left;
GL = ~red & left;
GR = ~red & ~left;



%%

daynSpikesT = double(daynDataT.spikes);
daynSpikesC = double(daynDataC.spikes);

FRmatrixT = [];
FRmatrix = [];

FRT = []; FRC = [];

g = normpdf([-0.1:0.001:0.1],0,0.025);
chopTime = 200;
for im = 1:size(daynSpikesT,3)
    
    for id = 1:size(daynSpikesT,2)
        FRT = conv(daynSpikesT(:,id,im), g, 'same');
        FRC = conv(daynSpikesC(:,id,im), g, 'same');
        FRmatrixT(im,:,id) = FRT(chopTime+1:end-chopTime);
        FRmatrix(im,:,id) = FRC(chopTime+1:end-chopTime);
        
    end
end

%%
pre = 0;
post = 0.8;
tSpan = linspace(-0.8, 0.8 - 0.001, size(FRmatrix,2));
tSelect = tSpan>=pre & tSpan <post;
FRmatrix = FRmatrix(:,tSelect,:);


preT = -0.2;
postT = 0.6;
tSpan = linspace(-0.2, 1.8-0.001, size(FRmatrixT,2));
tSelect = tSpan>=preT & tSpan <= postT-0.001;
FRmatrixT = FRmatrixT(:,tSelect,:);


%% Plot PSTH 


alpha = 0.3;
yminMax = [0 90];
    


for ip = 15%1:size(FRmatrix,1)  % [3 12]

figure;   


t = [pre:0.001:post-0.001];




rFR_LR = squeeze((FRmatrix(ip,:,RL)))';
rFR_RR = squeeze((FRmatrix(ip,:,RR)))';
rFR_LG = squeeze((FRmatrix(ip,:,GL)))';
rFR_RG = squeeze((FRmatrix(ip,:,GR)))';



subplot(1,2,2); hold on
data = rFR_RR;
PSTH_mean = nanmean(data);
PSTH_sem = std(data)./sqrt(size(data,1));
patch = fill([t fliplr(t)] , [PSTH_mean+PSTH_sem fliplr(PSTH_mean-PSTH_sem)], [0.4 0 0.2]);
set(patch, 'edgecolor', 'none', 'FaceAlpha', alpha );
hold on;

data = rFR_LR;
PSTH_mean = nanmean(data);
PSTH_sem = std(data)./sqrt(size(data,1));
patch = fill([t fliplr(t)] , [PSTH_mean+PSTH_sem fliplr(PSTH_mean-PSTH_sem)], [0.8 0 0]);
set(patch, 'edgecolor', 'none', 'FaceAlpha', alpha );
hold on;

data = rFR_RG;
PSTH_mean = nanmean(data);
PSTH_sem = std(data)./sqrt(size(data,1));
patch = fill([t fliplr(t)] , [PSTH_mean+PSTH_sem fliplr(PSTH_mean-PSTH_sem)], [0 0.4 0.2]);
set(patch, 'edgecolor', 'none', 'FaceAlpha', alpha );
hold on;

data = rFR_LG;
PSTH_mean = nanmean(data);
PSTH_sem = std(data)./sqrt(size(data,1));
patch = fill([t fliplr(t)] , [PSTH_mean+PSTH_sem fliplr(PSTH_mean-PSTH_sem)], [0 0.8 0.2]);
set(patch, 'edgecolor', 'none', 'FaceAlpha', alpha );
hold on;    


% mean psths
plot(t, nanmean(rFR_RR),'--','color',[0.4 0 0.2], 'LineWidth', 2)
hold on
plot(t, nanmean(rFR_LR),'-','color',[ 0.8 0 0], 'LineWidth', 2);
hold on
plot(t, nanmean(rFR_RG),'--','color',[0 0.4 0.2], 'LineWidth', 2)
hold on
plot(t, nanmean(rFR_LG),'-','color',[ 0.0 0.8 0.2], 'LineWidth', 2);
hold on

% aligned
xline(0, 'k--', 'linewidth', 1)
%legend('Right Red', 'Left Red', 'Right Green' ,'Left Green', '', 'Location', 'southeast')
title(ip)
set(gcf, 'Color', 'w','renderer','Painters')
set(gca,'tickdir','out');
box off;
%axis on
axis tight
hold on;


xlim([pre, post])


ylim(yminMax)


%% plot target aligned

t = [preT:0.001:postT-0.001];




rFR_cxt1 = squeeze((FRmatrixT(ip,:,cxt1)))';
rFR_cxt2 = squeeze((FRmatrixT(ip,:,~cxt1)))';




subplot(1,2,1); hold on
data = rFR_cxt1;
PSTH_mean = nanmean(data);
PSTH_sem = std(data)./sqrt(size(data,1));
patch = fill([t fliplr(t)] , [PSTH_mean+PSTH_sem fliplr(PSTH_mean-PSTH_sem)], [0.8500 0.3250 0.0980]);
set(patch, 'edgecolor', 'none', 'FaceAlpha', alpha );
hold on;

data = rFR_cxt2;
PSTH_mean = nanmean(data);
PSTH_sem = std(data)./sqrt(size(data,1));
patch = fill([t fliplr(t)] , [PSTH_mean+PSTH_sem fliplr(PSTH_mean-PSTH_sem)], [0 0.4470 0.7410]);
set(patch, 'edgecolor', 'none', 'FaceAlpha', alpha );
hold on;

 


% mean psths
plot(t, nanmean(rFR_cxt1),'-','color',[0.8500 0.3250 0.0980], 'LineWidth', 2)
hold on
plot(t, nanmean(rFR_cxt2),'-','color',[0 0.4470 0.7410], 'LineWidth', 2);
hold on


% aligned
xline(0, 'k--', 'linewidth', 1)
%legend('Right Red', 'Left Red', 'Right Green' ,'Left Green', '', 'Location', 'southeast')
title(ip)
set(gcf, 'Color', 'w','renderer','Painters')
set(gca,'tickdir','out');
box off;
%axis on
axis tight
hold on;


xlim([preT, postT])


ylim(yminMax)
 


end

%% 

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig2/PMD20240906Unit22','.eps']);

