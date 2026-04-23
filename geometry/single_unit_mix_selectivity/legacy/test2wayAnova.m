

clear all; close all; clc

totalAccuracy = [];

binSize = 50;
stepSize = 20;

alignment = 'C';

switch alignment
    case 'T'
        dataDir = '/Volumes/TianSSD/TiberiusDLPFCRaster/';
%         dataDir = '/Volumes/ZiggySSD/VinnieDLPFCRaster/';
        
        files = dir(fullfile(dataDir, '202*.mat'));
        tStart = -800;
        tEnd = 2400;
        timeAxis = [tStart+binSize:stepSize:tEnd];
        tSelected = timeAxis > -200 & timeAxis <= 800;        
    case 'C'
        dataDir = '/Volumes/TianSSD/TiberiusDLPFCRaster/RasterC/';
%         dataDir = '/Volumes/ZiggySSD/VinnieDLPFCRaster/RasterC/';

        files = dir(fullfile(dataDir, '202*.mat'));
        tStart = -1000;
        tEnd = 1600;  
        timeAxis = [tStart+binSize:stepSize:tEnd];
        tSelected = timeAxis > -200 & timeAxis <= 800;
    case 'M'
%         dataDir = '/Volumes/TianSSD/TiberiusDLPFCRaster/RasterM/';
        dataDir = '/Volumes/ZiggySSD/VinnieDLPFCRaster/RasterM/';

        files = dir(fullfile(dataDir, '202*.mat'));
        tStart = -1000;
        tEnd = 1000;
        timeAxis = [tStart+binSize:stepSize:tEnd];
        tSelected = timeAxis > -600 & timeAxis <= 300;
end



%% 
dayn = 40;


data = load([dataDir files(dayn).name]).dataframe;

files(dayn).name
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% extract the reaching direction for each trial 
perf = [data.performance];
perfTable = struct2table(perf);
a = perfTable(:,{'ChosenSide'});
b = table2cell(a);
left = strcmp(b, 'left');
right = strcmp(b, 'right');


% extract color
a = perfTable(:,{'ChosenColor'});
b = table2cell(a);
red = strcmp(b, 'red');
green = strcmp(b, 'green');


% extract target configuration
%target configuration 1: GL&RR; target configureation 2: GR&RL
dataParams = [data.params];
leftColor = [dataParams.LeftTargetColor];
rightColor = [dataParams.RightTargetColor];

cxt1 = leftColor == 2 & rightColor == 3;
cxt2 = leftColor == 3 & rightColor == 2;    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


temp = struct2table(data);
spikeTable = temp(:,{'rasterC'});
spikeStruct = table2struct(spikeTable);

oldField = 'rasterC';
newField = 'spikes';

[spikeStruct.(newField)] = spikeStruct.(oldField);
spikeStruct = rmfield(spikeStruct,oldField);  


