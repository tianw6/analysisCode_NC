% plot dpca encoder matrix functional gradient
% created by Tian on Jun.18 2025
% use it aftter cal_gradient.m 

% 0328 superficial neuropixel has 1 huge color unit

Tibs = load('/Users/tianwang/Documents/MATLAB/ChandLab/DLPFC_analysis/createDataInfo/DLPFC_neurons.mat').database;

Vinnie = load('/Users/tianwang/Documents/MATLAB/ChandLab/Vinnie_DLPFC/createDataInfo/DLPFC_neurons.mat').database;

Ziggy = load('/Users/tianwang/Documents/MATLAB/ChandLab/Ziggy_DLPFC/createDataInfo/DLPFC_neurons.mat').database;
a = struct2table(Tibs);
b = struct2table(Vinnie);
c = struct2table(Ziggy);

d = [a(:,1); b(:,1); c(:,1)];

Channels = table2struct(d);



allAP = [];
allDepth = [];

cnt = 1;

for ii = 1:length(Channels)
    units = length(Channels(ii).channelID);
    
    channelId = Channels(ii).channelID;
    
    depth1Day = depth(ii) - (32-channelId)./10;
    AP1Day = AP(ii) + rand(units,1).*0.4-0.2;
    
    allDepth = [allDepth; depth1Day];
    allAP = [allAP; AP1Day];
        
    cnt = cnt+units;
    
end

allAP = allAP - endPSAP;


%% plot choice, cxt, color


uChoiceLoad = unique(choiceLoad);
uCxtLoad = unique(cxtLoad);
uColorLoad = unique(colorLoad);


figure(1); hold on

for jj = 1:length(allAP)
    if choiceLoad(jj) < uChoiceLoad(end-6) % remove the largest 0.1% outliers
        plot(allAP(jj), allDepth(jj), '.', 'markersize', choiceLoad(jj).*400, 'color', 'b');
    end
end

ylim([0 12])
set(gca, 'YDir','reverse')

title('choice')


% plot cxt
figure(2); hold on

    for jj = 1:length(allAP)
        if cxtLoad(jj) < uCxtLoad(end - 6)  
            plot(allAP(jj), allDepth(jj), '.', 'markersize', cxtLoad(jj).*400, 'color', 'k');
        end
    end

ylim([0 12])
set(gca, 'YDir','reverse')

title('cxt')

% plot color
figure(3); hold on

    for jj = 1:length(allAP)
        if colorLoad(jj) < uColorLoad(end - 6)
            plot(allAP(jj), allDepth(jj), '.', 'markersize', colorLoad(jj).*400, 'color', 'm');
        end
    end

ylim([0 12])
set(gca, 'YDir','reverse')

title('color')
%% 

Vnpix = dir('/Volumes/TianSSD/VinnieNpix/waveforms/*.mat');

TnpixPFC = dir('/Volumes/TianSSD/TiberiusNpix/waveforms/*DLPFC*.mat');

TnpixPMD = dir('/Volumes/TianSSD/TiberiusNpix/waveforms/*PMD*.mat');

npix = [Vnpix; TnpixPFC; TnpixPMD];

%%
npixDepth = [];
npixAP = [];


for ii = 1:length(npix)
    
    npix1Day = load([npix(ii).folder '/' npix(ii).name]).goodUnits;
    
    npix1DayDepth = depth(length(Channels)+ii) - [npix1Day.depth]/1000;
    npixDepth = [npixDepth; npix1DayDepth'];
    
    npix1DayAP = AP(length(Channels)+ii) + rand(length(npix1Day),1).*0.2-0.1;
    npixAP = [npixAP; npix1DayAP];
end
    

npixAP = npixAP - endPSAP;
 
%%

% plot npix choice
figure(1); hold on

for jj = 1:length(npixAP)
    choiceLoad1 = choiceLoad(jj+length(allAP));
    if choiceLoad1 < uChoiceLoad(end-6)
        plot(npixAP(jj), npixDepth(jj), '.', 'markersize', choiceLoad1.*400, 'color', 'b');
    end
end

ylim([0 12])
xlim([-12.5, 12.5])
set(gca, 'YDir','reverse')

title('choice')

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig5/', 'choiceGradient_01n.eps']);


% plot npix cxt
figure(2); hold on


    for jj = 1:length(npixAP)
        cxtLoad1 = cxtLoad(jj+length(allAP));
        if cxtLoad1 < uCxtLoad(end-6)
            plot(npixAP(jj), npixDepth(jj), '.', 'markersize', cxtLoad1.*400, 'color', 'k');
        end
    end

ylim([0 12])
xlim([-12.5, 12.5])
set(gca, 'YDir','reverse')

title('cxt')

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig5/', 'cxtGradient_01n.eps']);

% plot npix color
figure(3); hold on


    for jj = 1:length(npixAP)
        colorLoad1 = colorLoad(jj+length(allAP));
        if colorLoad1 < uColorLoad(end - 6)
            plot(npixAP(jj), npixDepth(jj), '.', 'markersize', colorLoad1.*400, 'color', 'm');
        end
    end

ylim([0 12])
xlim([-10, 12])
set(gca, 'YDir','reverse')

title('color')

% print('-painters','-depsc',['~/Desktop/', 'colorGradient_01n.eps']);


%% linear regression add pmd

AP = [allAP; npixAP];
Depth = [allDepth; npixDepth];
X = [AP, Depth];

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
[r,p] = partialcorr(choiceLoad, X(:,1), X(:,2));
