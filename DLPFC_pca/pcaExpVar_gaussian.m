%% created by Tian on May 29th 

% calculated the DLPFC and PMd variance explaind by pca 
% subsample DLPFC units. Use gaussian smoothed data
clear; clc; close all

addpath('../utils/')


%% for dlpfc Data

allTime = -799:800;

tStart = -100;
tEnd = 300; 
tSelected = allTime > tStart & allTime <= tEnd;

time = allTime(tSelected);

%%

% for DLPFC data
a = load('/Volumes/TianSSD/TiberiusNpix/checkerboardAligned/DLPFCtotalDataframeC.mat').totalDataframe;

b = load('/Volumes/TianSSD/TiberiusDLPFCforDPCA/checkerboardAligned/totalDataframeC.mat').totalDataframe;

c = load('/Volumes/TianSSD/VinnieNpix/checkerboardAligned/DLPFCtotalDataframeC.mat').totalDataframe;

d = load('/Volumes/ZiggySSD/VinnieDLPFCforDPCA/checkerboardAligned/totalDataframeC.mat').totalDataframe;


FRpfc = [a(:,:,:,tSelected); b(:,:,:,tSelected); c(:,:,:,tSelected); d(:,:,:,tSelected)];


%% for pmd data
e = load('/Volumes/TianSSD/PMd/PMdData/Tiberius/PMDtotalDataframeC.mat').totalDataframe;

f = load('/Volumes/TianSSD/PMd/PMdData/Olaf/PMDtotalDataframeC.mat').totalDataframe;

g = load('/Volumes/TianSSD/TiberiusNpix/checkerboardAligned/PMDtotalDataframeC.mat').totalDataframe;

FRpmd = [e(:,:,:,tSelected); f(:,:,:,tSelected); g(:,:,:,tSelected)];


%%
% don't subtract the aveage FR
[processedFRpfc] = preprocess(FRpfc, 1);
[processedFRpmd] = preprocess(FRpmd, 1);



%%

DLPFClatentAll = [];
PMdlatentAll = [];
cnt = 1;
DimV = [];
% S = floor(10.^(1.5:0.2:3.2));
S = 50:150:1600;
for j=1:100
    
    cnt = 1;
    fprintf('.');
    
    for ii = S
        
        select = randsample(size(processedFRpfc,1), ii);
        
        sFRpfc = processedFRpfc(select,:,:);
        
        % pca
        test = sFRpfc';
        
        
        [coeff, score, latent] = pca(test);
        
        Vpfc =  cumsum(latent(1:30)./sum(latent));;
        DLPFClatentAll(j,cnt,:) = Vpfc;
        
        
           
        select = randsample(size(processedFRpmd,1), ii);
        
        sFRpmd = processedFRpmd(select,:,:);
        
        test = sFRpmd';
        
        [coeff, score, PMDlatent] = pca(test);
         Vpmd = cumsum(PMDlatent(1:30)./sum(PMDlatent));
         PMdlatentAll(j,cnt,:) = Vpmd;
        
        
        DimV(j,cnt,1) = find(Vpfc > 0.9,1,'first');
        DimV(j,cnt,2) = find(Vpmd > 0.9,1,'first');
        cnt = cnt + 1;
        
        
        
    end
    
end


%% 

figure; hold on
errorbar(S, nanmean(DimV(:,:,1)), nanstd(DimV(:,:,1)))
errorbar(S, nanmean(DimV(:,:,2)), nanstd(DimV(:,:,2)))

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig3/', 'dimensions_CI', '.eps']);
%% sign rank test
p = [];
for ii = 1:size(DimV,2)
    p(ii) = signrank(squeeze(DimV(:,ii,1)), squeeze(DimV(:,ii,2)));
    
end



