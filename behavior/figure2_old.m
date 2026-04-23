%% Plot the raw psychometric and chronometric curves
% Load the data from the Mat files
%
% figTData
% figOData 
% 
% These are structures with the number of sessions.
clear all; close all;clc
addpath('./')
load('Fig2_MonkeyT_data_combined.mat');
load('Fig2_MonkeyV_data_combined.mat');

load('Fig2_MonkeyT_data_old.mat');
% load('Fig2_MonkeyO_data_old.mat');

figZData.params.Color = 'k';
% T: blue color
figTData.params.Color = "#0072BD";
figVData.params.Color = "#D95319";
figOData.params.Color = "m";

figure()
% figOData.params.Color = 'b';
% figVData.params.Color = 'm';

plotPsychAndChrono(figTData);
% plotPsychAndChrono(figVData);


% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig1/TibsVinnie','.eps'], '-r300');

%% Plot boxplots of RT vs. Coherence
figure(1);
width = 0.4;
ax = axes('position',[0.05 0.05 width width]);
TT = drawRTboxplot(figTData, ax);


% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig1/psychTibs','.eps'], '-r300');



