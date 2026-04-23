clear; clc; 

load('A6V.mat')

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



%% color
a = cxtLoad(1:100,:);
b = cxtLoad(101:200,:);
c = cxtLoad(201:300,:);
d = cxtLoad(301:400,:);

A = [a(:), b(:), c(:), d(:)];

stdA = std(A)./sqrt(size(A,1));



y = mean(A);

X = categorical({'1','2','3','4'});
X = reordercats(X,{'1','2','3','4'});

figure; hold on
b = bar(X,y, 0.4, 'grouped');
% Calculate the number of groups and number of bars in each group
[ngroups,nbars] = size(y');
% Get the x coordinate of the bars
x = nan(nbars, ngroups);
for i = 1:nbars
    x(i,:) = b(i).XEndPoints;
end
% Plot the errorbars
errorbar(x',y,stdA,'k','linestyle','none', 'linewidth', 1.5);
hold off

%% 
addpath('violinplot/');

[Acolor,~, ~] = plotBar2(colorLoad);
ylim([0 0.08])
% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig6/', 'colorLoad.eps']);
% figure;
% violinplot(Acolor)

[Acxt, ~,~] = plotBar2(cxtLoad)
ylim([0 0.06])
% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig6/', 'cxtLoad.eps']);
% figure;
% violinplot(Acxt)

[Achoice,~,~] = plotBar2(choiceLoad)
ylim([0 0.07])
% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig6/', 'choiceLoad.eps']);
% figure;
% violinplot(Achoice)


%% 

figure;

vlRatio1 = (Acolor(:,1) .* Acxt(:,1) .* Achoice(:,1)) ./ (max([Acolor(:,1), Acxt(:,1), Achoice(:,1)], [], 2));

vlRatio2 = (Acolor(:,2) .* Acxt(:,2) .* Achoice(:,2)) ./ (max([Acolor(:,2), Acxt(:,2), Achoice(:,1)], [], 2));


bar([mean(vlRatio1), mean(vlRatio2)])


%% 

