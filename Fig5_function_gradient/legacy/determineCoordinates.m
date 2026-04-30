% this code determines each recording's AP and depth from dura 

% calculate functional gradients with dpca 


% clear; clc

addpath('/Users/tianwang/Documents/MATLAB/ChandLab/DLPFC_analysis/createDataInfo/');
% grid 6: 8.5mm; grid 8:12mm  

% grid 7: 10.25mm, AP: 32
% anterior edge of burrhole 4: AP: 35.6
% posterior edge of burrhole 2: AP: 27

% burrhole 2: 30-27 (12.75-15.5)
% burrhole 3: AP: 33-30 (9.75-12.75)
% burrhole 4: 35.6-33 (5.5-8.5)

% burrhole 2: 14
% burrhole 3: 11.25  (assume posterior edge of burrhole 3 (~12.5) as end of principal sculus)
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




%% determine AP of each vprobe unit


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

endPSAP = 12.5;


%% determine depth of each vprobe unit


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


%% 


Vnpix = dir('/Volumes/TianSSD/VinnieNpix/waveforms/*.mat');

TnpixPFC = dir('/Volumes/TianSSD/TiberiusNpix/waveforms/*DLPFC*.mat');

TnpixPMD = dir('/Volumes/TianSSD/TiberiusNpix/waveforms/*PMD*.mat');

npix = [Vnpix; TnpixPFC; TnpixPMD];

%% determine AP and depth of each npix unit
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

AP = [allAP; npixAP];
Depth = [allDepth; npixDepth];
X = [AP, Depth];

% save('coordinates.mat', 'X')