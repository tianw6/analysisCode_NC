clear; clc; close all

dataSet = 'TFT'; 

switch(dataSet)
    case {'TFT'}
    resultsStruct= struct('R_squared', [], 'model', [], 'regressor', []);

    case {'TFC'}
        resultsStructColor = struct('R_squared', [], 'model', [], 'regressor', []);
        resultsStructCxt = struct('R_squared', [], 'model', [], 'regressor', []);
        resultsStructSide = struct('R_squared', [], 'model', [], 'regressor', []);
end 


folder = dir('/Volumes/TianSSD/npx2Banks/targetsAligned/*.mat');

% choose only [0,800] aligned to checkerboard
stimOn = 200;
segment = 700;

g = normpdf([-0.1:0.001:0.1],0,0.025);

%% preprocess the dataset to match format of the algorithm 

for ii = 1:length(folder)

fileName = [folder(ii).folder '/' folder(ii).name]
rawData = load(fileName).allData;

% only choose correct trials
rawData = rawData([rawData.correctness] == 1);
% remove 1st trial
rawData = rawData(2:end);

m = length(rawData);
[n, t] = size(rawData(1).rasterT);
window = length(g):(t-length(g))+1;


    %% create firing rate matrix 
    
% 3D matrix to store firing rates: n (#neurons) by t (#timepoints) by m (#trials);
FR_matrix = zeros(n, length(window), m);
parfor im = 1:m
    for jj = 1:n
        temp = rawData(im).rasterT(jj,:);
        temp = conv(temp, g, 'same');
        % make sure there is no NaN in the FR_matrix
        if sum(isnan(temp)) ~= 0 | isempty(temp)
            temp = zeros(1,t);
        end

        FR_matrix(jj,:,im) = temp(window);
    end
end


FR_matrix = FR_matrix(:,stimOn+1:stimOn+segment,:);
red = [rawData.cue] > 113;
left = [rawData.chosenSide] == 1;
cxt1 = [rawData.leftTarget] == 2;


%% 


    data = FR_matrix; 
    color = red'; 
    cxt = cxt1'; 
    side = left'; 

    numUnits = size(data, 1);
    numTimepoints = size(data, 2); 
    numTrials = size(data, 3); 

    %% bin activity (100ms overlapping bins) 

    timeSteps = 1:10:numTimepoints(end)-100;

    allNeuralValues = struct('unitValues', cell(1, numUnits));

    parfor unitIndex = 1:numUnits
        neural_activity_unit = squeeze(data(unitIndex, 1:numTimepoints, :));
        unitValues = zeros(length(timeSteps), numTrials); 

        for i = 1:numTrials   
            binnedData = zeros(length(timeSteps), 1); 

            for j = 1:length(timeSteps)
                start_row = (j-1)*10 + 1;
                currBin = neural_activity_unit(start_row:start_row+99, i);
                binnedData(j) = mean(currBin);
            end

            unitValues(:, i) = binnedData;   
        end

        % Transpose to have numTrials X numTimepoints
        unitValues = unitValues';
        allNeuralValues(unitIndex).unitValues = unitValues;
    end

    
    %% regression per unit for each time bin 

    numBin = length(timeSteps); 

    results = zeros(numUnits, numBin); 
    resultsColor  = zeros(numUnits, numBin);
    resultsCxt  = zeros(numUnits, numBin);
    resultsSide  = zeros(numUnits, numBin);

    switch(dataSet)
        case {'CFDC', 'TFT'}
            parfor l = 1:numUnits
                for i = 1:numBin
                    y = allNeuralValues(l).unitValues(:, i); 
        
                    model = fitlm(cxt,y); 
                    results(l, i) = model.Rsquared.Ordinary;
                end 
        
            end
        
            % store results 
            resultsStruct(ii).R2cxt = results;
            resultsStruct(ii).name = folder(ii).name;

% %             resultsStruct(ii).model = model;
%             resultsStruct(ii).regressor = 'cxt'; 
%             resultsStruct(ii).inputData = dataSet; 


        case {'CFDT', 'TFC'}
            parfor l = 1:numUnits
                for i = 1:numBin
                    y = allNeuralValues(l).unitValues(:, i); 
    
                    modelColor = fitlm(color,y); 
                    resultsColor(l, i) = modelColor.Rsquared.Ordinary;
    
                    modelCxt = fitlm(cxt,y);
                    resultsCxt(l, i) = modelCxt.Rsquared.Ordinary;
    
                    modelSide = fitlm(side,y);
                    resultsSide(l, i) = modelSide.Rsquared.Ordinary;
    
                end 
    
            end
    
            % store results 
%             resultsStructColor(ii).R_squared = resultsColor;
% %             resultsStructColor(ii).model = modelColor;
%             resultsStructColor(ii).regressor = 'Color'; 
%             resultsStructColor(ii).inputData = dataSet; 
% 
%             resultsStructCxt(ii).R_squared = resultsCxt;
% %             resultsStructCxt(ii).model = modelCxt;
%             resultsStructCxt(ii).regressor = 'Cxt'; 
%             resultsStructCxt(ii).inputData = dataSet; 
% 
%             resultsStructSide(ii).R_squared = resultsSide;
% %             resultsStructSide(ii).model = modelSide;
%             resultsStructSide(ii).regressor = 'Side'; 
%             resultsStructSide(ii).inputData = dataSet; 
%             
            
            % append all 
%             resultsStruct = [resultsStructColor, resultsStructCxt, resultsStructSide]; 
            resultsStruct(ii).R2color = resultsColor;
            resultsStruct(ii).R2cxt = resultsCxt;
            resultsStruct(ii).R2dir = resultsSide;
            resultsStruct(ii).name = folder(ii).name;
            
            

    end

end


%% plot the results 

% dataSet = 'TFC'; 
% load resultsStructTFT.mat

switch(dataSet)
    case {'TFT'}

    for ii = 1:length(resultsStruct)

        figure; 
        plot(resultsStruct(ii).R2cxt')
        title([resultsStruct(ii).name ' cxt'])

    end 
         
   
    case {'TFC'}

    for ii = 1:length(resultsStruct)
        figure; 
        plot(resultsStruct(ii).R2color')
        title([resultsStruct(ii).name ' color'])

        figure; 
        plot(resultsStruct(ii).R2cxt')
        title([resultsStruct(ii).name ' cxt'])

        figure; 
        plot(resultsStruct(ii).R2dir')        
        title([resultsStruct(ii).name ' dir'])

        %         pause; 
        %         close; 
    end    
   

end 


%% plot psth 


% 
% RL = mean(FR_matrix(:,:,red & left), 3);
% RR = mean(FR_matrix(:,:,red & ~left), 3);
% GL = mean(FR_matrix(:,:,~red & left), 3);
% GR = mean(FR_matrix(:,:,~red & ~left), 3);
% 
% for ip = 1:size(RL,1)
%     figure; hold on
%     plot(RL(ip,:), 'r');
%     plot(RR(ip,:), 'r--');
%     plot(GL(ip,:), 'g');
%     plot(GR(ip,:), 'g--');
%     pause;
%     close;
% end



%% 

% save('/Volumes/TianSSD/npx2Banks/checkerboardAligned/resultsStruct.mat', 'resultsStruct')