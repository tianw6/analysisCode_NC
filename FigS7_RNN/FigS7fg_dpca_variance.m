

%%%%%%%%%%%%%%%%%%%%
% This code plots FigS7f: compare between full model and Variant 3 area 3&4 color and interaction variance

varPerRun = load('resultsA5.mat').varPerRun;

figure; hold on
cols = {'r','g','b','m'};
for j=3:4
    plot(varPerRun(:,j,4), varPerRun(:,j,1), 'o','color',cols{j}, 'MarkerFaceColor', cols{j});
    hold on
end


axis equal

xlim([0 0.7])
ylim([0 0.7])

legend('area3', 'area4')
xlabel('cxt')
ylabel('color')
title('FigS7f: Vanilla model area 3 and 4 color and interaction variance')

%% FigS7g: Variant 3 area 3&4 color and interaction variance

varPerRun = load('resultsA3.mat').varPerRun;

figure; hold on
cols = {'r','g','b','m'};
for j=3:4
    plot(varPerRun(:,j,4), varPerRun(:,j,1), 'o','color',cols{j}, 'MarkerFaceColor', cols{j});
    hold on
end


axis equal

xlim([0 0.7])
ylim([0 0.7])

legend('area3', 'area4')
xlabel('cxt')
ylabel('color')
title('FigS7g: Variant 3 area 3 and 4 color and interaction variance')

