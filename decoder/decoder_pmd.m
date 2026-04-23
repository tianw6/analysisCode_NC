% decode choice  

% aligned with checkerboard
% choose (-200:800) with zero centered to checkerboard
% separately 

% aligned with targets
% choose (-200:800) with zero centered to targets
% separately 

% aligned with movements
% choose (-600:300) with zero centered to checkerboard
% separately 

%%%%%%%%%%%%%%%%%%%%% Might only use vprobe data instead of all units 
% since single units will decrease decoding accuracy. 


% clear all; close all; clc


binSize = 50;
stepSize = 20;

alignment = 'T';

switch alignment
    case 'T'
        dataDir = '/Volumes/TianSSD/PMd/PMdData/Olaf/OlafPMdT1.mat';
        load(dataDir);
        tStart = -400;
        tEnd = 2000;
        timeAxis = [tStart+binSize:stepSize:tEnd];
        tSelected = timeAxis > -200 & timeAxis <= 800;        
    case 'C'
        dataDir = '/Volumes/TianSSD/PMd/PMdData/Olaf/OlafPMdC1.mat';
        load(dataDir);
        tStart = -1000;
        tEnd = 1000;  
        timeAxis = [tStart+binSize:stepSize:tEnd];
        tSelected = timeAxis > -200 & timeAxis <= 800;
    case 'M'
        dataDir = '/Volumes/TianSSD/PMd/PMdData/Olaf/OlafPMdM1.mat';
        load(dataDir);
        tStart = -1000;
        tEnd = 1000;
        timeAxis = [tStart+binSize:stepSize:tEnd];
        tSelected = timeAxis > -600 & timeAxis <= 300;
end

%%%%%%%%%%%%%%%%%%%%% Only choose vprobe data instead of all units 
% since single units will decrease decoding accuracy. 

load('./OlafDatabase_v.mat');
a = struct2table(database_v);
b = table2cell(a(:,{'name'}));
c = struct2table(dataframe);
d = table2cell(c(:,{'date'}));

dataframe = dataframe(ismember(d, b));
%%%%%%%%%%%%%%%%%%%%%

%%
totalAccuracy = [];

taskVariable = 'choice';

tic
parfor dayn = 1:length(dataframe)
    
    data = dataframe(dayn);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    switch taskVariable
        case 'choice'
            % extract the reaching direction for each trial 
            perf = [data.behavior];
            left = [perf.chosenSide] == 1;
            right = [perf.chosenSide] == 2;

        case 'color'
            % extract color
            perf = [data.behavior];
            red = [perf.CentralCuenSquares] > 112 & [perf.CorrectResponse] == 1 | [perf.CentralCuenSquares] < 112 & [perf.CorrectResponse] == 2;
            green = ~red;
   
    
        % extract target configuration
        case 'cxt'
            % target configuration 1: GL&RR; target configureation 2: GR&RL
            perf = [data.behavior];
            config1 = [perf.LeftTargetColor] == 2;
            config2 = [perf.LeftTargetColor] == 3;
   

    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    spikeStruct = struct;
    spikes = data.spikes;
    for is = 1:size(spikes,2)
        spikeStruct(is).spikes = squeeze(double(spikes(:,is,:)))';
    end
    
    % check slideBins (whether it's non-causal) 50:20:1590
    
    seq = slideBins(spikeStruct, binSize,stepSize);    
    
    trials = [];
    for ii = 1 : length(seq)
        trials(ii,:,:)= seq(ii).y;
    end
    
    % choose -0.2 to 0.8 aligned with target
    trials = trials(:,:,tSelected);
 
    % decoder to predict choice
    accuracy = zeros(1, size(trials, 3));
    
    
    switch taskVariable
        case 'choice'
            % equalize left and right trials
            c1Trials = find(left == 1);
            c2Trials = find(right == 1);
            num = min(length(c1Trials), length(c2Trials));

            index1 = randperm(length(c1Trials));
            extract1 = sort(index1(1:num));    
            index2 = randperm(length(c2Trials));
            extract2 = sort(index2(1:num));     

            % extract trials feed into classifier
            extract = [c1Trials(extract1) c2Trials(extract2)];


            train_x = trials(extract, :, :);
            % left: 0,  right: 1
            train_y = right(extract);
        case 'color'
            % equalize red and green trials
            c1Trials = find(red == 1);
            c2Trials = find(green == 1);
            num = min(length(c1Trials), length(c2Trials));

            index1 = randperm(length(c1Trials));
            extract1 = sort(index1(1:num));    
            index2 = randperm(length(c2Trials));
            extract2 = sort(index2(1:num));     

            % extract trials feed into classifier
            extract = [c1Trials(extract1) c2Trials(extract2)];


            train_x = trials(extract, :, :);
            % red: 0,  green: 1
            train_y = green(extract);
        case 'cxt'
            % equalize left and right trials
            c1Trials = find(config1 == 1);
            c2Trials = find(config2 == 1);
            num = min(length(c1Trials), length(c2Trials));

            index1 = randperm(length(c1Trials));
            extract1 = sort(index1(1:num));    
            index2 = randperm(length(c2Trials));
            extract2 = sort(index2(1:num));     

            % extract trials feed into classifier
            extract = [c1Trials(extract1) c2Trials(extract2)];


            train_x = trials(extract, :, :);
            % config1: 0,  config2: 1
            train_y = config2(extract);
    end
    
    
    
    
    for ii = 1 : size(train_x,3)

        t1 = squeeze(train_x(:,:,ii));
        
        %%%%%%%%%%%%%%%%%
        %%% add condId on t1
        %%%%%%%%%%%%%%%%%
%         t1 = [squeeze(train_x(:,:,ii)) temp1.condId];
        
%         md1 = fitclinear(t1, train_y, 'learner', 'logistic', 'KFold', 5);

        md1 = fitcsvm(t1, train_y,  'KFold', 5, 'KernelFunction','RBF', 'KernelScale','auto');
        
        
        error = kfoldLoss(md1);
        accuracy(ii) = 1 - error;    
    end
    
    
%     totalAccuracy(dayn,:) = accuracy;
    totalAccuracy = [totalAccuracy; accuracy];
    
    fprintf("\n Day %d finished ", dayn);
    
%      figure(1)
%     if dayn >= 2
%         plot(timeAxis(tSelected), nanmean(totalAccuracy));
%     end
%     drawnow;
end

 toc
 

result.accuracy = totalAccuracy;
result.dataStart = tStart;
result.dataEnd = tEnd;
result.dataBinAxis = timeAxis;
result.selectedBin = timeAxis(tSelected);
result.alignment = alignment;
result.taskVariable = taskVariable

% save(['./results/Olaf/' result.taskVariable 'decodingAcc' result.alignment 'V.mat'], 'result');
 


%% 
figure; hold on
plot(timeAxis(tSelected), totalAccuracy', 'color', [1,1,1].*0.5)
plot(timeAxis(tSelected), mean(totalAccuracy,1), 'r', 'linewidth', 2)

