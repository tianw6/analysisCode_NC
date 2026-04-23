
%% 



clear all; close all; clc

addpath('..')


binSize = 50;
stepSize = 20;

alignment = 'C';

switch alignment
    case 'T'
%         dataDir = '/Volumes/TianSSD/VinnieNpix/targetAligned/';
        dataDir = '/Volumes/TianSSD/TiberiusNpix/targetAligned/';
        
        files = dir(fullfile(dataDir, '202*PMD*.mat'));
        tStart = -400;
        tEnd = 2000;
        timeAxis = [tStart+binSize:stepSize:tEnd];
        tSelected = timeAxis >= -200 & timeAxis <= 800;        
    case 'C'
        dataDir = '/Volumes/TianSSD/VinnieNpix/checkerboardAligned/';
%         dataDir = '/Volumes/TianSSD/TiberiusNpix/checkerboardAligned/';
        
        files = dir(fullfile(dataDir, '202*DLPFC*.mat'));
        tStart = -1000;
        tEnd = 1000;  
        timeAxis = [tStart+binSize:stepSize:tEnd];
        tSelected = timeAxis >= -200 & timeAxis <= 500;
    case 'M'
%         dataDir = '/Volumes/TianSSD/VinnieNpix/movementAligned/';
        dataDir = '/Volumes/TianSSD/TiberiusNpix/movementAligned/';
        
        files = dir(fullfile(dataDir, '202*PMD*.mat'));
        tStart = -1000;
        tEnd = 1000;
        timeAxis = [tStart+binSize:stepSize:tEnd];
        tSelected = timeAxis >= -600 & timeAxis <= 300;
end




%% 

results = struct;

dayn = 1;

data = load([dataDir files(dayn).name]).allData;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% extract the reaching direction for each trial 
perf = [data.DLperformance];
perfTable = struct2table(perf);
a = perfTable(:,{'ChosenSide'});
b = table2cell(a);
left = strcmp(b, 'left')';
right = strcmp(b, 'right')';

% extract color
a = perfTable(:,{'ChosenColor'});
b = table2cell(a);
red = strcmp(b, 'red')';
green = strcmp(b, 'green')';

% extract target configuration

 % target configuration 1: GL&RR; target configureation 2: GR&RL
dataParams = [data.DLparams];
leftColor = [dataParams.LeftTargetColor];
rightColor = [dataParams.RightTargetColor];

config1 = leftColor == 2 & rightColor == 3;
config2 = leftColor == 3 & rightColor == 2;  


temp = struct2table(data);
spikeTable = temp(:,{'rasterT'});
spikeStruct = table2struct(spikeTable);

oldField = 'rasterT';
newField = 'spikes';

[spikeStruct.(newField)] = spikeStruct.(oldField);
spikeStruct = rmfield(spikeStruct,oldField);  

trials = slideBins_mat(spikeStruct, binSize,stepSize);    

% choose -0.2 to 0.8 aligned with target
trials = trials(:,:,tSelected);




% trials = trials./50.*1000;


%% test 1 unit on all time bins

anovaResults = struct;

