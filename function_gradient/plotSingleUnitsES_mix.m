% plot effect size nonlinear mix selectivity (tetrahedron volume)
% and linear mix selectivty (surface area)
% with coordinates from determineCoordiantes.m 
% created by Tian on Jun.18 2025
% ES time range: (-100, 400) aligns to checkerboard

% clear; clc


load('coordinates.mat');
AP = X(:,1);
Depth = X(:,2);
%%

load('/Users/tianwang/Documents/MATLAB/ChandLab/DLPFC_PMD/geometry/single_unit_mix_selectivity/ESresultsAll.mat');

thres = 0.01;

p_all = [];
cnt = 1;
for id = 1:length(results)
    temp = results(id).anovaResults;
    for idx = 1:length(temp)
        p_all(:,:,cnt) = temp(idx).anova2R;
        ES_all(:,:,cnt) = temp(idx).effect_size;
        cnt = cnt+1;
    end
end

% find significant p values for color, cxt and choice 
sigP = p_all < thres;

ES = sigP.* ES_all;


%%

ES(isnan(ES))=0;

% allES = squeeze(max(ES, [], 2));
% ES = squeeze(mean(ES, 2));

allES = [];
% % color average: 100 to 400
% allES(1,:) = squeeze(mean(ES(1,40:end,:),2));
% 
% % choice average: 150:400
% allES(2,:) = squeeze(mean(ES(2,50:end,:), 2));
% 
% % cxt average: -100:400
% allES(3,:) = squeeze(mean(ES(3,:,:), 2));


% color average: 100 to 400
allES(1,:) = squeeze(mean(ES(1,40:end,:),2));

% choice average: 150:400
allES(2,:) = squeeze(mean(ES(2,40:end,:), 2));

% cxt average: -100:400
allES(3,:) = squeeze(mean(ES(3,40:end,:), 2));



choiceLoad = allES(2,:);
uChoiceES = unique(choiceLoad);


cxtLoad = allES(3,:);
uCxtES = unique(cxtLoad);


colorLoad = allES(1,:);
uColorES = unique(colorLoad);


tetra = (choiceLoad.*colorLoad.*cxtLoad);
utetra = unique(tetra);

figure(1); hold on

for jj = 1:length(AP)
    if tetra(jj) > 0 & tetra(jj) < utetra(end)  % remove the largest 0.1% outliers
        plot(AP(jj), Depth(jj), '.', 'markersize', tetra(jj).*750, 'color', 'b');
    end
end

ylim([0 12])
xlim([-11 11])
set(gca, 'YDir','reverse')
title('nonlinear mixed selectivity')


%%
surf = 2.*(choiceLoad.*colorLoad + choiceLoad.*cxtLoad + cxtLoad.*colorLoad);
% surf = colorLoad.*cxtLoad;
usurf = unique(surf);

figure(1); hold on

for jj = 1:length(AP)
    if  surf(jj) > 0 & surf(jj) < usurf(end)  % remove the largest 0.1% outliers
        plot(AP(jj), Depth(jj), '.', 'markersize', surf(jj).*50, 'color', 'b');
    end
end

ylim([0 12])
xlim([-11 11])
set(gca, 'YDir','reverse')
title('linear mixed selectivity')


%% plot volume over surf 

vsRatio = tetra ./ surf;
vsRatio(isnan(vsRatio)) = 0;
uVSRatio = unique(vsRatio);

figure(1); hold on

for jj = 1:length(AP)
    if  vsRatio(jj) > 1e-10 & vsRatio(jj) < uVSRatio(end)  % remove the largest 0.1% outliers
        plot(AP(jj), Depth(jj), '.', 'markersize', vsRatio(jj).*500, 'color', 'b');
    end
end

ylim([0 12])
xlim([-11 11])
set(gca, 'YDir','reverse')
title('mixed selectivity')


%% plot volume over largest edge 
allLoad = [choiceLoad;colorLoad;cxtLoad];
maxLoad = max(allLoad,[],1);
vlRatio = tetra ./ maxLoad;
vlRatio(isnan(vlRatio)) = 0;

uVLRatio = unique(vlRatio);

figure(1); hold on

for jj = 1:length(AP)
    if   vlRatio(jj) > 1e-6 & vlRatio(jj) < uVLRatio(end)  % remove the largest 0.1% outliers
        plot(AP(jj), Depth(jj), '.', 'markersize', vlRatio(jj).*500, 'color', 'b');
    end
end

ylim([0 12])
xlim([-11 11])
set(gca, 'YDir','reverse')
title('mixed selectivity')

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig5_s/', 'mixGradient_ES.eps']);
