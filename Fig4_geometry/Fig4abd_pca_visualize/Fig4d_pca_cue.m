%%%%%%%%%%%%%%%%%%%%
% This code plots Fig 4d if choosing pc 4 and 8; choose pc 5 and 6 to plot FigS3 b

% pca on different difficulties but didn't subtract average signal

clear; clc; close all

addpath('../../utils/')


%% load dlpfc Data

a = load('../../../analysisData_NC/Fig4/Tiberius/checkerboardAligned/allBinFRnpix.mat').allBinFR;
b = load('../../../analysisData_NC/Fig4/Vinnie/checkerboardAligned/allBinFRnpix.mat').allBinFR;
c = load('../../../analysisData_NC/Fig4/Tiberius/checkerboardAligned/allBinFRvprobe.mat').allBinFR;
d = load('../../../analysisData_NC/Fig4/Vinnie/checkerboardAligned/allBinFRvprobe.mat').allBinFR;

binFRpfc = [c,a,d,b];



%%

allTime = binFRpfc(1).time;

tStart = -100;
tEnd = 300; 
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

%%

processedFR = preprocess(firingRatesAverage, 0);
%% pca
test = processedFR';


[coeff, score, latent] = pca(test);



%%

m = size(firingRatesAverage,2) * size(firingRatesAverage,3);
t = size(firingRatesAverage,4);

orthF = reshape(score', [size(score,2), t, m]);

orthFM = orthF - mean(orthF,3);





%% Fig 4d or FigS3b: pca cue 

% specifiy which figure to plot ('Fig4d' or FigS3b)
% Fig4d: plot pc 4 and 8
% FigS3a: plot pc 5 and 6
figHandle = 'Fig4d';

switch figHandle
    case{'Fig4d'}
        selectPC = [4 8];

        x_limit = [-6 8];
        y_limit = [-5 5];
    case{'FigS3b'}
        selectPC = [5 6];

        x_limit = [-8 7];
        y_limit = [-4 5];
end

% specify color theme
c1 = autumn(6);
c2 = summer(6);


traj = orthFM(selectPC,:,:);


timePts = [200, 300];


% plot DLPFC
figure('Position',[100 100 1500 400]); % [x, y, width, height]
 
cnt = 1;

for tt = timePts

    tV = find(time == tt);
% 

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
                
        cnt = cnt + 1;
    end

end

sgtitle([figHandle ': pca Cue'])

