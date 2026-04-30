
ii = 7;

fig2Ylim = [[0 60]; [0,30]; [0,30]; [5,50]; [0,60]; [0,50]; [0,90]; [5,40]];

name = {'20240326DLPFCB0', '20240628DLPFC', '20230818DLPFCB0', '20240328DLPFCB0','20240906PMD', '20240906PMD'};

unitNum = [54,32,16,21,16,2];


figS2Name = {'20230811DLPFC', '20230811DLPFC', '20230811DLPFC', '20220930', '20240614DLPFC', '20240614DLPFC', '20220222', '20220930'};
figS2UnitNum = [59,65,3,9,17,21,8,12];
figS2Ylim = [[0,16]; [0,60]; [0,50]; [10,45]; [0,110]; [0,30]; [0,60]; [0,20]];



% figData = extractPSTHdata(name{ii}, unitNum(ii), fig2Ylim(ii,:));

figS2Data = extractPSTHdata(figS2Name{ii}, figS2UnitNum(ii), figS2Ylim(ii,:));


% save(['S2_' figS2Name{ii} '_unit_' num2str(ii) '.mat'], 'figS2Data');

plotPSTH(figS2Data);


function figData = extractPSTHdata(date, ip, yminMax, recording)
%   figData = extractPSTHdata(date, ip, yminMax, recording)
%
%   Inputs:
%       date      : e.g. '20220930'
%       ip        : unit index (e.g. 9)
%       yminMax   : y axis limits e.g. [10 45]
%       recording : e.g. 'R1' (default 'R1')

if nargin < 4, recording = 'R1'; end

g        = normpdf(-0.1:0.001:0.1, 0, 0.025);
chopTime = 200;
baseDir = ['/Volumes/TianSSD/TiberiusDLPFCRaster/RasterC/'];
baseDirT = ['/Volumes/TianSSD/TiberiusDLPFCRaster/'];

% --- Cue-aligned ---
allData  = load([baseDir  date recording '.mat']).dataframe;

perf     = [allData.performance];
perfTable = struct2table(perf);
red  = strcmp(table2cell(perfTable(:,{'ChosenColor'})), 'red')';
left = strcmp(table2cell(perfTable(:,{'ChosenSide'})), 'left')';

FRmatrix = buildFRmatrix(allData, 'rasterC', g, chopTime);
tSpan    = linspace(-0.8, 1.6-0.001, size(FRmatrix, 2));
tIdx     = tSpan >= 0 & tSpan < 0.8;

figData.cue.time = tSpan(tIdx);
figData.cue.RR   = squeeze(FRmatrix(ip, tIdx, red  & ~left))';
figData.cue.LR   = squeeze(FRmatrix(ip, tIdx, red  &  left))';
figData.cue.RG   = squeeze(FRmatrix(ip, tIdx, ~red & ~left))';
figData.cue.LG   = squeeze(FRmatrix(ip, tIdx, ~red &  left))';

% --- Target-aligned ---
allDataT  = load([baseDirT date recording '.mat']).dataframe;
params    = [allDataT.params];
cxt1      = [params.LeftTargetColor] == 2;

FRmatrixT = buildFRmatrix(allDataT, 'rasterT', g, chopTime);
tSpanT    = linspace(-0.6, 3.8-0.001, size(FRmatrixT, 2));
tIdxT     = tSpanT >= -0.2 & tSpanT < 0.6;

figData.tar.time = tSpanT(tIdxT);
figData.tar.cxt1 = squeeze(FRmatrixT(ip, tIdxT,  cxt1))';
figData.tar.cxt2 = squeeze(FRmatrixT(ip, tIdxT, ~cxt1))';

% --- Metadata ---
figData.ip      = ip;
figData.name    = [date recording];
figData.yminMax = yminMax;

end


function FRmatrix = buildFRmatrix(allData, rasterField, g, chopTime)
nT  = size(allData(1).(rasterField), 2) - chopTime*2;
nU  = size(allData(1).(rasterField), 1);
FRmatrix = zeros(nU, nT, length(allData));
for im = 1:length(allData)
    raster = allData(im).(rasterField);
    for id = 1:nU
        FR = conv(raster(id,:), g, 'same');
        FRmatrix(id,:,im) = FR(chopTime+1:end-chopTime);
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