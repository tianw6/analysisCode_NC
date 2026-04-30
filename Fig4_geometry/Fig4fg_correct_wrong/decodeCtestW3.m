% in this code, we train decoder on correct trials and test on correct and error trials
% for config, color and choice. 


clear; close all; clc


addpath('../pca_visualize/')


load('wrongTrials.mat')
load('correctTrialsAll.mat')



%%

accuracy = struct;

parfor dayn = 1:length(wrongTrials)
    
    trials      = correctTrials(dayn).trials;      % m × n × t
    taskLabels  = correctTrials(dayn).labels;

    wtrials     = wrongTrials(dayn).trials;        % k × n × t
    wtaskLabels = wrongTrials(dayn).labels;

    minTrials = min([sum(taskLabels == 0), sum(taskLabels == 1),sum(taskLabels == 2),sum(taskLabels == 3)]);

    % Total number of wrong trials (existing test set)
    numTest = size(wtrials, 1);

    Ltrials = (taskLabels == 0 | taskLabels == 2);  

    train_x_full = trials;         % full training neural data
    train_y_full = Ltrials';       % full training labels


    % --- Randomly select a validation subset (same size as wrong trials) ---
    m = size(train_x_full, 1);     % number of correct trials

    idx_test2 = randperm(m, numTest);     % chosen validation trials
    idx_train = setdiff(1:m, idx_test2);  % remaining trials for training


    % Create correct test trials
    test_x2 = train_x_full(idx_test2, :, :);
    test_y2 = train_y_full(idx_test2);


    % create training trials
    train_x = train_x_full(idx_train, :, :);
    train_y = train_y_full(idx_train);


    % wrong-trial test set
    test_x = wtrials;
    test_y = (wtaskLabels == 0 | wtaskLabels == 2)';
    
    
    correct_accuracy = [];
    wrong_accuracy = [];
    
    for t = 1:size(trials,3)

        t1 = squeeze(train_x(:,:,t));
        t2 = squeeze(test_x(:,:,t));
        t3 = squeeze(test_x2(:,:,t));
        % --- Final model trained on all training data ---
        finalModel = fitclinear(t1, train_y, 'Learner', 'logistic');

        % --- correct trials accuracy ---
        y_testC = predict(finalModel, t3);
        correct_accuracy(t) = mean(y_testC == test_y2);            
        
        % --- wrong trials accuracy ---
        yhat_test = predict(finalModel, t2);
        wrong_accuracy(t) = mean(yhat_test == test_y);    
    
        
        
    end

    accuracy(dayn).choiceAccC = correct_accuracy;
    accuracy(dayn).choiceAccW = wrong_accuracy;


    %% decode red vs green 
    
    trials      = correctTrials(dayn).trials;      % m × n × t
    taskLabels  = correctTrials(dayn).labels;

    wtrials     = wrongTrials(dayn).trials;        % k × n × t
    wtaskLabels = wrongTrials(dayn).labels;

    minTrials = min([sum(taskLabels == 0), sum(taskLabels == 1),sum(taskLabels == 2),sum(taskLabels == 3)]);

    % Total number of wrong trials (existing test set)
    numTest = size(wtrials, 1);

    Ltrials = (taskLabels == 0 | taskLabels == 1);  

    train_x_full = trials;         % full training neural data
    train_y_full = Ltrials';       % full training labels


    % --- Randomly select a validation subset (same size as wrong trials) ---
    m = size(train_x_full, 1);     % number of correct trials

    idx_test2 = randperm(m, numTest);     % chosen validation trials
    idx_train = setdiff(1:m, idx_test2);  % remaining trials for training


    % Create correct test trials
    test_x2 = train_x_full(idx_test2, :, :);
    test_y2 = train_y_full(idx_test2);


    % create training trials
    train_x = train_x_full(idx_train, :, :);
    train_y = train_y_full(idx_train);


    % wrong-trial test set
    test_x = wtrials;
    test_y = (wtaskLabels == 0 | wtaskLabels == 1)';
    
    
    correct_accuracy = [];
    wrong_accuracy = [];
    
    for t = 1:size(trials,3)

        t1 = squeeze(train_x(:,:,t));
        t2 = squeeze(test_x(:,:,t));
        t3 = squeeze(test_x2(:,:,t));
        % --- Final model trained on all training data ---
        finalModel = fitclinear(t1, train_y, 'Learner', 'logistic');

        % --- correct trials accuracy ---
        y_testC = predict(finalModel, t3);
        correct_accuracy(t) = mean(y_testC == test_y2);            
        
        % --- wrong trials accuracy ---
        yhat_test = predict(finalModel, t2);
        wrong_accuracy(t) = mean(yhat_test == test_y);    
    
        
        
    end

    accuracy(dayn).colorAccC = correct_accuracy;
    accuracy(dayn).colorAccW = wrong_accuracy;
    
    

    %% decode config1 vs config2 
    
    trials      = correctTrials(dayn).trials;      % m × n × t
    taskLabels  = correctTrials(dayn).labels;

    wtrials     = wrongTrials(dayn).trials;        % k × n × t
    wtaskLabels = wrongTrials(dayn).labels;

    minTrials = min([sum(taskLabels == 0), sum(taskLabels == 1),sum(taskLabels == 2),sum(taskLabels == 3)]);

    % Total number of wrong trials (existing test set)
    numTest = size(wtrials, 1);

    Ltrials = (taskLabels == 0 | taskLabels == 3);  

    train_x_full = trials;         % full training neural data
    train_y_full = Ltrials';       % full training labels


    % --- Randomly select a validation subset (same size as wrong trials) ---
    m = size(train_x_full, 1);     % number of correct trials

    idx_test2 = randperm(m, numTest);     % chosen validation trials
    idx_train = setdiff(1:m, idx_test2);  % remaining trials for training


    % Create correct test trials
    test_x2 = train_x_full(idx_test2, :, :);
    test_y2 = train_y_full(idx_test2);


    % create training trials
    train_x = train_x_full(idx_train, :, :);
    train_y = train_y_full(idx_train);


    % wrong-trial test set
    test_x = wtrials;
    test_y = (wtaskLabels == 0 | wtaskLabels == 3)';
    
    
    correct_accuracy = [];
    wrong_accuracy = [];
    
    for t = 1:size(trials,3)

        t1 = squeeze(train_x(:,:,t));
        t2 = squeeze(test_x(:,:,t));
        t3 = squeeze(test_x2(:,:,t));
        % --- Final model trained on all training data ---
        finalModel = fitclinear(t1, train_y, 'Learner', 'logistic');

        % --- correct trials accuracy ---
        y_testC = predict(finalModel, t3);
        correct_accuracy(t) = mean(y_testC == test_y2);            
        
        % --- wrong trials accuracy ---
        yhat_test = predict(finalModel, t2);
        wrong_accuracy(t) = mean(yhat_test == test_y);    
    
        
        
    end

    accuracy(dayn).cxtAccC = correct_accuracy;
    accuracy(dayn).cxtAccW = wrong_accuracy;    
    
    
    
    
    fprintf("dayn: %d finished \n", dayn)

