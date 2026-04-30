%%%%%%%%%%%%%%%%%%%%
% This code plots Fig 1d: chronometric curves and reaction time curves 


clear all; close all; clc

TibsDLPFC = load('Fig2_MonkeyT_data_combined.mat').figTData;
TibsPMD   = load('Fig2_MonkeyT_data_old.mat').figTData;

figTData = TibsDLPFC;
figTData.rawdata.RT   = [TibsDLPFC.rawdata.RT;   TibsPMD.rawdata.RT];
figTData.rawdata.pRed = [TibsDLPFC.rawdata.pRed; TibsPMD.rawdata.pRed];
figTData.combined     = [TibsDLPFC.combined;      TibsPMD.combined];

load('Fig2_MonkeyV_data_combined.mat');
load('Fig2_MonkeyO_data_old.mat');

% Colors
figTData.params.Color = "#0072BD";
figVData.params.Color = "#D95319";
figOData.params.Color = "m";


% -------------------------------------------------------------------------
% Layout constants
% -------------------------------------------------------------------------
width      = 0.4;
vLabOffset = 10;

% Shared y limits for the RT axis
yLimRT  = [400 850];
RT_ticks = linspace(yLimRT(1), yLimRT(2), 4);

% Use horizontal Axes Offset  
hAxesOffsetPC = figTData.params.hAxesOffsetPC;
hAxesOffsetRT = figTData.params.hAxesOffsetRT;

% -------------------------------------------------------------------------
figure()
set(gcf, 'color', [1 1 1], 'units', 'normalized', ...
    'position', figTData.params.position);

% psychometric curves axis format
pos = [0.05 0.55 width width];
axPsych = axes('position', pos);
hold on;
axis([-10 110 -10 105]); axis square;
getAxesP([-100 100], [-100:50:100], hAxesOffsetPC, -5, ...
    'Signed Coherence (%)', [0 100], [0:50:100], vLabOffset, -105, 'Percent Red');
set(gca, 'visible', 'off');
line([-100 100], [50 50], 'color', 'k', 'linestyle', '--');
line([0 0],      [0 100], 'color', 'k', 'linestyle', '--');
setAxes(axPsych, pos);

% RT curves axes format
pos = [0.55 0.55 width width];
axRT = axes('position', pos);
hold on;
set(gca, 'visible', 'off');
getAxesP([-100 100], [-100:50:100], hAxesOffsetRT, yLimRT(1)-10, ...
    'Signed Coherence (%)', yLimRT, RT_ticks, vLabOffset, -110, 'RT (ms)');
line([0 0], yLimRT, 'color', 'k', 'linestyle', '--');
set(gcf, 'DefaultAxesFontName', 'Arial');
setAxes(axRT, pos);

% plot psychometric and RT curves
plotPsychAndChrono(figTData, axPsych, axRT, yLimRT);
plotPsychAndChrono(figOData, axPsych, axRT, yLimRT);
plotPsychAndChrono(figVData, axPsych, axRT, yLimRT);

sgtitle('Fig 1d: psychometric curves', 'FontSize', 14, 'FontWeight', 'bold');


% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig1/psychometric','.eps'], '-r300');


%% Plot Ziggy behavior data (used in supplementary figure S1)

load('Fig2_MonkeyZ_data.mat');

figZData.params.Color = [1 1 1] .* 0.7;

yLimRT_Z = [850 1150];

figure()
set(gcf, 'color', [1 1 1], 'units', 'normalized', ...
    'position', figZData.params.position);

pos = [0.05 0.55 width width];
axPsych_Z = axes('position', pos);
hold on;
axis([-10 110 -10 105]); axis square;
getAxesP([-100 100], [-100:50:100], figZData.params.hAxesOffsetPC, -5, ...
    'Signed Coherence (%)', [0 100], [0:50:100], vLabOffset, -105, 'Percent Red');
set(gca, 'visible', 'off');
line([1-100 100], [50 50], 'color', 'k', 'linestyle', '--');
line([0 0],       [0 100], 'color', 'k', 'linestyle', '--');
text(-100, 104, ['Monkey:' figZData.monkey], 'color', 'k', 'fontsize', 12);
setAxes(axPsych_Z, pos);

pos = [0.55 0.55 width width];
axRT_Z = axes('position', pos);
hold on;
set(gca, 'visible', 'off');
Z_ticks = linspace(yLimRT_Z(1), yLimRT_Z(2), 4);
getAxesP([-100 100], [-100:50:100], figZData.params.hAxesOffsetRT, yLimRT_Z(1)-10, ...
    'Signed Coherence (%)', yLimRT_Z, Z_ticks, vLabOffset, -110, 'RT (ms)');
line([0 0], yLimRT_Z, 'color', 'k', 'linestyle', '--');
set(gcf, 'DefaultAxesFontName', 'Arial');
setAxes(axRT_Z, pos);

plotPsychAndChrono(figZData, axPsych_Z, axRT_Z, yLimRT_Z);


sgtitle('S1e: psychometric curves of Ziggy', 'FontSize', 14, 'FontWeight', 'bold');

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig1_s/Ziggy','.eps'], '-r300');


function setAxes(aH, pos)
set(aH, 'position', pos);
axis square;
set(aH, 'visible', 'off');
axis tight;
box off;

end

