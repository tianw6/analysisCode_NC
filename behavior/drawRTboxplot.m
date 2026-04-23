function T = drawRTboxplot(summary, whichPlot, varargin)
%
%
%
% Chand-lab, 2023

minRT = 200;
maxRT = 2000;
assignopts(who, varargin);


rawData = summary.combined;
cueV = 100*abs([rawData(:,1) - (225 - rawData(:,1))]./225);
cueLabelV = unique(cueV);
cueText = {};
for n=1:length(cueLabelV)
    cueId(n) = n;
    cueText{n} = sprintf('%2.0f',cueLabelV(n));
    cueColors{n} = 'b'; 
end
cohLabels = getTextLabel(cueId, cueText',cueColors');

axes(whichPlot)

RT = rawData(:,3);
V = (RT > minRT & RT < maxRT);
h = boxplot(RT(V), cueV(V),'symbol','ko');

T = table(cueV(V), RT(V));


X = [];  
X(:,1) = log10(cueV(V));
X(:,2) = 1;
Y = log10(RT(V));
[~,~,~,~,st] = regress(Y,X);
st(1);
axis tight;
axis square;

text(4, 2200, sprintf('Regression with log10(c): %3.2f%%',...
    100*st(1)));
text(1, 2200, sprintf('%d Trials',sum(V)));

formatBoxPlot(gca, cohLabels)




function formatBoxPlot(ax, cohLabels)
%
%
%
%
hold on;
box off;
set(gca,'visible','off');
h = findobj(ax,'tag','Outliers');
set(h,'markerfacecolor',[0 0.45 0.7],'markersize',...
    8,'markeredgecolor','none');
hold on;
getAxesP([1 7],[ ],'Conditions',-5,1,[200 2000],...
    [200:400:2000],'RT(ms)',.5,1,[1 1], cohLabels);  