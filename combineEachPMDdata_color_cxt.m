clear all; close all; clc



onlyCorrect = 1;

alignment = 'T';

% give a name of the data to be saved
dataName = ['PMD_' alignment '_ColorCxtCorrect'];

g = normpdf([-0.1:0.001:0.1],0,0.025);

dataSaveDir = '/Volumes/TianSSD/PMd/PMdData/Olaf/';

switch alignment
    case 'T'
        dataDir = '/Volumes/TianSSD/PMd/PMdData/Olaf/OlafPMdT1.mat';
%         dataDir = '/Volumes/TianSSD/PMd/PMdData/Tiberius/TibsPMdT1.mat';
        
        load(dataDir);
        tStart = -400;
        tEnd = 2000-1;
        timeAxis = [tStart:tEnd];
        tSelected = timeAxis >= -200 & timeAxis < 1200;        
    case 'C'
        dataDir = '/Volumes/TianSSD/PMd/PMdData/Olaf/OlafPMdC1.mat';
%         dataDir = '/Volumes/TianSSD/PMd/PMdData/Tiberius/TibsPMdC1.mat';
        
        load(dataDir);
        tStart = -1000;
        tEnd = 1000-1;  
        timeAxis = [tStart:tEnd];
        tSelected = timeAxis >= -800 & timeAxis < 800;
    case 'M'
        dataDir = '/Volumes/TianSSD/PMd/PMdData/Olaf/OlafPMdM1.mat';
%         dataDir = '/Volumes/TianSSD/PMd/PMdData/Tiberius/TibsPMdM1.mat';
        
        load(dataDir);
        tStart = -1000;
        tEnd = 1000-1;
        timeAxis = [tStart:tEnd];
        tSelected = timeAxis >= -800 & timeAxis < 800;
end
        

totalDataframe = [];

%%
for dayn = 1:length(dataframe)


    data = dataframe(dayn);



    % extract the reaching direction for each trial 
    perf = [data.behavior];

    % extract chosen color (need trial outcome)
    perfTable = struct2table(perf);
    a = perfTable(:,{'TrialOutcome'});
    b = table2cell(a);    
    correct = strcmp(b, 'Correct Choice')';
    
    spikes = data.spikes;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % choose only correct trials

    if (onlyCorrect == 1)
        perf = perf(correct == 1);
        spikes = spikes(:,correct == 1);
    end
    
    left = [perf.chosenSide] == 1;
    right = [perf.chosenSide] == 2;
    
    red = [perf.CentralCuenSquares] > 112;
    green = ~red;


    % extract target configuration
    % target configuration 1: GL&RR; target configureation 2: GR&RL
    config1 = [perf.LeftTargetColor] == 2;
    config2 = [perf.LeftTargetColor] == 3;  


    RC1 = red & config1;
    RC2 = red & config2;
    GC1 = green & config1;
    GC2 = green & config2;
%%

    daynSpikes = double(spikes);

    FRmatrix = [];
    FRaverage = [];

    for im = 1:size(daynSpikes,3)

        for id = 1:size(daynSpikes,2)
            FR = conv(daynSpikes(:,id,im), g, 'same');
            FRmatrix(im,:,id) = FR(tSelected);
        end
    end

    rFR_RC1 = squeeze(mean(FRmatrix(:,:,RC1),3));
    rFR_RC2 = squeeze(mean(FRmatrix(:,:,RC2),3));
    rFR_GC1 = squeeze(mean(FRmatrix(:,:,GC1),3));
    rFR_GC2 = squeeze(mean(FRmatrix(:,:,GC2),3));

    FRaverage(:,1,1,:) = rFR_RC1;
    FRaverage(:,1,2,:) = rFR_RC2;
    FRaverage(:,2,1,:) = rFR_GC1;
    FRaverage(:,2,2,:) = rFR_GC2;



    totalDataframe = [totalDataframe; FRaverage];



    fprintf('Up to Day %d, total units are %d \n', dayn, size(totalDataframe, 1));



end


save([dataSaveDir dataName '.mat'],'totalDataframe');

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


