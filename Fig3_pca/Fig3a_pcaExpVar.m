

clear; clc; close all

addpath('../utils/')


%% for dlpfc Data

allTime = -799:800;

tStart = -100;
tEnd = 300; 
tSelected = allTime > tStart & allTime <= tEnd;

time = allTime(tSelected);

%% load DLPFC data

a = load('../../analysisData_NC/Fig3/TiberiusNpix/DLPFCtotalDataframeC.mat').totalDataframe;

b = load('../../analysisData_NC/Fig3/TiberiusVprobe/totalDataframeC.mat').totalDataframe;

c = load('../../analysisData_NC/Fig3/VinnieNpix/DLPFCtotalDataframeC.mat').totalDataframe;

d = load('../../analysisData_NC/Fig3/VinnieVprobe/totalDataframeC.mat').totalDataframe;




FRpfc = [a(:,:,:,tSelected); b(:,:,:,tSelected); c(:,:,:,tSelected); d(:,:,:,tSelected)];


%% load pmd data

e = load('../../analysisData_NC/Fig3/TiberiusVprobe/PMDtotalDataframeC.mat').totalDataframe;

f = load('../../analysisData_NC/Fig3/OlafVprobe/PMDtotalDataframeC.mat').totalDataframe;

g = load('../../analysisData_NC/Fig3/TiberiusNpix/PMDtotalDataframeC.mat').totalDataframe;



FRpmd = [e(:,:,:,tSelected); f(:,:,:,tSelected); g(:,:,:,tSelected)];


%% calculated required dimensions to explain PCA 90% variance 


S = 50:150:1600;
 
DimV_sub  = computeDimVsNeurons(FRpfc, FRpmd, 1, S);   % subtract mean
DimV_raw  = computeDimVsNeurons(FRpfc, FRpmd, 0, S);   % don't subtract mean
 

%% Fig3a: plot dimensions required to explain 90% variance
figure;
 
ax1 = subplot(1,2,1); hold on;
errorbar(S, nanmean(DimV_sub(:,:,1)), nanstd(DimV_sub(:,:,1)));
errorbar(S, nanmean(DimV_sub(:,:,2)), nanstd(DimV_sub(:,:,2)));
xlabel('# units')
ylabel('dims')
title('with CI removal')

ax2 = subplot(1,2,2); hold on;
errorbar(S, nanmean(DimV_raw(:,:,1)), nanstd(DimV_raw(:,:,1)));
errorbar(S, nanmean(DimV_raw(:,:,2)), nanstd(DimV_raw(:,:,2)));
xlabel('# units')
ylabel('dims')
title('without CI removal')
legend('DLPFC', 'PMd')

%%

function DimV = computeDimVsNeurons(FRpfc, FRpmd, subtractMean, S)
    %   DimV = computeDimVsNeurons(FRpfc, FRpmd, subtractMean)
    %   subtractMean: 1 = subtract, 0 = don't subtract
    %   DimV: [100 x numel(S) x 2]  (dim 3: 1=DLPFC, 2=PMd)

    [processedFRpfc] = preprocess(FRpfc, subtractMean);
    [processedFRpmd] = preprocess(FRpmd, subtractMean);

    DimV = [];

    for j = 1:100
        fprintf('.');
        for cnt = 1:numel(S)
            ii = S(cnt);

            select = randsample(size(processedFRpfc,1), ii);
            [~,~,latent] = pca(processedFRpfc(select,:,:)');
            Vpfc = cumsum(latent(1:30)./sum(latent));
            DimV(j,cnt,1) = find(Vpfc > 0.9, 1, 'first');

            select = randsample(size(processedFRpmd,1), ii);
            [~,~,latent] = pca(processedFRpmd(select,:,:)');
            Vpmd = cumsum(latent(1:30)./sum(latent));
            DimV(j,cnt,2) = find(Vpmd > 0.9, 1, 'first');
        end
    end

end