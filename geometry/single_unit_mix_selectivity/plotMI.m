
% plot time trace results of dlpfc and pmd modulation index (R-L)/(R+L)
% also choose certain time window and plot average d-prime

addpath('../../utils/')
%% plot all results

load('dPrimeresultsPMDC')
% load('dPrimeresultsPMDC')

d_all = [];
cnt = 1;
for id = 1:length(results)
    temp = results(id).dPrimeResults;
    for idx = 1:length(temp)
        d_all(:,:,cnt) = temp(idx).dPrime;
        cnt = cnt+1;
    end
end


t = results(1).time;

%%


a = figure('Position', [100 100 900 500]);

options.handle = gcf;
options.error = 'sem';
options.alpha      = 0.5;
options.line_width = 2;
options.x_axis = t;

options.color_area = [220 175 220]./255;    % Blue theme
options.color_line = [150 50 150]./255;
plot_areaerrorbar(c1', options)

options.color_area = [128 193 219]./255;    % Blue theme
options.color_line = [ 52 148 186]./255;
plot_areaerrorbar(c2', options)


options.color_area = [200 200 200]./255;    % black theme
options.color_line = [100 100 100]./255;
plot_areaerrorbar(c3', options)


ylim([0 0.3])
xlim([-50, 400])




%% 

dlpfcC = load('dPrimeresultsDLPFCC').results;
pmdC = load('dPrimeresultsPMDC').results;
dlpfcT = load('dPrimeresultsDLPFCT').results;
pmdT = load('dPrimeresultsPMDT').results;


% plot DLPFC modulation index 
figure('Position', [10 10 900 600]);

plotD(dlpfcT, subplot(2,2,1), [-100 500], [0.2 0.3]);
plotD(dlpfcC, subplot(2,2,2), [-100 500], [0.2 0.3]);
plotD(dlpfcT, subplot(2,2,3), [-100 500], [0.05 0.15]);
plotD(dlpfcC, subplot(2,2,4), [-100 500], [0.05 0.15]);
% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig2_s/', 'MI_dlpfc', '.eps']);


% plot PMD modulation index 
figure('Position', [10 10 900 600]);

plotD(pmdT, subplot(2,2,1), [-100 500], [0.2 0.3]);
plotD(pmdC, subplot(2,2,2), [-100 500], [0.2 0.3]);
plotD(pmdT, subplot(2,2,3), [-100 500], [0.05 0.15]);
plotD(pmdC, subplot(2,2,4), [-100 500], [0.05 0.15]);

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig2_s/', 'MI_pmd', '.eps']);

%% align to checkerboard

tLim = [150,250];
[meanPFC, stdPFC, rawDpfc] = calD(dlpfcC, tLim);
[meanPMD, stdPMD, rawDpmd] = calD(pmdC, tLim);


meanV = [meanPFC, meanPMD];
stdV = [stdPFC, stdPMD];


figure;

plotBar(meanV, stdV)

xlabel('Group');
ylabel('Value');
title('3 Groups × 2 Bars (With Error Bars)');
legend({'DLPFC','PMD'});


ranksum(rawDpfc(1,:), rawDpmd(1,:))
ranksum(rawDpfc(2,:), rawDpmd(2,:))
ranksum(rawDpfc(3,:), rawDpmd(3,:))

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig2_s/', 'MI_cue', '.eps']);


%% align to targets

tLim = [100,300];
[meanPFC, stdPFC, rawDpfc] = calD(dlpfcT, tLim);
[meanPMD, stdPMD, rawDpmd] = calD(pmdT, tLim);


meanV = [meanPFC, meanPMD];
stdV = [stdPFC, stdPMD];
meanV = meanV(3,:)';
stdV = stdV(3,:)';

figure;

options.categorySpacing = 2; 
options.barWidth   = 0.5;   % how "wide" each group is

plotBar(meanV, stdV, options)
    
xlabel('Group');
ylabel('Value');
title('3 Groups × 2 Bars (With Error Bars)');
legend({'DLPFC','PMD'});


ranksum(rawDpfc(1,:), rawDpmd(1,:))
ranksum(rawDpfc(2,:), rawDpmd(2,:))
ranksum(rawDpfc(3,:), rawDpmd(3,:))

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig2_s/', 'MI_targets', '.eps']);

%%
function [meanV, stdV, d] = calD(results, tLim)

    t = results(1).time;
   
    select = t >= tLim(1) & t <= tLim(2);

    d_all = [];
    cnt = 1;
    for id = 1:length(results)
        temp = results(id).dPrimeResults;
        for idx = 1:length(temp)
            d_all(:,:,cnt) = temp(idx).dPrime;
            cnt = cnt+1;
        end
    end

    d_all = d_all(:,select,:);

    d = squeeze(mean(d_all,2));
    d_std = std(d, 0, 2)./(sqrt(size(d,2)));

    d_mean = mean(d,2);
 
    meanV = d_mean;
    stdV = d_std;


end


%% function to plot modulation index

function plotD(results, figHandle, tLim, ylimit)



d_all = [];
cnt = 1;
for id = 1:length(results)
    temp = results(id).dPrimeResults;
    for idx = 1:length(temp)
        d_all(:,:,cnt) = temp(idx).dPrime;
        cnt = cnt+1;
    end
end


t = results(1).time;


c1 = squeeze(d_all(1,:,:));
c2 = squeeze(d_all(2,:,:));
c3 = squeeze(d_all(3,:,:));


figHandle;

options.handle = gcf;
options.error = 'sem';
options.color_area = [220 175 220]./255;    % Blue theme
options.color_line = [150 50 150]./255;
options.alpha      = 0.5;
options.line_width = 2;
options.x_axis = t;
plot_areaerrorbar(c1', options)

options.color_area = [128 193 219]./255;    % Blue theme
options.color_line = [ 52 148 186]./255;
plot_areaerrorbar(c2', options)


options.color_area = [200 200 200]./255;    % black theme
options.color_line = [100 100 100]./255;
plot_areaerrorbar(c3', options)

ylim([ylimit])
xlim([tLim])



end
