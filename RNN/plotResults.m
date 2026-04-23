varPerRun = load('resultsA5.mat').varPerRun;

figure; hold on
cols = {'r','g','b','m'};
for j=1:4
    plot(varPerRun(:,j,4), varPerRun(:,j,2), 'd','color',cols{j}, 'MarkerFaceColor', cols{j});
    hold on
end


axis equal

xlim([0 0.7])
ylim([0 0.7])

xlabel('cxt')
ylabel('choice')

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig6_s/', 'cxt_choiceA3.eps']);

figure; hold on
cols = {'r','g','b','m'};
for j=1:4
    plot(varPerRun(:,j,4), varPerRun(:,j,1), 'o','color',cols{j}, 'MarkerFaceColor', cols{j});
    hold on
end


axis equal

xlim([0 0.7])
ylim([0 0.7])

xlabel('cxt')
ylabel('color')

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig6_s/', 'color_cxtA3.eps']);

%%



figure;
cols = {'r','g','b','m'};
for j=1:4
    plot3(varPerRun(:,j,1), varPerRun(:,j,4), varPerRun(:,j,2), 'o','color',cols{j});
    hold on
end


axis equal

% xlim([0 0.7])
% ylim([0 0.7])
% zlim([0 0.7])

xlabel('color')
ylabel('cxt')
zlabel('choice')

%% 

A2 = load('resultsA6.mat').varPerRun;
A3 = load('resultsA3.mat').varPerRun;
A5nofb = load('resultsA5nofb.mat').varPerRun;
A5 = load('resultsA5.mat').varPerRun;


% specify color: dim1; choice: dim2; cxt: dim4
dim = 4;
area = 2;
A5 = squeeze(A5(:,area,dim));
A5nofb = squeeze(A5nofb(:,area,dim));
A2 = squeeze(A2(:,area,dim));
A3 = squeeze(A3(:,area,dim));

A = [A5, A5nofb, A2, A3];
stdA = std(A)./sqrt(size(A,1));



y = mean(A);

X = categorical({'A5','A5nofb','A2', 'A3'});
X = reordercats(X,{'A5','A5nofb','A2', 'A3'});

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

%% each model, plot each area's modulation to a task variable
dim = 4;

A6 = load('resultsA6.mat').varPerRun;
A3 = load('resultsA3.mat').varPerRun;
A5nofb = load('resultsA5nofb.mat').varPerRun;
A5_1 = load('resultsA5_1.mat').varPerRun;

A = A6;

A = [squeeze(A(:,1,dim)),squeeze(A(:,2,dim)),squeeze(A(:,3,dim)),squeeze(A(:,4,dim))];
stdA = std(A)./sqrt(size(A,1));

y = mean(A);

% X = categorical({'1','2','3', 'A3'});
% X = reordercats(X,{'A5','A5nofb','A2', 'A3'});


figure; hold on
b = bar(y, 0.4, 'grouped');
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

figure; 
violinplot(A)

%% 

dim = 4;

for area = 1:4
    
A2 = load('resultsA6.mat').varPerRun;
A3 = load('resultsA3.mat').varPerRun;
A5nofb = load('resultsA5nofb.mat').varPerRun;
A5 = load('resultsA5.mat').varPerRun;
    
A5 = squeeze(A5(:,area,dim));
A5nofb = squeeze(A5nofb(:,area,dim));
A2 = squeeze(A2(:,area,dim));
A3 = squeeze(A3(:,area,dim));

A = [A5, A5nofb, A2, A3];


addpath('violinplot/');

figure;
violinplot(A)
title(['area' num2str(area)])

end