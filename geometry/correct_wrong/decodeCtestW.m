% in this code, we decode pure choice. 
% then we decode RL vs GR, RR vs GL
% for 5 simultaneous recording days

clear; close all; clc


addpath('../pca_visualize/')


load('wrongTrials.mat')
load('correctTrialsAll.mat')



%%

accuracy = struct;

parfor dayn = 1:23%length(wrongTrials)
    
    % binary decoding (choice)
    
    trials = correctTrials(dayn).trials;
    taskLabels = correctTrials(dayn).labels;

    wtrials = wrongTrials(dayn).trials;
    wtaskLabels = wrongTrials(dayn).labels;
    
    
    minTrials = min([sum(taskLabels == 0), sum(taskLabels == 1),sum(taskLabels == 2),sum(taskLabels == 3)]);
    
    wTrials = min([sum(wtaskLabels == 0), sum(wtaskLabels == 1),sum(wtaskLabels == 2),sum(wtaskLabels == 3)]);

    

    Ltrials = (taskLabels == 0 | taskLabels == 2);  
    
    
    train_y = Ltrials';
    train_x = trials;

        
    test_y = (wtaskLabels == 0 | wtaskLabels == 2)';
    test_x = wtrials;

    
    
    cv_accuracy = [];
    test_accuracy = [];
    
    for t = 1:size(trials,3)

        t1 = squeeze(train_x(:,:,t));
        t2 = squeeze(test_x(:,:,t));

        % --- Cross-validation on training set ---
        CVMdl = fitclinear(t1, train_y, 'Learner', 'logistic', 'KFold', 5);
        cv_error = kfoldLoss(CVMdl);
        cv_accuracy(t) = 1 - cv_error;

        % --- Final model trained on all training data ---
        finalModel = fitclinear(t1, train_y, 'Learner', 'logistic');

        % --- Test accuracy ---
        yhat_test = predict(finalModel, t2);
        test_accuracy(t) = mean(yhat_test == test_y);    
    
        
        
    end


    accuracy(dayn).choiceAccC = cv_accuracy;
    accuracy(dayn).choiceAccW = test_accuracy;


    %% decode RL & GR

    trials = correctTrials(dayn).trials;
    taskLabels = correctTrials(dayn).labels;

    wtrials = wrongTrials(dayn).trials;
    wtaskLabels = wrongTrials(dayn).labels;


    RLtrials = find(taskLabels == 0);  
    
    GRtrials = find(taskLabels == 3);
    
    select = [RLtrials(1:minTrials), GRtrials(1:minTrials)];
        
    train_x = trials(select,:,:);
    train_y = taskLabels(select)';

    selectW = wtaskLabels == 0 | wtaskLabels == 3;
    test_x = wtrials(selectW,:,:);    
    test_y = wtaskLabels(selectW)';
    


    cv_accuracy = [];
    test_accuracy = [];
    
    for t = 1:size(trials,3)

        t1 = squeeze(train_x(:,:,t));
        t2 = squeeze(test_x(:,:,t));

        % --- Cross-validation on training set ---
        CVMdl = fitclinear(t1, train_y, 'Learner', 'logistic', 'KFold', 5);
        cv_error = kfoldLoss(CVMdl);
        cv_accuracy(t) = 1 - cv_error;

        % --- Final model trained on all training data ---
        finalModel = fitclinear(t1, train_y, 'Learner', 'logistic');

        % --- Test accuracy ---
        yhat_test = predict(finalModel, t2);
        test_accuracy(t) = mean(yhat_test == test_y);    
    
        
        
    end
    
    accuracy(dayn).RLGRAccC = cv_accuracy;
    accuracy(dayn).RLGRAccW = test_accuracy;
    
    


    %% decode RR & GL

    trials = correctTrials(dayn).trials;
    taskLabels = correctTrials(dayn).labels;

    wtrials = wrongTrials(dayn).trials;
    wtaskLabels = wrongTrials(dayn).labels;


    RRtrials = find(taskLabels == 1);  
    
    GLtrials = find(taskLabels == 2);
    
    select = [RRtrials(1:minTrials), GLtrials(1:minTrials)];
        
    train_x = trials(select,:,:);
    train_y = taskLabels(select)';

    selectW = wtaskLabels == 1 | wtaskLabels == 2;
    test_x = wtrials(selectW,:,:);    
    test_y = wtaskLabels(selectW)';
    


    cv_accuracy = [];
    test_accuracy = [];
    
    for t = 1:size(trials,3)

        t1 = squeeze(train_x(:,:,t));
        t2 = squeeze(test_x(:,:,t));

        % --- Cross-validation on training set ---
        CVMdl = fitclinear(t1, train_y, 'Learner', 'logistic', 'KFold', 5);
        cv_error = kfoldLoss(CVMdl);
        cv_accuracy(t) = 1 - cv_error;

        % --- Final model trained on all training data ---
        finalModel = fitclinear(t1, train_y, 'Learner', 'logistic');

        % --- Test accuracy ---
        yhat_test = predict(finalModel, t2);
        test_accuracy(t) = mean(yhat_test == test_y);    
    
        
        
    end
    
    accuracy(dayn).RRGLAccC = cv_accuracy;
    accuracy(dayn).RRGLAccW = test_accuracy;
    
    fprintf("dayn: %d finished \n", dayn)

end

%% 



time = linspace(-100,400,91);
% time = linspace(-200,200,81);


correctAcc = [];
wrongAcc = [];
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


ylim([0.45 0.8])
xlim([-50, 400])



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


ylim([0.45 0.8])
xlim([-50, 400])

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
xlim([-50, 400])