end

%% 

% save('projectWonC_accuracy.mat', 'accuracy');
%% 



time = linspace(-50,500,111);
% time = linspace(-200,200,81);


choiceAccC = [];
choiceAccW = [];
colorAccC = [];
colorAccW = [];
cxtAccC = [];
cxtAccW = [];
for ip = 1:length(accuracy)
    
    choiceAccC(:,ip) = accuracy(ip).choiceAccC;
    choiceAccW(:,ip) = accuracy(ip).choiceAccW;
    
    colorAccC(:,ip) = accuracy(ip).colorAccC;
    colorAccW(:,ip) = accuracy(ip).colorAccW;

    cxtAccC(:,ip) = accuracy(ip).cxtAccC;
    cxtAccW(:,ip) = accuracy(ip).cxtAccW;
    
end



%%
a = figure('Position', [10 10 900 500]);

options.handle = gcf;
options.error = 'sem';
options.color_area = [243 169 114]./255;    % Orange theme
options.color_line = [236 112  22]./255;
options.alpha      = 0.5;
options.line_width = 2;
options.x_axis = time;
plot_areaerrorbar(choiceAccC', options)


options.color_area = [128 193 219]./255;    % Blue theme
options.color_line = [ 52 148 186]./255;
plot_areaerrorbar(choiceAccW', options)


% ylim([0.45 0.8])
% xlim([-50, 400])



%% 


a = figure('Position', [10 10 900 500]);

options.handle = gcf;
options.error = 'sem';
options.color_area = [243 169 114]./255;    % Orange theme
options.color_line = [236 112  22]./255;
options.alpha      = 0.5;
options.line_width = 2;
options.x_axis = time;
plot_areaerrorbar(colorAccC', options)


options.color_area = [128 193 219]./255;    % Blue theme
options.color_line = [ 52 148 186]./255;
plot_areaerrorbar(colorAccW', options)


% ylim([0.45 0.8])
% xlim([-50, 400])

%% 
a = figure('Position', [10 10 900 500]);

options.handle = gcf;
options.error = 'sem';
options.color_area = [243 169 114]./255;    % Orange theme
options.color_line = [236 112  22]./255;
options.alpha      = 0.5;
options.line_width = 2;
options.x_axis = time;
plot_areaerrorbar(cxtAccC', options)


options.color_area = [128 193 219]./255;    % Blue theme
options.color_line = [ 52 148 186]./255;
plot_areaerrorbar(cxtAccW', options)


ylim([0.45 0.8])
% xlim([-50, 400])
