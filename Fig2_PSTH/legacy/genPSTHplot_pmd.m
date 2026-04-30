%%%%%%%%%%%%%%%% for pmd data

clear all; close all; clc


% load allTrials data from TiberiusDLPFCAllTrials
baseDir = ['/Volumes/TianSSD/PMd/PMdData/Olaf/'];


allDataT = load([baseDir 'OlafPMdT1.mat']).dataframe;
allData = load([baseDir 'OlafPMdC1.mat']).dataframe;


ii = 8;

fig2Ylim = [[0 60]; [0,30]; [0,30]; [5,50]; [0,60]; [0,50]; [30,90]; [5,40]];

name = {'20240326DLPFCB0', '20240628DLPFC', '20230818DLPFCB0', '20240328DLPFCB0','20240906PMD', '20240906PMD', '20150503PMD', '20150503PMD'};

unitNum = [54,32,16,21,16,2,15,4];


figS2Name = {'20230811DLPFC', '20230811DLPFC', '20230811DLPFC', '20220930', '20240614DLPFC', '20240614DLPFC', '20220222DLPFC', '20220930'};
figS2UnitNum = [59,65,3,9,17,21,8,12];
figS2Ylim = [[0,16]; [0,60]; [0,50]; [10,45]; [0,110]; [0,30]; [0,60]; [0,20]];



figData = extractPSTHdata(allData, allDataT, 73, unitNum(ii), fig2Ylim(ii,:));



save([name{ii} '_unit_' num2str(ii) '.mat'], 'figData');

plotPSTH(figData);


function figData = extractPSTHdata(allData, allDataT, dayn, ip, yminMax)
%   figData = extractPSTHdata(allData, allDataT, dayn, ip, yminMax)
%
%   Inputs:
%       allData  : cue-aligned dataframe (already loaded)
%       allDataT : target-aligned dataframe (already loaded)
%       dayn     : session/day index (e.g. 73)
%       ip       : unit index (e.g. 15)
%       yminMax  : y axis limits e.g. [0 90]

g        = normpdf(-0.1:0.001:0.1, 0, 0.025);
chopTime = 200;

daynDataC = allData(dayn);
daynDataT = allDataT(dayn);

% --- Trial labels ---
perf      = [daynDataC.behavior];
left      = [perf.chosenSide] == 1;
perfTable = struct2table(perf(:));
b         = table2cell(perfTable(:, {'TrialOutcome'}));
correct   = strcmp(b, 'Correct Choice')';
red       = [perf.CentralCuenSquares] > 112 &  correct | ...
            [perf.CentralCuenSquares] < 112 & ~correct;
cxt1      = [perf.LeftTargetColor] == 2;

% --- Build FR matrices (spikes: [time x units x trials] -> [trials x time x units]) ---
FRmatrix  = buildFRmatrix(double(daynDataC.spikes), g, chopTime);
FRmatrixT = buildFRmatrix(double(daynDataT.spikes), g, chopTime);

% --- Cue-aligned ---
tSpan = linspace(-0.8, 0.8-0.001, size(FRmatrix, 2));
tIdx  = tSpan >= 0 & tSpan < 0.8;

figData.cue.time = tSpan(tIdx);





figData.cue.RR   = squeeze(FRmatrix(red  & ~left, tIdx, ip));
figData.cue.LR   = squeeze(FRmatrix(red  &  left, tIdx, ip));
figData.cue.RG   = squeeze(FRmatrix(~red & ~left, tIdx, ip));
figData.cue.LG   = squeeze(FRmatrix(~red &  left, tIdx, ip));

% --- Target-aligned ---
tSpanT = linspace(-0.2, 1.8-0.001, size(FRmatrixT, 2));
tIdxT  = tSpanT >= -0.2 & tSpanT < 0.6;

figData.tar.time = tSpanT(tIdxT);
figData.tar.cxt1 = squeeze(FRmatrixT( cxt1, tIdxT, ip));
figData.tar.cxt2 = squeeze(FRmatrixT(~cxt1, tIdxT, ip));

% --- Metadata ---
figData.ip      = ip;
figData.name    = ['OlafDay' num2str(dayn)];
figData.yminMax = yminMax;
end

function FR = buildFRmatrix(spikes, g, chopTime)
% spikes: [time x trials x units] -> FR: [trials x time x units]

nTraw   = size(spikes, 1);
nTrials = size(spikes, 2);
nUnits  = size(spikes, 3);
nT      = nTraw - chopTime*2;

FR = zeros(nTrials, nT, nUnits);

for im = 1:nTrials
    for id = 1:nUnits
        c = conv(spikes(:, im, id), g, 'same');
        FR(im, :, id) = c(chopTime+1:end-chopTime);
    end
end

end




function plotPSTH(figData)

figure; set(gcf, 'Color', 'w', 'renderer', 'Painters');

% colors: [fill, line] per condition
tarColors = {[0.8500 0.3250 0.0980], [0 0.4470 0.7410]};
cueColors = {[0.4 0 0.2], [0.8 0 0], [0 0.4 0.2], [0.0 0.8 0.2]};
cueStyles = {'--', '-', '--', '-'};

subplot(1,2,1);
plotConditions(figData.tar.time, ...
    {figData.tar.cxt2, figData.tar.cxt1}, tarColors, {'-','-'});
ylim(figData.yminMax); title(figData.ip);

subplot(1,2,2);
plotConditions(figData.cue.time, ...
    {figData.cue.RR, figData.cue.LR, figData.cue.RG, figData.cue.LG}, cueColors, cueStyles);
ylim(figData.yminMax); title(figData.ip);

end

function plotConditions(t, conditions, colors, styles)
hold on;
alpha = 0.3;
for ic = 1:length(conditions)
    data = conditions{ic};
    m    = nanmean(data);
    sem  = nanstd(data) ./ sqrt(size(data,1));
    c    = colors{ic};
    fill([t fliplr(t)], [m+sem fliplr(m-sem)], c, 'EdgeColor', 'none', 'FaceAlpha', alpha);
    plot(t, m, styles{ic}, 'Color', c, 'LineWidth', 2);
end
xline(0, 'k--', 'LineWidth', 1);
set(gca, 'TickDir', 'out'); box off; axis tight;
xlim([t(1) t(end)]);
end