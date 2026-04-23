% in this code, we decode choice and color for 2 easiest difficulties 
% on only correct trials

clear; close all; clc


addpath('../nonlinear_decoding/')

%% load dlpfc
load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/checkerboardAligned/allBinFRnpix.mat');


temp = allBinFR;

temp(18).trials = cat(2, temp(18).trials, temp(19).trials);
temp(19) = [];

allBinFR = temp;


a = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Vinnie/checkerboardAligned/allBinFRnpix.mat').allBinFR;

allBinFR = [allBinFR, a];

%%
allTime = allBinFR(1).time;

tStart = -50;
tEnd = 500; 
tSelected = allTime >= tStart & allTime <= tEnd;

time = allTime(tSelected);

for ii = 1:length(allBinFR)
    
    allBinFR(ii).trials = allBinFR(ii).trials(:,:,tSelected);
    allBinFR(ii).time = allBinFR(ii).time(tSelected);

end


% cueC = {[180 214] [147 158] [67 78] [11 45]};

cueC = {[180 214] [147 158] [117 124 135] [90 101 108] [67 78] [11 45]};


%%

parfor dayn = 1:length(allBinFR)
    
    
    %% binary decoding (choice)
    

    
    
        
    trials = allBinFR(dayn).trials;
    taskLabels = allBinFR(dayn).taskLabels;

    behavior = allBinFR(dayn).behavior;
    cue = [behavior.cue];   
    

    
    %%%%%%%%%%%%%%%%%%% choose all correct trials 

    correct = [behavior.correctness] == 1;
    
    selectW = [behavior.correctness] == 0 & ismember(cue, [117 124 135 90 101 108]);
    WtaskLabels = taskLabels(selectW);
    WminTrials = min([sum(WtaskLabels == 0), sum(WtaskLabels == 1), sum(WtaskLabels == 2), sum(WtaskLabels == 3)])

    
    trials = trials(correct,:,:);
    taskLabels = taskLabels(correct);
    cue = cue(correct);
    %%%%%%%%%%%%%%%%%%
    
    if WminTrials > 5 && size(trials,2) > 20

        for is = 1:length(cueC)/2
            select = ismember(cue, cueC{is}) | ismember(cue, cueC{length(cueC) + 1-is});

            Strials = trials(select,:,:);
            StaskLabels = taskLabels(select);
            
            % L vs R
            Ltrials = find(StaskLabels == 0 | StaskLabels == 2);  
            Rtrials = find(StaskLabels == 1 | StaskLabels == 3);

            minTrials = min(length(Ltrials), length(Rtrials));
            selectLR = [Ltrials(1:minTrials), Rtrials(1:minTrials)];


            train_y = StaskLabels(selectLR)';
            train_y = (train_y == 0 | train_y == 2);
            train_x = Strials(selectLR,:,:);       

            accuracy(dayn).choiceAcc(:,is) = binaryDecode(train_x, train_y)';       

            
            % R vs G
            Rtrials = find(StaskLabels == 0 | StaskLabels == 1);  
            Gtrials = find(StaskLabels == 2 | StaskLabels == 3);

            minTrials = min(length(Rtrials), length(Gtrials));
            selectRG = [Rtrials(1:minTrials), Gtrials(1:minTrials)];


            train_y = StaskLabels(selectRG)';
            train_y = (train_y == 0 | train_y == 1);
            train_x = Strials(selectRG,:,:);       

            accuracy(dayn).colorAcc(:,is) = binaryDecode(train_x, train_y)';                
            
        end

        
    end
        
    
    %% decode RL & GR



    fprintf("dayn: %d finished \n", dayn);

end

%% 
isEmpty = cellfun(@isempty, {accuracy.choiceAcc});
accuracy = accuracy(~isEmpty);

% save('choice_colorAcc_allStim.mat', 'accuracy');
%% plot results

% load('pfcStimulus.mat')


time = -50:5:500;

choiceAcc = [];
colorAcc = [];

for ip = 1:length(accuracy)
    
    choiceAcc(:,1,ip) = accuracy(ip).choiceAcc(:,1);
    choiceAcc(:,2,ip) = accuracy(ip).choiceAcc(:,2);
    
    colorAcc(:,1,ip) = accuracy(ip).colorAcc(:,1);
    colorAcc(:,2,ip) = accuracy(ip).colorAcc(:,2);
      
    
end



%%
a = figure('Position', [10 10 900 500]);

options.handle = a;
options.error = 'sem';
options.color_area = [243 169 114]./255;    % Orange theme
options.color_line = [236 112  22]./255;
options.alpha      = 0.7;
options.line_width = 2;
options.x_axis = time;
plot_areaerrorbar(squeeze(choiceAcc(:,1,:))', options)

options.alpha      = 0.4;
plot_areaerrorbar(squeeze(choiceAcc(:,2,:))', options)


ylim([0.45 1])
xlim([-50, 500])

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig4/', 'pfcChoiceDecoder_cueEqualTrials', '.eps']);

%%
a = figure('Position', [10 10 900 500]);

options.handle = a;
options.error = 'sem';
options.color_area = [243 169 114]./255;    % Orange theme
options.color_line = [236 112  22]./255;
options.alpha      = 0.7;
options.line_width = 2;
options.x_axis = time;
plot_areaerrorbar(squeeze(colorAcc(:,1,:))', options)

options.alpha      = 0.4;
plot_areaerrorbar(squeeze(colorAcc(:,2,:))', options)


ylim([0.45 1])
xlim([-50, 500])


% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig4/', 'pfcNlinrDecoder_cueEqualTrials', '.eps']);


%% 


