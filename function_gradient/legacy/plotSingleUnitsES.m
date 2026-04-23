% plot effect size functional gradient
% created by Tian on Jun.18 2025
% ES time range: (-100, 400) aligns to checkerboard

% clear; clc

addpath('/Users/tianwang/Documents/MATLAB/ChandLab/DLPFC_analysis/createDataInfo/');
addpath('../geometry/pca_visualize/')
% grid 6: 8.5mm; grid 8:12mm  

% grid 7: 10.25mm, AP: 32
% anterior edge of burrhole 4: AP: 35.6
% posterior edge of burrhole 2: AP: 27

% burrhole 2: 30-27 (12.75-15.5)
% burrhole 3: AP: 33-30 (9.75-12.75)
% burrhole 4: 35.6-33 (5.5-8.5)

% burrhole 2: 14
% burrhole 3: 11.25
% burrhole 4: 7
% pmd burrhole: 21.75

opts = detectImportOptions('insert_locations.xlsx');

% Set column types
% 'string' for text columns
% 'double' for numeric columns
opts.VariableTypes{1} = 'string';   % 1st column string
opts.VariableTypes{2} = 'double';   % 2nd column number
opts.VariableTypes{3} = 'double';   % 3rd column number
opts.VariableTypes{4} = 'double';   % 4th column number
opts.VariableTypes{6} = 'string';   % 6th column string

% Read the table with specified options
data = readtable('insert_locations.xlsx', opts);


AP = data{:,7};
depth = data{:,5};


AP(1:13) = AP(1) + 1.6.*rand(length(1:13),1) - 0.8;
AP(14:29) = AP(14) + 2.*rand(length(14:29),1) - 1;
AP(30:54) = AP(30) + 2.*rand(length(30:54),1) - 1;
AP(55:65) = AP(55) + 2.*rand(length(55:65),1) - 1;
AP(130:162) = AP(130) + 2.*rand(length(130:162),1) - 1;
AP(163:181) = AP(163) + 1.6.*rand(length(163:181),1) - 0.8;
AP(182:185) = AP(182) + 2.*rand(length(182:185),1) - 1;
AP(206:end) = AP(206) + 1.6.*rand(length(206:217),1) - 0.8;

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



%%
Tibs = load('/Users/tianwang/Documents/MATLAB/ChandLab/DLPFC_analysis/createDataInfo/DLPFC_neurons.mat').database;

Vinnie = load('/Users/tianwang/Documents/MATLAB/ChandLab/Vinnie_DLPFC/createDataInfo/DLPFC_neurons.mat').database;

Ziggy = load('/Users/tianwang/Documents/MATLAB/ChandLab/Ziggy_DLPFC/createDataInfo/DLPFC_neurons.mat').database;

T1 = struct2table(Tibs);
V1 = struct2table(Vinnie);
Z1 = struct2table(Ziggy);

c = [T1(:,1); V1(:,1); Z1(:,1)];

Channels = table2struct(c);


cnt = 1;


allAP = [];
allDepth = [];


for ii = 1:length(Channels)
    units = length(Channels(ii).channelID);
    
    channelId = Channels(ii).channelID;
    
    depth1Day = depth(ii) - (32-channelId)./10;
    AP1Day = AP(ii) + rand(units,1).*0.4-0.2;
    
    allDepth = [allDepth; depth1Day];
    allAP = [allAP; AP1Day];
        
    cnt = cnt+units;
    
end


%%
ES = allES(:,1:length(allAP));




%%
[choiceES, I] = sort(ES(2,:));

allAPc = allAP(I);
allDepthc = allDepth(I);


uniqueES = unique(choiceES);
% 
% normES = max((choiceES - uniqueES(2))./range(uniqueES), 0);

figure(1); hold on

for ii = 1:length(allAPc)
    
    if choiceES(ii) > uniqueES(2) & choiceES(ii) < uChoiceES(end - 6)
        plot(allAPc(ii), allDepthc(ii), '.', 'markersize', (choiceES(ii)-uniqueES(2)).*70, 'color', 'b');
    end
        
    
end
 
ylim([0 12])

set(gca, 'YDir','reverse')

title('choice')


%% 
[cxtES, I] = sort(ES(3,:));

allAPcxt = allAP(I);
allDepthcxt = allDepth(I);

uniqueES = unique(cxtES);
% 
% normES = max((cxtES - uniqueES(2))./range(uniqueES), 0);

figure(2); hold on

for ii = 1:length(allAPcxt)
    
    if cxtES(ii) > uniqueES(2) & cxtES(ii) < uCxtES(end - 6)
        plot(allAPcxt(ii), allDepthcxt(ii), '.', 'markersize', (cxtES(ii)-uniqueES(2)).*70, 'color', 'k');
    end
        
    
end
 
ylim([0 12])

set(gca, 'YDir','reverse')

title('cxt')


%% 
[colorES, I] = sort(ES(1,:));

allAPcol = allAP(I);
allDepthcol = allDepth(I);

uniqueES = unique(colorES);
% 
% normES = max((colorES - uniqueES(2))./range(uniqueES), 0);

figure(3); hold on

for ii = 1:length(allAPcol)
    
    if colorES(ii) > uniqueES(2) & colorES(ii) < uColorES(end - 6)
        plot(allAPcol(ii), allDepthcol(ii), '.', 'markersize', (colorES(ii)-uniqueES(2)).*70, 'color', 'm');
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
    

    
%%

% plot npix choice
figure(1); hold on


    for jj = 1:length(npixAP)
        choiceLoad1 = choiceLoad(jj+length(allAP));
        if (choiceLoad1 > uChoiceES(2))  & choiceLoad1 < uChoiceES(end - 6)
            plot(npixAP(jj), npixDepth(jj), '.', 'markersize', (choiceLoad1 - uChoiceES(2))*70, 'color', 'b');
        end
    end

ylim([0 12])
set(gca, 'YDir','reverse')

title('choice')

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig5_s/', 'choiceGradient_ES.eps']);


%%
% plot npix cxt


figure(2); hold on


    for jj = 1:length(npixAP)
        cxtLoad1 = cxtLoad(jj+length(allAP));
        
        if (cxtLoad1 > uCxtES(2)) 
            plot(npixAP(jj), npixDepth(jj), '.', 'markersize', (cxtLoad1 - uCxtES(2))*70, 'color', 'k');
        end
        
    end

ylim([0 12])
set(gca, 'YDir','reverse')

title('cxt')

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig5_s/', 'cxtGradient_ES.eps']);


%% plot npix color

figure(3); hold on


    for jj = 1:length(npixAP)
        
        colorLoad1 = colorLoad(jj+length(allAP));
     
       if (colorLoad1 > uColorES(2)) & colorLoad1 < uColorES(end - 6)
            plot(npixAP(jj), npixDepth(jj), '.', 'markersize', (colorLoad1 - uColorES(2))*70, 'color', 'm');
        end        
        
    end

ylim([0 12])
set(gca, 'YDir','reverse')

title('color')

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig5_s/', 'colorGradient_ES.eps']);

