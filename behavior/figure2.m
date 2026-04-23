%% Plot the raw psychometric and chronometric curves
% Load the data from the Mat files
%
% figTData
% figOData 
% 
% These are structures with the number of sessions.
clear all; close all;clc
addpath('./')
TibsDLPFC = load('Fig2_MonkeyT_data_combined.mat').figTData;
TibsPMD = load('Fig2_MonkeyT_data_old.mat').figTData;

figTData = TibsDLPFC;
figTData.rawdata.RT = [TibsDLPFC.rawdata.RT; TibsPMD.rawdata.RT];
figTData.rawdata.pRed = [TibsDLPFC.rawdata.pRed; TibsPMD.rawdata.pRed];
figTData.combined = [TibsDLPFC.combined; TibsPMD.combined];


load('Fig2_MonkeyV_data_combined.mat');
load('Fig2_MonkeyO_data_old.mat');


% T: blue color
figTData.params.Color = "#0072BD";
figVData.params.Color = "#D95319";
figOData.params.Color = "m";

figure()


plotPsychAndChrono(figTData);
plotPsychAndChrono(figOData);
plotPsychAndChrono(figVData);


% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig1/TibsVinnieOlaf','.eps'], '-r300');





%% plot ziggy

addpath('./')
load('Fig2_MonkeyZ_data.mat');

load('Fig2_MonkeyV_data_combined.mat');
load('Fig2_MonkeyO_data_old.mat');


% T: blue color
figZData.params.Color = [1,1,1].*0.7;


figure()


plotPsychAndChrono(figZData);

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig1_s/Ziggy','.eps'], '-r300');





