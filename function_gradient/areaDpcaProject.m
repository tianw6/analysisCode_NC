% Tibs v-probe: 3577
% Vinnie v-probe: 517: 
% Vinnie npix: 190; 
% Tibs npix pmd: 690

% a = xlsread('insert_locations.xlsx');

% grid 6: 8.5mm; grid 8:12mm  

clear;clc 

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

monkey = data{:,6};    % 1st column strings

channel = data{:,2};
areaUp = data{:,3};
areaDown = data{:,4};
bound = data{:,8};
boundDown = data{:,9};



%% 

area8 = [];
dlpfcD = [];
dlpfcV = [];
dlpfcA = [];
pmd = [];


Tibs = load('/Users/tianwang/Documents/MATLAB/ChandLab/DLPFC_analysis/createDataInfo/DLPFC_neurons.mat').database;
Ziggy = load('/Users/tianwang/Documents/MATLAB/ChandLab/Ziggy_DLPFC/createDataInfo/DLPFC_neurons.mat').database;
Vinnie = load('/Users/tianwang/Documents/MATLAB/ChandLab/Vinnie_DLPFC/createDataInfo/DLPFC_neurons.mat').database;


T1 = struct2table(Tibs);
V1 = struct2table(Vinnie);
Z1 = struct2table(Ziggy);

c = [T1(:,1); V1(:,1); Z1(:,1)];

Channels = table2struct(c);

cnt = 1;

% area 8 unit num
for ii = 1:length(Channels)
    
    dur = length(Channels(ii).channelID); 
    
    if (areaUp(ii) == 4 & channel(ii) == 32)
        area8 = [area8 (cnt: cnt + dur - 1)]; 
    end

    cnt = cnt + dur;
end

% dlpfcD unit num

cnt = 1;
for ii = 1:length(Channels)
    
    dur = length(Channels(ii).channelID); 
    
    if (areaUp(ii) == 3 & channel(ii) == 32 & ~isnan(bound(ii)))
        dlpfcD = [dlpfcD (cnt: cnt + dur - 1)]; 
    end

    cnt = cnt + dur;
end


% dlpfcV unit num
cnt = 1;
for ii = 1:length(Channels)
    
    dur = length(Channels(ii).channelID); 
    
    if (areaUp(ii) == 2 & channel(ii) == 32 & ~isnan(bound(ii)))
        dlpfcV = [dlpfcV (cnt: cnt + dur - 1)]; 
    end

    cnt = cnt + dur;
end


% dlpfcA unit num

cnt = 1;
for ii = 1:length(Channels)
    
    dur = length(Channels(ii).channelID); 
    
    if (areaUp(ii) == 1)
        dlpfcA = [dlpfcA (cnt: cnt + dur - 1)]; 
    end

    cnt = cnt + dur;
end

%% vprobe session with half dlpfcD half dlpfcV

cnt = 1;

for ii = 1:length(Tibs)

    channelID = Channels(ii).channelID; 
    dur = length(channelID); 

    temp = cnt : cnt + dur - 1;
    if (channel(ii) ~= 32 & areaUp(ii) == 3 & areaDown(ii) == 2 )
        
        thresh = channel(ii);
        
        dlpfcD = [dlpfcD temp(channelID <= thresh)];
        
        dlpfcV = [dlpfcV temp(channelID > thresh)];

    end
    
    cnt = cnt + dur;
    
    
end


%% add npix 

Vnpix = dir('/Volumes/TianSSD/VinnieNpix/waveforms/*.mat');

TnpixPFC = dir('/Volumes/TianSSD/TiberiusNpix/waveforms/*DLPFC*.mat');

TnpixPMD = dir('/Volumes/TianSSD/TiberiusNpix/waveforms/*PMD*.mat');


npix = [Vnpix; TnpixPFC; TnpixPMD];

% add vinnie
cnt = 3577+517+394+1;

