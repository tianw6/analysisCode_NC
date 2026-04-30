%%%%%%%%%%%%%%%%%%%%
% This code plots FigS7c: average dpc loading of each area 

clear; clc; 

load('A5V.mat')

colorLoad = [];
choiceLoad = [];
cxtLoad = [];
for ii = 1:length(dpcaV)
    
    whichMarg = dpcaV(ii).whichMarg;
    V = dpcaV(ii).V;

    colorDim = find(whichMarg == 1);
    choiceDim = find(whichMarg == 2);
    cxtDim = find(whichMarg == 4);

    colorLoad = [colorLoad, abs(V(:, colorDim(1)))];
    choiceLoad  = [choiceLoad, abs(V(:, choiceDim(1)))];
    cxtLoad  = [cxtLoad, abs(V(:, cxtDim(1)))];

    
end


%% FigS7c: for vanilla model, bar plot of average dpc loadings of task variables

[Acolor,~, ~] = plotBar2(colorLoad);
ylim([0 0.08])
% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig6/', 'colorLoad.eps']);

title('FigS7c: color')

[Acxt, ~,~] = plotBar2(cxtLoad)
ylim([0 0.06])
% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig6/', 'cxtLoad.eps']);
title('FigS7c: color x action')


[Achoice,~,~] = plotBar2(choiceLoad)
ylim([0 0.07])
% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig6/', 'choiceLoad.eps']);
title('FigS7c: action')





%% 

