function [processedFR, firingRatesAverage] = prepareData(allBinFR, subtractCI)

firingRatesAverage = [];
for ii = 1:length(allBinFR)
    
    trials = allBinFR(ii).trials;
    taskLabels = allBinFR(ii).taskLabels;
    
    RL = taskLabels == 0;
    RR = taskLabels == 1;
    GL = taskLabels == 2;
    GR = taskLabels == 3;
    
    temp = [];
    if size(trials, 2) ~= 1
        temp(:,1,1,:) = squeeze(nanmean(trials(RL,:,:),1));
        temp(:,1,2,:) = squeeze(nanmean(trials(RR,:,:),1));
        temp(:,2,1,:) = squeeze(nanmean(trials(GL,:,:),1));
        temp(:,2,2,:) = squeeze(nanmean(trials(GR,:,:),1));
    else

        temp(:,1,1,:) = squeeze(nanmean(trials(RL,:,:),1))';
        temp(:,1,2,:) = squeeze(nanmean(trials(RR,:,:),1))';
        temp(:,2,1,:) = squeeze(nanmean(trials(GL,:,:),1))';
        temp(:,2,2,:) = squeeze(nanmean(trials(GR,:,:),1))';        
        
    end
    
    firingRatesAverage = [firingRatesAverage; temp];
end

processedFR = preprocess(firingRatesAverage, subtractCI);

end

