%% created by Tian on Sep 18th 

% pca on different difficulties but don't subtract average signal
% Aligned to movement

clear; clc; close all

addpath('..')


%% for dlpfc Data



a = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/movementAligned/allBinFRnpix.mat').allBinFR;



b = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Vinnie/movementAligned/allBinFRnpix.mat').allBinFR;
c = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/movementAligned/allBinFRvprobe.mat').allBinFR;
d = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Vinnie/movementAligned/allBinFRvprobe.mat').allBinFR;

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


%% 

% aa = mean(firingRatesAverage(:,:,1,:), 2);
% bb = mean(firingRatesAverage(:,:,2,:), 2);
% 
% left_ave = firingRatesAverage(:,:,1,:) - aa;
% right_ave = firingRatesAverage(:,:,2,:) - bb;
% 
% firingRatesAverage = cat(3, left_ave, right_ave);


%% remove action signal 
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


% m = size(firingRatesAverage,2) * size(firingRatesAverage,3);
% t = size(firingRatesAverage,4);
% 
% orthF = [];
% for thi = 1 : m
%     orthF(:,:,thi) = (score( (1:t) + (thi-1)*t, :))';
% end



% orthFM = orthF - mean(orthF,3);
orthFM = orthF;
%% 





%% 

addpath('/Users/tianwang/Documents/MATLAB/ChandLab/DLPFC_PMD/LabCode');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% you adjust the number here to select different PCs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% selectPC = [1 3 4];
selectPC = [4 1 2];

traj = orthFM(selectPC,:,:);



c1 = autumn(6);
c2 = summer(6);

figure;

for tV = [1 21 41 61]

time(tV)


 
for jj = [1 3 5]
    plot3(time(tV), traj(2,tV,jj),traj(3,tV,jj),'o', 'markersize', 14, 'linewidth', 2, 'color', c1(jj,:));
    hold on
    plot3(time(tV), traj(2,tV,jj+1),traj(3,tV,jj+1), 'd', 'markersize', 14,'MarkerFaceColor',c1(jj,:));
    plot3(time(tV), traj(2,tV,m-jj),traj(3,tV,m-jj),'o', 'markersize', 14, 'linewidth', 2, 'color', c2(jj,:));
    plot3(time(tV), traj(2,tV,m-jj+1),traj(3,tV,m-jj+1),'d', 'markersize', 14,'MarkerFaceColor', c2(jj,:));


%     % RL&RL
%     line([time(tV), time(tV)], [traj(2,tV,jj), traj(2,tV,m-jj)], [traj(3,tV,jj), traj(3,tV,m-jj)] ,'color', 'k')
%     % RR&GR
%     line([time(tV), time(tV)], [traj(2,tV,jj+1), traj(2,tV,m-jj+1)], [traj(3,tV,jj+1), traj(3,tV,m-jj+1)] ,'color', 'k')

%     % RL&GR
    line([time(tV), time(tV)], [traj(2,tV,jj), traj(2,tV,m-jj+1)], [traj(3,tV,jj), traj(3,tV,m-jj+1)] ,'color', 'k')
%     % RR&GL
    line([time(tV), time(tV)], [traj(2,tV,jj+1), traj(2,tV,m-jj)], [traj(3,tV,jj+1), traj(3,tV,m-jj)] ,'color', 'k')


%     % RL&RR
    line([time(tV), time(tV)], [traj(2,tV,jj), traj(2,tV,jj+1)], [traj(3,tV,jj), traj(3,tV,jj+1)] ,'color', 'k')
%     % GL&GR
    line([time(tV), time(tV)], [traj(2,tV,m-jj), traj(2,tV,m-jj+1)], [traj(3,tV,m-jj), traj(3,tV,m-jj+1)] ,'color', 'k')
    
    
     pause
end


end





%% plot in 2D 

c1 = autumn(6);
c2 = summer(6);

% selectPC = [4 8];
% 
% x_limit = [-6 8];
% y_limit = [-5 5];


selectPC = [1 2];

x_limit = [-11 11];
y_limit = [-10 10];

traj = orthFM(selectPC,:,:);


for tV = [21 41 61] %[21 51  61  81]


% 

    for jj = [1 3 5]

        A = [traj(1,tV,jj),traj(2,tV,jj)];
        B = [traj(1,tV,jj+1),traj(2,tV,jj+1)];
        C = [traj(1,tV,m-jj),traj(2,tV,m-jj)];
        D = [traj(1,tV,m-jj+1),traj(2,tV,m-jj+1)];

        points = [A;B;C;D];
        figure; hold on
        
        plotGeometryCue(points, tV, c1(jj,:), c2(jj,:), 'cyan')
        
        axis equal
        xlim(x_limit)
        ylim(y_limit)

        title(time(tV))   
        
%         print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig4_s/geometry_move/', num2str(jj), 'pfcStimulus' num2str(time(tV)), '.eps']);
        
        
    end







end


%% plot each pc

c1 = autumn(6);
c2 = summer(6);

 for ii = 1:10
     
     
    figure; hold on
    
    for jj = [1 3 5]
        
        plot(time, squeeze(orthFM(ii, :, jj)), '-', 'color', c1(jj,:))
        plot(time, squeeze(orthFM(ii, :, jj+1)), '--', 'color', c1(jj,:))

        plot(time, squeeze(orthFM(ii, :, m - jj)), '-', 'color', c2(jj,:))
        plot(time, squeeze(orthFM(ii, :, m-jj+1)), '--', 'color', c2(jj,:))
        
        
        title(['pc ' num2str(ii)]);
        
        pause;
    end
 end

