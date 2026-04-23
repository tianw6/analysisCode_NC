% created by Tian on Jan 27th, 2025. plot decoding accuracy 

clear; close all; clc;
% plot DLPFC decoding results

% tibs 
TresultsTV = load('./results/Tiberius/choicedecodingAccTV.mat').result;
TresultsCV = load('./results/Tiberius/choicedecodingAccCV.mat').result;
TresultsMV = load('./results/Tiberius/choicedecodingAccMV.mat').result;

TresultsTN = load('./results/Tiberius/choicedecodingAccTN.mat').result;
TresultsCN = load('./results/Tiberius/choicedecodingAccCN.mat').result;
TresultsMN = load('./results/Tiberius/choicedecodingAccMN.mat').result;

% vinnie
VresultsTV = load('./results/Vinnie/choicedecodingAccTV.mat').result;
VresultsCV = load('./results/Vinnie/choicedecodingAccCV.mat').result;
VresultsMV = load('./results/Vinnie/choicedecodingAccMV.mat').result;

VresultsTN = load('./results/Vinnie/choicedecodingAccTN.mat').result;
VresultsCN = load('./results/Vinnie/choicedecodingAccCN.mat').result;
VresultsMN = load('./results/Vinnie/choicedecodingAccMN.mat').result;


accT = [TresultsTV.accuracy; TresultsTN.accuracy; VresultsTV.accuracy; VresultsTN.accuracy];
accC = [TresultsCV.accuracy; TresultsCN.accuracy; VresultsCV.accuracy; VresultsCN.accuracy];
accM = [TresultsMV.accuracy; TresultsMN.accuracy; VresultsMV.accuracy; VresultsMN.accuracy];




%%

figure('Position', [10 10 900 600]);

subplot(1,3,1); hold on
plot(TresultsTV.selectedBin, accT', 'color', [1,1,1].*0.7)
plot(TresultsTV.selectedBin, mean(accT,1), 'r', 'linewidth', 2)
ylim([0.4 1])
xlim([-100, 400])

subplot(1,3,2); hold on
plot(TresultsCV.selectedBin, accC', 'color', [1,1,1].*0.7)
plot(TresultsCV.selectedBin, mean(accC,1), 'r', 'linewidth', 2)
ylim([0.4 1])
xlim([TresultsCV.selectedBin(1), 300])

subplot(1,3,3); hold on
plot(TresultsMV.selectedBin, accM', 'color', [1,1,1].*0.7)
plot(TresultsMV.selectedBin, mean(accM,1), 'r', 'linewidth', 2)
ylim([0.4 1])
xlim([-200, TresultsMV.selectedBin(end)])

% print('-painters','-depsc',['~/Desktop/', 'choice', '.eps']);


%% plot PMD decoding results 

clear; clc; close all
% tibs 
TresultsTV = load('./results/Tiberius/PMD/choicedecodingAccTV.mat').result;
TresultsCV = load('./results/Tiberius/PMD/choicedecodingAccCV.mat').result;
TresultsMV = load('./results/Tiberius/PMD/choicedecodingAccMV.mat').result;

TresultsTN = load('./results/Tiberius/PMD/choicedecodingAccTN.mat').result;
TresultsCN = load('./results/Tiberius/PMD/choicedecodingAccCN.mat').result;
TresultsMN = load('./results/Tiberius/PMD/choicedecodingAccMN.mat').result;

% olaf
OresultsTV = load('./results/Olaf/choicedecodingAccTV.mat').result;
OresultsCV = load('./results/Olaf/choicedecodingAccCV.mat').result;
OresultsMV = load('./results/Olaf/choicedecodingAccMV.mat').result;


accT = [TresultsTV.accuracy; TresultsTN.accuracy; OresultsTV.accuracy];
accC = [TresultsCV.accuracy; TresultsCN.accuracy; OresultsCV.accuracy];
accM = [TresultsMV.accuracy; TresultsMN.accuracy; OresultsMV.accuracy];


%%
figure('Position', [10 10 900 600]);

subplot(1,3,1); hold on
plot(TresultsTV.selectedBin, accT', 'color', [1,1,1].*0.7)
plot(TresultsTV.selectedBin, mean(accT,1), 'r', 'linewidth', 2)
ylim([0.4 1])
xlim([-100, 400])

subplot(1,3,2); hold on
plot(TresultsCV.selectedBin, accC', 'color', [1,1,1].*0.7)
plot(TresultsCV.selectedBin, mean(accC,1), 'r', 'linewidth', 2)
ylim([0.4 1])
xlim([TresultsCV.selectedBin(1), 300])

subplot(1,3,3); hold on
plot(TresultsMV.selectedBin, accM', 'color', [1,1,1].*0.7)
plot(TresultsMV.selectedBin, mean(accM,1), 'r', 'linewidth', 2)
ylim([0.4 1])
xlim([-200, TresultsMV.selectedBin(end)])








%%
[accT, accC, accM] = loadCombineDecoderResults('DLPFC', 'choice');
TresultsTV = load('./results/Tiberius/choicedecodingAccTV.mat').result;
TresultsCV = load('./results/Tiberius/choicedecodingAccCV.mat').result;
TresultsMV = load('./results/Tiberius/choicedecodingAccMV.mat').result;


%% plot single traces
figure('Position', [10 10 900 600]);

subplot(1,3,1); hold on
plot(TresultsTV.selectedBin, accT', 'color', [1,1,1].*0.7)
plot(TresultsTV.selectedBin, mean(accT,1), 'r', 'linewidth', 2)
ylim([0.4 1])
xlim([-100, 400])

subplot(1,3,2); hold on
plot(TresultsCV.selectedBin, accC', 'color', [1,1,1].*0.7)
plot(TresultsCV.selectedBin, mean(accC,1), 'r', 'linewidth', 2)
ylim([0.4 1])
xlim([TresultsCV.selectedBin(1), 300])

subplot(1,3,3); hold on
plot(TresultsMV.selectedBin, accM', 'color', [1,1,1].*0.7)
plot(TresultsMV.selectedBin, mean(accM,1), 'r', 'linewidth', 2)
ylim([0.4 1])
xlim([-200, TresultsMV.selectedBin(end)])


%% or plot shaded area

figure('Position', [10 10 900 600]);

options.handle = subplot(1,3,1);
options.error = 'c99';
options.color_area = [243 169 114]./255;    % Orange theme
options.color_line = [236 112  22]./255;
options.alpha      = 0.5;
options.line_width = 2;
options.x_axis = TresultsTV.selectedBin;
plot_areaerrorbar(accT, options)
ylim([0.4 1])
xlim([-100, 400])

options.handle = subplot(1,3,2);
options.x_axis = TresultsCV.selectedBin;
plot_areaerrorbar(accC, options)
ylim([0.4 1])
xlim([TresultsCV.selectedBin(1), 300])

options.handle = subplot(1,3,3);

options.alpha      = 0.5;
options.line_width = 2;
options.x_axis = TresultsMV.selectedBin;
plot_areaerrorbar(accM, options)
ylim([0.4 1])
xlim([-200, TresultsMV.selectedBin(end)])


% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig3/decoder', 'dlpfcChoice', '.eps']);