% check slideBins (whether it's non-causal) 50:20:1590
seq = slideBins(spikeStruct, binSize,stepSize);    

trials = [];
for ii = 1 : length(seq)
    trials(ii,:,:)= seq(ii).y;
end

% choose -0.2 to 0.8 aligned with target
trials = trials(:,:,tSelected);

% trials = trials./50.*1000;



%% test 1 unit
binNum = 29;

unitNum = 31;
unit31 = squeeze(trials(:,unitNum,binNum));



% Perform two-way ANOVA
[p, tbl, stats] = anovan(unit31, {red, left}, 'model', 'full', ...
                         'varnames', {'red', 'left'}, ...
                         'display', 'on');

                     
% Extract p-values for interpretation
p_red = tbl{2,7};
p_left = tbl{3,7};
p_interaction = tbl{4,7};
                     
                     
                     
% plot target unit psth 

RL = red & left;
RR = red & right;
GL = green & left;
GR = green & right;


t = timeAxis(tSelected);

figure; hold on
temp = squeeze(trials(:,unitNum,:));

plot(t, mean(temp(RL,:),1), 'r-');
plot(t, mean(temp(RR,:),1), 'r--');
plot(t, mean(temp(GL,:),1), 'g-');
plot(t, mean(temp(GR,:),1), 'g--');

xline(t(binNum), 'k--')




%% 

% RL = red & left;
% RR = red & right;
% GL = green & left;
% GR = green & right;
% 
% t = timeAxis(tSelected);
% for ip = 1:size(trials,2)
%     figure; hold on
%     temp = squeeze(trials(:,ip,:));
%     
%     plot(t, mean(temp(RL,:),1), 'r-');
%     plot(t, mean(temp(RR,:),1), 'r--');
%     plot(t, mean(temp(GL,:),1), 'g-');
%     plot(t, mean(temp(GR,:),1), 'g--');
%     
%     
%     title(ip)   
%     pause;
%     close
% 
%     
% end
    



%% HSD analysis 


% Step 1: Prepare the data for ANOVA
% Convert factors to categorical variables
red_cat = categorical(red);
left_cat = categorical(left);

% Create a table with the data
T = table(unit31, red_cat, left_cat, 'VariableNames', {'Response', 'Red', 'Left'});

% Display summary of the data
fprintf('Data summary:\n');
fprintf('Total observations: %d\n', height(T));
fprintf('Number of Red=0: %d, Red=1: %d\n', sum(red == 0), sum(red == 1));
fprintf('Number of Left=0: %d, Left=1: %d\n', sum(left == 0), sum(left == 1));

% Group combinations (for post-hoc analysis)
group = zeros(size(red));
group(red == 0 & left == 0) = 1; % Red=0, Left=0
group(red == 1 & left == 0) = 2; % Red=1, Left=0
group(red == 0 & left == 1) = 3; % Red=0, Left=1
group(red == 1 & left == 1) = 4; % Red=1, Left=1

group_cat = categorical(group);
T.Group = group_cat;

% Display group counts
fprintf('\nGroup counts:\n');
groupCounts = groupcounts(T, 'Group');
disp(groupCounts);

% Step 2: Perform two-way ANOVA
fprintf('\nPerforming two-way ANOVA...\n');
model = fitlm(T, 'Response ~ Red*Left');
anovatbl = anova(model);

% Display ANOVA results
fprintf('\nANOVA Results:\n');
disp(anovatbl);

%%
% Step 3: Calculate means for each factor combination
fprintf('\nMeans for each condition:\n');
meanTable = grpstats(T, {'Red', 'Left'}, 'mean', 'DataVars', 'Response');
disp(meanTable);

% Step 4: Tukey's HSD post hoc test
% We'll use the multcompare function which requires an anovan model
fprintf('\nPerforming Tukey''s HSD post hoc test...\n');

% Recreate the ANOVA using anovan for multcompare compatibility
[p, tbl, stats] = anovan(unit31, {red_cat, left_cat}, 'model', 'full', 'varnames', {'Red', 'Left'}, 'display', 'off');

% Re-display the ANOVA results (should match the previous ones)
fprintf('\nANOVA Results (from anovan):\n');
disp(tbl);

%%
% Perform Tukey's HSD test for main effect of Red
fprintf('\nTukey''s HSD for Red main effect:\n');
[c_red, m_red, h_red, gnames_red] = multcompare(stats, 'Dimension', 1, 'Display', 'off');
red_comparison = array2table(c_red, 'VariableNames', {'Group1', 'Group2', 'LowerCI', 'MeanDiff', 'UpperCI', 'PValue'});
red_comparison.Group1 = gnames_red(c_red(:,1));
red_comparison.Group2 = gnames_red(c_red(:,2));
disp(red_comparison);

% Perform Tukey's HSD test for main effect of Left
fprintf('\nTukey''s HSD for Left main effect:\n');
[c_left, m_left, h_left, gnames_left] = multcompare(stats, 'Dimension', 2, 'Display', 'off');
left_comparison = array2table(c_left, 'VariableNames', {'Group1', 'Group2', 'LowerCI', 'MeanDiff', 'UpperCI', 'PValue'});
left_comparison.Group1 = gnames_left(c_left(:,1));
left_comparison.Group2 = gnames_left(c_left(:,2));
disp(left_comparison);

% For interaction effects, we need to compare all combinations
% Rerun ANOVA with a single grouping variable
fprintf('\nPerforming post hoc tests for all group combinations...\n');
[p_comb, tbl_comb, stats_comb] = anovan(unit31, {group_cat}, 'display', 'off');

% Perform Tukey's HSD test for all combinations
[c_comb, m_comb, h_comb, gnames_comb] = multcompare(stats_comb, 'Display', 'off');
comb_comparison = array2table(c_comb, 'VariableNames', {'Group1', 'Group2', 'LowerCI', 'MeanDiff', 'UpperCI', 'PValue'});

% Replace group numbers with descriptive names
groupNames = {'GR', 'RR', 'GL', 'RL'};
comb_comparison.Group1 = groupNames(c_comb(:,1))';
comb_comparison.Group2 = groupNames(c_comb(:,2))';

fprintf('\nTukey''s HSD for all group combinations:\n');
disp(comb_comparison);

% Step 5: Create visualizations
% Main effects plot
figure;
subplot(2, 1, 1);
[gMeans, gGroups] = grpstats(unit31, red_cat, {'mean', 'gname'});
bar(categorical(gGroups), gMeans);
title('Main Effect of Red');
xlabel('Red');
ylabel('Mean Response');

subplot(2, 1, 2);
[gMeans, gGroups] = grpstats(unit31, left_cat, {'mean', 'gname'});
bar(categorical(gGroups), gMeans);
title('Main Effect of Left');
xlabel('Left');
ylabel('Mean Response');

% Interaction plot
figure;
[gMeans, gGroups] = grpstats(unit31, {red_cat, left_cat}, {'mean', 'gname'});
gMeans_matrix = reshape(gMeans, [2, 2]); % Reshape for interaction plot (assuming 2×2 design)

% Plot interaction
h = plot(gMeans_matrix);
set(h, 'LineWidth', 2);
set(gca, 'XTick', 1:2);
set(gca, 'XTickLabel', {'0', '1'});
title('Interaction between Red and Left');
xlabel('Left');
ylabel('Mean Response');
legend({'Red=0', 'Red=1'}, 'Location', 'best');
grid on;

% Box plot of all combinations
figure;
boxplot(unit31, group, 'Labels', groupNames);
title('Response by Condition Combinations');
ylabel('Response Value');
