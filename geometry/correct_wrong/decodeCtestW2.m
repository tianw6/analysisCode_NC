% in this code, we train decoder on correct trials and test on correct and error trials
% for pure choice, and nonlinear chocie. 

clear; close all; clc


addpath('../pca_visualize/')


load('wrongTrials.mat')
load('correctTrialsAll.mat')



%%

accuracy = struct;

parfor dayn = 1:16%length(wrongTrials)
    
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


    %% decode RL & GR

    trials      = correctTrials(dayn).trials;
    taskLabels  = correctTrials(dayn).labels;

    wtrials     = wrongTrials(dayn).trials;
    wtaskLabels = wrongTrials(dayn).labels;

    % Indices for labels 0 and 3 in correct trials
    RLtrials = find(taskLabels == 0);
    GRtrials = find(taskLabels == 3);

    % Assume minTrials is already defined outside (balanced sampling)
    select = [RLtrials(1:minTrials), GRtrials(1:minTrials)];

    % Full (balanced) training set before splitting
    train_x_all = trials(select, :, :);      % size: M × units × time
    train_y_all = taskLabels(select)';       % size: M × 1


    % ----- Wrong-trial test set (original) -----
    selectW = (wtaskLabels == 0 | wtaskLabels == 3);
    test_x  = wtrials(selectW, :, :);
    test_y  = wtaskLabels(selectW)';


    % ===== Create test_x2 / test_y2 from correct trials, and remove from train =====

    % Number of trials to hold out from the correct-trial pool
    numTest2 = size(test_x, 1);          % same #trials as wrong-trial test set

    M = size(train_x_all, 1);            % total balanced correct trials

    idx_test2 = randperm(M, numTest2);   % indices for test_x2/test_y2
    idx_train = setdiff(1:M, idx_test2); % remaining for training

    % New held-out set from correct trials
    test_x2 = train_x_all(idx_test2, :, :);
    test_y2 = train_y_all(idx_test2);

    % Final training set (with those trials removed)
    train_x = train_x_all(idx_train, :, :);
    train_y = train_y_all(idx_train);

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
    
    accuracy(dayn).RLGRAccC = correct_accuracy;
    accuracy(dayn).RLGRAccW = wrong_accuracy;
    

    %% decode RR & GL

    trials      = correctTrials(dayn).trials;
    taskLabels  = correctTrials(dayn).labels;

    wtrials     = wrongTrials(dayn).trials;
    wtaskLabels = wrongTrials(dayn).labels;

    % Indices for labels 1 and 2 in correct trials
    RRtrials = find(taskLabels == 1);
    GLtrials = find(taskLabels == 2);

    % Assume minTrials is already defined outside (balanced sampling)
    select = [RRtrials(1:minTrials), GLtrials(1:minTrials)];

    % Full (balanced) training set before splitting
    train_x_all = trials(select, :, :);      % size: M × units × time
    train_y_all = taskLabels(select)';       % size: M × 1


    % ----- Wrong-trial test set (original) -----
    selectW = (wtaskLabels == 1 | wtaskLabels == 2);
    test_x  = wtrials(selectW, :, :);
    test_y  = wtaskLabels(selectW)';


    % ===== Create test_x2 / test_y2 from correct trials, and remove from train =====

    % Number of trials to hold out from the correct-trial pool
    numTest2 = size(test_x, 1);          % same #trials as wrong-trial test set

    M = size(train_x_all, 1);            % total balanced correct trials

    idx_test2 = randperm(M, numTest2);   % indices for test_x2/test_y2
    idx_train = setdiff(1:M, idx_test2); % remaining for training

    % New held-out set from correct trials
    test_x2 = train_x_all(idx_test2, :, :);
    test_y2 = train_y_all(idx_test2);

    % Final training set (with those trials removed)
    train_x = train_x_all(idx_train, :, :);
    train_y = train_y_all(idx_train);

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
    
    accuracy(dayn).RRGLAccC = correct_accuracy;
    accuracy(dayn).RRGLAccW = wrong_accuracy;
    
    fprintf("dayn: %d finished \n", dayn)

end

%% 



time = linspace(-50,500,111);
% time = linspace(-200,200,81);


correctAcc = [];
wrongAcc = [];
RLGRAccC = [];
RLGRAccW = [];
RRGLAccC = [];
RRGLAccW = [];
for ip = 1:length(accuracy)
    
    correctAcc(:,ip) = accuracy(ip).choiceAccC;
    wrongAcc(:,ip) = accuracy(ip).choiceAccW;
    
    RLGRAccC(:,ip) = accuracy(ip).RLGRAccC;
    RLGRAccW(:,ip) = accuracy(ip).RLGRAccW;

    RRGLAccC(:,ip) = accuracy(ip).RRGLAccC;
    RRGLAccW(:,ip) = accuracy(ip).RRGLAccW;
    
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
plot_areaerrorbar(correctAcc', options)


options.color_area = [128 193 219]./255;    % Blue theme
options.color_line = [ 52 148 186]./255;
plot_areaerrorbar(wrongAcc', options)


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
plot_areaerrorbar(RLGRAccC', options)


options.color_area = [128 193 219]./255;    % Blue theme
options.color_line = [ 52 148 186]./255;
plot_areaerrorbar(RLGRAccW', options)


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
plot_areaerrorbar(RRGLAccC', options)


options.color_area = [128 193 219]./255;    % Blue theme
options.color_line = [ 52 148 186]./255;
plot_areaerrorbar(RRGLAccW', options)


ylim([0.45 0.8])
% xlim([-50, 400])
