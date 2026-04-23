%% created by Tina on May 27th 

clear; clc; close all

addpath('..')


%% for dlpfc Data
a = load('~/Desktop/allBinFR_T50_5.mat').allBinFR;
b = load('~/Desktop/allBinFR_V50_5.mat').allBinFR;
c = load('~/Desktop/allBinFR_T50_5_vprobe.mat').allBinFR;
d = load('~/Desktop/allBinFR_V50_5_vprobe.mat').allBinFR;

allBinFR = [a, b,c,d];


%% for pmd data
allBinFR = load('~/Desktop/allBinFR_T50_5_pmd.mat').allBinFR;

%%
binSize = 50;
stepSize = 5;


tStart = -1000;
tEnd = 1000; 
timeAxis = [tStart+binSize:stepSize:tEnd];
tSelected = timeAxis > -100 & timeAxis <= 300;

time = timeAxis(tSelected);





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% path of all dpca core code %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath("/Users/tianwang/Documents/MATLAB/ChandLab/dPCA/matlab");


firingRatesAverage = [];
for ii = 1:length(allBinFR)
    
    trials = allBinFR(ii).trials;
    taskLabels = allBinFR(ii).taskLabels;
    
    RL = taskLabels == 0;
    RR = taskLabels == 1;
    GL = taskLabels == 2;
    GR = taskLabels == 3;
    
    temp = [];
    if size(trials, 2) ~= 1
        temp(:,1,1,:) = squeeze(mean(trials(RL,:,:),1));
        temp(:,1,2,:) = squeeze(mean(trials(RR,:,:),1));
        temp(:,2,1,:) = squeeze(mean(trials(GL,:,:),1));
        temp(:,2,2,:) = squeeze(mean(trials(GR,:,:),1));
    else

        temp(:,1,1,:) = squeeze(mean(trials(RL,:,:),1))';
        temp(:,1,2,:) = squeeze(mean(trials(RR,:,:),1))';
        temp(:,2,1,:) = squeeze(mean(trials(GL,:,:),1))';
        temp(:,2,2,:) = squeeze(mean(trials(GR,:,:),1))';        
        
    end
    
    firingRatesAverage = [firingRatesAverage; temp];
end

%%

processedFR = preprocess(firingRatesAverage);
%% pca
test = processedFR';
test = X';


[coeff, score, latent] = pca(test);

% B = rotatefactors(coeff(:,1:10));

% score = test*B;

m = size(firingRatesAverage,2) + size(firingRatesAverage,3);
t = size(firingRatesAverage,4);

orthF = [];
for thi = 1 : m
    orthF(:,:,thi) = (score( (1:t) + (thi-1)*t, :))';
end


%% 

addpath('/Users/tianwang/Documents/MATLAB/ChandLab/DLPFC_PMD/LabCode');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% you adjust the number here to select different PCs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% selectPC = [1 3 4];
selectPC = [4 1 2];

traj = orthF(selectPC,:,:);

medianCOn = 100;
% medianRT = 527+400+735;

figure;

cc = [0,1,0;
    1,0,0;
    0,0.4,0.2;
    0.4,0,0.2];


for tV = [25 35 45 50 60 80]

time(tV)

plot3(time(tV), traj(2,tV,1),traj(3,tV,1),'ro', 'markersize', 14, 'linewidth', 2);
hold on
plot3(time(tV), traj(2,tV,2),traj(3,tV,2), 'rd', 'markersize', 14,'MarkerFaceColor','r');
plot3(time(tV), traj(2,tV,3),traj(3,tV,3),'go', 'markersize', 14, 'linewidth', 2);
plot3(time(tV), traj(2,tV,4),traj(3,tV,4),'gd', 'markersize', 14,'MarkerFaceColor','g');


% RL&RR
line([time(tV), time(tV)], [traj(2,tV,1), traj(2,tV,3)], [traj(3,tV,1), traj(3,tV,3)] ,'color', 'k')
% GL&GR
line([time(tV), time(tV)], [traj(2,tV,2), traj(2,tV,4)], [traj(3,tV,2), traj(3,tV,4)] ,'color', 'k')

line([time(tV), time(tV)], [traj(2,tV,1), traj(2,tV,4)], [traj(3,tV,1), traj(3,tV,4)] ,'color', 'k')
% RR&GL
line([time(tV), time(tV)], [traj(2,tV,2), traj(2,tV,3)], [traj(3,tV,2), traj(3,tV,3)] ,'color', 'k')

zlim([-2 2])
ylim([-2 2])

pause;

end

