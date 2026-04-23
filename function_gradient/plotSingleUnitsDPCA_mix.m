% plot the dpca loadings on nonlinear mix selectivity (tetrahedron volume)
% and linear mix selectivty (surface area) with coordinates from
% determineCoordiantes.m and loadings from calGradients.m

% after that, linear regression and partial correlation analysis

load('coordinates.mat');
AP = X(:,1);
Depth = X(:,2);

% load('loads_norm.mat');
load('loads_nonorm.mat');

choiceLoad = loads.choiceLoad;
colorLoad = loads.colorLoad;
cxtLoad = loads.cxtLoad;


tetra = (choiceLoad.*colorLoad.*cxtLoad);
utetra = unique(tetra);

figure(1); hold on

for jj = 1:length(AP)
    if tetra(jj) > 1e-10 & tetra(jj) < utetra(end)  % remove the largest 0.1% outliers
        plot(AP(jj), Depth(jj), '.', 'markersize', tetra(jj).*80000, 'color', 'b');
    end
end

ylim([0 12])
xlim([-11 11])
set(gca, 'YDir','reverse')
title('nonlinear mixed selectivity')






%% plot color and cxt mixed selectivity
surf = 2.*(choiceLoad.*colorLoad + choiceLoad.*cxtLoad + cxtLoad.*colorLoad);
% surf = cxtLoad.*colorLoad;

usurf = unique(surf);

figure(1); hold on

for jj = 1:length(AP)
    if  surf(jj) > 1e-10 & surf(jj) < usurf(end)  % remove the largest 0.1% outliers
        plot(AP(jj), Depth(jj), '.', 'markersize', surf(jj).*1500, 'color', 'b');
    end
end

ylim([0 12])
xlim([-11 11])
set(gca, 'YDir','reverse')
title('linear mixed selectivity')


% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig5_s/', 'colorGradient.eps']);


%% plot volume over surf 

vsRatio = tetra ./ surf;
uVSRatio = unique(vsRatio);

figure(1); hold on

for jj = 1:length(AP)
    if  vsRatio(jj) > 1e-10 & vsRatio(jj) < uVSRatio(end)  % remove the largest 0.1% outliers
        plot(AP(jj), Depth(jj), '.', 'markersize', vsRatio(jj).*3000, 'color', 'b');
    end
end

ylim([0 12])
xlim([-11 11])
set(gca, 'YDir','reverse')
title('mixed selectivity')



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

mdSurf = fitlm(X, surf);
disp(mdSurf)


%% partial correlation

[r,p] = partialcorr(tetra, X(:,1), X(:,2));
[r,p] = partialcorr(tetra, X(:,2), X(:,1));

[r,p] = partialcorr(surf, X(:,1), X(:,2));
[r,p] = partialcorr(surf, X(:,2), X(:,1));




