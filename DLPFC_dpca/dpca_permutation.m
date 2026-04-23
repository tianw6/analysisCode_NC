% permutation test of color and configuration on single trial bin fr counts neuropixel data aligns to checkerboard 
% shuffle color labels then average for color test; same logic for
% configuration

%% for dlpfc Data

addpath('../function_gradient/')
a = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/checkerboardAligned/allBinFRnpix.mat').allBinFR;

b = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Vinnie/checkerboardAligned/allBinFRnpix.mat').allBinFR;
% c = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/checkerboardAligned/allBinFRvprobe.mat').allBinFR;
% d = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Vinnie/checkerboardAligned/allBinFRvprobe.mat').allBinFR;

binFRpfc = [a, b];



allTime = binFRpfc(1).time;

tStart = -100;
tEnd = 500; 
tSelected = allTime >= tStart & allTime <= tEnd;

time = allTime(tSelected);



for ii = 1:length(binFRpfc)
    
    binFRpfc(ii).trials = binFRpfc(ii).trials(:,:,tSelected);
    binFRpfc(ii).time = binFRpfc(ii).time(tSelected);

end


%% Parameters
nPermutations = 100;
nSessions = length(binFRpfc);


%% Run color permutations

% Cell array to store all permuted datasets
permutedDatasetsColor = cell(nPermutations, 1);

fprintf('Running %d color permutations...\n', nPermutations);

for perm = 1:nPermutations
    if mod(perm, 10) == 0
        fprintf('Permutation %d/%d\n', perm, nPermutations);
    end
    
    % Cell array to store permuted data from each session
    sessionData = cell(nSessions, 1);
    
    for sess = 1:nSessions
        trials = binFRpfc(sess).trials; % #trials x #units x #time
        taskLabels = binFRpfc(sess).taskLabels; % #trials x 1
        
        nTrials = size(trials, 1);
        nUnits = size(trials, 2);
        nTime = size(trials, 3);
        
        % Extract original color and context labels
        % taskLabels: 0=red+ctx1, 1=red+ctx2, 2=green+ctx2, 3=green+ctx1
        originalColor = (taskLabels >= 2); % 0=red (0,1), 1=green (2,3)
        originalContext = (taskLabels == 1) | (taskLabels == 2); % 0=ctx1 (0,3), 1=ctx2 (1,2)
        
        % Randomly permute color labels (keep context fixed)
        permutedColor = originalColor(randperm(nTrials));
        
        % Create new task labels from permuted color + original context
        newTaskLabels = zeros(nTrials, 1);
        for i = 1:nTrials
            if permutedColor(i) == 0  % red
                if originalContext(i) == 0  % ctx1
                    newTaskLabels(i) = 0;  % red + ctx1
                else  % ctx2
                    newTaskLabels(i) = 1;  % red + ctx2
                end
            else  % green
                if originalContext(i) == 0  % ctx1
                    newTaskLabels(i) = 3;  % green + ctx1
                else  % ctx2
                    newTaskLabels(i) = 2;  % green + ctx2
                end
            end
        end
        
        % Average trials for each condition
        firingRatesSession = zeros(nUnits, 2, 2, nTime);
        
        for color = 0:1 % 0=red, 1=green
            for context = 0:1 % 0=ctx1, 1=ctx2
                % Map to the correct conditionLabel
                if color == 0  % red
                    conditionLabel = context;  % 0 or 1
                else  % green
                    conditionLabel = 3 - context;  % 3 or 2
                end
                
                trialIdx = (newTaskLabels == conditionLabel);
                
                if sum(trialIdx) > 0
                    % Average across trials: mean over dimension 1
                    firingRatesSession(:, color+1, context+1, :) = ...
                        squeeze(mean(trials(trialIdx, :, :), 1));
                end
            end
        end
        
        sessionData{sess} = firingRatesSession;
    end
    
    % Concatenate across sessions (along unit dimension)
    firingRatesAverage = cat(1, sessionData{:}); % totalUnits x 2 x 2 x nTime
    
    % Store this permuted dataset
    permutedDatasetsColor{perm} = firingRatesAverage;
end

fprintf('Done! Generated %d color-permuted datasets.\n', nPermutations);
fprintf('Each dataset has size: %s\n', mat2str(size(permutedDatasetsColor{1})));



% Permutation test - generate 100 context-permuted datasets
% Save permuted firingRatesAverage for each iteration



%% Run context permutations

% Cell array to store all permuted datasets
permutedDatasetsContext = cell(nPermutations, 1);

fprintf('Running %d context permutations...\n', nPermutations);

