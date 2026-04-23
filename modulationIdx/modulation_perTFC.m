clear; clc;

% Vinnie & Tiberius: TF target aligned [-0.8, 2.4]; TF checkerboard aligned: [-1, 1.6]; 
% Ziggy: data span: TF target aligned -0.8:4 aligned to target; TF checkerboard aligned: [-1, 1.8]; 
%%
CMod = struct; 

dirName = dir("/Volumes/ZiggySSD/ZiggyDLPFCRaster/RasterC/*.mat");

for dayn = 1:length(dirName)


data = load([dirName(dayn).folder '/' dirName(dayn).name]).dataframe;

% choose only correct trials
dataTable = struct2table(data);
outcomeTable = dataTable(:,{'TrialOutcome'});
outcomeCell = table2cell(outcomeTable);
correct = strcmp(outcomeCell, 'Correct Choice')';
allData = data(correct);   

% identify contexts 
params = [allData.params];

cxt1 = [params.LeftTargetColor] == 2;
cxt2 = [params.LeftTargetColor] == 3;

% identify left & right; red & green 

%left and right trials
perf = [allData.performance];

perfTable = struct2table(perf);
a = perfTable(:,{'ChosenSide'});
b = table2cell(a);
left = strcmp(b, 'left')';
right = strcmp(b, 'right')';
% red vs green trials
red = [perf.CueV] > 112;
green = [perf.CueV] < 112;




istart = -1;
istop = 1.8;

% choose time window around targets or checker
select = [-0.2, 1.3]; 
dat = struct;

for ii = 1:length(allData)
    dat(ii).trialId = ii;
    dat(ii).spikes = allData(ii).rasterC;
    dat(ii).time = istart:0.001:istop-0.001;

end

binWidth = 100;

seq = getSeq(dat, 100);

binEndPt = round(istart+0.1 : binWidth/1000 : istop, 1);

[~, iloc] = ismember(select, binEndPt);

binSelected = [iloc(1): iloc(2)];

trials = [];
for id = 1:length(seq)
    trials(id,:,:) = seq(id).y;
end



%% 
trials = trials(:,:,binSelected);

RL = trials(left == 1 & red == 1,:,:);
RR = trials(right == 1 & red == 1,:,:);
GL = trials(left == 1 & green == 1,:,:);
GR = trials(right == 1 & green == 1,:,:);

extract = min([size(RL,1), size(RR,1),size(GL,1),size(GR,1)]);
RL = RL(1:extract,:,:);
RR = RR(1:extract,:,:);
GL = GL(1:extract,:,:);
GR = GR(1:extract,:,:);

%% direction modulation
dirModulation = [];
bound = 2.58;

dir1Trials = trials(left,:,:);
dir2Trials = trials(right,:,:);


for n = 1:size(trials,2)
    for idx = 1:size(trials,3)
        
        dir1bin = dir1Trials(:,n,idx);
        dir2bin = dir2Trials(:,n,idx);
        
        dir1SEM = std(dir1bin)./sqrt(length(dir1bin));
        dir1stat = [mean(dir1bin) - dir1SEM*bound, mean(dir1bin) + dir1SEM*bound];
        
        dir2SEM = std(dir2bin)./sqrt(length(dir2bin));
        dir2stat = [mean(dir2bin) - dir2SEM*bound, mean(dir2bin) + dir2SEM*bound];
        
        
        highBd = max([dir1stat(1), dir1stat(2), dir2stat(1), dir2stat(2)]);
        lowBd = min([dir1stat(1), dir1stat(2), dir2stat(1), dir2stat(2)]);

        dirModulation(n, idx) = (highBd - lowBd) > (range(dir1stat) + range(dir2stat));
        
    end
end



%% color modulation
colModulation = [];

bound = 2.58;

col1Trials = trials(red,:,:);
col2Trials = trials(green,:,:);

