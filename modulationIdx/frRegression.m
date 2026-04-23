% for each day's dataset, use color, cxt and dir to regress FR, calculate 
% how much variance in FR can be explaiend by task variables
clear; clc; close all

dataSet = 'TFC'; 

switch(dataSet)
    case {'CFDC', 'TFT'}
    resultsStruct= struct('R_squared', [], 'model', [], 'regressor', []);

    case {'CFDT', 'TFC'}
        resultsStructColor = struct('R_squared', [], 'model', [], 'regressor', []);
        resultsStructCxt = struct('R_squared', [], 'model', [], 'regressor', []);
        resultsStructSide = struct('R_squared', [], 'model', [], 'regressor', []);
end 

% gaussian kernal
g = normpdf([-0.1:0.001:0.1],0,0.025);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Path which store raster plot data created by createPCADataTian.m %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dataDir = '/Volumes/TianSSD/TiberiusDLPFCRaster/RasterC/';
files = dir(fullfile(dataDir, '202*.mat'));


%%
for dayn = 1:length(files)

        
    % load raster plot data
    data = load([dataDir files(dayn).name]).dataframe;

    % only choose correct trials
    dataTable = struct2table(data);
    outcomeTable = dataTable(:,{'TrialOutcome'});
    outcomeCell = table2cell(outcomeTable);
    correct = strcmp(outcomeCell, 'Correct Choice')';
    data = data(correct); 
    

    perf = [data.performance];


    % left and right trials
    perfTable = struct2table(perf);
    a = perfTable(:,{'ChosenSide'});
    b = table2cell(a);
    left = strcmp(b, 'left')';
    right = strcmp(b, 'right')';    
    
    % chosen color 
    colorTable = perfTable(:,{'ChosenColor'});
    colorCell = table2cell(colorTable);
    green = strcmp(colorCell, 'green')';
    red = strcmp(colorCell, 'red')';     
    
    % cxt1: GL&RR; cxt2: GR&RL
    dataParams = [data.params];
    leftColor = [dataParams.LeftTargetColor];
    rightColor = [dataParams.RightTargetColor];
    
    cxt1 = leftColor == 2 & rightColor == 3;
    cxt2 = leftColor == 3 & rightColor == 2;

    
    % dimension of data: n (#neurons); m (#trials); t(#timepoints);
    [n, t] = size(data(1).rasterC);

    % window size to reserve after convolution
    % original data span: -0.8:2.4 aligne dwith taraget (target appears at 0)
    % after conv: -0.6:2.2 aligned with target (target appears at 0)

    % original data span: -1:1.6 aligne dwith taraget (target appears at 0)
    % after conv: -0.8:1.4 aligned with target (target appears at 0)    
    window = length(g) :(t-length(g))+1;
    t = length(window);

    time = round(-0.8:0.001:1.4-0.001, 3);
    selectWindow = [0, 0.7000];
    [~, iloc] = ismember(selectWindow, time);

    m = length(data);
    
    % create FR matrix 
    FR_matrix = zeros(n, t, m);
    for ii = 1:m
        for jj = 1:n
            temp = data(ii).rasterC(jj,:);
            temp = conv(temp, g, 'same');
            % make sure there is no NaN in the FR_matrix
            if sum(isnan(temp)) ~= 0 | isempty(temp)
                temp = zeros(1,t);
            end

            FR_matrix(jj,:,ii) = temp(window);
        end
    end    
    % select time from FR_matrix   
    FR = FR_matrix(:,iloc(1):iloc(2),:);
    




    color = red'; 
    cxt = cxt1'; 
    side = left'; 

    numUnits = size(FR, 1);
    numTimepoints = size(FR, 2); 
    numTrials = size(FR, 3); 

    %% bin activity (100ms overlapping bins) 

    timeSteps = 1:10:numTimepoints(end)-100;

    allNeuralValues = struct('unitValues', cell(1, numUnits));

    for unitIndex = 1:numUnits
        neural_activity_unit = squeeze(FR(unitIndex, 1:numTimepoints, :));
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
            for l = 1:numUnits
                for i = 1:numBin
                    y = allNeuralValues(l).unitValues(:, i); 
        
                    model = fitlm(cxt,y); 
                    results(l, i) = model.Rsquared.Ordinary;
                end 
        
            end
        
            % store results 
            resultsStruct(dayn).R_squared = results;
            resultsStruct(dayn).model = model;
            resultsStruct(dayn).regressor = 'cxt'; 
            resultsStruct(dayn).inputData = dataSet; 


        case {'CFDT', 'TFC'}
            for l = 1:numUnits
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
            resultsStructColor(dayn).R_squared = resultsColor;
            resultsStructColor(dayn).model = modelColor;
            resultsStructColor(dayn).regressor = 'Color'; 
            resultsStructColor(dayn).inputData = dataSet; 

            resultsStructCxt(dayn).R_squared = resultsCxt;
            resultsStructCxt(dayn).model = modelCxt;
            resultsStructCxt(dayn).regressor = 'Cxt'; 
            resultsStructCxt(dayn).inputData = dataSet; 

            resultsStructSide(dayn).R_squared = resultsSide;
            resultsStructSide(dayn).model = modelSide;
            resultsStructSide(dayn).regressor = 'Side'; 
            resultsStructSide(dayn).inputData = dataSet; 
            
            % append all 
            resultsStruct = [resultsStructColor, resultsStructCxt, resultsStructSide]; 

    end

end








%% plot the results 

% dataSet = 'TFC'; 
% load resultsStructTFT.mat

switch(dataSet)
    case {'CFDC', 'TFT'}

    for dayn = 1:length(resultsStruct)
        figure; 
        title('color')
        hold on 
        for i = 1:size(resultsStruct(dayn).R_squared)
            plot(resultsStruct(dayn).R_squared(i, :))
        end 
    
        pause; 
        close; 
    end 
        
    case {'CFDT', 'TFC'}
     
   for dayn = 1:length(resultsStruct)
        figure; 
        title(resultsStruct(dayn).regressor)
        hold on 
        for i = 1:size(resultsStruct(dayn).R_squared)
            plot(resultsStruct(dayn).R_squared(i, :))
        end 

        pause; 
        close; 
    end 

end 

