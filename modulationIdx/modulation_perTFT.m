clear; clc;

% Vinnie & Tiberius: TF target aligned [-0.8, 2.4]; TF checkerboard aligned: [-1, 1.6]; 

% Ziggy: data span: TF target aligned -0.8:4 aligned to target


cxtTMod = struct; 

dirName = dir("/Volumes/ZiggySSD/VinnieDLPFCRaster/*.mat");

istart = -0.8;
istop = 2.4;


tic

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


% choose time window around targets or checker
select = [0, 0.7000]; 
dat = struct;

for ii = 1:length(allData)
    dat(ii).trialId = ii;
    dat(ii).spikes = allData(ii).rasterT;
    dat(ii).time = istart:0.001:istop-0.001;

end

binWidth = 100;

seq = getSeq(dat, 100);

binEndPt = round(istart+0.1 : binWidth/1000 : istop, 1);

[~, iloc] = ismember(select, binEndPt);

binSelected = [iloc(1): iloc(2)];

trials = [];
for ix = 1:length(seq)
    trials(ix,:,:) = seq(ix).y;
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

% %% context modulation 
% cxtModulation = [];
% FR_diff = 0.0;
% bound = 2.58;
% 
% for n = 1:size(trials,2)
%     for idx = 1:size(trials,3)
%         
%         cxt1bin = (RL(:,n,idx) + GR(:,n,idx))./2;
%         cxt2bin = (RR(:,n,idx) + GL(:,n,idx))./2;
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
% 



%% context modulation 
cxtModulation = [];
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

        cxtModulation(n, idx) = (highBd - lowBd) > (range(cxt1stat) + range(cxt2stat));
        
    end
end

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


%%
% FRthresh = 3;
% TOn = 600;
% % add a constrain on firing rates
% aa = FRmatrix(:,round([select(1):0.001:select(2)].*1000) + TOn,:);
% bb = mean(aa, [2,3]);
% unitIdx = find(sum(cxtModulation, 2) > 0 & bb > FRthresh);


% calculate max FR within this time window of interest
FRthresh = 3;
TOn = 600;

% % add a constrain on firing rates
% TOI = FRmatrix(:,round([select(1):0.001:select(2)].*1000) + TOn,:);
% cxt1FR = TOI(:,:,cxt1);
% cxt2FR = TOI(:,:,cxt2);
% aa = squeeze(mean(cxt1FR, 3));
% bb = squeeze(mean(cxt2FR, 3));
% reachThresh = max(aa, [], 2) > FRthresh | max(bb, [], 2) > FRthresh;


% % add a constrain on firing rates
TOI = FRmatrix(:,round([select(1):0.001:select(2)].*1000) + COn,:);
reachThresh = checkThreshReach(TOI, left, right, green, red, FRthresh);

unitIdx = find(sum(cxtModulation, 2) > 0 & reachThresh);


% for jj = 1:length(unitIdx) %size(FRmatrix,1)
%     id = unitIdx(jj);
%     figure(); hold on
%     
%     plot(mean(squeeze(FRmatrix(id,:, left == 1 & red == 1)), 2), 'r-');
%     plot(mean(squeeze(FRmatrix(id,:, right == 1 & red == 1)), 2), 'r--');
%     plot(mean(squeeze(FRmatrix(id,:, left == 1 & green == 1)), 2), 'g-');
%     plot(mean(squeeze(FRmatrix(id,:, right == 1 & green == 1)), 2), 'g--');
%     
%     xline(600);
%     xline(1300);
%     title(id)
%     pause()
%     close
% end
%     


cxtTMod(dayn).name = dirName(dayn).name(1:end-4);
cxtTMod(dayn).cxtUnits = unitIdx;
cxtTMod(dayn).totalUnits = size(trials,2);

fprintf('dayn %d finished \n', dayn);

end


toc
%%
% save('VinnieCxtTMod.mat', 'cxtTMod');







