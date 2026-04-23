% build all 6 decoders on correct and wrong trials 

binFR = load('wrongTrials.mat').wrongTrials;

% binFR = load('correctTrials.mat').correctTrials;

accuracy = struct;
parfor dayn = 1:16%length(binFR)
    
    
    % binary decoding (choice)
     
    trials = binFR(dayn).trials;
    taskLabels = binFR(dayn).labels;
    train_y = (taskLabels == 0 | taskLabels == 2)';


    train_y = (taskLabels == 0 | taskLabels == 2)';

    accuracy(dayn).choiceAcc = binaryDecode(trials, train_y)';       

    
   
    fprintf("dayn: %d finished \n", dayn);
    
    
    
    %% decode RL & RR
    
    trials = binFR(dayn).trials;
    taskLabels = binFR(dayn).labels;


    RLtrials = find(taskLabels == 0);  
    
    RRtrials = find(taskLabels == 1);
    
    select = [RLtrials, RRtrials];
        
    train_x = trials(select,:,:);
    train_y = taskLabels(select)';



    accuracy(dayn).RLRR_acc = binaryDecode(train_x, train_y);    

    
    %% decode RL & GL
    
    trials = binFR(dayn).trials;
    taskLabels = binFR(dayn).labels;


    RLtrials = find(taskLabels == 0);  
    
    GLtrials = find(taskLabels == 2);
    
    select = [RLtrials, GLtrials];
        
    train_x = trials(select,:,:);
    train_y = taskLabels(select)';



    accuracy(dayn).RLGL_acc = binaryDecode(train_x, train_y);    
    %% decode RL & GR

    trials = binFR(dayn).trials;
    taskLabels = binFR(dayn).labels;


    RLtrials = find(taskLabels == 0);  
    
    GRtrials = find(taskLabels == 3);
    
    select = [RLtrials, GRtrials];
        
    train_x = trials(select,:,:);
    train_y = taskLabels(select)';



    accuracy(dayn).RLGR_acc = binaryDecode(train_x, train_y);

    
    %% decode RR & GR


    trials = binFR(dayn).trials;
    taskLabels = binFR(dayn).labels;

    RRtrials = find(taskLabels == 1);  
    
    GRtrials = find(taskLabels == 3);
    
    select = [RRtrials, GRtrials];
        
    train_x = trials(select,:,:);
    train_y = taskLabels(select)';


    accuracy(dayn).RRGR_acc = binaryDecode(train_x, train_y);

    

    %% decode RR & GL


    trials = binFR(dayn).trials;
    taskLabels = binFR(dayn).labels;

    RRtrials = find(taskLabels == 1);  
    
    GLtrials = find(taskLabels == 2);
    
    select = [RRtrials, GLtrials];
        
    train_x = trials(select,:,:);
    train_y = taskLabels(select)';

    accuracy(dayn).RRGL_acc = binaryDecode(train_x, train_y);

    %% decode GL & GR


    trials = binFR(dayn).trials;
    taskLabels = binFR(dayn).labels;

    GRtrials = find(taskLabels == 3);  
    
    GLtrials = find(taskLabels == 2);
    
    select = [GRtrials, GLtrials];
        
    train_x = trials(select,:,:);
    train_y = taskLabels(select)';

    accuracy(dayn).GRGL_acc = binaryDecode(train_x, train_y);



    fprintf("dayn: %d finished \n", dayn);    
    
    
    
    
    
    
    
    
    

end

%% 

% time = linspace(-200,200,81);
time = linspace(-50,500,111);


choiceAcc = [];
RLGR_acc = [];
RRGL_acc = [];
for ip = 1:length(accuracy)
    
    choiceAcc(:,ip) = accuracy(ip).choiceAcc;
    RLRR_acc(:,ip) = accuracy(ip).RLRR_acc;
    RLGL_acc(:,ip) = accuracy(ip).RLGL_acc;
    RLGR_acc(:,ip) = accuracy(ip).RLGR_acc;
    
    RRGR_acc(:,ip) = accuracy(ip).RRGR_acc;
    RRGL_acc(:,ip) = accuracy(ip).RRGL_acc;
    GRGL_acc(:,ip) = accuracy(ip).GRGL_acc;
    
    
end

% figure; hold on
% 
% plot(time, mean(choiceAcc,2), 'r')
% plot(time, mean(RLRR_acc,2), 'm')
% plot(time, mean(RLGL_acc,2), 'm')
% plot(time, mean(RLGR_acc,2), 'm')
% plot(time, mean(RRGR_acc,2), 'm')
% plot(time, mean(RRGL_acc,2), 'm')
% plot(time, mean(GRGL_acc,2), 'm')

%% 


plot(time, mean(choiceAcc,2), 'k')
plot(time, mean(RLRR_acc,2), 'b')
plot(time, mean(RLGL_acc,2), 'b')
plot(time, mean(RLGR_acc,2), 'b')
plot(time, mean(RRGR_acc,2), 'b')
plot(time, mean(RRGL_acc,2), 'b')
plot(time, mean(GRGL_acc,2), 'b')

%%

plot(time, mean(RLRR_acc,2), 'c', 'linewidth', 2)
plot(time, mean(GRGL_acc,2), 'c', 'linewidth', 2)

%% 

a = figure('Position', [10 10 900 500]);

options.handle = gcf;
options.error = 'sem';
options.alpha  = 0.3;
options.line_width = 2;
options.x_axis = time;

options.color_area = [0 193 219]./255;    % green theme
options.color_line = [ 0 148 186]./255;
plot_areaerrorbar(RLRR_acc', options)


options.color_area = [0 193 219]./255;    % green theme
options.color_line = [ 0 148 186]./255;
plot_areaerrorbar(RLGL_acc', options)


options.color_area = [0 193 219]./255;    % green theme
options.color_line = [ 0 148 186]./255;
plot_areaerrorbar(RLGR_acc', options)


options.color_area = [0 193 219]./255;    % green theme
options.color_line = [ 0 148 186]./255;
plot_areaerrorbar(RRGR_acc', options)


options.color_area = [0 193 219]./255;    % green theme
options.color_line = [ 0 148 186]./255;
plot_areaerrorbar(RRGL_acc', options)


options.color_area = [0 193 219]./255;    % green theme
options.color_line = [ 0 148 186]./255;
plot_areaerrorbar(GRGL_acc', options)


