clear; clc;

% Tiberius:  TF checkerboard aligned: [-1, 1]; 
%%
CMod = struct; 

dirName = dir('/Volumes/TianSSD/simultaneousRecording/*C*pmd.mat');
temp = dir('/Volumes/TianSSD/simultaneousRecording/*PMD20240430*.mat');
dirName = [dirName; temp];
for dayn = 1:length(dirName)


data = load([dirName(dayn).folder '/' dirName(dayn).name]).allData;

% choose only correct trials

correct = [data.correctness];
allData = data(correct == 1);   

% identify contexts 

cxt1 = [allData.leftTarget] == 2;
cxt2 = [allData.leftTarget] == 3;

% identify left & right; red & green 

%left and right trials

left = [allData.chosenSide] == 1;
right = [allData.chosenSide] == 2;
% red vs green trials
red = [allData.cue] > 112;
green = [allData.cue] < 112;




istart = -1;
istop = 1;

% choose time window around targets or checker ziggy: [0, 1.3], others: [0, 0.8]
select = [0 0.8]; 
dat = struct;

for ii = 1:length(allData)
    dat(ii).trialId = ii;
    dat(ii).spikes = allData(ii).rasterT;
    dat(ii).time = istart:0.001:istop-0.001;

end

binWidth = 50;

seq = getSeq(dat, binWidth);

% decimal bug if not round
binEndPt = round(istart+binWidth/1000 : binWidth/1000 : istop,3);

[~, iloc] = ismember(select, binEndPt);

binSelected = [iloc(1): iloc(2)];

trials = [];
for id = 1:length(seq)
    trials(id,:,:) = seq(id).y;
end
 
trials = trials(:,:,binSelected);

%% direction modulation
dirModulation = [];
bound = 2.58;

% dir1Trials = trials(left,:,:);
% dir2Trials = trials(right,:,:);


% for n = 1:size(trials,2)
%     for idx = 1:size(trials,3)
%         
%         dir1bin = dir1Trials(:,n,idx);
%         dir2bin = dir2Trials(:,n,idx);
%         
%         dir1SEM = std(dir1bin)./sqrt(length(dir1bin));
%         dir1stat = [mean(dir1bin) - dir1SEM*bound, mean(dir1bin) + dir1SEM*bound];
%         
%         dir2SEM = std(dir2bin)./sqrt(length(dir2bin));
%         dir2stat = [mean(dir2bin) - dir2SEM*bound, mean(dir2bin) + dir2SEM*bound];
%         
%         
%         highBd = max([dir1stat(1), dir1stat(2), dir2stat(1), dir2stat(2)]);
%         lowBd = min([dir1stat(1), dir1stat(2), dir2stat(1), dir2stat(2)]);
% 
%         dirModulation(n, idx) = (highBd - lowBd) > (range(dir1stat) + range(dir2stat));
%         
%     end
% end


[dirModulation dirEffectSize] = calMod(trials, left, right, bound);

%% color modulation
colModulation = [];

bound = 2.58;

% col1Trials = trials(red,:,:);
% col2Trials = trials(green,:,:);
% 
% for n = 1:size(trials,2)
%     for idx = 1:size(trials,3)
%         
%         col1bin = col1Trials(:,n,idx);
%         col2bin = col2Trials(:,n,idx);
%         
%         col1SEM = std(col1bin)./sqrt(length(col1bin));
%         col1stat = [mean(col1bin) - col1SEM*bound, mean(col1bin) + col1SEM*bound];
%         
%         col2SEM = std(col2bin)./sqrt(length(col2bin));
%         col2stat = [mean(col2bin) - col2SEM*bound, mean(col2bin) + col2SEM*bound];
%         
%         
%         highBd = max([col1stat(1), col1stat(2), col2stat(1), col2stat(2)]);
%         lowBd = min([col1stat(1), col1stat(2), col2stat(1), col2stat(2)]);
% 
%         colModulation(n, idx) = (highBd - lowBd) > (range(col1stat) + range(col2stat));
%         
%     end
% end


[colModulation colEffectSize] = calMod(trials, red, green, bound);

%% context modulation 
cxtModulation = [];
FR_diff = 0.0;
bound = 2.58;

