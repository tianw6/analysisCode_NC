%% created by Tina on May 29th 

% combine pfc and pmd data and do pca together

clear; clc; close all

addpath('../../utils/')


%% load dlpfc Data
a = load('../../../analysisData_NC/Fig4/Tiberius/checkerboardAligned/allBinFRnpix.mat').allBinFR;
b = load('../../../analysisData_NC/Fig4/Vinnie/checkerboardAligned/allBinFRnpix.mat').allBinFR;
c = load('../../../analysisData_NC/Fig4/Tiberius/checkerboardAligned/allBinFRvprobe.mat').allBinFR;
d = load('../../../analysisData_NC/Fig4/Vinnie/checkerboardAligned/allBinFRvprobe.mat').allBinFR;

binFRpfc = [c,a,d,b];

%% load pmd data
a = load('../../../analysisData_NC/Fig4/Tiberius/checkerboardAligned/allBinFRnpixPMD.mat').allBinFR;
b = load('../../../analysisData_NC/Fig4/Tiberius/checkerboardAligned/allBinFRvprobePMD.mat').allBinFR;
c = load('../../../analysisData_NC/Fig4/Olaf/checkerboardAligned/allBinFRvprobePMD.mat').allBinFR;


binFRpmd = [a b c];

%%

allTime = binFRpfc(1).time;

tStart = -100;
tEnd = 300; 
tSelected = allTime >= tStart & allTime <= tEnd;

time = allTime(tSelected);



%% 


for ii = 1:length(binFRpfc)
    
    binFRpfc(ii).trials = binFRpfc(ii).trials(:,:,tSelected);
    binFRpfc(ii).time = binFRpfc(ii).time(tSelected);

end

for ii = 1:length(binFRpmd)
    

    binFRpmd(ii).trials = binFRpmd(ii).trials(:,:,tSelected);
    binFRpmd(ii).time = binFRpmd(ii).time(tSelected);
end



%%
% don't subtract the aveage FR
subtractCI = 0;
[processedFRpfc, ~] = prepareData(binFRpfc, subtractCI);
[processedFRpmd, ~] = prepareData(binFRpmd, subtractCI);


%%
dims = 1:10;
distResultPFC = [];

for ii = 1:100
    
    % subselect dlpfc units to be same number as pmd
    select = randsample(size(processedFRpfc, 1), size(processedFRpmd, 1));

    sFRpfc = processedFRpfc(select,:,:);
    
    X = [sFRpfc; processedFRpmd];
    %% pca
    test = X';


    [coeff, score, latent] = pca(test);



    Zpfc = coeff(1:size(sFRpfc,1),:)'*sFRpfc;
    Zpmd = coeff(size(sFRpfc,1) + 1:end,:)'*processedFRpmd;


%%

    m = length(unique(binFRpfc(1).taskLabels));
    t = size(sFRpfc,2)/m;

    orthFpfc = reshape(Zpfc, [size(Zpfc,1),t,m]);
    orthFpmd = reshape(Zpmd, [size(Zpmd,1),t,m]);


    %% distance analysis pfc (choose first 10 dimension)

    for timePt = 1:size(orthFpfc,2)
        t = time(timePt);

        TCdistV1 = orthFpfc(dims,timePt, 1) - orthFpfc(dims,timePt, 4);
        TCdistV2 = orthFpfc(dims,timePt, 2) - orthFpfc(dims,timePt, 3);

        T1 = sqrt(sum(TCdistV1.^2));
        T2 = sqrt(sum(TCdistV2.^2));
        T3 = .5*(T1+T2);



        CdistV = mean(orthFpfc(dims,timePt, [1 2]),3) - mean(orthFpfc(dims,timePt, [3 4]),3);
        ChdistV = mean(orthFpfc(dims,timePt, [1 3]),3) - mean(orthFpfc(dims,timePt, [2 4]),3);

    % 
        TargDistV = mean(orthFpfc(dims,timePt, [1 4]),3) - mean(orthFpfc(dims,timePt, [2 3]),3);

        colorDist = sqrt(sum(CdistV.^2));
        choiceDist = sqrt(sum(ChdistV.^2));
        cxtDist = sqrt(sum(TargDistV.^2));

        distResultPFC(timePt, 1, ii) = cxtDist;
        distResultPFC(timePt, 2,ii) = colorDist;
        distResultPFC(timePt, 3,ii) = choiceDist;
        distResultPFC(timePt, 4,ii) = T3;

    end




    % distance analysis pmd (choose first 10 dimension)



    fprintf('shuffle %d finished\n', ii);

