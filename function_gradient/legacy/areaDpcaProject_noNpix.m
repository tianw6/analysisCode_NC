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
a = struct2table(Tibs);
Channels = table2struct(a(:,1));

cnt = 1;

% area 8 unit num
for ii = 1:length(Tibs)
    
    dur = length(Channels(ii).channelID); 
    
    if (areaUp(ii) == 4 & channel(ii) == 32 & ~isnan(bound(ii)))
        area8 = [area8 (cnt: cnt + dur - 1)]; 
    end

    cnt = cnt + dur;
end

    
% dlpfcD unit num

cnt = 1;
for ii = 1:length(Tibs)
    
    dur = length(Channels(ii).channelID); 
    
    if (areaUp(ii) == 3 & channel(ii) == 32 & ~isnan(bound(ii)))
        dlpfcD = [dlpfcD (cnt: cnt + dur - 1)]; 
    end

    cnt = cnt + dur;
end


% dlpfcV unit num
cnt = 1;
for ii = 1:length(Tibs)
    
    dur = length(Channels(ii).channelID); 
    
    if (areaUp(ii) == 2 & channel(ii) == 32 & ~isnan(bound(ii)))
        dlpfcV = [dlpfcV (cnt: cnt + dur - 1)]; 
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

% dlpfcA
dlpfcA = 3578:3578+707-1;


%% 

a = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/checkerboardAligned/allBinFRvprobe.mat').allBinFR;
b = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Vinnie/checkerboardAligned/allBinFRvprobe.mat').allBinFR;
% c = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Ziggy/checkerboardAligned/allBinFRvprobe.mat').allBinFR;

d = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Vinnie/checkerboardAligned/allBinFRnpix.mat').allBinFR;
% e = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/checkerboardAligned/allBinFRnpix.mat').allBinFR;
f = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/checkerboardAligned/allBinFRnpixPMD.mat').allBinFR;

binFRpfc = [a,b,d,f];

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
removeCI = 0;
[processedFRpfc, firingRatesAverage] = prepareData(binFRpfc,removeCI);

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

pmd = size(V,1) - 690 : size(V, 1);
%% 

d1 = 2;
d2 = 3;

figure('Position', [10 10 1400 600])
% area 8
c22 = cov(allLoad(area8,[d1 d2]));
subplot(2,4,3); hold on
plot(allLoad(area8,d1), allLoad(area8,d2), 'k.')
error_ellipse(c22,'conf',0.99);
ylim([-0.1 0.1])
xlim([-0.1 0.1])
title('area 8')


% dlpfcD
c22 = cov(allLoad(dlpfcD,[d1 d2]));
subplot(2,4,2); hold on
plot(allLoad(dlpfcD,d1), allLoad(dlpfcD,d2), 'k.')
error_ellipse(c22,'conf',0.99);
ylim([-0.1 0.1])
xlim([-0.1 0.1])
title('dlpfcD')

% dlpfcV
c22 = cov(allLoad(dlpfcV,[d1 d2]));
subplot(2,4,6); hold on
plot(allLoad(dlpfcV,d1), allLoad(dlpfcV,d2), 'k.')
error_ellipse(c22,'conf',0.99);
ylim([-0.1 0.1])
xlim([-0.1 0.1])
xlabel('cxt')
ylabel('color')
title('dlpfcV')

% dlpfcA
c22 = cov(allLoad(dlpfcA,[d1 d2]));
subplot(2,4,1); hold on
plot(allLoad(dlpfcA,d1), allLoad(dlpfcA,d2), 'k.')
error_ellipse(c22,'conf',0.99);
ylim([-0.1 0.1])
xlim([-0.1 0.1])
title('dlpfcA')

% pmd
c22 = cov(allLoad(pmd,[d1 d2]));
subplot(2,4,4); hold on
plot(allLoad(pmd,d1), allLoad(pmd,d2), 'k.')
error_ellipse(c22,'conf',0.99);
ylim([-0.1 0.1])
xlim([-0.1 0.1])
title('pmd')
