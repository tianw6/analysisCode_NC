

clear all; close all; clc

totalAccuracy = [];

binSize = 50;
stepSize = 5;

alignment = 'C';

switch alignment
    case 'T'
        dataDir = '/Volumes/TianSSD/VinnieNpix/targetAligned/';
        files = dir(fullfile(dataDir, '202*DLPFC*.mat'));
        tStart = -400;
        tEnd = 2000;
        timeAxis = [tStart+binSize:stepSize:tEnd];
        tSelected = timeAxis > -200 & timeAxis <= 800;        
    case 'C'
        dataDir = '/Volumes/TianSSD/TiberiusNpix/checkerboardAligned/';
        files = dir(fullfile(dataDir, '202*DLPFC*.mat'));
        tStart = -1000;
        tEnd = 1000;  
        timeAxis = [tStart+binSize:stepSize:tEnd];
        tSelected = timeAxis > -100 & timeAxis <= 400;
    case 'M'
        dataDir = '/Volumes/TianSSD/VinnieNpix/movementAligned/';
        files = dir(fullfile(dataDir, '202*DLPFC*.mat'));
        tStart = -1000;
        tEnd = 1000;
        timeAxis = [tStart+binSize:stepSize:tEnd];
        tSelected = timeAxis > -600 & timeAxis <= 300;
end


thres = 0.01;

%% 

results = struct;


for dayn = 1:length(files)

    data = load([dataDir files(dayn).name]).allData;
    % choose all correct trials 
    data = data([data.correctness] == 1);

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
        effect_size_raw = zeros(3, size(trials,3));

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






            %% anova analysis 


            % Step 1: Prepare the data for ANOVA
            % Convert factors to categorical variables
            red_cat = categorical(red);
            left_cat = categorical(left);


            % Group combinations (for post-hoc analysis)
            group = zeros(size(red));
            group(red == 0 & left == 0) = 1; % Red=0, Left=0
            group(red == 1 & left == 0) = 2; % Red=1, Left=0
            group(red == 0 & left == 1) = 3; % Red=0, Left=1
            group(red == 1 & left == 1) = 4; % Red=1, Left=1

            group_cat = categorical(group);



            %  Step 2: 2 way ANOVA using anovan for multcompare compatibility
            [p, tbl, stats] = anovan(unitN, {red_cat, left_cat}, 'model', 'full', 'varnames', {'Red', 'Left'}, 'display', 'off');

            % % Re-display the ANOVA results (should match the previous ones)
            % fprintf('\nANOVA Results (from anovan):\n');
            % disp(tbl);

            % get main effect 
            % Extract p-values for interpretation
            p_red = tbl{2,7};
            p_left = tbl{3,7};
            p_interaction = tbl{4,7};

            p_all(:,binNum) = cell2mat(tbl(2:4,7));
            % gName = tbl{2:4,1};

            if p_red < thres
                % calculate effect size
                a = unitN(red);
                b = unitN(~red);
                effect_size_raw(1,binNum) = abs(mean(a,1) - mean(b,1))./sqrt(0.5.*(var(a) + var(b)));
            else
                effect_size_raw(1,binNum) = 0;
            end

            if p_left < thres
                a = unitN(left);
                b = unitN(~left);
                effect_size_raw(2,binNum) = abs(mean(a,1) - mean(b,1))./sqrt(0.5.*(var(a) + var(b)));
            else
                effect_size_raw(2,binNum) = 0;
            end

            if p_interaction < thres
                a = unitN(config1);
                b = unitN(config2);
                effect_size_raw(3,binNum) = abs(mean(a,1) - mean(b,1))./sqrt(0.5.*(var(a) + var(b)));
            else
                effect_size_raw(3,binNum) = 0;
            end



            anovaResults(unitNum).anova2R = p_all;
            anovaResults(unitNum).effect_size = effect_size_raw;



        end

    end

    results(dayn).anovaResults = anovaResults;

    results(dayn).name = files(dayn).name(1:end-4);

    fprintf('day %d finished \n', dayn);

end


%% 


% 

%% test: plot results of 1 data

% plot target unit psth 

RL = red & left;
RR = red & right;
GL = green & left;
GR = green & right;


t = timeAxis(tSelected);

for unitNum = 1:size(trials,2)
    figure; hold on
    temp = squeeze(trials(:,unitNum,:));

    plot(t, mean(temp(RL,:),1), 'r-');
    plot(t, mean(temp(RR,:),1), 'r--');
    plot(t, mean(temp(GL,:),1), 'g-');
    plot(t, mean(temp(GR,:),1), 'g--');

    % plot effect size
    ES = anovaResults(unitNum).effect_size;
    
    plot(t, ES(1,:), 'm*')
    plot(t, ES(2,:), 'b*')
    plot(t, ES(3,:), 'k*')       
    
    % plot anova p-value
    anova2R = anovaResults(unitNum).anova2R;
    plot(t, 0.98.*(anova2R(3,:)<thres), 'k*')
    plot(t, 1.02.*(anova2R(1,:)<thres), 'm*')
    plot(t, anova2R(2,:)<thres, 'b*')

    
 

    title(unitNum)
    pause 
    close
end
 

%% 



%% plot all results
t = timeAxis(tSelected);
thres = 0.01;

p_all = [];
cnt = 1;
for id = 1:length(results)
    temp = results(id).anovaResults;
    for idx = 1:length(temp)
        p_all(:,:,cnt) = temp(idx).anova2R;
        ES_all(:,:,cnt) = temp(idx).effect_size;
        cnt = cnt+1;
    end
end


sigP = p_all < thres;

sigPer = (sum(sigP,3)./size(sigP,3));

figure; hold on
plot(t, sigPer(3,:), 'k')
plot(t, sigPer(1,:), 'm')
plot(t, sigPer(2,:), 'b')

xlim([t(1), t(end)])

title('MI')


ES_all(ES_all == 0) = NaN;
ES_mean = squeeze(nanmean(ES_all,3));

figure; hold on
plot(t, ES_mean(3,:), 'k')
plot(t, ES_mean(1,:), 'm')
plot(t, ES_mean(2,:), 'b')

xlim([t(1), t(end)])

title('ES')
%%

figure;
mixP = squeeze(sum(sigP,1) > 1);

plot(sum(mixP,2)./size(sigP,3));


%% 
% save('VinnieNpixDLPFC_ES.mat', 'results')