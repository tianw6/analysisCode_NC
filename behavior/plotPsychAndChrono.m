function plotPsychAndChrono(summary)
%
%   plotPsychAndChrono(summary)
%
%
%   Plots the psychometric and chronometric curves given a summary data
%   structure. 
% 
%        summary contains field rawdata that contains pRed and RT as
%        fields.
% 
%        summary also contains a field params that is useful for drawing 
%        the axes 
%
% Pierre Boucher and Chand Chandrasekaran, January 2022


params = summary.params;
% figure; 
set(gcf, 'color', [1 1 1],'units','normalized','position',params.position);


pRed = summary.rawdata.pRed;
RT = summary.rawdata.RT;

summary.pRed = squeeze(nanmean(pRed));
summary.pRedError = squeeze(nanstd(pRed))./sqrt(size(pRed,1));

summary.RT = squeeze(nanmean(RT));
summary.RTe = squeeze(nanstd(RT))./sqrt(size(RT,1));


vLabOffset = 10;
width = 0.4;
height = 0.4;

width = 0.4;
pos = [0.05 0.55 width width];
aH = getAxes(pos);
hold on;
axis([-10 110 -10 105]); axis square;
getAxesP([-100 100],[-100:50:100],params.hAxesOffsetPC,-5,'Signed Coherence (%)',...
    [0 100],[0:50:100],vLabOffset,-105,'Percent Red');
set(gca,'visible','off');

errorbar(summary.signedColorCoherence,summary.pRed,params.CI*summary.pRedError,'o-','color',params.Color, 'linewidth',params.lineWidth,'markersize',params.markerSize, 'MarkerFaceColor',[0.4 0.4 0.4]);
% 
% text(40, 14, sprintf('%3.2f sessions',length(summary.thresholds)));
% text(40, 8, sprintf('Threshold (\\alpha): %3.2f \\pm %3.2f%%',nanmean(summary.thresholds(:,1)), nanstd(summary.thresholds(:,1))));
% text(40, 2, sprintf('Slope (\\beta): %3.2f \\pm %3.2f',nanmean(summary.thresholds(:,2)), nanstd(summary.thresholds(:,2))));

line([1-100 100],[50 50],'color','k','linestyle','--');
line([0 0],[0 100],'color','k','linestyle','--');
axis tight;
setAxes(aH, pos);

text(-100,104,['Monkey:' summary.monkey],'color','k','fontsize',12);


pos = [0.55 0.55 width width];
aH = getAxes(pos);
hold on;
axis([-110 110 min(summary.RT-4*summary.RTe) max(summary.RT + 4*summary.RTe)]); axis square;
set(gca,'visible','off');
vLims = round([ceil(min(summary.RT - (3*params.CI)*summary.RTe)), ceil(max(summary.RT+(3*params.CI)*summary.RTe))],1);
T = round([linspace(vLims(1),vLims(2),4)],1);
delta = max(diff(T));
vLims(2) = vLims(1) + 3*delta;

% specific y limit manually
% vLims = [400 571];
% T = linspace(400,571,4);
% 
% vLims = [400 850];
% T = linspace(400,850,4);

% for ziggy

vLims = [850 1150];
T = linspace(850,1150,4);


% RT plot axis position
getAxesP([-100 100],[-100:50:100],params.hAxesOffsetRT, vLims(1)-10,'Coherence',...
    vLims,T,vLabOffset,-110,'RT (ms)');
axis tight;
errorbar(summary.signedColorCoherence, summary.RT, params.CI*summary.RTe,'o-','color',params.Color, 'linewidth',params.lineWidth,'markersize',params.markerSize, 'MarkerFaceColor',[0.4 0.4 0.4]); hold on;
line([0 0],vLims,'color','k','linestyle','--');
set(gcf, 'DefaultAxesFontName', 'Arial');
setAxes(aH, pos);


function aH = getAxes(pos)
%
%
aH = axes('position',pos);



function setAxes(aH, pos)
%
%
set(aH,'position',pos);
axis square;
set(aH,'visible','off');
axis tight;
box off;
