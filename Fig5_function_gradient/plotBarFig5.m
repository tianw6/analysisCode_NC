function plotBarFig5(y,dataCI)

% figure('position', [1000,1000,600,300]); hold on

X = categorical({'9/46 Anterior','9/46 Deep','9/46 Superficial','Area 8', 'pmd'});
X = reordercats(X,{'9/46 Anterior', '9/46 Deep','9/46 Superficial','Area 8', 'pmd'});

b = bar(X,y, 0.4, 'grouped');
% Calculate the number of groups and number of bars in each group
[ngroups,nbars] = size(y);
% Get the x coordinate of the bars
x = nan(nbars, ngroups);
for i = 1:nbars
    x(i,:) = b(i).XEndPoints;
end
% Plot the errorbars
errorbar(x',y,dataCI,'k','linestyle','none', 'linewidth', 1.5);
hold off


ylabel("demixed PC loadings")


end