for perm = 1:nPermutations
    if mod(perm, 10) == 0
        fprintf('Permutation %d/%d\n', perm, nPermutations);
    end
    
    % Cell array to store permuted data from each session
    sessionData = cell(nSessions, 1);
    
    for sess = 1:nSessions
        trials = binFRpfc(sess).trials; % #trials x #units x #time
        taskLabels = binFRpfc(sess).taskLabels; % #trials x 1
        
        nTrials = size(trials, 1);
        nUnits = size(trials, 2);
        nTime = size(trials, 3);
        
        % Extract original color and context labels
        % taskLabels: 0=red+ctx1, 1=red+ctx2, 2=green+ctx2, 3=green+ctx1
        originalColor = (taskLabels >= 2); % 0=red (0,1), 1=green (2,3)
        originalContext = (taskLabels == 1) | (taskLabels == 2); % 0=ctx1 (0,3), 1=ctx2 (1,2)
        
        % Randomly permute context labels (keep color fixed)
        permutedContext = originalContext(randperm(nTrials));
        
        % Create new task labels from original color + permuted context
        newTaskLabels = zeros(nTrials, 1);
        for i = 1:nTrials
            if originalColor(i) == 0  % red
                if permutedContext(i) == 0  % ctx1
                    newTaskLabels(i) = 0;  % red + ctx1
                else  % ctx2
                    newTaskLabels(i) = 1;  % red + ctx2
                end
            else  % green
                if permutedContext(i) == 0  % ctx1
                    newTaskLabels(i) = 3;  % green + ctx1
                else  % ctx2
                    newTaskLabels(i) = 2;  % green + ctx2
                end
            end
        end
        
        % Average trials for each condition
        firingRatesSession = zeros(nUnits, 2, 2, nTime);
        
        for color = 0:1 % 0=red, 1=green
            for context = 0:1 % 0=ctx1, 1=ctx2
                % Map to the correct conditionLabel
                if color == 0  % red
                    conditionLabel = context;  % 0 or 1
                else  % green
                    conditionLabel = 3 - context;  % 3 or 2
                end
                
                trialIdx = (newTaskLabels == conditionLabel);
                
                if sum(trialIdx) > 0
                    % Average across trials: mean over dimension 1
                    firingRatesSession(:, color+1, context+1, :) = ...
                        squeeze(mean(trials(trialIdx, :, :), 1));
                end
            end
        end
        
        sessionData{sess} = firingRatesSession;
    end
    
    % Concatenate across sessions (along unit dimension)
    firingRatesAverage = cat(1, sessionData{:}); % totalUnits x 2 x 2 x nTime
    
    % Store this permuted dataset
    permutedDatasetsContext{perm} = firingRatesAverage;
end

fprintf('Done! Generated %d context-permuted datasets.\n', nPermutations);
fprintf('Each dataset has size: %s\n', mat2str(size(permutedDatasetsContext{1})));





%% 

combinedParams = {{1, [1 3]}, {2, [2 3]}, {3}, {[1 2], [1 2 3]}};
margNames = {'Stimulus', 'cxt', 'Condition-independent', 'S/D Interaction'};

% margNames = {'SC', 'Configuration', 'Condition-independent', 'C/D Interaction'};

margColours = [23 100 171; 187 20 25; 150 150 150; 114 97 171]/256;



%% permute color results
varAll = [];
for ii = 1:nPermutations
    fr = permutedDatasetsColor{ii};


    [W,V,whichMarg] = dpca(fr, 30, ...
        'combinedParams', combinedParams, 'lambda', 1e-9);

    explVar = dpca_explainedVariance(fr, W, V, ...
        'combinedParams', combinedParams);

    dpcaVar = explVar.totalMarginalizedVar / explVar.totalVar * 100;
    varAll(ii,:) = dpcaVar;
    if mod(ii,10) == 0
        fprintf('session %d finished \n', ii)
    end
    
end

histogram(varAll(:,1))


%% permute context results
varAll = [];
for ii = 1:nPermutations
    fr = permutedDatasetsContext{ii};


    [W,V,whichMarg] = dpca(fr, 30, ...
        'combinedParams', combinedParams, 'lambda', 1e-9);

    explVar = dpca_explainedVariance(fr, W, V, ...
        'combinedParams', combinedParams);

    dpcaVar = explVar.totalMarginalizedVar / explVar.totalVar * 100;
    varAll(ii,:) = dpcaVar;
    if mod(ii,10) == 0
        fprintf('session %d finished \n', ii)
    end
    
end

histogram(varAll(:,2))

%% 

normalizeData = 0;
[firingRatesAverage] = prepareFRaverage(binFRpfc, normalizeData);

[W,V,whichMarg] = dpca(firingRatesAverage, 30, ...
    'combinedParams', combinedParams, 'lambda', 1e-9);
toc

explVar = dpca_explainedVariance(firingRatesAverage, W, V, ...
    'combinedParams', combinedParams);

dpcaVar = explVar.totalMarginalizedVar / explVar.totalVar * 100
