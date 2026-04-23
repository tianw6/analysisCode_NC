% in this code, we decode pure choice. 
% then we decode RL vs GR, RR vs GL
% for 5 simultaneous recording days

clear; close all; clc

addpath('..')
addpath('../nonlinear_decoding/')

%% load dlpfc
load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/movementAligned/allBinFRnpix.mat');

temp = allBinFR;

temp(18).trials = cat(2, temp(18).trials, temp(19).trials);
temp(19) = [];

b = temp; 

a = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Vinnie/movementAligned/allBinFRnpix.mat').allBinFR;




% c = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/checkerboardAligned/allBinFRvprobe.mat').allBinFR;
% 
% 
% 
% d = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Vinnie/checkerboardAligned/allBinFRvprobe.mat').allBinFR;


% allBinFR = [temp, a, b, c];

allBinFR = [b, a];



%% 
ii = 1;
while ii < length(allBinFR)
    if (size(allBinFR(ii).trials,2)) < 15 
        allBinFR(ii) = [];
    else
        ii = ii+1;
    end
end
        
        

%% load pmd

% load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/checkerboardAligned/allBinFRnpixPMD.mat');

%%
allTime = allBinFR(1).time;

tStart = -200;
tEnd = 200; 
tSelected = allTime >= tStart & allTime <= tEnd;

time = allTime(tSelected);

for ii = 1:length(allBinFR)
    
    allBinFR(ii).trials = allBinFR(ii).trials(:,:,tSelected);
    allBinFR(ii).time = allBinFR(ii).time(tSelected);

end


% cueC = {[180 214] [147 158] [117 124 135] [90 101 108] [67 78] [11 45]};

cueC =  [135 124 117 108 101 90];

% cueC = [180 214 11 45];

% cueC = [147 158 67 78];

CorW = 'W';

%%
cnt = 1;
for dayn = 1:length(allBinFR)
    
    
    % binary decoding (choice)
    


        
    trials = allBinFR(dayn).trials;
    taskLabels = allBinFR(dayn).taskLabels;

    behavior = allBinFR(dayn).behavior;
    
    cue = [behavior.cue];    
    correct = [behavior.correctness];
 
    selectW = ismember(cue, cueC) & correct == 0;

    selectC = ismember(cue, cueC) & correct == 1;
     
    % select hardest trials correct and wrong
    Wtrials = trials(selectW,:,:);
    WtaskLabels = taskLabels(selectW);
    
    Ctrials = trials(selectC,:,:);
    CtaskLabels = taskLabels(selectC);
    
    
    
    minTrials = min([sum(WtaskLabels == 0), sum(WtaskLabels == 1), sum(WtaskLabels == 2), sum(WtaskLabels == 3)])
%     minTrials = min([sum(CtaskLabels == 0), sum(CtaskLabels == 1), sum(CtaskLabels == 2), sum(CtaskLabels == 3)]);
    
    if minTrials > 5 
        
        switch CorW
            case 'W'

                a = find(WtaskLabels == 0);
                b = find(WtaskLabels == 1);
                c = find(WtaskLabels == 2);
                d = find(WtaskLabels == 3);




                Wequal = [a(1:minTrials), b(1:minTrials), c(1:minTrials), d(1:minTrials)];

    %             Wequal = [a,b,c,d];

                Strials = Wtrials(Wequal,:,:);
                StaskLabels = WtaskLabels(Wequal);

            case 'C'

                a = find(CtaskLabels == 0);
                b = find(CtaskLabels == 1);
                c = find(CtaskLabels == 2);
                d = find(CtaskLabels == 3);


%                 Cequal = [a(1:minTrials), b(1:minTrials), c(1:minTrials), d(1:minTrials)];

                Cequal = [a, b, c, d];

                Strials = Ctrials(Cequal,:,:);
                StaskLabels = CtaskLabels(Cequal);            
        end




    %     find(CtaskLabels == 0)
    %     find(CtaskLabels == 1)
    %     find(CtaskLabels == 2)
    %     find(CtaskLabels == 3)
    %         
    %     

        Ctrain_y = (StaskLabels == 0 | StaskLabels == 2)';


        % equalize choice decoder and nonlinear decoder trials
        n = length(Ctrain_y)/4

        if (mod(n,2) == 0)
            randSelect = [1:n/2 n+1:n+n/2 2*n+1:2*n+n/2 3*n+1:3*n+n/2];
        else
            randSelect = [1:(n+1)/2 n+1:n+(n-1)/2 2*n+1:2*n+(n+1)/2 3*n+1:3*n+(n-1)/2];
        end

        choiceTrials = Strials(int32(randSelect),:,:);
        choiceTrain_y = Ctrain_y(int32(randSelect));

        accuracy(cnt).choiceAcc = binaryDecode(choiceTrials, choiceTrain_y)';       




        selectRLGR = (StaskLabels == 0 | StaskLabels == 3);

        RLGRtrials = Strials(selectRLGR,:,:);
        RLGRtrain_y = StaskLabels(selectRLGR)';

        accuracy(cnt).RLGR_acc = binaryDecode(RLGRtrials, RLGRtrain_y)';



        selectRRGL = (StaskLabels == 1 | StaskLabels == 2);

        RRGLtrials = Strials(selectRRGL,:,:);
        RRGLtrain_y = StaskLabels(selectRRGL)';

        accuracy(cnt).RRGL_acc = binaryDecode(RRGLtrials, RRGLtrain_y)';

        cnt = cnt+1;

    end
        
        
    
    %% decode RL & GR



    fprintf("dayn: %d finished \n", dayn);

end

% save('pfcAcc_correct.mat', 'accuracy');



%% plot results

% load('pfcAcc_correct.mat')

tStart = -200;
tEnd = 200; 
time = tStart:5:tEnd;


choiceAcc = [];
RLGR_acc = [];
RRGL_acc = [];
for ip = 1:length(accuracy)
    
    choiceAcc(:,ip) = accuracy(ip).choiceAcc;
    RLGR_acc(:,ip) = accuracy(ip).RLGR_acc;
    RRGL_acc(:,ip) = accuracy(ip).RRGL_acc;
    
end





%%

% a = figure('Position', [10 10 900 500]);

options.handle = gcf;
options.error = 'sem';
options.color_area = [243 169 114]./255;    % Orange theme
options.color_line = [236 112  22]./255;
options.alpha      = 0.5;
options.line_width = 2;
options.x_axis = time;
plot_areaerrorbar(choiceAcc', options)


% options.color_area = [128 193 219]./255;    % Blue theme
% options.color_line = [ 52 148 186]./255;
% plot_areaerrorbar(RLGR_acc', options)


options.color_area = [128 193 219]./255;    % Blue theme
options.color_line = [ 52 148 186]./255;
plot_areaerrorbar(RRGL_acc', options)
%% 


