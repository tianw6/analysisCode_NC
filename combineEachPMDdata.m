clear all; close all; clc


% load allTrials data from TiberiusDLPFCAllTrials
dataSaveDir = ['/Volumes/TianSSD/PMd/PMdData/Olaf/'];


% give a name of the data to be saved
dataName = 'PMDtotalDataframeT';
g = normpdf([-0.1:0.001:0.1],0,0.025);
chopTime = 200;

% monkey = 'Olaf';
monkey = 'Olaf';

switch dataName 
    case'PMDtotalDataframeT'
        allData = load([dataSaveDir monkey 'PMdT1.mat']).dataframe;
    case'PMDtotalDataframeC'
        allData = load([dataSaveDir monkey 'PMdC1.mat']).dataframe;
    case'PMDtotalDataframeM'
        allData = load([dataSaveDir monkey 'PMdM1.mat']).dataframe;        
end

        

totalDataframe = [];

%%
for dayn = 1:length(allData)

daynData = allData(dayn);

perf = [daynData.behavior];
% chosen side
left = [perf.chosenSide] == 1;


% extract chosen color (need trial outcome)
perfTable = struct2table(perf);
a = perfTable(:,{'TrialOutcome'});
b = table2cell(a);    
correct = strcmp(b, 'Correct Choice')';

red = [perf.CentralCuenSquares] > 112 & correct == 1 | [perf.CentralCuenSquares] < 112 & correct == 0;


cxt1 = [perf.LeftTargetColor] == 2;
RL = red & left;
RR = red & ~left;
GL = ~red & left;
GR = ~red & ~left;



%%

daynSpikes = double(daynData.spikes);

FRmatrix = [];
FRaverage = [];

g = normpdf([-0.1:0.001:0.1],0,0.025);
chopTime = 200;
for im = 1:size(daynSpikes,3)
    
    for id = 1:size(daynSpikes,2)
        FR = conv(daynSpikes(:,id,im), g, 'same');
        FRmatrix(im,:,id) = FR(chopTime+1:end-chopTime);
        
    end
end


rFR_LR = mean(FRmatrix(:,:,RL),3);
rFR_RR = mean(FRmatrix(:,:,RR),3);
rFR_LG = mean(FRmatrix(:,:,GL),3);
rFR_RG = mean(FRmatrix(:,:,GR),3);

FRaverage(:,1,1,:) = rFR_LR;
FRaverage(:,1,2,:) = rFR_RR;
FRaverage(:,2,1,:) = rFR_LG;
FRaverage(:,2,2,:) = rFR_RG;



totalDataframe = [totalDataframe; FRaverage];



fprintf('Up to Day %d, total units are %d \n', dayn, size(totalDataframe, 1));



end


% save([dataSaveDir dataName '.mat'],'totalDataframe');

%% plot some average psth

for ip = 1:size(FRaverage,1)
    figure; hold on
    plot(squeeze(FRaverage(ip,1,1,:)), 'r')
    plot(squeeze(FRaverage(ip,1,2,:)), 'r--')
    plot(squeeze(FRaverage(ip,2,1,:)), 'g')
    plot(squeeze(FRaverage(ip,2,2,:)), 'g--')     
    pause;
    close;
end
%% Sanity check: check for nan 
% will display # neuron which has nan 
for ii = 1 : size(totalDataframe, 1)
    if sum(isnan(totalDataframe(ii,:,:,:)), 'All') ~= 0
        fprintf('Nan neurons: %d \n', ii)
    end
end

%% Sanity check: check for zeros 
% will display # neuron which has nan 
for ii = 1 : size(totalDataframe, 1)
    
    if sum(totalDataframe(ii,:,:,:), 'all') == 0
        fprintf('zero FR neurons: %d \n', ii)
    end
end


