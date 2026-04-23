% plot psths of a unit with SEM 
% inset image: plot all waveforms of that unit 
clear all; close all; clc


% load allTrials data from TiberiusDLPFCAllTrials
baseDir = ['/Volumes/TianSSD/TiberiusDLPFCAllTrials/'];
date = '20220222';
allTrials = load([baseDir 'TiberiusCOLGRID' date '.mat']).allTrials;

sT = [allTrials.SaveTag]; %get savetags
% print trials in e ach saveTag
disp("Trials in each saveTag: " + mat2str(histc(sT,[1:16])))

%% declare some parameters

% define which channel 
chosenChannel = 11;
% define which unit (unitV = -1: plot psth of all units together)
unitV = 1;
whichTrials = ismember(sT,[4]); %savetag
alignment = 'targets';
% specify which recording
Recording = 'R2';

pre= -1.6;
preV = abs(pre);
post = 1.6-0.001;
n = length(pre:0.001:post);

rLR = zeros(1,n);
rRR = zeros(1,n);
rLG = zeros(1,n);
rRG = zeros(1,n);

rFR_LR = [];
rFR_RR = [];
rFR_LG = [];
rFR_RG = [];

lrcnt = 1;
rrcnt = 1;
lgcnt = 1;
rgcnt = 1;

whichSession = str2num(erase(erase(baseDir, 'D:/Tiberius DLPFC/'),'/'));
currTrials = allTrials(whichTrials);
spikeCnt = 1;

% sessionLabel = sprintf('Session %d, Channel %d, Unit %d',whichSession,chosenChannel,unitV);
sessionLabel = sprintf('%s%s Channel%d Unit%d',date,Recording, chosenChannel,unitV);

perf = [currTrials.performance];
RTv = [perf.RT];
[~,ixSort] = sort(RTv);
currTrials = currTrials(ixSort);

%% Plot PSTH
psthfig = figure;
%set(gcf,'units','normalized','position',[0.3887    0.0042    0.2227    0.9132]);
g = normpdf([-0.1:0.001:0.1],0,0.025);

for f=1:length(currTrials)
    if ~isempty(currTrials(f).spikes)
        
        D = currTrials(f).contBehavior.PhotoBox;
        cbTime = currTrials(f).contBehavior.t - currTrials(f).events.CheckerboardDrawnTime;
        pBoxOn = find(D(cbTime > 0) > 1,1,'first');
        
        c = currTrials(f).spikes.channelId;
        u = currTrials(f).spikes.unit;
        
        if unitV >= 0
            iV = c == chosenChannel & u == unitV;
        else
            iV = c == chosenChannel;
        end
        
        if (strcmp(alignment, 'move') == 1)
            % align to movement onset
            currSpikes = [currTrials(f).spikes.xPCtimeStamp(iV) - (currTrials(f).events.CheckerboardDrawnTime+pBoxOn + currTrials(f).performance.RT)]./1000;
        elseif (strcmp(alignment, 'check') == 1)
            % align to checkerboard onset
            currSpikes = [currTrials(f).spikes.xPCtimeStamp(iV) - (currTrials(f).events.CheckerboardDrawnTime+pBoxOn )]./1000;
        elseif (strcmp(alignment, 'targets') == 1)
            % align to target onset
            currSpikes = [currTrials(f).spikes.xPCtimeStamp(iV) - (currTrials(f).events.TargetsDrawnTime )]./1000;
        end
        
        RT = currTrials(f).performance.RT;     
        delay = currTrials(f).events.CheckerboardDrawnTime - currTrials(f).events.TargetsDrawnTime;
        
        
        currIdx = currSpikes > pre & currSpikes < post;
        if ~isempty(currSpikes(currIdx))
            if strcmp(currTrials(f).performance.ChosenSide,'left')==1 && strcmp(currTrials(f).performance.ChosenColor,'red')==1
               
                rLR(lrcnt,floor(1000*currSpikes(currIdx))+preV*1000) = 1;
                rFR_LR(lrcnt,:) = conv(rLR(lrcnt,:),g,'same');
                lrcnt = lrcnt + 1;
                
            end
            
            if strcmp(currTrials(f).performance.ChosenSide,'right')==1 && strcmp(currTrials(f).performance.ChosenColor,'red')==1

                rRR(rrcnt,floor(1000*currSpikes(currIdx))+preV*1000) = 1;
                rFR_RR(rrcnt,:) = conv(rRR(rrcnt,:),g,'same');
                rrcnt = rrcnt + 1;
                
            end
            
            
             if strcmp(currTrials(f).performance.ChosenSide,'left')==1 && strcmp(currTrials(f).performance.ChosenColor,'green')==1
        
                rLG(lgcnt,floor(1000*currSpikes(currIdx))+preV*1000) = 1;
                rFR_LG(lgcnt,:) = conv(rLG(lgcnt,:),g,'same');
                lgcnt = lgcnt + 1;
                
            end
            
            if strcmp(currTrials(f).performance.ChosenSide,'right')==1 && strcmp(currTrials(f).performance.ChosenColor,'green')==1

                rRG(rgcnt,floor(1000*currSpikes(currIdx))+preV*1000) = 1;
                rFR_RG(rgcnt,:) = conv(rRG(rgcnt,:),g,'same');
                rgcnt = rgcnt + 1;
                
            end
        else
        
        end

    else
        
    end
    RTall(f) = RT;
