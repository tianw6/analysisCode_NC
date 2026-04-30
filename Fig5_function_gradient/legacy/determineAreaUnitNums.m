%%%%%% This code determines the rough area each recorded unit belongs to

% Tibs v-probe: 3577
% Vinnie v-probe: 517: 
% Vinnie npix: 190; 
% Tibs npix pmd: 690

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
    
    
    % add 5 sessions of long shank
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

% save allLoads and positions

areaUnitNums = struct;
areaUnitNums.area8 = area8;
areaUnitNums.dlpfcD = dlpfcD;
areaUnitNums.dlpfcV = dlpfcV;
areaUnitNums.dlpfcA = dlpfcA;
areaUnitNums.pmd = pmd;

% save('areaUnitNums.mat', 'areaUnitNums')