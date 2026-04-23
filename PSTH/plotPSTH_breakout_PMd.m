% plot PMd psths of a unit with SEM 
% both align to Tar and Cue, with breakout in the middle
clear all; close all; clc


% load allTrials data from TiberiusDLPFCAllTrials
baseDir = ['/Volumes/TianSSD/PMd/PMdData/Tiberius/'];


TarData = load([baseDir 'TibsPMdT1.mat']).dataframe;
CueData = load([baseDir 'TibsPMdC1.mat']).dataframe;


%% generate FR matrix
dayn = 126;
daynDataT = TarData(dayn); 
daynDataC = CueData(dayn);

daynSpikesT = double(daynDataT.spikes);
daynSpikesC = double(daynDataC.spikes);

FRmatrixT = [];
FRmatrixC = [];

g = normpdf([-0.1:0.001:0.1],0,0.025);
chopTime = 200;
for im = 1:size(daynSpikesT,3)
    
    for id = 1:size(daynSpikesT,2)
        FRT = conv(daynSpikesT(:,id,im), g, 'same');
        FRC = conv(daynSpikesC(:,id,im), g, 'same');
        FRmatrixT(im,:,id) = FRT(chopTime+1:end-chopTime);
        FRmatrixC(im,:,id) = FRC(chopTime+1:end-chopTime);
        
    end
end


%% declare some parameters




% define which channel 
chosenChannel = 13;
% define which unit (unitV = -1: plot psth of all units together)
unitV = 1;

id = find(daynDataT.channelId == chosenChannel & daynDataT.unitId == unitV);

% extract performance data
perf = [daynDataC.behavior];
% chosen side
left = [perf.chosenSide] == 1;
right = [perf.chosenSide] == 2;
% chosen color


% extract chosen color (need trial outcome)
perfTable = struct2table(perf);
a = perfTable(:,{'TrialOutcome'});
b = table2cell(a);    
correct = strcmp(b, 'Correct Choice')';

red = [perf.CentralCuenSquares] > 112 & correct == 1 | [perf.CentralCuenSquares] < 112 & correct == 0;
green = ~red;

% red = [perf.CentralCuenSquares] > 112 & [perf.CorrectResponse] == 1 | [perf.CentralCuenSquares] < 112 & [perf.CorrectResponse] == 2;
% green = [perf.CentralCuenSquares] < 112 & [perf.CorrectResponse] == 1 | [perf.CentralCuenSquares] > 112 & [perf.CorrectResponse] == 2;



%% Plot PSTH
tT = daynDataT.time(chopTime+1:end-chopTime);
tC = daynDataC.time(chopTime+1:end-chopTime);

figure; 
subplot(1,2,1)
generatePSTH_PMd(FRmatrixT, left, right, red, green, tT, -0.2, 0.5, id);
ylim([5, 25])
pos = get(gca, 'Position');
set(gca,'Position',[pos(1), pos(2), pos(3)*0.8, pos(4)]);

subplot(1,2,2)
generatePSTH_PMd(FRmatrixC, left, right, red, green, tC, -0.2, 0.8, id);
ylim([5, 25])
get(gca, 'Position')

sessionLabel = [daynDataT.date ' Channel ' num2str(chosenChannel) ' unit: ' num2str(unitV)];
title(sessionLabel)

% print('-painters','-depsc',['~/Desktop/', sessionLabel,'.eps']);


