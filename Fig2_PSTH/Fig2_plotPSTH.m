%%%%%%%%%%%%%%%%%%%% 
% This code plots Fig2 and Fig2Sa-h



%% Fig 2: plot example DLPFC and PMd PSTH 
files = dir('20*.mat');

% figure('Position', [100 100 2000, 1800])

for i = 1:8
    load(files(i).name);  % loads figData
    
    plotPSTH(figData);

    
    unitTitle = erase(files(i).name, "_");
    title(unitTitle);
end


%% FigS2: plot more DLPFC PSTH

files = dir('S2*.mat');

% figure('Position', [100 100 2000, 1800])

for i = 1:8
    load(files(i).name);  % loads figData
    
    plotPSTH(figS2Data);

    unitTitle = erase(files(i).name, "_");
    title(unitTitle);
end



%%

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