end



%%
distResultPMD = [];
for timePt = 1:size(orthFpmd,2)
    t = time(timePt);

    TCdistV1 = orthFpmd(dims,timePt, 1) - orthFpmd(dims,timePt, 4);
    TCdistV2 = orthFpmd(dims,timePt, 2) - orthFpmd(dims,timePt, 3);

    T1 = sqrt(sum(TCdistV1.^2));
    T2 = sqrt(sum(TCdistV2.^2));
    T3 = .5*(T1+T2);

    CdistV = mean(orthFpmd(dims,timePt, [1 2]),3) - mean(orthFpmd(dims,timePt, [3 4]),3);
    ChdistV = mean(orthFpmd(dims,timePt, [1 3]),3) - mean(orthFpmd(dims,timePt, [2 4]),3);

% 
    TargDistV = mean(orthFpmd(dims,timePt, [1 4]),3) - mean(orthFpmd(dims,timePt, [2 3]),3);

    colorDist = sqrt(sum(CdistV.^2));
    choiceDist = sqrt(sum(ChdistV.^2));
    cxtDist = sqrt(sum(TargDistV.^2));

    distResultPMD(timePt, 1) = cxtDist;
    distResultPMD(timePt, 2) = colorDist;
    distResultPMD(timePt, 3) = choiceDist;
    distResultPMD(timePt, 4) = T3;

end




% distResult = mean(distResultPFC,3);
% 
% figure; hold on
% plot(time, distResult(:,1), 'k')
% plot(time, distResult(:,2), 'm')
% plot(time, distResult(:,3), 'b')
% plot(time, distResult(:,4), 'r')
% 
% plot(time, distResultPMD(:,1), 'k')
% plot(time, distResultPMD(:,2), 'm')
% plot(time, distResultPMD(:,3), 'b')
% plot(time, distResultPMD(:,4), 'r')

%%

a = figure('Position', [20 20 1200 500]);

options.handle = gcf;
options.error = 'std';
options.alpha      = 0.5;
options.line_width = 1;
options.x_axis = time;

options.color_area = [100 100 100]./255;    % black theme
options.color_line = [0 0 0]./255;
subplot(311);

plot_areaerrorbar(squeeze(distResultPFC(:,1,:))', options)

options.color_area = [255 0 255]./255;    % Orange theme
options.color_line = [255 0 255]./255;
subplot(312);

plot_areaerrorbar(squeeze(distResultPFC(:,2,:))', options)

subplot(313);

options.color_area = [0 0 255]./255;    % Orange theme
options.color_line = [0 0 255]./255;
plot_areaerrorbar(squeeze(distResultPFC(:,3,:))', options)

options.color_area = [255 0 0]./255;    % Orange theme
options.color_line = [255 0 0]./255;
plot_areaerrorbar(squeeze(distResultPFC(:,4,:))', options)

subplot(311);
plot(time, distResultPMD(:,1), 'k')

subplot(312);
plot(time, distResultPMD(:,2), 'm')

subplot(313);
plot(time, distResultPMD(:,3), 'b')
plot(time, distResultPMD(:,4), 'r')

xlim([-50 300])
ylim([0 4])

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig4/geometry/', 'pfcpmdDistanceShuffle', '.eps']);

%% plot coeff(loadings) of each unit on pc axis 1 and 2


plot(coeff(5500:end,1), coeff(5500:end,2),'k.')
hold on
plot(coeff(1:1500,1), coeff(1:1500,2),'m.')
plot(coeff(1500:4800,1), coeff(1500:4800,2),'c.')
plot(coeff(4800:5500,1), coeff(4800:5500,2),'b.')



