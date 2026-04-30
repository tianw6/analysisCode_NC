

clear; close all; clc

a = load('~/Desktop/allBinFR_T50_5.mat').allBinFR;
b = load('~/Desktop/allBinFR_V50_5.mat').allBinFR;
c = load('~/Desktop/allBinFR_T50_5_vprobe.mat').allBinFR;
d = load('~/Desktop/allBinFR_V50_5_vprobe.mat').allBinFR;

allBinFR = [a, b];

binSize = 50;
stepSize = 5;


tStart = -1000;
tEnd = 1000; 
timeAxis = [tStart+binSize:stepSize:tEnd];
tSelected = timeAxis > -100 & timeAxis <= 300;

t = timeAxis(tSelected);

accuracy = struct;

cnt = 1;


for dayn = 1:length(allBinFR)

trials = allBinFR(dayn).trials;
taskLabels = allBinFR(dayn).taskLabels;

for unitNum = 1:size(trials,2)

    for binNum = 1:size(trials,3)

        RL = []; RR = []; GL = []; GR = [];
        
        RL = squeeze(trials(taskLabels == 0,unitNum, binNum));
        RR = squeeze(trials(taskLabels == 1,unitNum, binNum));
        GL = squeeze(trials(taskLabels == 2,unitNum, binNum));
        GR = squeeze(trials(taskLabels == 3,unitNum, binNum));

        

%         [p1(cnt, binNum), h1(cnt, binNum), stats1] = ranksum(RL, GR, 'alpha',0.01);
% 
%         [p2(cnt, binNum), h2(cnt, binNum), stats2] = ranksum(RR, GL, 'alpha',0.01);
%         
%         [p3(cnt, binNum), h3(cnt, binNum), stats3] = ranksum([RR; GR], [RL;GL], 'alpha',0.01);
%         
        
        [ h1(cnt, binNum), p1(cnt, binNum), stats1] = ttest2(RL, GR, 'alpha',0.01);

        [ h2(cnt, binNum), p2(cnt, binNum), stats2] = ttest2(RR, GL, 'alpha',0.01);
        
        % choice
        [ h3(cnt, binNum), p3(cnt, binNum), stats3] = ttest2([RR; GR], [RL;GL], 'alpha',0.01);
        % targer configuration
        [ h4(cnt, binNum), p4(cnt, binNum), stats4] = ttest2([RL; GR], [RR;GL], 'alpha',0.01);
        % color
        [ h5(cnt, binNum), p5(cnt, binNum), stats5] = ttest2([RL; RR], [GR;GL], 'alpha',0.01);
        

    end
    
    
    cnt = cnt + 1;
end

fprintf('dayn %d finished \n', dayn)

end

%% 
addpath('../anova_results/')
dlpfcC = [load('TibsDLPFCVprobeC.mat').results, load('TibsDLPFCNpixC.mat').results, load('VinnieVprobeC.mat').results, load('VinnieNpixC.mat').results];

plotAnova(dlpfcC, figure(1), [50 300], [0 0.3])
%%
hold on
plot(t, nansum(h1,1)./size(h1,1));
plot(t, nansum(h2,1)./size(h2,1));

plot(t, nansum(h3,1)./size(h3,1), 'linewidth', 2);

plot(t, nansum(h4,1)./size(h4,1), 'linewidth', 2, 'color', 'k');

plot(t, nansum(h5,1)./size(h5,1), 'linewidth', 2, 'color', 'm');


plot(t, nansum(h4,1)./size(h4,1) - nansum(h1,1)./size(h1,1), 'linewidth', 2, 'color', 'c');




        