for ii = 1:length(npix)
    
    npix1Day = load([npix(ii).folder '/' npix(ii).name]).goodUnits;
    
    dur = length(npix1Day);
    
    if (areaUp(ii + 181) == 1 )
        dlpfcA = [dlpfcA (cnt: cnt + dur - 1)]; 
    end
    
    if (areaUp(ii + 181) == 2 )
        dlpfcV = [dlpfcV (cnt: cnt + dur - 1)]; 
    end  
    
    if (areaUp(ii + 181) == 3 & channel(ii + 181) == 384)
        dlpfcD = [dlpfcD (cnt: cnt + dur - 1)]; 
        length((cnt: cnt + dur - 1))
        ii
    end    

    if (areaUp(ii + 181) == 5 )
        pmd = [pmd (cnt: cnt + dur - 1)]; 
    end 
    
    
    % add 5 sessions of 
    if (channel(ii+181) ~= 384 & areaUp(ii+181) == 3 & areaDown(ii+181) == 2)
        temp = cnt: cnt  + dur - 1;
        rawThresh = channel(ii+181);
       
        channelID = [npix1Day.depth];
        depth1 = 7680:-20:0;
        thresh = depth1(rawThresh);
        
        dlpfcD = [dlpfcD temp(channelID >= thresh)];
        length(temp(channelID >= thresh))
        ii
        
        dlpfcV = [dlpfcV temp(channelID < thresh)];        
    end
    
    
    cnt = cnt + dur;
    
end



%% 

a = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/checkerboardAligned/allBinFRvprobe.mat').allBinFR;
b = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Vinnie/checkerboardAligned/allBinFRvprobe.mat').allBinFR;
c = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Ziggy/checkerboardAligned/allBinFRvprobe.mat').allBinFR;

d = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Vinnie/checkerboardAligned/allBinFRnpix.mat').allBinFR;
e = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/checkerboardAligned/allBinFRnpix.mat').allBinFR;
f = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/checkerboardAligned/allBinFRnpixPMD.mat').allBinFR;

binFRpfc = [a,b,c, d,e, f];

allTime = binFRpfc(1).time;

tStart = -100;
tEnd = 400; 
tSelected = allTime >= tStart & allTime <= tEnd;

time = allTime(tSelected);

for ii = 1:length(binFRpfc)
    
    binFRpfc(ii).trials = binFRpfc(ii).trials(:,:,tSelected);
    binFRpfc(ii).time = binFRpfc(ii).time(tSelected);

end

%% 
normalizeData = 1;
[firingRatesAverage] = prepareFRaverage(binFRpfc, normalizeData);
%% 

combinedParams = {{1, [1 3]}, {2, [2 3]}, {3}, {[1 2], [1 2 3]}};
margNames = {'Stimulus', 'Decision', 'Condition-independent', 'S/D Interaction'};

% margNames = {'SC', 'Configuration', 'Condition-independent', 'C/D Interaction'};

margColours = [23 100 171; 187 20 25; 150 150 150; 114 97 171]/256;

% time of combined T and C data
timeEvents = [0];


%%

tic
[W,V,whichMarg] = dpca(firingRatesAverage, 30, ...
    'combinedParams', combinedParams, 'lambda', 1e-9);
toc

explVar = dpca_explainedVariance(firingRatesAverage, W, V, ...
    'combinedParams', combinedParams);

z = dpca_plot(firingRatesAverage, W, V, @dpca_plot_default, ...
    'explainedVar', explVar, ...
    'marginalizationNames', margNames, ...
    'marginalizationColours', margColours, ...
    'whichMarg', whichMarg,                 ...
    'time', time,                        ...
    'timeEvents', timeEvents,               ...
    'timeMarginalization', 3, ...
    'legendSubplot', 16, ...
    'numCompToShow', 20);

%%
choiceLoad = V(:,3);
cxtLoad = V(:,5);
colorLoad = V(:,7);

allLoad = V(:,[3,5,7]);

%% 

d1 = 1;
d2 = 2;

figure('Position', [10 10 1400 600])
% area 8
c22 = cov(allLoad(area8,[d1 d2]));
subplot(2,4,3); hold on
plot(allLoad(area8,d1), allLoad(area8,d2), 'k.')
[~, a8] = error_ellipse(c22,'conf',0.99);
ylim([-0.1 0.1])
xlim([-0.1 0.1])
title('area 8')


% dlpfcD
c22 = cov(allLoad(dlpfcD,[d1 d2]));
subplot(2,4,2); hold on
plot(allLoad(dlpfcD,d1), allLoad(dlpfcD,d2), 'k.')
[~, aD] = error_ellipse(c22,'conf',0.99);
ylim([-0.1 0.1])
xlim([-0.1 0.1])
title('dlpfcD')

