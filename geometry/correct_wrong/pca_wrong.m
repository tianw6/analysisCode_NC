%% created by Tian on May 29th 

% combine pfc and pmd data and do pca together

clear; clc; close all

addpath('..')


%% for dlpfc Data
a = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/checkerboardAligned/allBinFRnpix.mat').allBinFR;
b = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Vinnie/checkerboardAligned/allBinFRnpix.mat').allBinFR;
c = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/checkerboardAligned/allBinFRvprobe.mat').allBinFR;
d = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Vinnie/checkerboardAligned/allBinFRvprobe.mat').allBinFR;

binFRpfc = [c,a,d,b];


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

%%
% cueC =  [135 124 117 108 101 90];


CbinFR = struct;
WbinFR = struct;

for dayn = 1:length(binFRpfc)
    
    
           
    trials = binFRpfc(dayn).trials;
    taskLabels = binFRpfc(dayn).taskLabels;

    behavior = binFRpfc(dayn).behavior;
    
    cue = [behavior.cue];    
    correct = [behavior.correctness];
 
%     selectW = ismember(cue, cueC) & correct == 0;
%     selectC = ismember(cue, cueC) & correct == 1;

    selectW = correct == 0;
    selectC = correct == 1;    
    
    % select hardest trials correct and wrong
    WbinFR(dayn).trials = trials(selectW,:,:);
    WbinFR(dayn).taskLabels = taskLabels(selectW);
    
    CbinFR(dayn).trials = trials(selectC,:,:);
    CbinFR(dayn).taskLabels = taskLabels(selectC);
    
    
    
end


%%
% don't subtract the aveage FR
[processedFRpfc, ~] = prepareData(WbinFR);

% replace all nan to 0
processedFRpfc(isnan(processedFRpfc)) = 0;

X = [processedFRpfc];



%% pca
test = X';


[coeff, score, latent] = pca(test);



m = 4;
t = size(processedFRpfc,2)/m;

