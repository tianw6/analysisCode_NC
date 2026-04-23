% created by Tian on Jun. 20th 
% plot area-averaged spectrolaminar motif
clear
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

load('LFPdataAll.mat');
LFP_V = load('LFPdataAll_V.mat').LFPdataAll;
LFP_N = load('LFPdataAll_npix.mat').LFPdataAll;
% one long shank npix
LFP_N1 = load('LFPdataAll_npix1.mat').LFPdataAll;
LFP_PMD = load('LFPdataAll_npixPMD.mat').LFPdataAll;


% neuropixel lfp: chooose every 5 columes to match vprobe
LFP_N = LFP_N(:,1:5:end,:);
LFP_N1 = LFP_N1(:,1:5:end,:);


%% 

area8 = NaN(200, 64, size(LFPdataAll, 3));
dlpfcD = NaN(200, 64, size(LFPdataAll, 3));
dlpfcV = NaN(200, 100, size(LFPdataAll, 3));
dlpfcA = NaN(200, 64, size(LFPdataAll, 3));
pmd = NaN(100,384,size(LFPdataAll, 3));


channel = data{:,2};
areaUp = data{:,3};
areaDown = data{:,4};
bound = data{:,8};
boundDown = data{:,9};


%% npix pmd
cnt = 1;
temp = [];

for ii = length(channel) - size(LFP_PMD,1)+1:length(channel)
    if (areaUp(ii) == 5 & channel(ii) == 384 & ~isnan(bound(ii)))
    
        temp = squeeze(LFP_PMD(ii  - length(channel) + size(LFP_PMD,1),:,:));

        cRange  = (192 - bound(ii)) + 1:  (192 - bound(ii)) + 192;
        pmd(cnt, cRange, :) = temp;
        cnt = cnt+1;
    end
    
end

%% 8AD
cnt = 1;
temp = [];

for ii = 1:13
    if (areaUp(ii) == 4 & channel(ii) == 32 & ~isnan(bound(ii)))
    
        temp = LFPdataAll(ii,:,:);

        cRange  = (33 - bound(ii)) + 1:  (33 - bound(ii)) + 32;
        area8(cnt, cRange, :) = temp;
        cnt = cnt+1;
    end
    
end
 

%% DLPFCD
cnt = 1;
temp = [];

for ii = 1:size(LFPdataAll, 1)
    
    if (areaUp(ii) == 3 & channel(ii) == 32 & ~isnan(bound(ii)))
        temp = LFPdataAll(ii,:,:);
        cRange  = (33 - bound(ii)) + 1:  (33 - bound(ii)) + 32;

        dlpfcD(cnt, cRange, :) = temp;
        cnt = cnt+1;
    end
    
end

cnt = cnt+1;

% add npix 
for ii = 1:size(LFP_N,1)
    if (areaUp(ii+185) ==3 & channel(ii+185) == 384 & ~isnan(bound(ii + 185)))
    
        temp = squeeze(LFP_N(ii,:,:));
        
        l4 = floor(bound(ii + 185)/5) + 1;
        
        cRange  = (33 - l4) + 1:  (33 - l4) + size(temp,1);

        dlpfcD(cnt, cRange, :) = temp;
        cnt = cnt+1;
    end
end

%% DLPFCV

cnt3 = 1;
temp = [];

for ii = 1:size(LFPdataAll, 1)
    
    if (areaUp(ii) == 2 & channel(ii) == 32 & ~isnan(bound(ii)))
        temp = LFPdataAll(ii,:,:);
        cRange  = (50 - bound(ii)) + 1:  (50 - bound(ii)) + 32;

        dlpfcV(cnt3, cRange, :) = temp;
        cnt3 = cnt3+1;
    end
    
end

cnt3 = cnt3+1;

% add npix 
for ii = 1:size(LFP_N,1)
    if (areaUp(ii+185) == 2 & channel(ii+185) == 384 & ~isnan(bound(ii+185)))
    
        temp = squeeze(LFP_N(ii,:,:));
        
        l4 = floor(bound(ii + 185)/5) + 1;
        
        cRange  = (50 - l4) + 1:  (50 - l4) + size(temp,1);

        dlpfcV(cnt3, cRange, :) = temp;
        cnt3 = cnt3+1;
    end
end

%% problematic, needs to fix

cnt = 100;
temp = [];

for ii = 1:size(LFPdataAll, 1)
    
    if (channel(ii) ~= 32 & areaUp(ii) == 3 & areaDown(ii) == 2 )
        
        channel1 = channel(ii);
        temp = squeeze(LFPdataAll(ii,:,:));
        
        
        if (bound(ii) > 1)

            temp1 = temp(1:channel(ii),:);
            cRange1  = (33 - bound(ii)) + 1:  (33 - bound(ii)) + size(temp1,1);
            dlpfcD(cnt, cRange1, :) = temp1;
            cnt = cnt+1;
        end
        
        if (boundDown(ii) < 32)
            
            temp2 = temp(channel(ii)+1:32,:);
            cRange2  = (50 - boundDown(ii) + channel1) + 1:  (50 - boundDown(ii)+ channel1) + + size(temp2,1);
            dlpfcV(cnt, cRange2, :) = temp2;  
            
%             figure; imagesc(temp) 
%             hold on 
%             yline(channel(ii))
%             figure; imagesc(temp2)
%            
%             figure; imagesc(squeeze(dlpfcV(cnt, :, :)))
%             pause; 
            
            cnt = cnt+1;

        end
        

        

        
    end
    
end




%% DLPFCA


cnt = 1;
temp = [];
for ii = size(LFPdataAll, 1)+ 1:size(LFPdataAll, 1) + size(LFP_V,1)
    if (areaUp(ii) == 1 & channel(ii) == 32 & ~isnan(bound(ii)))
    
        temp = LFP_V(ii - size(LFPdataAll, 1),:,:);

        cRange  = (33 - bound(ii)) + 1:  (33 - bound(ii)) + 32;
        dlpfcA(cnt, cRange, :) = temp;
        cnt = cnt+1;
    end
    
end

%% 
% ix = [[1:54 75:113 127:150]];
ix = [[1:58 63:118 122:150]];

ix2 = [20:54];
ix3 = [25:80];
ix4 = [100:340];
figure; 
area8M = squeeze(nanmean(area8(:,ix2,ix),1));
imagesc(area8M)
caxis([0.4 0.9]);
colorbar
% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig5/', 'area8', '.eps']);



figure; 
dlpfcDM = squeeze(nanmean(dlpfcD(:,ix2,ix),1));
imagesc(dlpfcDM)
caxis([0.4 0.9]);
colorbar
% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig5/', '46D', '.eps']);

figure; 
dlpfcVM = squeeze(nanmean(dlpfcV(:,ix3,ix),1));
imagesc(dlpfcVM)
caxis([0.4 0.9]);
colorbar
% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig5/', '46V', '.eps']);

figure; 
dlpfcAM = squeeze(nanmean(dlpfcA(:,ix2,ix),1));
imagesc(dlpfcAM)
caxis([0.4 0.9]);
colorbar
% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig5/', '46A', '.eps']);


figure; 
pmdM = squeeze(nanmean(pmd(:,ix4,:),1));
imagesc(pmdM)
caxis([0.4 0.9]);
colorbar
ylim([1 230])
% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig5/', 'pmd', '.eps']);

%% 


%% 

