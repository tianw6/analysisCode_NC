% plot DLPFC psths of a unit with SEM 
% both align to Tar and Cue, with breakout in the middle
clear all; close all; clc


name = '20230630DLPFC';
yminMax = [0 40];

%%
for ip = 1:size(allData(1).rasterT, 1)


% load allTrials data from TiberiusDLPFCAllTrials
allData = load(['/Volumes/TianSSD/TiberiusNpix/checkerboardAligned/' name '.mat']).allData;

% context
cxt1 = [allData.leftTarget] == 2;
% chosenSide
left = [allData.chosenSide] == 1;

% calculate chosen color
cue = [allData.cue];
red = cue > 113;
correctTrials = find([allData.correctness] == 1);
wrongTrials = find([allData.correctness] == 0);
chosenColor = red;
chosenColor(wrongTrials) = ~red(wrongTrials);


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



%% Plot PSTH 


alpha = 0.3;
    

RL = chosenColor & left;
RR = chosenColor & ~left;
GL = ~chosenColor & left;
GR = ~chosenColor & ~left;






    
    figure;   

    tPre = 0;
    tPost = 0.8;
    pre= -0.8;
    preV = abs(pre);
    post = 0.8-0.001;
    t = [pre:0.001:post];
    tIdx = (t > tPre & t < tPost);

    
    
    
    rFR_LR = squeeze((FRmatrix(ip,:,RL)))';
    rFR_RR = squeeze((FRmatrix(ip,:,RR)))';
    rFR_LG = squeeze((FRmatrix(ip,:,GL)))';
    rFR_RG = squeeze((FRmatrix(ip,:,GR)))';
    
    
    
    subplot(1,2,2); hold on
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
    
    
    % mean psths
    plot(t(tIdx), nanmean(rFR_RR(:,tIdx)),'--','color',[0.4 0 0.2], 'LineWidth', 2)
    hold on
    plot(t(tIdx), nanmean(rFR_LR(:,tIdx)),'-','color',[ 0.8 0 0], 'LineWidth', 2);
    hold on
    plot(t(tIdx), nanmean(rFR_RG(:,tIdx)),'--','color',[0 0.4 0.2], 'LineWidth', 2)
    hold on
    plot(t(tIdx), nanmean(rFR_LG(:,tIdx)),'-','color',[ 0.0 0.8 0.2], 'LineWidth', 2);
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


    xlim([tPre, tPost])
    

ylim(yminMax)





%% plot target epoch 


allData = load(['/Volumes/TianSSD/TiberiusNpix/targetAligned/' name '.mat']).allData;

% context
cxt1 = [allData.leftTarget] == 2;


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



%% Plot PSTH 

tPre = -0.2;
tPost = 0.7;
pre= -0.2;
preV = abs(pre);
post = 1.4-0.001;
t = [pre:0.001:post];
tIdx = (t > tPre & t < tPost);

alpha = 0.3;
    






    
    rFR_LR = squeeze((FRmatrix(ip,:,cxt1)))';
    rFR_RR = squeeze((FRmatrix(ip,:,~cxt1)))';

    
    
    
    subplot(1,2,1); hold on
    data = rFR_RR(:,tIdx);
    PSTH_mean = nanmean(data);
    PSTH_sem = std(data)./sqrt(size(data,1));
    patch = fill([t(tIdx) fliplr(t(tIdx))] , [PSTH_mean+PSTH_sem fliplr(PSTH_mean-PSTH_sem)], [0.8500 0.3250 0.0980]);
    set(patch, 'edgecolor', 'none', 'FaceAlpha', alpha);
    hold on;

    data = rFR_LR(:,tIdx);
    PSTH_mean = nanmean(data);
    PSTH_sem = std(data)./sqrt(size(data,1));
    patch = fill([t(tIdx) fliplr(t(tIdx))] , [PSTH_mean+PSTH_sem fliplr(PSTH_mean-PSTH_sem)], [0 0.4470 0.7410]);
    set(patch, 'edgecolor', 'none', 'FaceAlpha', alpha);
    hold on;

    
    
    
    % mean psths
    plot(t(tIdx), nanmean(rFR_RR(:,tIdx)),'--','color',[0.8500 0.3250 0.0980], 'LineWidth', 2)
    hold on
    plot(t(tIdx), nanmean(rFR_LR(:,tIdx)),'-','color',[0 0.4470 0.7410], 'LineWidth', 2);
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


    xlim([tPre, tPost])
    


ylim(yminMax)

pause 
close;


end
%%
% print('-painters','-depsc',['~/Desktop/breakout/', '0628PMDU' num2str(ip),'.eps']);