for n = 1:size(trials,2)
    for idx = 1:size(trials,3)
        
        col1bin = col1Trials(:,n,idx);
        col2bin = col2Trials(:,n,idx);
        
        col1SEM = std(col1bin)./sqrt(length(col1bin));
        col1stat = [mean(col1bin) - col1SEM*bound, mean(col1bin) + col1SEM*bound];
        
        col2SEM = std(col2bin)./sqrt(length(col2bin));
        col2stat = [mean(col2bin) - col2SEM*bound, mean(col2bin) + col2SEM*bound];
        
        
        highBd = max([col1stat(1), col1stat(2), col2stat(1), col2stat(2)]);
        lowBd = min([col1stat(1), col1stat(2), col2stat(1), col2stat(2)]);

        colModulation(n, idx) = (highBd - lowBd) > (range(col1stat) + range(col2stat));
        
    end
end



%% context modulation 
cxtModulation = [];
FR_diff = 0.0;
bound = 2.58;

cxt1Trials = trials(cxt1,:,:);
cxt2Trials = trials(cxt2,:,:);

for n = 1:size(trials,2)
    for idx = 1:size(trials,3)
        
        cxt1bin = cxt1Trials(:,n,idx);
        cxt2bin = cxt2Trials(:,n,idx);
        
        cxt1SEM = std(cxt1bin)./sqrt(length(cxt1bin));
        cxt1stat = [mean(cxt1bin) - cxt1SEM*bound, mean(cxt1bin) + cxt1SEM*bound];
        
        cxt2SEM = std(cxt2bin)./sqrt(length(cxt2bin));
        cxt2stat = [mean(cxt2bin) - cxt2SEM*bound, mean(cxt2bin) + cxt2SEM*bound];
        
        
        highBd = max([cxt1stat(1), cxt1stat(2), cxt2stat(1), cxt2stat(2)]);
        lowBd = min([cxt1stat(1), cxt1stat(2), cxt2stat(1), cxt2stat(2)]);

        cxtModulation(n, idx) = (highBd - lowBd) > (range(cxt1stat) + range(cxt2stat) + FR_diff);
        
    end
end


%% plot PSTH
chopTime = 200;
[a, b] = size(allData(1).rasterC);
FRmatrix = zeros([a, b - chopTime*2, length(allData)]);

g = normpdf([-0.1:0.001:0.1],0,0.025);
for im = 1:length(allData)
    raster = allData(im).rasterC;
    
    for id = 1:size(raster,1)
        FR = conv(raster(id,:), g, 'same');
        FRmatrix(id,:,im) = FR(chopTime+1:end-chopTime);
    end
end


%% plot direction modulated units
FRthresh = 3;
COn = 800;

% % add a constrain on firing rates
% aa = FRmatrix(:,round([select(1):0.001:select(2)].*1000) + COn,:);
% bb = mean(aa, [2,3]);
% 
% dirUnitIdx = [];
% colUnitIdx = [];
% cxtUnitIdx = [];
% dirUnitIdx = find(sum(dirModulation, 2) > 0 & bb > FRthresh);
% colUnitIdx = find(sum(colModulation, 2) > 0 & bb > FRthresh);
% cxtUnitIdx = find(sum(cxtModulation, 2) > 0 & bb > FRthresh);
% 

% add a constrain on firing rates

TOI = FRmatrix(:,round([select(1):0.001:select(2)].*1000) + COn,:);
reachThresh = checkThreshReach(TOI, left, right, green, red, FRthresh);
dirUnitIdx = [];
colUnitIdx = [];
cxtUnitIdx = [];
dirUnitIdx = find(sum(dirModulation, 2) > 0 & reachThresh);
colUnitIdx = find(sum(colModulation, 2) > 0 & reachThresh);
cxtUnitIdx = find(sum(cxtModulation, 2) > 0 & reachThresh);


% % plot dir modulation units
% for jj = 1:length(dirUnitIdx) %size(FRmatrix,1)
%     id = dirUnitIdx(jj);
%     figure(); hold on
%     
%     plot(mean(squeeze(FRmatrix(id,:, left == 1 & red == 1)), 2), 'r-');
%     plot(mean(squeeze(FRmatrix(id,:, right == 1 & red == 1)), 2), 'r--');
%     plot(mean(squeeze(FRmatrix(id,:, left == 1 & green == 1)), 2), 'g-');
%     plot(mean(squeeze(FRmatrix(id,:, right == 1 & green == 1)), 2), 'g--');
%     
%     xline(800); 
%     title(id)
%     pause()
%     close
% end
  
