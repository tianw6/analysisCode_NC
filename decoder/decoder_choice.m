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




clear all; close all; clc

totalAccuracy = [];

binSize = 50;
stepSize = 20;

alignment = 'M';
taskVariable = 'cxt';

switch alignment
    case 'T'
%         dataDir = '/Volumes/TianSSD/TiberiusDLPFCRaster/';
        dataDir = '/Volumes/ZiggySSD/VinnieDLPFCRaster/';
        
        files = dir(fullfile(dataDir, '202*.mat'));
        tStart = -800;
        tEnd = 2400;
        timeAxis = [tStart+binSize:stepSize:tEnd];
        tSelected = timeAxis > -200 & timeAxis <= 800;        
    case 'C'
%         dataDir = '/Volumes/TianSSD/TiberiusDLPFCRaster/RasterC/';
        dataDir = '/Volumes/ZiggySSD/VinnieDLPFCRaster/RasterC/';

        files = dir(fullfile(dataDir, '202*.mat'));
        tStart = -1000;
        tEnd = 1600;  
        timeAxis = [tStart+binSize:stepSize:tEnd];
        tSelected = timeAxis > -200 & timeAxis <= 800;
    case 'M'
%         dataDir = '/Volumes/TianSSD/TiberiusDLPFCRaster/RasterM/';
        dataDir = '/Volumes/ZiggySSD/VinnieDLPFCRaster/RasterM/';

        files = dir(fullfile(dataDir, '202*.mat'));
        tStart = -1000;
        tEnd = 1000;
        timeAxis = [tStart+binSize:stepSize:tEnd];
        tSelected = timeAxis > -600 & timeAxis <= 300;
end


tic
parfor dayn = 1:length(files)
    
    data = load([dataDir files(dayn).name]).dataframe;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    switch taskVariable
        case 'choice'
            % extract the reaching direction for each trial 
            perf = [data.performance];
            perfTable = struct2table(perf);
            a = perfTable(:,{'ChosenSide'});
            b = table2cell(a);
            left = strcmp(b, 'left')';
            right = strcmp(b, 'right')';
        case 'color'
            % extract color
            perf = [data.performance];
            perfTable = struct2table(perf);
            a = perfTable(:,{'ChosenColor'});
            b = table2cell(a);
            red = strcmp(b, 'red')';
            green = strcmp(b, 'green')';
   
    
    % extract target configuration
        case 'cxt'
%             target configuration 1: GL&RR; target configureation 2: GR&RL
            dataParams = [data.params];
            leftColor = [dataParams.LeftTargetColor];
            rightColor = [dataParams.RightTargetColor];

            config1 = leftColor == 2 & rightColor == 3;
            config2 = leftColor == 3 & rightColor == 2;    

    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    temp = struct2table(data);
    spikeTable = temp(:,{'rasterM'});
    spikeStruct = table2struct(spikeTable);
  
    oldField = 'rasterM';
    newField = 'spikes';
    
    [spikeStruct.(newField)] = spikeStruct.(oldField);
    spikeStruct = rmfield(spikeStruct,oldField);  
    
    
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
result.taskVariable = taskVariable;

% save(['./results/Vinnie/' result.taskVariable 'decodingAcc' result.alignment 'V.mat'], 'result');
 


%% 
figure; hold on
plot(timeAxis(tSelected), totalAccuracy', 'color', [1,1,1].*0.5)
plot(timeAxis(tSelected), mean(totalAccuracy,1), 'r', 'linewidth', 2)