for unitNum = 1:size(trials,2)

    p_all = zeros(3, size(trials,3));
    p_allPairs = zeros(6, size(trials,3));

    
    %%%%%%%%%%% plot all unit psth 

    RL = red & left;
    RR = red & right;
    GL = green & left;
    GR = green & right;


    t = timeAxis(tSelected);

    figure; hold on
    temp = squeeze(trials(:,unitNum,:));

    plot(mean(temp(RL,:),1), 'r-');
    plot(mean(temp(RR,:),1), 'r--');
    plot(mean(temp(GL,:),1), 'g-');
    plot(mean(temp(GR,:),1), 'g--');
        
    
    
    
    
    for binNum = 1:size(trials,3)

        unitN = squeeze(trials(:,unitNum,binNum));

        %% HSD analysis 


        % Step 1: Prepare the data for ANOVA
        % Convert factors to categorical variables
        red_cat = categorical(red);
        left_cat = categorical(left);
        config_cat = categorical(config1);


        % Group combinations (for post-hoc analysis)
        group = zeros(size(red));
        group(red == 1 & config1 == 1) = 1; % RL
        group(red == 1 & config1 == 0) = 2; % RR
        group(red == 0 & config1 == 0) = 3; % GL
        group(red == 0 & config1 == 1) = 4; % GR

        group_cat = categorical(group);



        %  Step 2: 2 way ANOVA using anovan for multcompare compatibility
        [p, tbl, stats] = anovan(unitN, {config_cat,red_cat}, 'model', 'full', 'varnames', {'Red', 'Left'}, 'display', 'off');

        % % Re-display the ANOVA results (should match the previous ones)
        % fprintf('\nANOVA Results (from anovan):\n');
        % disp(tbl);

        % get main effect 
        % Extract p-values for interpretation
        p_config = tbl{2,7};
        p_red = tbl{3,7};
        p_interaction = tbl{4,7};

        p_all(:,binNum) = cell2mat(tbl(2:4,7));
        % gName = tbl{2:4,1};


        % % Step 3: Tukey's HSD post hoc test
        % % We'll use the multcompare function which requires an anovan model
        % For interaction effects, we need to compare all combinations

        % Rerun ANOVA with a single grouping variable
        % fprintf('\nPerforming post hoc tests for all group combinations...\n');
        [p_comb, tbl_comb, stats_comb] = anovan(unitN, {group_cat}, 'display', 'off');

        % Perform Tukey's HSD test for all combinations
        [c_comb, m_comb, h_comb, gnames_comb] = multcompare(stats_comb, 'Display', 'off');
        comb_comparison = array2table(c_comb, 'VariableNames', {'Group1', 'Group2', 'LowerCI', 'MeanDiff', 'UpperCI', 'PValue'});

        % Replace group numbers with descriptive names
        groupNames = {'RL', 'RR', 'GL', 'GR'};
        comb_comparison.Group1 = groupNames(c_comb(:,1))';
        comb_comparison.Group2 = groupNames(c_comb(:,2))';

        % fprintf('\nTukey''s HSD for all group combinations:\n');
        % disp(comb_comparison);

        p_allPairs(:,binNum) = comb_comparison{:,6};
        gName1 = comb_comparison{:,1};
        gName2 = comb_comparison{:,2};


        anovaResults(unitNum).anova2R = p_all;
        anovaResults(unitNum).HSDR = p_allPairs;



    end

end

results(dayn).anovaResults = anovaResults;
results(dayn).name = files(dayn).name(1:end-4);
results(dayn).time = timeAxis(tSelected);




%% test: plot results of one data
% 
% % plot target unit psth 
% 
% RL = red & left;
% RR = red & right;
% GL = green & left;
% GR = green & right;
% 
% 
% t = timeAxis(tSelected);
% thres = 0.05;
% 
% for unitNum = 1:size(trials,2)
% figure; hold on
% temp = squeeze(trials(:,unitNum,:));
% 
% plot(t, mean(temp(RL,:),1), 'r-');
% plot(t, mean(temp(RR,:),1), 'r--');
% plot(t, mean(temp(GL,:),1), 'g-');
% plot(t, mean(temp(GR,:),1), 'g--');
% 
% 
% 
% anova2R = anovaResults(unitNum).anova2R;
% plot(t, 0.9.*(anova2R(3,:)<thres), 'k*')
% plot(t, 1.1.*(anova2R(1,:)<thres), 'm*')
% plot(t, anova2R(2,:)<thres, 'b*')
%   
% title(unitNum)
% pause 
% close
% end




%%



addpath('../anova_results/');



dlpfcC = [load('TibsDLPFCVprobeC.mat').results, load('TibsDLPFCNpixC.mat').results, load('VinnieVprobeC.mat').results, load('VinnieNpixC.mat').results];



results = dlpfcC;

t = dlpfcC(1).time;
        
thres = 0.01;

HSDp_all = [];
anovaP_all = [];
cnt = 1;
for id = 1:length(results)
    temp = results(id).anovaResults;
    for idx = 1:length(temp)
        HSDp_all(:,:,cnt) = temp(idx).HSDR;
        anovaP_all(:,:,cnt) = temp(idx).anova2R;
        
        cnt = cnt+1;
    end
end


sigP = HSDp_all < thres;
sigPer = (sum(sigP,3)./size(sigP,3));

sigPanova = anovaP_all < thres;
sigPerAnova = (sum(sigPanova,3)./size(sigPanova,3));

%% 

RLGR = squeeze(sigP(1,:,:));
RRGL = squeeze(sigP(6,:,:));

figure; hold on
plot(t, sum(RLGR,2)./size(RLGR,2))
plot(t, sum(RRGL,2)./size(RRGL,2))

plot(t, sigPerAnova(1,:), 'k')
plot(t, sigPerAnova(2,:), 'm')
plot(t, sigPerAnova(3,:), 'c')


%%


% %figure;
% mixP = squeeze(sum(sigP,1) > 1);
% 
% plot(t, sum(mixP,2)./size(sigP,3), 'color', "#D95319", 'linewidth', 2);
% 
% legend('cxt', 'col', 'choice', 'mixed')
% ylim([0 0.7])
% xlabel('ms after checkerboard')
% ylabel('ratio')