% in this code, we decode pure choice. 
% then we decode cxt, RL vs GR, RR vs GL


clear; close all; clc

load('~/Desktop/allBinFR_V50_5_vprobe.mat')

binSize = 50;
stepSize = 5;


tStart = -1000;
tEnd = 1000; 
timeAxis = [tStart+binSize:stepSize:tEnd];
tSelected = timeAxis > 50 & timeAxis <= 300;

time = timeAxis(tSelected);

accuracy = struct;


%%
parfor dayn = 1:length(allBinFR)
    
    
    %% binary decoding (choice)
    
    trials = allBinFR(dayn).trials;
    taskLabels = allBinFR(dayn).taskLabels;

    train_y = (taskLabels == 0 | taskLabels == 2)';


    accuracy(dayn).choiceAcc = binaryDecode(trials, train_y);

    % 
    % for t = 1:size(trials,3)
    %     t1 = squeeze(trials(:,:,t));
    % 
    % 
    % %     md1 = fitcsvm(t1, train_y,  'KFold', 5, 'KernelFunction','linear');
    %     md1 = fitclinear(t1, train_y, 'learner', 'logistic', 'KFold', 5);
    % 
    % 
    %     error = kfoldLoss(md1);
    %     accuracy = 1 - error;
    %     fprintf('time: %d, accuracy: %.2f', time(t), accuracy);
    %     fprintf('\n')    
    % end





    %% decode RL & GR

    trials = allBinFR(dayn).trials;
    taskLabels = allBinFR(dayn).taskLabels;

    select = (taskLabels == 0 | taskLabels == 3);

    trials = trials(select,:,:);
    train_y = taskLabels(select)';



    accuracy(dayn).RLGR_acc = binaryDecode(trials, train_y);


    % for t = 1:size(trials,3)
    %     t1 = squeeze(trials(:,:,t));
    % 
    % 
    % %     md1 = fitcsvm(t1, train_y,  'KFold', 5, 'KernelFunction','linear');
    %     md1 = fitclinear(t1, train_y, 'learner', 'logistic', 'KFold', 5);
    % 
    % 
    %     error = kfoldLoss(md1);
    %     accuracy = 1 - error;
    %     fprintf('time: %d, accuracy: %.2f', time(t), accuracy);
    %     fprintf('\n')    
    % end


    %% decode RR & GL


    trials = allBinFR(dayn).trials;
    taskLabels = allBinFR(dayn).taskLabels;

    select = (taskLabels == 1 | taskLabels == 2);

    trials = trials(select,:,:);
    train_y = taskLabels(select)';


    accuracy(dayn).RRGL_acc = binaryDecode(trials, train_y);


    % for t = 1:size(trials,3)
    %     t1 = squeeze(trials(:,:,t));
    % 
    % 
    % %     md1 = fitcsvm(t1, train_y,  'KFold', 5, 'KernelFunction','linear');
    %     md1 = fitclinear(t1, train_y, 'learner', 'logistic', 'KFold', 5);
    % 
    % 
    %     error = kfoldLoss(md1);
    %     accuracy = 1 - error;
    %     fprintf('time: %d, accuracy: %.2f', time(t), accuracy);
    %     fprintf('\n')    
    % end



    fprintf("dayn: %d finished \n", dayn);

end

% save('~/Desktop/nonlinearAcc_vprobe.mat', 'accuracy');



%% plot results

for ip = 1:length(accuracy)
    
    choiceAcc(:,ip) = accuracy(ip).choiceAcc;
    RLGR_acc(:,ip) = accuracy(ip).RLGR_acc;
    RRGL_acc(:,ip) = accuracy(ip).RRGL_acc;
end



%%
a = figure('Position', [10 10 900 600]);

