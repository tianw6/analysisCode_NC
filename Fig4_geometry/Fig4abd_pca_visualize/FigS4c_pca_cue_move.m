%%%%%%%%%%%%%%%%%%%%
% This code plots Fig S3c 

% pca on different difficulties but didn't subtract average signal
% Aligned to movement

clear; clc; close all

addpath('../../utils/')


%% load dlpfc Data



a = load('../../../analysisData_NC/Fig4/Tiberius/movementAligned/allBinFRnpix.mat').allBinFR;
b = load('../../../analysisData_NC/Fig4/Vinnie/movementAligned/allBinFRnpix.mat').allBinFR;
c = load('../../../analysisData_NC/Fig4/Tiberius/movementAligned/allBinFRvprobe.mat').allBinFR;
d = load('../../../analysisData_NC/Fig4/Vinnie/movementAligned/allBinFRvprobe.mat').allBinFR;

binFRpfc = [c,a,d,b];



%%

allTime = binFRpfc(1).time;

tStart = -200;
tEnd = 200; 
tSelected = allTime >= tStart & allTime <= tEnd;

time = allTime(tSelected);


for ii = 1:length(binFRpfc)
    
    binFRpfc(ii).trials = binFRpfc(ii).trials(:,:,tSelected);
    binFRpfc(ii).time = binFRpfc(ii).time(tSelected);

end

%% choose all correct trials
% 
% for ii = 1:length(binFRpfc)
%     behavior = binFRpfc(ii).behavior;
%     correct = [behavior.correctness]';
%     
%     binFRpfc(ii).trials = binFRpfc(ii).trials(correct,:,:);
%     binFRpfc(ii).taskLabels = binFRpfc(ii).taskLabels(correct);
%     behavior.chosenRed = behavior.chosenRed(correct);
%     behavior.config1 = behavior.config1(correct);
%     behavior.cue = behavior.cue(correct);
%     behavior.chosenLeft = behavior.chosenLeft(correct);
%     behavior.RT = behavior.RT(correct);
%     behavior.correctness = behavior.correctness(correct);
%     
%     binFRpfc(ii).behavior = behavior;
%     
%     
% end
%% 


% cueC = {[180 214] [147 158] [117 124 135] [90 101 108] [67 78] [11 45]};

cueC = {[180 214] [147 158 135] [124 117] [101 108] [67 78 90] [11 45]};



firingRatesAverage = [];
for ii = 1:length(binFRpfc)
    
    trials = binFRpfc(ii).trials;
    taskLabels = binFRpfc(ii).taskLabels;
    behavior = binFRpfc(ii).behavior;
    
    cue = [behavior.cue];
    left = [behavior.chosenLeft];
    
    temp = [];
    
    for is = 1:length(cueC)
        currCue = cueC{is};
        selectLeft = ismember(cue, currCue) & left == 1;
        selectRight = ismember(cue, currCue) & left == 0;
        
        if size(trials, 2) ~= 1

            temp(:,is,1,:) = squeeze(mean(trials(selectLeft,:,:),1));
            temp(:,is,2,:) = squeeze(mean(trials(selectRight,:,:),1));

        else
            temp(:,is,1,:) = squeeze(mean(trials(selectLeft,:,:),1))';
            temp(:,is,2,:) = squeeze(mean(trials(selectRight,:,:),1))';
        end
            
    end
    
    firingRatesAverage = [firingRatesAverage; temp];
end


%% remove action signal since it's it explains most variances 
n = size(firingRatesAverage,2);
reconstruct = firingRatesAverage;
     
    
for jj = [1 2 3]


    leftSub = ((reconstruct(:, jj, 1, :)) + (reconstruct(:, n - jj + 1, 1,:)))./2;
    rightSub = ((reconstruct(:, jj, 2,:)) + (reconstruct(:, n - jj + 1, 2,:)))./2;

    reconstruct(:, jj,1,:) = reconstruct(:, jj,1,:) - leftSub;
    reconstruct(:, n - jj + 1, 1,:) = reconstruct(:, n - jj + 1, 1,:) - leftSub;
    reconstruct(:, jj, 2, :) = reconstruct(:, jj, 2, :) - rightSub;
    reconstruct(:, n-jj+1, 2,:) = reconstruct(:, n - jj + 1, 2,:) - rightSub;


end

%%

processedFR = preprocess(reconstruct, 0);

% processedFR = preprocess(firingRatesAverage, 1);

%% pca
test = processedFR';


[coeff, score, latent] = pca(test);



%%

m = size(firingRatesAverage,2) * size(firingRatesAverage,3);
t = size(firingRatesAverage,4);

orthF = reshape(score', [size(score,2), t, m]);


% orthFM = orthF - mean(orthF,3);
orthFM = orthF;


%% plot in 2D 

c1 = autumn(6);
c2 = summer(6);


selectPC = [1 2];

x_limit = [-11 11];
y_limit = [-10 10];

traj = orthFM(selectPC,:,:);



timePts = [-100, 0];


% plot DLPFC
figure('Position',[100 100 1500 400]); % [x, y, width, height]
 
cnt = 1;

for tt = timePts

    tV = find(time == tt);
    
    for jj = [1 3 5]

        A = [traj(1,tV,jj),traj(2,tV,jj)];
        B = [traj(1,tV,jj+1),traj(2,tV,jj+1)];
        C = [traj(1,tV,m-jj),traj(2,tV,m-jj)];
        D = [traj(1,tV,m-jj+1),traj(2,tV,m-jj+1)];

        points = [A;B;C;D];
        subplot(2,3,cnt); hold on
        
        plotGeometryCue(points, tV, c1(jj,:), c2(jj,:), 'cyan')
        
        axis equal
        axis off        
        xlim(x_limit)
        ylim(y_limit)

        title(time(tV))   
        
%         print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig4_s/geometry_move/', num2str(jj), 'pfcStimulus' num2str(time(tV)), '.eps']);
        
        cnt = cnt + 1;
        
    end


end

