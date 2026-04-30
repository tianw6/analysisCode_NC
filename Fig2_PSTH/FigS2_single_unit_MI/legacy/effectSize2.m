% calculate effect size with processed data

clear all; close all; clc

e = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/targetAligned/allBinFRnpix.mat').allBinFR;

d = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Vinnie/targetAligned/allBinFRnpix.mat').allBinFR;

a = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/targetAligned/allBinFRvprobe.mat').allBinFR;
b = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Vinnie/targetAligned/allBinFRvprobe.mat').allBinFR;
% c = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Ziggy/targetAligned/allBinFRvprobe.mat').allBinFR;

% f = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/targetAligned/allBinFRvprobePMD.mat').allBinFR;
% g = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Olaf/targetAligned/allBinFRvprobePMD.mat').allBinFR;
% h = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/targetAligned/allBinFRnpixPMD.mat').allBinFR;

binFRpfc = [a b e d];

%% 
allTime = binFRpfc(1).time;

tStart = -100;
tEnd = 500; 
tSelected = allTime >= tStart & allTime <= tEnd;

time = allTime(tSelected);


for ii = 1:length(binFRpfc)
    
    binFRpfc(ii).trials = binFRpfc(ii).trials(:,:,tSelected);
    binFRpfc(ii).time = binFRpfc(ii).time(tSelected);

end



%% 
results = struct;

thres = 0.01;

for dayn = 1:length(binFRpfc)

  

    taskLabels = binFRpfc(dayn).taskLabels;
    trials = binFRpfc(dayn).trials;
    behaviors = binFRpfc(dayn).behavior;
    red = behaviors.chosenRed;
    left = behaviors.chosenLeft;
    config1 = behaviors.config1;

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

            % calculate effect size
            a = unitN(red);
            b = unitN(~red);
            effect_size_raw(1,binNum) = abs(mean(a) - mean(b))./sqrt(0.5.*(var(a) + var(b)));


            a = unitN(left);
            b = unitN(~left);
            effect_size_raw(2,binNum) = abs(mean(a) - mean(b))./sqrt(0.5.*(var(a) + var(b)));


            a = unitN(config1);
            b = unitN(~config1);
            effect_size_raw(3,binNum) = abs(mean(a) - mean(b))./sqrt(0.5.*(var(a) + var(b)));




            anovaResults(unitNum).anova2R = p_all;
            anovaResults(unitNum).effect_size = effect_size_raw;



        end

    end

    results(dayn).anovaResults = anovaResults;
    results(dayn).name = binFRpfc(dayn).name;
    results(dayn).time = binFRpfc(dayn).time;

    fprintf('day %d finished \n', dayn);

end

% save('ESresultsDLPFCT.mat', 'results');
%%
thres = 0.01;

p_all = [];
cnt = 1;
for id = 1:length(results)
    temp = results(id).anovaResults;
    for idx = 1:length(temp)
        ES_all(:,:,cnt) = temp(idx).effect_size;
        cnt = cnt+1;
    end
end

ES = squeeze(max(ES_all, [], 2));


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
% t = timeAxis(tSelected);
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

%% 

ES = sigP.* ES_all;

ES = squeeze(max(ES, [], 2));


ES(isnan(ES))=0;

%% 
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