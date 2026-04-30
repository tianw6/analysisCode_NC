% generate plot in FigS5h: plot the dpca loadings on mix selectivity index with coordinates from
% determineCoordiantes.m and loadings from calGradients.m

% after that, linear regression and partial correlation analysis

load('coordinates.mat');
AP = X(:,1);
Depth = X(:,2);

load('loads_norm.mat');
% load('loads_nonorm.mat');

choiceLoad = loads.choiceLoad;
colorLoad = loads.colorLoad;
cxtLoad = loads.cxtLoad;

%% plot volume over largest edge 
tetra = (choiceLoad.*colorLoad.*cxtLoad);

allLoad = [choiceLoad,colorLoad,cxtLoad];
maxLoad = max(allLoad,[],2);
vlRatio = tetra ./ maxLoad;
uVLRatio = unique(vlRatio);

figure(1); hold on

for jj = 1:length(AP)
    if  vlRatio(jj) > 1e-5 & vlRatio(jj) < uVLRatio(end)  % remove the largest 0.1% outliers
        plot(AP(jj), Depth(jj), '.', 'markersize', vlRatio(jj).*10000, 'color', 'b');
    end
end

ylim([0 12])
xlim([-11 11])
set(gca, 'YDir','reverse')
title('mixed selectivity')

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig5_s/', 'mixGradient.eps']);




%% linear regression add pmd


mdTetra = fitlm(X, tetra);
disp(mdTetra)


%% partial correlation

[r,p] = partialcorr(tetra, X(:,1), X(:,2));
[r,p] = partialcorr(tetra, X(:,2), X(:,1));





