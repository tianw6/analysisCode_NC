% created by Tian on Sep 29th 
% try modulation index (R-L)/(R+L)

clear all; close all; clc

e = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/checkerboardAligned/allBinFRnpix.mat').allBinFR;

d = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Vinnie/checkerboardAligned/allBinFRnpix.mat').allBinFR;

a = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/checkerboardAligned/allBinFRvprobe.mat').allBinFR;
b = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Vinnie/checkerboardAligned/allBinFRvprobe.mat').allBinFR;

c = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Ziggy/targetAligned/allBinFRvprobe.mat').allBinFR;

% f = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/targetAligned/allBinFRvprobePMD.mat').allBinFR;
% g = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Olaf/targetAligned/allBinFRvprobePMD.mat').allBinFR;
% h = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/checkerboardAligned/allBinFRnpixPMD.mat').allBinFR;

binFRpfc = [a b e d c];
% binFRpfc = [h];

%% 
allTime = binFRpfc(1).time;

tStart = -100;
tEnd = 400; 
tSelected = allTime >= tStart & allTime <= tEnd;

time = allTime(tSelected);


for ii = 1:length(binFRpfc)
    
    binFRpfc(ii).trials = binFRpfc(ii).trials(:,:,tSelected);
    binFRpfc(ii).time = binFRpfc(ii).time(tSelected);

end



%% 
results = struct;

% (R-L)/(R+L + frCompensation)
frCompensation = 0.01;
for dayn = 1:length(binFRpfc)

  

    taskLabels = binFRpfc(dayn).taskLabels;
    trials = binFRpfc(dayn).trials;
    behaviors = binFRpfc(dayn).behavior;
    red = behaviors.chosenRed;
    left = behaviors.chosenLeft;
    config1 = behaviors.config1;

    % trials = trials./50.*1000;


    %% test 1 unit on all time bins

    dPrimeResults = struct;

    for unitNum = 1:size(trials,2)


        dPrime = zeros(3, size(trials,3));

        for binNum = 1:size(trials,3)

            unitN = squeeze(trials(:,unitNum,binNum));

            dPrime(1, binNum) = abs(mean(unitN(red)) - mean(unitN(~red))) ./ (mean(unitN(red)) + mean(unitN(~red)) + frCompensation);
            dPrime(2, binNum) = abs(mean(unitN(left)) - mean(unitN(~left))) ./ (mean(unitN(left)) + mean(unitN(~left)) + frCompensation);
            dPrime(3, binNum) = abs(mean(unitN(config1)) - mean(unitN(~config1))) ./ (mean(unitN(config1)) + mean(unitN(~config1)) + frCompensation);


        end
       
        dPrimeResults(unitNum).dPrime = dPrime;
        

    end

    results(dayn).dPrimeResults = dPrimeResults;
    results(dayn).name = binFRpfc(dayn).name;
    results(dayn).time = binFRpfc(dayn).time;

    fprintf('day %d finished \n', dayn);

end

 



%% plot all results
% t = timeAxis(tSelected);

d_all = [];
cnt = 1;
for id = 1:length(results)
    temp = results(id).dPrimeResults;
    for idx = 1:length(temp)
        d_all(:,:,cnt) = temp(idx).dPrime;
        cnt = cnt+1;
    end
end


%% 

t = results(1).time;

d_mean = squeeze(nanmean(d_all,3));

figure; hold on
plot(t, d_mean(3,:), 'k')
plot(t, d_mean(1,:), 'm')
plot(t, d_mean(2,:), 'b')

xlim([t(1), t(end)])
ylim([0 0.3])
title('d_prime')




%% 
% save('VinnieNpixDLPFC_ES.mat', 'results')

