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

load('/Users/tianwang/Documents/MATLAB/ChandLab/DLPFC_PMD/geometry/single_unit_mix_selectivity/ESresultsAll.mat');



%% 

thres = 0.01;

p_all = [];
cnt = 1;
for id = 1:length(results)
    temp = results(id).anovaResults;
    for idx = 1:length(temp)
        p_all(:,:,cnt) = temp(idx).anova2R;
        cnt = cnt+1;
    end
end


sigP = p_all < thres;

pmd = [size(sigP,3)-689:size(sigP,3)];
%% plot

t = -100:5:400;

figure('Position', [10 10 1400 600])

% area8 
anova8 = sigP(:,:,area8);
sigPer = (sum(anova8,3)./size(anova8,3));
subplot(2,4,3); hold on
plot(t, sigPer(1,:), 'm')
plot(t, sigPer(2,:), 'b')
plot(t, sigPer(3,:), 'k')

mixP = squeeze(sum(anova8,1) > 1);
plot(t, sum(mixP,2)./size(anova8,3), 'linewidth', 2);
title('area 8')
ylim([0 0.6])

% dlpfcD
anovaD = sigP(:,:,dlpfcD);
sigPer = (sum(anovaD,3)./size(anovaD,3));
subplot(2,4,2); hold on
plot(t, sigPer(1,:), 'm')
plot(t, sigPer(2,:), 'b')
plot(t, sigPer(3,:), 'k')

mixP = squeeze(sum(anovaD,1) > 1);
plot(t, sum(mixP,2)./size(anovaD,3), 'linewidth', 2);
title('dlpfcD')
ylim([0 0.6])

% dlpfcV
anovaV = sigP(:,:,dlpfcV);
sigPer = (sum(anovaV,3)./size(anovaV,3));
subplot(2,4,6); hold on
plot(t, sigPer(1,:), 'm')
plot(t, sigPer(2,:), 'b')
plot(t, sigPer(3,:), 'k')
mixP = squeeze(sum(anovaV,1) > 1);
plot(t, sum(mixP,2)./size(anovaV,3), 'linewidth', 2);
title('dlpfcV')
ylim([0 0.6])


% dlpfcA
anovaA = sigP(:,:,dlpfcA);
sigPer = (sum(anovaA,3)./size(anovaA,3));
subplot(2,4,1); hold on
plot(t, sigPer(1,:), 'm')
plot(t, sigPer(2,:), 'b')
plot(t, sigPer(3,:), 'k')
mixP = squeeze(sum(anovaA,1) > 1);
plot(t, sum(mixP,2)./size(anovaA,3), 'linewidth', 2);
title('dlpfcA')
ylim([0 0.6])

% pmd
anovaP = sigP(:,:,pmd);
sigPer = (sum(anovaP,3)./size(anovaP,3));
subplot(2,4,4); hold on
plot(t, sigPer(1,:), 'm')
plot(t, sigPer(2,:), 'b')
plot(t, sigPer(3,:), 'k')
mixP = squeeze(sum(anovaP,1) > 1);
plot(t, sum(mixP,2)./size(anovaP,3), 'linewidth', 2);
title('pmd')
ylim([0 0.6])