options.handle = a;
options.error = 'c99';
options.color_area = [243 169 114]./255;    % Orange theme
options.color_line = [236 112  22]./255;
options.alpha      = 0.5;
options.line_width = 2;
options.x_axis = time;
plot_areaerrorbar(choiceAcc', options)
% ylim([0.4 1])
% xlim([-100, 400])


options.color_area = [128 193 219]./255;    % Blue theme
options.color_line = [ 52 148 186]./255;
plot_areaerrorbar(RLGR_acc', options)


options.color_area = [0 193 219]./255;    % green theme
options.color_line = [ 0 148 186]./255;
plot_areaerrorbar(RRGL_acc', options)



%% permutation test (choice)

tic
nPerm = 100;

dayn = 1;
% use 1st bin as example 
trials = allBinFR(dayn).trials;
taskLabels = allBinFR(dayn).taskLabels;
train_y = (taskLabels == 0 | taskLabels == 2)';

parfor t = 20:35
    
    
    t1 = trials(:,:,t);

    perm_accChoice(t-19, :) = permutation_test(t1, train_y, nPerm);

    % acc_perm = zeros(nPerm, 1);
    % 
    % for i = 1:nPerm
    %     y_perm = train_y(randperm(length(train_y)));  % shuffle labels
    % 
    %     % Train on permuted labels
    %     model_perm = fitclinear(t1, y_perm, 'learner', 'logistic', 'KFold', 5);
    %         
    %     
    %     error = kfoldLoss(model_perm);
    % 
    %     % Save accuracy
    %     perm_acc(i) = 1-error;
    % end


end
toc


%% permutation test (RLGR)

tic
nPerm = 100;

dayn = 1;
% use 1st bin as example 
trials = allBinFR(dayn).trials;
taskLabels = allBinFR(dayn).taskLabels;

select = (taskLabels == 0 | taskLabels == 3);

trials = trials(select,:,:);
train_y = taskLabels(select)';

parfor t = 20:35
    
    
    t1 = trials(:,:,t);

    perm_accRLGR(t-19, :) = permutation_test(t1, train_y, nPerm);

    % acc_perm = zeros(nPerm, 1);
    % 
    % for i = 1:nPerm
    %     y_perm = train_y(randperm(length(train_y)));  % shuffle labels
    % 
    %     % Train on permuted labels
    %     model_perm = fitclinear(t1, y_perm, 'learner', 'logistic', 'KFold', 5);
    %         
    %     
    %     error = kfoldLoss(model_perm);
    % 
    %     % Save accuracy
    %     perm_acc(i) = 1-error;
    % end


end
toc


%% permutation test (RRGL)

tic
nPerm = 100;

dayn = 1;
% use 1st bin as example 
trials = allBinFR(dayn).trials;
taskLabels = allBinFR(dayn).taskLabels;


select = (taskLabels == 1 | taskLabels == 2);

trials = trials(select,:,:);
train_y = taskLabels(select)';

parfor t = 20:35
    
    
    t1 = trials(:,:,t);

    perm_accRRGL(t-19, :) = permutation_test(t1, train_y, nPerm);

    % acc_perm = zeros(nPerm, 1);
    % 
    % for i = 1:nPerm
    %     y_perm = train_y(randperm(length(train_y)));  % shuffle labels
    % 
    %     % Train on permuted labels
    %     model_perm = fitclinear(t1, y_perm, 'learner', 'logistic', 'KFold', 5);
    %         
    %     
    %     error = kfoldLoss(model_perm);
    % 
    %     % Save accuracy
    %     perm_acc(i) = 1-error;
    % end


end
toc



%% 

load('~/Desktop/nonlinearAcc.mat')

prc99 = prctile(perm_accChoice,99,2);
temp = choiceAcc(20:35,1);

realChoice = temp.*(temp > prc99);

plot(time(20:35), realChoice)

%%
prc99 = prctile(perm_accRLGR,99,2);
temp = RLGR_acc(20:35,1);

realRLGR = temp.*(temp > prc99);

plot(time(20:35), realRLGR)

%%
prc99 = prctile(perm_accRRGL,99,2);
temp = RRGL_acc(20:35,1);

realRRGL = temp.*(temp > prc99);

plot(time(20:35), realRRGL)

%% 
figure; hold on
plot(time(20:35), realChoice, 'o')
plot(time(20:35), realRLGR, 'o')
plot(time(20:35), realRRGL, 'o')

