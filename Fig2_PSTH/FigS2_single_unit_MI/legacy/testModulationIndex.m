% not very clear

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
%         dataDir = '/Volumes/TianSSD/VinnieNpix/checkerboardAligned/';
        dataDir = '/Volumes/TianSSD/TiberiusNpix/checkerboardAligned/';
        
        files = dir(fullfile(dataDir, '202*DLPFC*.mat'));
        tStart = -1000;
        tEnd = 1000;  
        timeAxis = [tStart+binSize:stepSize:tEnd];
        tSelected = timeAxis >= 0 & timeAxis <= 500;
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
tic
parfor dayn = 1:length(files)


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

MIresults = struct;

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



        %% 
        p_all(1, binNum) = abs(mean(unitN(config1)) - mean(unitN(~config1)))./(mean(unitN(config1)) + mean(unitN(~config1)));
        p_all(2, binNum) = abs(mean(unitN(red)) - mean(unitN(~red)))./(mean(unitN(red)) + mean(unitN(~red)));
        p_all(3, binNum) = abs(mean(unitN(left)) - mean(unitN(~left)))./(mean(unitN(left)) + mean(unitN(~left)));

        MIresults(unitNum).MI = p_all;



    end

end

results(dayn).MIresults = MIresults;
results(dayn).name = files(dayn).name(1:end-4);
results(dayn).time = timeAxis(tSelected);


end

toc



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

%% plot all results

anovaResults = load('../anova_results/TibsDLPFCNpixC.mat').results;

t = timeAxis(tSelected);
thres = 0.01;

p_all = [];
cnt = 1;
for id = 1:length(anovaResults)
    temp = anovaResults(id).anovaResults;
    temp2 = results(id).MIresults;
    
    for idx = 1:length(temp)
        p_all(:,:,cnt) = temp(idx).anova2R;
        MI_all(:,:,cnt) = temp2(idx).MI;
        cnt = cnt+1;
    end
end


sigP = p_all < thres;

sigPer = (sum(sigP,3)./size(sigP,3));

figure; hold on
plot(t, sigPer(3,:), 'b')
plot(t, sigPer(1,:), 'k')
plot(t, sigPer(2,:), 'm')

xlim([t(1), t(end)])



%% 

[~, cxtIdx] = max(sigPer(1,:));
[~, colorIdx] = max(sigPer(2,:));
[~, choiceIdx] = max(sigPer(3,:));


a = squeeze(MI_all(1,cxtIdx, :));
b = squeeze(MI_all(2,colorIdx, :));
c = squeeze(MI_all(3,choiceIdx, :));


figure; histogram(a)
figure; histogram(b)

figure; histogram(c)

figure; boxplot([a, b, c])

%% 


% MI_p = sigP.*MI_all;

cxtUnits = sum(squeeze(sigP(1,:,:)), 1) ~= 0;
colorUnits = sum(squeeze(sigP(2,:,:)), 1) ~= 0;
choiceUnits = sum(squeeze(sigP(3,:,:)), 1) ~= 0;

a = squeeze(MI_p(1,:,cxtUnits));

b = squeeze(MI_p(2,:,colorUnits));

c = squeeze(MI_p(3,:,choiceUnits));


cxtMI = (max(a,[], 1))';
colorMI = (max(b,[], 1))';
choiceMI = (max(c,[], 1))';

figure; histogram(cxtMI)
figure; histogram(colorMI)

figure; histogram(choiceMI)




%%

figure;
mixP = squeeze(sum(sigP,1) > 1);

plot(sum(mixP,2)./size(sigP,3));


%% 
