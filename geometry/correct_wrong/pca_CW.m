addpath('../pca_visualize/')


load('wrongTrials.mat')
load('correctTrialsAll.mat')

% firingRatesAverage = [];
% 
% for ii = 1:length(wrongTrials)
%     
%     trials = wrongTrials(ii).trials;
%     labels = wrongTrials(ii).labels;
%     
%     temp = [];
%     
%     temp(:,1,1,:) = squeeze(mean(trials(labels == 0,:,:), 1));
%     temp(:,1,2,:) = squeeze(mean(trials(labels == 1,:,:), 1));
%     temp(:,2,1,:) = squeeze(mean(trials(labels == 2,:,:), 1));
%     temp(:,2,2,:) = squeeze(mean(trials(labels == 3,:,:), 1));
%     
%     firingRatesAverage = [firingRatesAverage; temp];
% end
% %%
% processedFR = preprocess(firingRatesAverage, 1);
% %% pca
% test = processedFR';
% 
% 
% [coeff, score, latent] = pca(test);
% 
% plot(cumsum(latent)./sum(latent))

[coeffW, scoreW, latentW, processedFRW] = calPCA(wrongTrials);

[coeffC, scoreC, latentC, processedFRC] = calPCA(correctTrials);


%% 

figure; hold on

plot(cumsum(latentC)./sum(latentC), 'b')
plot(cumsum(latentW)./sum(latentW), 'm')

xlim([1,50])



%% wrong trials

m = 4;
t = 111;

orthF = reshape(scoreW', [size(scoreW,2), t, m]);


for ii = 1:10
    figure; hold on
    
    plot(squeeze(orthF(ii,:,1)), 'r');
    plot(squeeze(orthF(ii,:,2)), 'r--');
    plot(squeeze(orthF(ii,:,3)), 'g');
    plot(squeeze(orthF(ii,:,4)), 'g--');
    
    pause;
    close
end

%% 

m = 4;
t = 111;

orthFC = reshape(scoreC', [size(scoreC,2), t, m]);


for ii = 1:10
    figure; hold on
    
    plot(squeeze(orthFC(ii,:,1)), 'r');
    plot(squeeze(orthFC(ii,:,2)), 'r--');
    plot(squeeze(orthFC(ii,:,3)), 'g');
    plot(squeeze(orthFC(ii,:,4)), 'g--');
    
    pause;
    close
end

%% project wrong trials to correct trials pca 

WpC = processedFRW'*coeffC; 
orthFW = reshape(WpC', [size(WpC,2), t, m]);

for ii = 1:5
    figure; hold on
    
    plot(squeeze(orthFW(ii,:,1)), 'r');
    plot(squeeze(orthFW(ii,:,2)), 'r--');
    plot(squeeze(orthFW(ii,:,3)), 'g');
    plot(squeeze(orthFW(ii,:, 4)), 'g--');
    
    pause; 
    close
end

% calculate cross-projection variance explained and plot them

total_var_data = sum(var(processedFRW', 0,  1));   % sum over all 3393 dims
var_per_pc = cumsum(var(WpC, 0, 1)) ./ total_var_data;

figure; hold on
plot(cumsum(latentW)./ sum(latentW))
plot(var_per_pc)
    
% calculate with cov matrix trace

% C = cov(processedFRW');
%   
% for ii = 1:size(coeffC,2)
%     Q = coeffC(:,1:ii);
%     var_per_pc(ii) = trace(Q'*C*Q)./sum(latentW);
% end
% 
% plot(var_per_pc)


%%
function [coeff, score, latent, processedFR] = calPCA(CWtrials)

    firingRatesAverage = [];

    for ii = 1:length(CWtrials)

        trials = CWtrials(ii).trials;
        labels = CWtrials(ii).labels;

        temp = [];

        temp(:,1,1,:) = squeeze(mean(trials(labels == 0,:,:), 1));
        temp(:,1,2,:) = squeeze(mean(trials(labels == 1,:,:), 1));
        temp(:,2,1,:) = squeeze(mean(trials(labels == 2,:,:), 1));
        temp(:,2,2,:) = squeeze(mean(trials(labels == 3,:,:), 1));

        firingRatesAverage = [firingRatesAverage; temp];
    end

    % normalize data and remove mean
    processedFR = preprocess(firingRatesAverage, 1);
    % pca
    test = processedFR';
    [coeff, score, latent] = pca(test);
    
end