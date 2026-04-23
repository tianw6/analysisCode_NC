% Not a lot of progress 
% for vinnie, CCGP kinds of work, showing color encoding and then choice
% for Tiberius, color is minor for CCGP

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


alignmentCell = {'T', 'C', 'M'};
taskVariableCell = {'cxt', 'color', 'choice'};

%%%%%%%%%%%%%%%%%%%%%%% Do not use the for loop. It has a bug 


        ia = 2;
        it = 2;
        
        
        alignment = alignmentCell{ia};
        taskVariable = taskVariableCell{it};

        switch alignment
            case 'T'
                dataDir = '/Volumes/TianSSD/TiberiusNpix/targetAligned/';
                files = dir(fullfile(dataDir, '202*DLPFC*.mat'));
                tStart = -400;
                tEnd = 2000;
                timeAxis = [tStart+binSize:stepSize:tEnd];
                tSelected = timeAxis > -200 & timeAxis <= 800;        
            case 'C'
                dataDir = '/Volumes/TianSSD/VinnieNpix/checkerboardAligned/';
                files = dir(fullfile(dataDir, '202*DLPFC*.mat'));
                tStart = -1000;
                tEnd = 1000;  
                timeAxis = [tStart+binSize:stepSize:tEnd];
                tSelected = timeAxis > -100 & timeAxis <= 800;
            case 'M'
                dataDir = '/Volumes/TianSSD/TiberiusNpix/movementAligned/';
                files = dir(fullfile(dataDir, '202*DLPFC*.mat'));
                tStart = -1000;
                tEnd = 1000;
                timeAxis = [tStart+binSize:stepSize:tEnd];
                tSelected = timeAxis > -600 & timeAxis <= 300;
        end

t = timeAxis(tSelected);

        dayn = 1;
        
        data = load([dataDir files(dayn).name]).allData;
        % choose only correct trials
        data = data([data.correctness] == 1);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % extract the reaching direction for each trial 
        perf = [data.DLperformance];
        perfTable = struct2table(perf);
        a = perfTable(:,{'ChosenSide'});
        b = table2cell(a);
        left = strcmp(b, 'left')';
        right = strcmp(b, 'right')';

        % extract color
        a = perfTable(:,{'ChosenColor'});
        b = table2cell(a);
        red = strcmp(b, 'red')';
        green = strcmp(b, 'green')';

        RL = find(red&left);
        RR = find(red&right);
        GL = find(green&left);
        GR = find(green&right);

  
        minTrials = min([length(RL), length(RR), length(GL), length(GR)]);
        RL = RL(1:minTrials);
        RR = RR(1:minTrials);
        GL = GL(1:minTrials);
        GR = GR(1:minTrials);
        

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        temp = struct2table(data);
        % 
        spikeTable = temp(:,{'rasterT'});
        spikeStruct = table2struct(spikeTable);


        oldField = 'rasterT';
        newField = 'spikes';

        [spikeStruct.(newField)] = spikeStruct.(oldField);
        spikeStruct = rmfield(spikeStruct,oldField);  


        % check slideBins (whether it's non-causal) 50:20:1590
        seq = slideBins(spikeStruct, binSize,stepSize);    

        trials = [];
        for ii = 1 : length(seq)
            trials(ii,:,:)= seq(ii).y;
        end

        trials = trials(:,:,tSelected);

        % decoder to predict choice
        accuracy = zeros(1, size(trials, 3));

        
        
%% for cxt
        
        train_x = [trials(RL,:,:); trials(RR,:,:)];
        
        train_y = [zeros(1,minTrials), ones(1,minTrials)];
        
        test_x = [trials(GL,:,:); trials(GR,:,:)];
        
        test_y = [ones(1,minTrials), zeros(1,minTrials)];
         
        
%% for choice

        train_x = [trials(RL,:,:); trials(GR,:,:)];
        
        train_y = [zeros(1,minTrials), ones(1,minTrials)];
        
        test_x = [trials(GL,:,:); trials(RR,:,:)];
        
        test_y = [zeros(1,minTrials), ones(1,minTrials)];

        %% for color?
        
        train_x = [trials(RL,:,:); trials(GR,:,:)] - mean(trials, 1);
        
        train_y = [zeros(1,minTrials), ones(1,minTrials)];
        
        test_x = [trials(RR,:,:); trials(GL,:,:)] - mean(trials, 1);
        
        test_y = [zeros(1,minTrials), ones(1,minTrials)];
         
        

        %%
        accuracy = [];
        test_accuracy = [];
        for ii = 1:size(train_x,3)
        t1 = squeeze(train_x(:,:,ii));
        t2 = squeeze(test_x(:,:,ii));

        %%%%%%%%%%%%%%%%%
        %%% add condId on t1
        %%%%%%%%%%%%%%%%%
%         t1 = [squeeze(train_x(:,:,ii)) temp1.condId];
%         md1 = fitclinear(t1, train_y, 'learner', 'logistic', 'KFold', 5);

        md1 = fitcsvm(t1, train_y,  'KFold', 5, 'KernelFunction','RBF', 'KernelScale','auto');
        error = kfoldLoss(md1);
        accuracy(ii) = 1 - error;    
    
        md2 = fitcsvm(t1, train_y);
        y_pred = predict(md2, t2);
        test_accuracy(ii) = sum(y_pred == test_y') / length(test_y);    

   
        
        end
        
      
     %%
plot(t, accuracy)
hold on
plot(t, test_accuracy)


%% 

