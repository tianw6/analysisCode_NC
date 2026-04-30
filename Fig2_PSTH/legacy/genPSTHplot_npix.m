
ii = 6;

fig2Ylim = [[0 60]; [0,30]; [0,30]; [5,50]; [0,60]; [0,50]; [0,90]; [5,40]];

name = {'20240326DLPFCB0', '20240628DLPFC', '20230818DLPFCB0', '20240328DLPFCB0','20240906PMD', '20240906PMD'};

unitNum = [54,32,16,21,16,2];


figS2Name = {'20230811DLPFC', '20230811DLPFC', '20230811DLPFC', '20220930DLPFC', '20240614DLPFC', '20240614DLPFC', '20220222DLPFC', '20220930DLPFC'};
figS2UnitNum = [59,65,3,9,17,21,8,12];
figS2Ylim = [[0,16]; [0,60]; [0,50]; [10,45]; [0,110]; [0,30]; [0,60]; [0,20]];



% figData = extractPSTHdata(name{ii}, unitNum(ii), fig2Ylim(ii,:));

figS2Data = extractPSTHdata(figS2Name{ii}, figS2UnitNum(ii), figS2Ylim(ii,:));


save(['S2_' figS2Name{ii} '_unit_' num2str(ii) '.mat'], 'figS2Data');

plotPSTH(figS2Data);




function figData = extractPSTHdata(name, ip, yminMax)
%   figData = extractPSTHdata(name, ip, yminMax)
%
%   Extracts and stores all data needed to reproduce the 2-panel PSTH figure.
%
%   Inputs:
%       name     : recording name string e.g. '20240326DLPFCB0'
%       ip       : unit index (e.g. 54)
%       yminMax  : y axis limits e.g. [0 60]
%
%   Output:
%       figData  : struct with fields:
%                    .cue      - cue-aligned data (subplot 2, 4 conditions)
%                    .tar      - target-aligned data (subplot 1, 2 conditions)
%                    .ip, .name, .yminMax

g        = normpdf(-0.1:0.001:0.1, 0, 0.025);
chopTime = 200;

% -------------------------------------------------------------------------
% Cue-aligned (subplot 2: RR, LR, RG, LG)
% -------------------------------------------------------------------------
allData = load(['/Volumes/TianSSD/TiberiusNpix/checkerboardAligned/' name '.mat']).allData;

cue          = [allData.cue];
red          = cue > 113;
left         = [allData.chosenSide] == 1;
wrongTrials  = find([allData.correctness] == 0);
chosenColor  = red;
chosenColor(wrongTrials) = ~red(wrongTrials);

FRmatrix = buildFRmatrix(allData, g, chopTime);

tPre = 0; tPost = 0.8;
t    = -0.8:0.001:0.799;
tIdx = t > tPre & t < tPost;

RL = chosenColor &  left;
RR = chosenColor & ~left;
GL = ~chosenColor &  left;
GR = ~chosenColor & ~left;

figData.cue.time  = t(tIdx);
figData.cue.RR    = squeeze(FRmatrix(ip, tIdx, RR))';   % [nTrials x nTime]
figData.cue.LR    = squeeze(FRmatrix(ip, tIdx, RL))';
figData.cue.RG    = squeeze(FRmatrix(ip, tIdx, GR))';
figData.cue.LG    = squeeze(FRmatrix(ip, tIdx, GL))';

% -------------------------------------------------------------------------
% Target-aligned (subplot 1: cxt1, cxt2)
% -------------------------------------------------------------------------
allData = load(['/Volumes/TianSSD/TiberiusNpix/targetAligned/' name '.mat']).allData;

cxt1 = [allData.leftTarget] == 2;

FRmatrix = buildFRmatrix(allData, g, chopTime);

tPre = -0.2; tPost = 0.7;
t    = -0.2:0.001:1.1999;
tIdx = t > tPre & t < tPost;

figData.tar.time  = t(tIdx);
figData.tar.cxt1  = squeeze(FRmatrix(ip, tIdx, cxt1))';
figData.tar.cxt2  = squeeze(FRmatrix(ip, tIdx, ~cxt1))';

% -------------------------------------------------------------------------
% Metadata
% -------------------------------------------------------------------------
figData.ip      = ip;
figData.name    = name;
figData.yminMax = yminMax;

end


% =========================================================================
function FRmatrix = buildFRmatrix(allData, g, chopTime)
FRmatrix = zeros(size(allData(1).rasterT, 1), ...
                 size(allData(1).rasterT, 2) - chopTime*2, ...
                 length(allData));
for im = 1:length(allData)
    raster = allData(im).rasterT;
    for id = 1:size(raster, 1)
        FR = conv(raster(id,:), g, 'same');
        FRmatrix(id, :, im) = FR(chopTime+1:end-chopTime);
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