% dlpfcV
c22 = cov(allLoad(dlpfcV,[d1 d2]));
subplot(2,4,6); hold on
plot(allLoad(dlpfcV,d1), allLoad(dlpfcV,d2), 'k.')
[~, aV] = error_ellipse(c22,'conf',0.99);
ylim([-0.1 0.1])
xlim([-0.1 0.1])
xlabel('cxt')
ylabel('color')
title('dlpfcV')

% dlpfcA
c22 = cov(allLoad(dlpfcA,[d1 d2]));
subplot(2,4,1); hold on
plot(allLoad(dlpfcA,d1), allLoad(dlpfcA,d2), 'k.')
[~, aA] = error_ellipse(c22,'conf',0.99);
ylim([-0.1 0.1])
xlim([-0.1 0.1])
title('dlpfcA')

% pmd
c22 = cov(allLoad(pmd,[d1 d2]));
subplot(2,4,4); hold on
plot(allLoad(pmd,d1), allLoad(pmd,d2), 'k.')
[~, aP] = error_ellipse(c22,'conf',0.99);
ylim([-0.1 0.1])
xlim([-0.1 0.1])
title('pmd')

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig5_s/', 'errorEllipse_dircxt', '.eps']);


% calculate relative area; aV is 1

a8/aV
aD/aV
aA/aV
aP/aV


%% save allLoads and positions

areaUnitNums = struct;
areaUnitNums.area8 = area8;
areaUnitNums.dlpfcD = dlpfcD;
areaUnitNums.dlpfcV = dlpfcV;
areaUnitNums.dlpfcA = dlpfcA;
areaUnitNums.pmd = pmd;


%% bar graph

load8 = abs(allLoad(area8,:));
loadD = abs(allLoad(dlpfcD,:));
loadV = abs(allLoad(dlpfcV,:));
loadA = abs(allLoad(dlpfcA,:));
loadP = abs(allLoad(pmd,:));

std8 = std(load8,0, 1)./sqrt(size(load8,1));
stdD = std(loadD,0, 1)./sqrt(size(loadD,1));
stdV = std(loadV,0, 1)./sqrt(size(loadV,1));
stdA = std(loadA,0, 1)./sqrt(size(loadA,1));
stdP = std(loadP,0, 1)./sqrt(size(loadP,1));


y_all = [mean(loadA,1); mean(loadV,1); mean(loadD,1); mean(load8,1); mean(loadP,1)];
dataCI_all = [stdA; stdV; stdD; std8; stdP];



figure('position', [1000,1000,600,300]); hold on
plotBar(y_all(:,1), dataCI_all(:,1))
% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig5/', 'loadingChoice_pn', '.eps']);

figure('position', [1000,1000,600,300]); hold on
plotBar(y_all(:,2), dataCI_all(:,2))
% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig5/', 'loadingInter_pn', '.eps']);

figure('position', [1000,1000,600,300]); hold on
plotBar(y_all(:,3), dataCI_all(:,3))
% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig5/', 'loadingColor_pn', '.eps']);


%% mixed selectivity index 

vlRatio8 = calVLRatio(load8);
vlRatioD = calVLRatio(loadD);
vlRatioV = calVLRatio(loadV);
vlRatioA = calVLRatio(loadA);
vlRatioP = calVLRatio(loadP);

std8 = std(vlRatio8,0, 1)./sqrt(size(vlRatio8,1));
stdD = std(vlRatioD,0, 1)./sqrt(size(vlRatioD,1));
stdV = std(vlRatioV,0, 1)./sqrt(size(vlRatioV,1));
stdA = std(vlRatioA,0, 1)./sqrt(size(vlRatioA,1));
stdP = std(vlRatioP,0, 1)./sqrt(size(vlRatioP,1));


y_all = [mean(vlRatioA,1); mean(vlRatioV,1); mean(vlRatioD,1); mean(vlRatio8,1); mean(vlRatioP,1)];
dataCI_all = [stdA; stdV; stdD; std8; stdP];


figure('position', [1000,1000,600,300]); hold on
plotBar(y_all, dataCI_all)
% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig5/', 'loadingMix_pn', '.eps']);



function vlRatio = calVLRatio(load)


    maxLoad = max(load,[],2);

    volV = load(:,1).*load(:,2).*load(:,3);

    vlRatio = (volV./maxLoad);

end