% % plot col modulation units
% for jj = 1:length(colUnitIdx) %size(FRmatrix,1)
%     id = colUnitIdx(jj);
%     figure(); hold on
%     
%     plot(mean(squeeze(FRmatrix(id,:, left == 1 & red == 1)), 2), 'r-');
%     plot(mean(squeeze(FRmatrix(id,:, right == 1 & red == 1)), 2), 'r--');
%     plot(mean(squeeze(FRmatrix(id,:, left == 1 & green == 1)), 2), 'g-');
%     plot(mean(squeeze(FRmatrix(id,:, right == 1 & green == 1)), 2), 'g--');
%     
%     xline(800); 
%     title(id)
%     pause()
%     close
% end


% % plot cxt modulation units
% for jj = 1:length(cxtUnitIdx) %size(FRmatrix,1)
%     id = cxtUnitIdx(jj);
%     figure(); hold on
%     
%     plot(mean(squeeze(FRmatrix(id,:, left == 1 & red == 1)), 2), 'r-');
%     plot(mean(squeeze(FRmatrix(id,:, right == 1 & red == 1)), 2), 'r--');
%     plot(mean(squeeze(FRmatrix(id,:, left == 1 & green == 1)), 2), 'g-');
%     plot(mean(squeeze(FRmatrix(id,:, right == 1 & green == 1)), 2), 'g--');
%     
%     xline(800); 
%     title(id)
%     pause()
%     close
% end


CMod(dayn).name = dirName(dayn).name(1:end-4);
CMod(dayn).colUnits = colUnitIdx;
CMod(dayn).dirUnits = dirUnitIdx;
CMod(dayn).cxtUnits = cxtUnitIdx;

CMod(dayn).totalUnits = size(trials,2);

fprintf('dayn %d finished \n', dayn);


end
% %% plot color modulated units
% FRthresh = 3;
% COn = 800;
% 
% % add a constrain on firing rates
% aa = FRmatrix(:,round([select(1):0.001:select(2)].*1000) + COn,:);
% bb = mean(aa, [2,3]);
% unitIdx = find(sum(colModulation, 2) > 0 & bb > FRthresh);
% 
% for jj = 1:length(unitIdx) %size(FRmatrix,1)
%     id = unitIdx(jj);
%     figure(); hold on
%     
%     plot(mean(squeeze(FRmatrix(id,:, left == 1 & red == 1)), 2), 'r-');
%     plot(mean(squeeze(FRmatrix(id,:, right == 1 & red == 1)), 2), 'r--');
%     plot(mean(squeeze(FRmatrix(id,:, left == 1 & green == 1)), 2), 'g-');
%     plot(mean(squeeze(FRmatrix(id,:, right == 1 & green == 1)), 2), 'g--');
%     
%     xline(800); 
%     title(id)
%     pause()
%     close
% end


%% plot context modulated units

% FRthresh = 3;
% COn = 800;
% 
% % add a constrain on firing rates
% aa = FRmatrix(:,round([select(1):0.001:select(2)].*1000) + COn,:);
% bb = mean(aa, [2,3]);
% unitIdx = find(sum(cxtModulation, 2) > 0 & bb > FRthresh);
% 
% for jj = 1:length(unitIdx) %size(FRmatrix,1)
%     id = unitIdx(jj);
%     figure(); hold on
%     
%     plot(mean(squeeze(FRmatrix(id,:, left == 1 & red == 1)), 2), 'r-');
%     plot(mean(squeeze(FRmatrix(id,:, right == 1 & red == 1)), 2), 'r--');
%     plot(mean(squeeze(FRmatrix(id,:, left == 1 & green == 1)), 2), 'g-');
%     plot(mean(squeeze(FRmatrix(id,:, right == 1 & green == 1)), 2), 'g--');
%     
%     xline(800); 
%     title(id)
%     pause()
%     close
% end
%%

% save('ZiggyCMod.mat', 'CMod');