end

t = [pre:0.001:post];
tPre = -0.2;
tPost = 0.8;
tIdx = (t > tPre & t < tPost);
xlim([tPre, tPost])
alpha = 0.3;

%% SEM plots
data = rFR_RR(:,tIdx);
PSTH_mean = nanmean(data);
PSTH_sem = std(data)./sqrt(size(data,1));
patch = fill([t(tIdx) fliplr(t(tIdx))] , [PSTH_mean+PSTH_sem fliplr(PSTH_mean-PSTH_sem)], [0.4 0 0.2]);
set(patch, 'edgecolor', 'none', 'FaceAlpha', alpha );
hold on;

data = rFR_LR(:,tIdx);
PSTH_mean = nanmean(data);
PSTH_sem = std(data)./sqrt(size(data,1));
patch = fill([t(tIdx) fliplr(t(tIdx))] , [PSTH_mean+PSTH_sem fliplr(PSTH_mean-PSTH_sem)], [ 0.8 0 0]);
set(patch, 'edgecolor', 'none', 'FaceAlpha', alpha );
hold on;

data = rFR_RG(:,tIdx);
PSTH_mean = nanmean(data);
PSTH_sem = std(data)./sqrt(size(data,1));
patch = fill([t(tIdx) fliplr(t(tIdx))] , [PSTH_mean+PSTH_sem fliplr(PSTH_mean-PSTH_sem)], [ 0 0.4 0.2]);
set(patch, 'edgecolor', 'none', 'FaceAlpha', alpha );
hold on;

data = rFR_LG(:,tIdx);
PSTH_mean = nanmean(data);
PSTH_sem = std(data)./sqrt(size(data,1));
patch = fill([t(tIdx) fliplr(t(tIdx))] , [PSTH_mean+PSTH_sem fliplr(PSTH_mean-PSTH_sem)], [ 0.0 0.8 0.2]);
set(patch, 'edgecolor', 'none', 'FaceAlpha', alpha );
hold on;

%% mean psths
plot(t(tIdx), nanmean(rFR_RR(:,tIdx)),'--','color',[0.4 0 0.2], 'LineWidth', 2)
hold on
plot(t(tIdx), nanmean(rFR_LR(:,tIdx)),'-','color',[ 0.8 0 0], 'LineWidth', 2);
hold on
plot(t(tIdx), nanmean(rFR_RG(:,tIdx)),'--','color',[0 0.4 0.2], 'LineWidth', 2)
hold on
plot(t(tIdx), nanmean(rFR_LG(:,tIdx)),'-','color',[ 0.0 0.8 0.2], 'LineWidth', 2);
hold on

% aligned
line([0 0],get(gca,'ylim'),'color','k','linestyle','--' , 'LineWidth', 1);
%legend('Right Red', 'Left Red', 'Right Green' ,'Left Green', '', 'Location', 'southeast')
title(sessionLabel, 'fontsize', 20)
set(gcf, 'Color', 'w','renderer','Painters')
set(gca,'tickdir','out');
box off;
%axis on
axis tight
hold on;

% print('-painters','-depsc',['~/Desktop/', sessionLabel,'.eps']);


%% cosmetic code

% vLimits = ylim;
% vTickLocations = get(gca, 'YTick');
% vLabOffset = 0.1;
% vAxisOffset =  tPre;
% vLabel = "Firing rate"; 
% 
% hLimits = [tPre tPost];
% hTickLocations = tPre:0.2:tPost;
% hLabOffset = 1.1;
% hAxisOffset = vLimits(1);
% hLabel = "time"; 
% 
% plotAxis = [1 1];
% 
% [hp,vp] = getAxesP(hLimits,...
%     hTickLocations,...
%     hLabOffset,...
%     hAxisOffset,...
%     hLabel,...
%     vLimits,...
%     vTickLocations,...
%     vLabOffset,...
%     vAxisOffset,...
%     vLabel, plotAxis)
% 
% set(gca,'XColor', 'none','YColor','none')

% print('-painters','-depsc',['~/Documents/MATLAB/ChandLab/DLPFC_analysis/resultFigures/Visualization/', sessionLabel, 'E','.eps']);
% savefig(['~/Documents/MATLAB/ChandLab/DLPFC_analysis/resultFigures/Visualization/', sessionLabel,'.fig']);


% print('-painters','-depsc',['~/Desktop/T', sessionLabel,'.eps']);


%% 

%% plot Waveform 
xstart=.2;
xend=.4;
ystart=.7;
yend=.9;
axes('position',[xstart ystart xend-xstart yend-ystart])
box on

V = [];
unit = [];
time_axis = [1:80]/30000;
for n=1:length(currTrials)
   V = [V; currTrials(n).spikes.data(currTrials(n).spikes.channelId==chosenChannel & currTrials(n).spikes.unit==1,:)];
    if mod(n,10)==1
        try
        unit = [unit, currTrials(n).spikes.data(currTrials(n).spikes.channelId==chosenChannel & currTrials(n).spikes.unit==unitV,:)'];
        hold on;
        catch
            n;
        end
    end
end


%% plotting all waveforms and mean
plot(unit,'color', [92/255, 126/255, 214/255, alpha]);
plot(mean(unit'), 'k-', 'LineWidth',2);
ylabel('Amplitude [a.u.]')
xlabel('Time [s]')
axis off;
axis tight;

