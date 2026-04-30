%%%%%%%%%%%%%%%%%%%%
% This code plots FigS7d-e

clear all; close all; clc


% FigS7d: generate bar plot in FigS7f: comparing interaction variance in area 1
% and area 2 between vanilla model and variant 1

% FigS7e: generate bar plot in FigS7e: comparing action variance in area 1
% and area 2 between vanilla model and variant 1
FigHandle = 'FigS7e';

switch FigHandle
    case{'FigS7d'}
        varName = 'cxt';
        A5V = load('A5V.mat').dpcaV;
        testV = load('A6V.mat').dpcaV;    
        
    case{'FigS7e'}
        varName = 'cxt';
        A5V = load('A5V.mat').dpcaV;
        testV = load('A6V.mat').dpcaV;
end


[X, y1, stdA5] = plotmultiBar(A5V, varName);
[X, y2, stdTest] = plotmultiBar(testV, varName);

% only choose area 1 and 2

area = 1:2;

X = 1:length(area);

y = [y1(area); y2(area)]';

stdA = [stdA5(area); stdTest(area)]';

figure; hold on

b = bar(X,y, 'grouped');
% Calculate the number of groups and number of bars in each group
[ngroups,nbars] = size(y);
% Get the x coordinate of the bars
x = nan(nbars, ngroups);
for i = 1:nbars
    x(i,:) = b(i).XEndPoints;
end


% Plot the errorbars
errorbar(x',y,stdA,'k','linestyle','none', 'linewidth', 1.5);
hold off

legend('vanilla', 'variant')
xlabel('area')

title([FigHandle])

