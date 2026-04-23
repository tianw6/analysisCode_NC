% created by Tian on Sep 20th. Calculate the ES differnce between dlpfc and
% pmd 

clear; clc


dlpfc = load('ESresultsDLPFC').results;
pmd = load('ESresultsPMD').results;

tLim = [150,400];
[meanPFC, stdPFC, rawPFC] = calES(dlpfc, tLim);
[meanPMD, stdPMD, rawPMD] = calES(pmd, tLim);

meanV = [meanPFC; meanPMD];
stdV = [stdPFC; stdPMD];

figure;
bar(meanV');
hold on;
% Get bar positions
ngroups = size(meanV, 2);  % 3 groups
nbars = size(meanV, 1);    % 2 bars per group
groupwidth = min(0.8, nbars/(nbars + 1.5));

% Calculate x positions for error bars
for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    errorbar(x, meanV(i,:), stdV(i,:), 'k', 'LineStyle', 'none', 'LineWidth', 1.5);
end
hold off;


fprintf("rank sum test of color: %s\n", ranksum(rawPFC{1}, rawPMD{1}))
fprintf("rank sum test of choice: %s\n", ranksum(rawPFC{2}, rawPMD{2}))
fprintf("rank sum test of cxt: %s\n", ranksum(rawPFC{3}, rawPMD{3}))

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig2_s/', 'ES_cue_new', '.eps']);

%% target aligned (only calculate targets)'


dlpfc = load('ESresultsDLPFCT').results;
pmd = load('ESresultsPMDT').results;

tLim = [100,300];
[meanPFC, stdPFC, rawPFC] = calES(dlpfc, tLim);
[meanPMD, stdPMD, rawPMD] = calES(pmd, tLim);

meanV = [meanPFC(3); meanPMD(3)];
stdV = [stdPFC(3); stdPMD(3)];

figure;
b_handle = bar(meanV, 0.3);  % Create bar graph
hold on;
errorbar(1:length(meanV), meanV, stdV, 'k.', 'LineWidth', 1.5);  % Add error bars
hold off;

fprintf("rank sum test of cxt: %s\n", ranksum(rawPFC{3}, rawPMD{3}))

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig2_s/', 'ES_tar_new', '.eps']);