% cxt1Trials = trials(cxt1,:,:);
% cxt2Trials = trials(cxt2,:,:);
% 
% for n = 1:size(trials,2)
%     for idx = 1:size(trials,3)
%         
%         cxt1bin = cxt1Trials(:,n,idx);
%         cxt2bin = cxt2Trials(:,n,idx);
%         
%         cxt1SEM = std(cxt1bin)./sqrt(length(cxt1bin));
%         cxt1stat = [mean(cxt1bin) - cxt1SEM*bound, mean(cxt1bin) + cxt1SEM*bound];
%         
%         cxt2SEM = std(cxt2bin)./sqrt(length(cxt2bin));
%         cxt2stat = [mean(cxt2bin) - cxt2SEM*bound, mean(cxt2bin) + cxt2SEM*bound];
%         
%         
%         highBd = max([cxt1stat(1), cxt1stat(2), cxt2stat(1), cxt2stat(2)]);
%         lowBd = min([cxt1stat(1), cxt1stat(2), cxt2stat(1), cxt2stat(2)]);
% 
%         cxtModulation(n, idx) = (highBd - lowBd) > (range(cxt1stat) + range(cxt2stat) + FR_diff);
%         
%     end
% end

[cxtModulation cxtEffectSize] = calMod(trials, cxt1, cxt2, bound);

%% plot PSTH
chopTime = 200;
[a, b] = size(allData(1).rasterT);
FRmatrix = zeros([a, b - chopTime*2, length(allData)]);

g = normpdf([-0.1:0.001:0.1],0,0.025);
for im = 1:length(allData)
    raster = allData(im).rasterT;
    
    for id = 1:size(raster,1)
        FR = conv(raster(id,:), g, 'same');
        FRmatrix(id,:,im) = FR(chopTime+1:end-chopTime);
    end
end


%% plot direction modulated units
FRthresh = 3;
COn = abs(istart)*1000-chopTime;


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




% %% plot col modulation units with SEM 
% for jj = 1:length(colUnitIdx) %size(FRmatrix,1)
%     id = colUnitIdx(jj);
%     figure(); hold on
%     
%     
%     t = 1:size(FRmatrix, 2);
%     rFR_red = squeeze(FRmatrix(id,:, red == 1));
%     rFR_green = squeeze(FRmatrix(id,:, green == 1));
%     
%     red_mean = mean(rFR_red, 2)';
%     green_mean = mean(rFR_green, 2)';
%     red_SEM = std(rFR_red')./sqrt(size(rFR_red,2)).*bound;
%     green_SEM = std(rFR_green')./sqrt(size(rFR_green,2)).*bound;
%     
%     patch = fill([t, fliplr(t)], [(red_mean + red_SEM) fliplr(red_mean-red_SEM)], 'r');
%     set(patch, 'edgecolor', 'none', 'FaceAlpha', 0.3);  
%     patch = fill([t, fliplr(t)], [(green_mean + red_SEM) fliplr(green_mean-red_SEM)], 'g');
%     set(patch, 'edgecolor', 'none', 'FaceAlpha', 0.3);    
%     
%     plot(red_mean, 'r-');
%     plot(green_mean, 'g');
% 
%     xline(800); 
%     title(id)
%     pause()
%     close
% end

% 
% % plot col modulation units with SEM (bined spike counts)
% for jj = 1:length(colUnitIdx) %size(FRmatrix,1)
%     id = colUnitIdx(jj);
% 
%     figure(); hold on
%     
%     t = 1:size(trials, 3);
%     rFR_red = squeeze(trials(red == 1,id,:));
%     rFR_green = squeeze(trials(green == 1,id,:));
%     
%     red_mean = mean(rFR_red, 1);
%     green_mean = mean(rFR_green, 1);
%     red_SEM = std(rFR_red)./sqrt(size(rFR_red,1)).*bound;
%     green_SEM = std(rFR_green)./sqrt(size(rFR_green,1)).*bound;
%     
%     patch = fill([t, fliplr(t)], [(red_mean + red_SEM) fliplr(red_mean-red_SEM)], 'r');
%     set(patch, 'edgecolor', 'none', 'FaceAlpha', 0.3);  
%     patch = fill([t, fliplr(t)], [(green_mean + red_SEM) fliplr(green_mean-red_SEM)], 'g');
%     set(patch, 'edgecolor', 'none', 'FaceAlpha', 0.3);    
%     
%     plot(red_mean, 'r-');
%     plot(green_mean, 'g');    
%     
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
CMod(dayn).colEffectSize = colEffectSize;
CMod(dayn).colModulation = colModulation;

CMod(dayn).dirUnits = dirUnitIdx;
CMod(dayn).dirEffectSize = dirEffectSize;
CMod(dayn).dirModulation = dirModulation;

CMod(dayn).cxtUnits = cxtUnitIdx;
CMod(dayn).cxtEffectSize = cxtEffectSize;
CMod(dayn).cxtModulation = cxtModulation;


CMod(dayn).totalUnits = size(trials,2);

fprintf('dayn %d finished \n', dayn);


end
% % %% plot color modulated units
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

save('./CModPMD/TibsnpixMod50ms.mat', 'CMod');
