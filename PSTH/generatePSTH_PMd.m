function [rFR_RL, rFR_RR, rFR_GL, rFR_GR] = generatePSTH_PMd(FRmatrix,left, right, red, green, t, tPre, tPost, id)

rFR_RL = squeeze(FRmatrix(id,:,left == 1 & red == 1))';
rFR_RR = squeeze(FRmatrix(id,:,right == 1 & red == 1))';
rFR_GL = squeeze(FRmatrix(id,:,left == 1 & green == 1))';
rFR_GR = squeeze(FRmatrix(id,:,right == 1 & green == 1))';


tIdx = (t > tPre & t < tPost);

%%


alpha = 0.3;

data = rFR_RR(:,tIdx);
PSTH_mean = nanmean(data);
PSTH_sem = std(data)./sqrt(size(data,1));
patch = fill([t(tIdx) fliplr(t(tIdx))] , [PSTH_mean+PSTH_sem fliplr(PSTH_mean-PSTH_sem)], [0.4 0 0.2]);
set(patch, 'edgecolor', 'none', 'FaceAlpha', alpha );
hold on;

data = rFR_RL(:,tIdx);
PSTH_mean = nanmean(data);
PSTH_sem = std(data)./sqrt(size(data,1));
patch = fill([t(tIdx) fliplr(t(tIdx))] , [PSTH_mean+PSTH_sem fliplr(PSTH_mean-PSTH_sem)], [ 0.8 0 0]);
set(patch, 'edgecolor', 'none', 'FaceAlpha', alpha );
hold on;

data = rFR_GR(:,tIdx);
PSTH_mean = nanmean(data);
PSTH_sem = std(data)./sqrt(size(data,1));
patch = fill([t(tIdx) fliplr(t(tIdx))] , [PSTH_mean+PSTH_sem fliplr(PSTH_mean-PSTH_sem)], [ 0 0.4 0.2]);
set(patch, 'edgecolor', 'none', 'FaceAlpha', alpha );
hold on;

data = rFR_GL(:,tIdx);
PSTH_mean = nanmean(data);
PSTH_sem = std(data)./sqrt(size(data,1));
patch = fill([t(tIdx) fliplr(t(tIdx))] , [PSTH_mean+PSTH_sem fliplr(PSTH_mean-PSTH_sem)], [ 0.0 0.8 0.2]);
set(patch, 'edgecolor', 'none', 'FaceAlpha', alpha );
hold on;

% mean psths
plot(t(tIdx), nanmean(rFR_RR(:,tIdx)),'--','color',[0.4 0 0.2], 'LineWidth', 2)
hold on
plot(t(tIdx), nanmean(rFR_RL(:,tIdx)),'-','color',[ 0.8 0 0], 'LineWidth', 2);
hold on
plot(t(tIdx), nanmean(rFR_GR(:,tIdx)),'--','color',[0 0.4 0.2], 'LineWidth', 2)
hold on
plot(t(tIdx), nanmean(rFR_GL(:,tIdx)),'-','color',[ 0.0 0.8 0.2], 'LineWidth', 2);
hold on


% aligned
xline(0, 'k--', 'linewidth', 1)
% title(sessionLabel, 'fontsize', 20)
set(gcf, 'Color', 'w','renderer','Painters')
set(gca,'tickdir','out');
box off;
%axis on
axis tight
hold on;


end

