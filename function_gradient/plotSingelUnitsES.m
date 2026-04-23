% plot effect size functional gradient
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





%% plot choice
figure(1); hold on


    for jj = 1:length(AP)
        if (choiceLoad(jj) > uChoiceES(2))  & choiceLoad(jj) < uChoiceES(end - 6)
            plot(AP(jj), Depth(jj), '.', 'markersize', (choiceLoad(jj) - uChoiceES(2))*70, 'color', 'b');
        end
    end

ylim([0 12])
xlim([-11 11])
set(gca, 'YDir','reverse')

title('choice')

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig5_s/', 'choiceGradient_ES.eps']);


%% plot cxt


figure(2); hold on


    for jj = 1:length(AP)
        
        if (cxtLoad(jj) > uCxtES(2)) 
            plot(AP(jj), Depth(jj), '.', 'markersize', (cxtLoad(jj) - uCxtES(2))*70, 'color', 'k');
        end
        
    end

ylim([0 12])
xlim([-11 11])
set(gca, 'YDir','reverse')

title('cxt')

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig5_s/', 'cxtGradient_ES.eps']);


%% plot npix color

figure(3); hold on


    for jj = 1:length(AP)
        
     
       if (colorLoad(jj) > uColorES(2)) & colorLoad(jj) < uColorES(end - 6)
            plot(AP(jj), Depth(jj), '.', 'markersize', (colorLoad(jj) - uColorES(2))*70, 'color', 'm');
        end        
        
    end

ylim([0 12])
xlim([-11 11])
set(gca, 'YDir','reverse')

title('color')

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig5_s/', 'colorGradient_ES.eps']);

