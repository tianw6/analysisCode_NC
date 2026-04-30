% plot DLPFC psths of a unit with SEM 
% both align to Tar and Cue, with breakout in the middle
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
chosenChannel = 5;
% define which unit (unitV = -1: plot psth of all units together)
unitV = 1;
whichTrials = ismember(sT,[4]); %savetag
% specify which recording
Recording = 'R2';


currTrials = allTrials(whichTrials);

% sessionLabel = sprintf('Session %d, Channel %d, Unit %d',whichSession,chosenChannel,unitV);
sessionLabel = sprintf('%s%s Channel%d Unit%d',date,Recording, chosenChannel,unitV);

perf = [currTrials.performance];
RTv = [perf.RT];
[~,ixSort] = sort(RTv);
currTrials = currTrials(ixSort);

%% Plot PSTH

figure;
subplot(1,2,1)

% [rFR_LR, rFR_RR, rFR_LG, rFR_RG] = generateFR(currTrials, 'targets', chosenChannel, unitV, -0.2, 0.767, sessionLabel);
[rFR_LR, rFR_RR, rFR_LG, rFR_RG] = generateFR(currTrials, 'targets', chosenChannel, unitV, -0.2, 0.5, sessionLabel);

ylim([0, 80])
% pos = get(gca, 'Position');
% set(gca,'Position',[pos(1), pos(2), pos(3)*0.8, pos(4)]);

subplot(1,2,2)

[rFR_LR, rFR_RR, rFR_LG, rFR_RG] = generateFR(currTrials, 'check', chosenChannel, unitV, -0.2, 0.8, sessionLabel);
ylim([0, 80])
% get(gca, 'Position')

% print('-painters','-depsc',['~/Desktop/', sessionLabel,'.eps']);

%% plot waveforms

figure; 
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

alpha = 0.3;
plot(unit,'color', [92/255, 126/255, 214/255, alpha]);
plot(mean(unit'), 'k-', 'LineWidth',2);
ylabel('Amplitude [a.u.]')
xlabel('Time [s]')
axis off;
axis tight;

