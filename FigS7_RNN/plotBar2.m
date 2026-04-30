function [A, y, stdA] = plotBar(dpcaLoad)

a = dpcaLoad(1:100,:);
b = dpcaLoad(101:200,:);
c = dpcaLoad(201:300,:);
d = dpcaLoad(301:400,:);

A = [a(:), b(:), c(:), d(:)];
size(A)
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

xlabel('area #')
ylabel('dpc loadings')

end

