% plot the dpca loadings on cxt, color and choice with coordinates from
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


uChoiceLoad = unique(choiceLoad);
uCxtLoad = unique(cxtLoad);
uColorLoad = unique(colorLoad);


figure(1); hold on

for jj = 1:length(AP)
    if choiceLoad(jj) < uChoiceLoad(end-6) % remove the largest 0.1% outliers
        plot(AP(jj), Depth(jj), '.', 'markersize', choiceLoad(jj).*400, 'color', 'b');
    end
end

ylim([0 12])
xlim([-11 11])
set(gca, 'YDir','reverse')
title('choice')

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig5_s/', 'choiceGradient.eps']);


% plot cxt
figure(2); hold on

    for jj = 1:length(AP)
        if cxtLoad(jj) < uCxtLoad(end - 6)  
            plot(AP(jj), Depth(jj), '.', 'markersize', cxtLoad(jj).*400, 'color', 'k');
        end
    end

ylim([0 12])
xlim([-11 11])
set(gca, 'YDir','reverse')
title('cxt')

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig5_s/', 'cxtGradient.eps']);

% plot color
figure(3); hold on

    for jj = 1:length(AP)
        if colorLoad(jj) < uColorLoad(end - 6)
            plot(AP(jj), Depth(jj), '.', 'markersize', colorLoad(jj).*400, 'color', 'm');
        end
    end

ylim([0 12])
xlim([-11 11])
set(gca, 'YDir','reverse')
title('color')

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig5_s/', 'colorGradient.eps']);


%% linear regression add pmd


mdColor = fitlm(X, colorLoad);
disp(mdColor)

mdCxt = fitlm(X, cxtLoad);
disp(mdCxt)

mdChoice = fitlm(X, choiceLoad);
disp(mdChoice)

%% partial correlation

[r,p] = partialcorr(colorLoad, X(:,1), X(:,2));
[r,p] = partialcorr(colorLoad, X(:,2), X(:,1));

[r,p] = partialcorr(cxtLoad, X(:,1), X(:,2));
[r,p] = partialcorr(cxtLoad, X(:,2), X(:,1));

[r,p] = partialcorr(choiceLoad, X(:,1), X(:,2));
[r,p] = partialcorr(choiceLoad, X(:,2), X(:,1));