orthFpfc = reshape(score', [size(score,2), t, m]);

orthFpfcM = orthFpfc - mean(orthFpfc,3);

%%

plot(cumsum(latent(1:30))./sum(latent))



%%
% 
% 
% 
% orthFpfc = [];
% for thi = 1 : m
%     orthFpfc(:,:,thi) = (Zpfc( (1:t) + (thi-1)*t, :))';
% end
% 
% orthFpmd = [];
% for thi = 1 : m
%     orthFpmd(:,:,thi) = (Zpmd( (1:t) + (thi-1)*t, :))';
% end

%% 

addpath('/Users/tianwang/Documents/MATLAB/ChandLab/DLPFC_PMD/LabCode');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% you adjust the number here to select different PCs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% selectPC = [1 3 4];
selectPC = [4 3 7];




traj = orthFpfcM(selectPC,:,:);
traj2 = orthFpmdM(selectPC,:,:);


figure;




for tV = [11 21 31 41 46 51 56 61 71 81]

time(tV)

plot3(time(tV), traj(2,tV,1),traj(3,tV,1),'ro', 'markersize', 14, 'linewidth', 2);
hold on
plot3(time(tV), traj(2,tV,2),traj(3,tV,2), 'rd', 'markersize', 14,'MarkerFaceColor','r');
plot3(time(tV), traj(2,tV,3),traj(3,tV,3),'go', 'markersize', 14, 'linewidth', 2);
plot3(time(tV), traj(2,tV,4),traj(3,tV,4),'gd', 'markersize', 14,'MarkerFaceColor','g');


% % RL&RR
% line([time(tV), time(tV)], [traj(2,tV,1), traj(2,tV,3)], [traj(3,tV,1), traj(3,tV,3)] ,'color', 'k')
% % GL&GR
% line([time(tV), time(tV)], [traj(2,tV,2), traj(2,tV,4)], [traj(3,tV,2), traj(3,tV,4)] ,'color', 'k')

line([time(tV), time(tV)], [traj(2,tV,1), traj(2,tV,4)], [traj(3,tV,1), traj(3,tV,4)] ,'color', 'k')
% RR&GL
line([time(tV), time(tV)], [traj(2,tV,2), traj(2,tV,3)], [traj(3,tV,2), traj(3,tV,3)] ,'color', 'k')


% RL&RR
line([time(tV), time(tV)], [traj(2,tV,1), traj(2,tV,2)], [traj(3,tV,1), traj(3,tV,2)] ,'color', 'k')
% GL&GR
line([time(tV), time(tV)], [traj(2,tV,3), traj(2,tV,4)], [traj(3,tV,3), traj(3,tV,4)] ,'color', 'k')




pause;

plot3(time(tV), traj2(2,tV,1),traj2(3,tV,1),'ro', 'markersize', 14, 'linewidth', 2);
hold on
plot3(time(tV), traj2(2,tV,2),traj2(3,tV,2), 'rd', 'markersize', 14,'MarkerFaceColor','r');
plot3(time(tV), traj2(2,tV,3),traj2(3,tV,3),'go', 'markersize', 14, 'linewidth', 2);
plot3(time(tV), traj2(2,tV,4),traj2(3,tV,4),'gd', 'markersize', 14,'MarkerFaceColor','g');


% % RL&RR
% line([time(tV), time(tV)], [traj2(2,tV,1), traj2(2,tV,3)], [traj2(3,tV,1), traj2(3,tV,3)] ,'color', 'k')
% % GL&GR
% line([time(tV), time(tV)], [traj2(2,tV,2), traj2(2,tV,4)], [traj2(3,tV,2), traj2(3,tV,4)] ,'color', 'k')

% RL&GR
line([time(tV), time(tV)], [traj2(2,tV,1), traj2(2,tV,4)], [traj2(3,tV,1), traj2(3,tV,4)] ,'color', 'k')
% RR&GL
line([time(tV), time(tV)], [traj2(2,tV,2), traj2(2,tV,3)], [traj2(3,tV,2), traj2(3,tV,3)] ,'color', 'k')

% RL&RR
line([time(tV), time(tV)], [traj2(2,tV,1), traj2(2,tV,2)], [traj2(3,tV,1), traj2(3,tV,2)] ,'color', 'k')
% GL&GR
line([time(tV), time(tV)], [traj2(2,tV,3), traj2(2,tV,4)], [traj2(3,tV,3), traj2(3,tV,4)] ,'color', 'k')





pause;
end


%% plot in 2D 

selectPC = [3 7];


orthFpfcM = orthFpfc - mean(orthFpfc,3);
orthFpmdM = orthFpmd - mean(orthFpmd,3);

traj = orthFpfcM(selectPC,:,:);
traj2 = orthFpmdM(selectPC,:,:);


for tV = [11 21 31 41 51  61  81]

figure; hold on

A = [traj(1,tV,1),traj(2,tV,1)];
B = [traj(1,tV,2),traj(2,tV,2)];
C = [traj(1,tV,3),traj(2,tV,3)];
D = [traj(1,tV,4),traj(2,tV,4)];

points = [A;B;C;D];
plotGeometry(points, tV, 'cyan')


title(time(tV))



axis equal

xlim([-3 3])
ylim([-2 2])


% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig4/geometry/', 'pfc' num2str(time(tV)), '.eps']);

end

%%

for tV = [11 21 31 41  51  61  81]



figure; hold on

A = [traj2(1,tV,1),traj2(2,tV,1)];
B = [traj2(1,tV,2),traj2(2,tV,2)];
C = [traj2(1,tV,3),traj2(2,tV,3)];
D = [traj2(1,tV,4),traj2(2,tV,4)];

points = [A;B;C;D];
plotGeometry(points, tV, 'm')

title(time(tV))

axis equal

xlim([-3 3])
ylim([-2 2])


% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig4/geometry/', 'pmd' num2str(time(tV)), '.eps']);

end

%% 

for ii = 1:10
    figure; hold on
    plot(time, squeeze(orthFpfcM(ii, :, 1)), 'r-')
    plot(time, squeeze(orthFpfcM(ii, :, 2)), 'r--')
    plot(time, squeeze(orthFpfcM(ii, :, 3)), 'g-')
    plot(time, squeeze(orthFpfcM(ii, :, 4)), 'g--')
    pause
    
%     plot(time, squeeze(orthFpmdM(ii, :, 1)), 'r-')
%     plot(time, squeeze(orthFpmdM(ii, :, 2)), 'r--')
%     plot(time, squeeze(orthFpmdM(ii, :, 3)), 'g-')
%     plot(time, squeeze(orthFpmdM(ii, :, 4)), 'g--')    
%     
    pause
    title(['pc ' num2str(ii)]);
        
 end





%% distance analysis pfc (choose first 10 dimension)
distResult = [];
dims = 1:10;

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

    distResult(timePt, 1) = cxtDist;
    distResult(timePt, 2) = colorDist;
    distResult(timePt, 3) = choiceDist;
    distResult(timePt, 4) = T3;
    
end


figure('position', [20 20 1200 500]); hold on

plot(time, distResult(:,1), 'k')
plot(time, distResult(:,2), 'm')
plot(time, distResult(:,3), 'b')
plot(time, distResult(:,4), 'r')


%% distance analysis pmd (choose first 10 dimension)

distResult = [];
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

    distResult(timePt, 1) = cxtDist;
    distResult(timePt, 2) = colorDist;
    distResult(timePt, 3) = choiceDist;
    distResult(timePt, 4) = T3;
    
end



plot(time, distResult(:,1), 'k')
plot(time, distResult(:,2), 'm')
plot(time, distResult(:,3), 'b')
plot(time, distResult(:,4), 'r')

xlim([-50 300])

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig4/geometry/', 'pfcpmdDistance', '.eps']);

%% plot coeff(loadings) of each unit on pc axis 1 and 2


plot(coeff(5500:end,1), coeff(5500:end,2),'k.')
hold on
plot(coeff(1:1500,1), coeff(1:1500,2),'m.')
plot(coeff(1500:4800,1), coeff(1500:4800,2),'c.')
plot(coeff(4800:5500,1), coeff(4800:5500,2),'b.')



