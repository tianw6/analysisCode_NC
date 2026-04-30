

clear all; close all; clc


binSize = 50;
stepSize = 20;

alignment = 'C';

switch alignment
    case 'T'
        dataDir = '/Volumes/TianSSD/PMd/PMdData/Olaf/OlafPMdT1.mat';
%         dataDir = '/Volumes/TianSSD/PMd/PMdData/Tiberius/TibsPMdT1.mat';
        
        load(dataDir);
        tStart = -400;
        tEnd = 2000;
        timeAxis = [tStart+binSize:stepSize:tEnd];
        tSelected = timeAxis >= -200 & timeAxis <= 800;        
    case 'C'
%         dataDir = '/Volumes/TianSSD/PMd/PMdData/Olaf/OlafPMdC1.mat';
        dataDir = '/Volumes/TianSSD/PMd/PMdData/Tiberius/TibsPMdC1.mat';
        
        load(dataDir);
        tStart = -1000;
        tEnd = 1000;  
        timeAxis = [tStart+binSize:stepSize:tEnd];
        tSelected = timeAxis >= -200 & timeAxis <= 500;
    case 'M'
        dataDir = '/Volumes/TianSSD/PMd/PMdData/Olaf/OlafPMdM1.mat';
%         dataDir = '/Volumes/TianSSD/PMd/PMdData/Tiberius/TibsPMdM1.mat';
        
        load(dataDir);
        tStart = -1000;
        tEnd = 1000;
        timeAxis = [tStart+binSize:stepSize:tEnd];
        tSelected = timeAxis >= -600 & timeAxis <= 300;
end


%% 

results = struct;
tic
for dayn = 1:length(dataframe)


    data = dataframe(dayn);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    % extract the reaching direction for each trial 
    perf = [data.behavior];
    left = [perf.chosenSide] == 1;
    right = [perf.chosenSide] == 2;

    % extract chosen color (need trial outcome)
    perfTable = struct2table(perf);
    a = perfTable(:,{'TrialOutcome'});
    b = table2cell(a);    
    correct = strcmp(b, 'Correct Choice')';
    
    red = [perf.CentralCuenSquares] > 112 & correct == 1 | [perf.CentralCuenSquares] < 112 & correct == 0;
    green = ~red;


% extract target configuration
    % target configuration 1: GL&RR; target configureation 2: GR&RL
    config1 = [perf.LeftTargetColor] == 2;
    config2 = [perf.LeftTargetColor] == 3;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

spikeStruct = struct;
spikes = data.spikes;
for is = 1:size(spikes,2)
    spikeStruct(is).spikes = squeeze(double(spikes(:,is,:)))';
end  

trials = slideBins_mat(spikeStruct, binSize,stepSize);    

trials = trials(:,:,tSelected);




% trials = trials./50.*1000;


%% test 1 unit on all time bins

anovaResults = struct;

tic
for unitNum = 1:size(trials,2)

    p_all = zeros(3, size(trials,3));
    p_allPairs = zeros(6, size(trials,3));
    
    for binNum = 1:size(trials,3)

        unitN = squeeze(trials(:,unitNum,binNum));



        % % plot target unit psth 
        % 
        % RL = red & left;
        % RR = red & right;
        % GL = green & left;
        % GR = green & right;
        % 
        % 
        % t = timeAxis(tSelected);
        % 
        % figure; hold on
        % temp = squeeze(trials(:,unitNum,:));
        % 
        % plot(t, mean(temp(RL,:),1), 'r-');
        % plot(t, mean(temp(RR,:),1), 'r--');
        % plot(t, mean(temp(GL,:),1), 'g-');
        % plot(t, mean(temp(GR,:),1), 'g--');
        % 
        % xline(t(binNum), 'k--')






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
        [p, tbl, stats] = anovan(unitN, {config_cat,red_cat}, 'model', 'full', 'varnames', {'config1', 'red'}, 'display', 'off');

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
results(dayn).name = dataframe(dayn).date;
results(dayn).time = timeAxis(tSelected);

end

toc



% %% plot results
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

%% plot all results
t = timeAxis(tSelected);
thres = 0.01;

p_all = [];
cnt = 1;
for id = 1:length(results)
    temp = results(id).anovaResults;
    for idx = 1:length(temp)
        p_all(:,:,cnt) = temp(idx).anova2R;
        cnt = cnt+1;
    end
end


sigP = p_all < thres;

sigPer = (sum(sigP,3)./size(sigP,3));

figure; hold on
plot(t, sigPer(1,:), 'k')
plot(t, sigPer(2,:), 'm')
plot(t, sigPer(3,:), 'b')


xlim([t(1), t(end)])
%%

figure;
mixP = squeeze(sum(sigP,1) > 1);

plot(sum(mixP,2)./size(sigP,3));

%%
% save('../anova_results/TibsPMDVprobeC.mat', 'results')