%% 

 for ii = 1:6
    figure; hold on
    plot(time, squeeze(orthF(ii, :, 1)), 'r-')
    plot(time, squeeze(orthF(ii, :, 2)), 'r--')
    plot(time, squeeze(orthF(ii, :, 3)), 'g-')
    plot(time, squeeze(orthF(ii, :, 4)), 'g--')
    title(['pc ' num2str(ii)]);
end


%% distance analysis (choose first 22 dimension)
orthF = Z;
% figure;
for timePt = 1:size(orthF,2)
    dims = 1:100;
    t = time(timePt);

    TCdistV1 = orthF(dims,timePt, 1) - orthF(dims,timePt, 4);
    TCdistV2 = orthF(dims,timePt, 2) - orthF(dims,timePt, 3);

    T1 = sqrt(sum(TCdistV1.^2));
    T2 = sqrt(sum(TCdistV2.^2));
    T3 = .5*(T1+T2);


    
    CdistV = mean(orthF(dims,timePt, [1 2]),3) - mean(orthF(dims,timePt, [3 4]),3);
    ChdistV = mean(orthF(dims,timePt, [1 3]),3) - mean(orthF(dims,timePt, [2 4]),3);
    
% 
    TargDistV = mean(orthF(dims,timePt, [1 4]),3) - mean(orthF(dims,timePt, [2 3]),3);
    

    hold on
    plot(t, T3, 'ko');
    hold on;
    
% plot(t, sqrt(sum(CdistV.^2)), 'md')
% plot(t, sqrt(sum(ChdistV.^2)),'bs')
% plot(t, sqrt(sum(TargDistV.^2)), 'gs')

end












%% 
data = reshape(firingRatesAverage, size(firingRatesAverage,1), size(firingRatesAverage,2).*size(firingRatesAverage,3));

[coeff, score, latent] = pca(data');

orthF = reshape(score, [size(firingRatesAverage,2) size(firingRatesAverage,3) size(score,2)]);

TCdistV1 = orthF(:,[2],1:5) - orthF(:,[3],1:5);
TCdistV2 = orthF(:,[1],1:5) - orthF(:,[4],1:5);

T1 = sqrt(squeeze(sum(nanmean(TCdistV1,2).^2,3)));
T2 = sqrt(squeeze(sum(nanmean(TCdistV2,2).^2,3)));
T3 = .5*(T1+T2);

CdistV = orthF(:,[1 2],1:5) - orthF(:,[3 4],1:5);
ChdistV = orthF(:,[1 3],1:5) - orthF(:,[2 4],1:5);

TargDistV = orthF(:,[1 4],1:5) - orthF(:,[2 3],1:5);

plot(t(1:10), T3);
hold on
plot(t(1:10), sqrt(squeeze(sum(nanmean(CdistV,2).^2,3))))
hold on
plot(t(1:10), sqrt(squeeze(sum(nanmean(ChdistV,2).^2,3))))
hold on;
plot(t(1:10), sqrt(squeeze(sum(nanmean(TargDistV,2).^2,3))))


%% Visualizes

hold on;
plot3(orthF(3,1,5),orthF(3,1,1), orthF(3,1,3),'ro')
plot3(orthF(3,2,5),orthF(3,2,1), orthF(3,2,3),'rd')
plot3(orthF(3,3,5),orthF(3,3,1), orthF(3,3,3),'go')
plot3(orthF(3,4,5),orthF(3,4,1), orthF(3,4,3),'gd')



%% 


timePt = 15;
temp = squeeze(firingRatesAverage(:,timePt,:));
aveFR = mean(temp,2);

RL = temp(:,1) - aveFR;
RR = temp(:,2) - aveFR;
GL = temp(:,3) - aveFR;
GR = temp(:,4) - aveFR;


data = [RL,RR,GL,GR]';
labels = {'RL', 'RR', 'GL', 'GR'};



% do PCA 

dim1 = 1;
dim2 = 2;
dim3 = 3;

[coeff, score, latent] = pca(data);

plot3(score(1,dim1),score(1,dim2),score(1,dim3),'ro', 'markersize', 10, 'linewidth', 2)
hold on
plot3(score(2,dim1), score(2,dim2), score(2,dim3),'rd', 'markersize', 10,'MarkerFaceColor','r')
plot3(score(3,dim1), score(3,dim2),score(3,dim3),'go', 'markersize', 10, 'linewidth', 2)
plot3(score(4,dim1), score(4,dim2),score(4,dim3),'gd', 'markersize', 10,'MarkerFaceColor','g')

latent./sum(latent)





%% 



















