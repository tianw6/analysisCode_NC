clear all; close all; clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% path of all dpca core code %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath("/Users/tianwang/Documents/MATLAB/ChandLab/dPCA/matlab");




% for DLPFC data
b = load('TibsDLPFCVprobeBinFR.mat').binFR;

d = load('TibsDLPFCNpixBinFR.mat').binFR;

f = load('VinnieDLPFCVprobeBinFR.mat').binFR;

h = load('VinnieDLPFCNpixBinFR.mat').binFR;



firingRatesAverage = [b; d; f; h];

% firingRatesAverage = [f; h];


%% for pmd data 


b = load('TibsPMDNpixBinFR.mat').binFR;
d = load('TibsPMDVprobeBinFR.mat').binFR;
f = load('OlafPMDVprobeBinFR.mat').binFR;




pmdFR = [b; d; f];

firingRatesAverage = pmdFR;
%% 

binSize = 50;
stepSize = 20;
tStart = -1000;
tEnd = 1000;  
timeAxis = [tStart+binSize:stepSize:tEnd];
tSelected = timeAxis > 50 & timeAxis <= 500;
t = timeAxis(tSelected);


%%

dim1 = 1;
dim2 = 2;

cnt =1;
coeffAll = [];
scoreAll = [];
figure('Position', [300 300 1100 500])
for timePt = 1:1:size(firingRatesAverage,2)

% subtract mean firing rate
temp = squeeze(firingRatesAverage(:,timePt,:));
aveFR = mean(temp,2);

RL = temp(:,1) - aveFR;
RR = temp(:,2) - aveFR;
GL = temp(:,3) - aveFR;
GR = temp(:,4) - aveFR;


data = [RL,RR,GL,GR]';
labels = {'RL', 'RR', 'GL', 'GR'};



%% do PCA 

[coeff, score, latent] = pca(data);

plot3(t(timePt), score(1,dim1),score(1,dim2),'ro', 'markersize', 10, 'linewidth', 2)
hold on
plot3(t(timePt), score(2,dim1), score(2,dim2), 'rd', 'markersize', 10,'MarkerFaceColor','r')
plot3(t(timePt), score(3,dim1), score(3,dim2),'go', 'markersize', 10, 'linewidth', 2)
plot3(t(timePt), score(4,dim1), score(4,dim2),'gd', 'markersize', 10,'MarkerFaceColor','g')

line([t(timePt), t(timePt)], [score(1,dim1), score(3,dim1)], [score(1,dim2), score(3,dim2)] ,'color', 'k')
line([t(timePt), t(timePt)], [score(2,dim1), score(4,dim1)], [score(2,dim2), score(4,dim2)] ,'color', 'k')

coeffAll(:,:,cnt) = coeff;
scoreAll(:,:,cnt) = score;
cnt = cnt+1;

end


xlabel('time after checkerboard')
ylabel('PC1')
zlabel('PC2')
zlim([-10,10])
% axis equal
view([-17.034545454545459,50.201226993865028])




%% 


timePt = 1;
temp = squeeze(firingRatesAverage(:,timePt,:));
aveFR = mean(temp,2);

RL = temp(:,1) - aveFR;
RR = temp(:,2) - aveFR;
GL = temp(:,3) - aveFR;
GR = temp(:,4) - aveFR;


data = [RL,RR,GL,GR]';
labels = {'RL', 'RR', 'GL', 'GR'};



% do PCA 

dim1 = 1;
dim2 = 2;
dim3 = 3;

[coeff, score, latent] = pca(data);

plot3(score(1,dim1),score(1,dim2),score(1,dim3),'ro', 'markersize', 10, 'linewidth', 2)
hold on
plot3(score(2,dim1), score(2,dim2), score(2,dim3),'rd', 'markersize', 10,'MarkerFaceColor','r')
plot3(score(3,dim1), score(3,dim2),score(3,dim3),'go', 'markersize', 10, 'linewidth', 2)
plot3(score(4,dim1), score(4,dim2),score(4,dim3),'gd', 'markersize', 10,'MarkerFaceColor','g')

latent./sum(latent)


%% I use a random data project on coeff, check for variance explained (needs more consideration)

aa = data';

% for k=1:size(temp,1)
%     D(k,:) = temp(k,randperm(4));
% end
%  


nRepeats = 100;
nullExplained = zeros(nRepeats, 3);

for i = 1:nRepeats
    
    for k=1:size(aa,1)
        data2(k,:) = aa(k,randperm(4));
    end    
    
    proj = coeff' * data2;
    projVar = var(proj, 0, 2);

    
    [~, ~, latent_data2] = pca(data2');  % eigenvalues of full PCA of permuted data
    totalVar = sum(latent_data2);  % total variance of data2 in its own PC space

    
    
    nullExplained(i,:) = projVar / totalVar * 100;
end



%%

aa = data';


for k=1:size(aa,1)
    data2(k,:) = aa(k,randperm(4));
end    



% Apply the same normalization to data2
data2_normalized = data2;

% Now project the normalized data2 onto the principal components
scores_data2 = data2_normalized' * coeff;  % assuming loadings is your coefficient matrix

% Calculate variance explained
total_var_data2 = sum(var(data2_normalized,[],2));
explained_var_data2 = var(scores_data2);
explained_var_ratio_data2 = sum(explained_var_data2) / total_var_data2




%% 

addpath("/Users/tianwang/Documents/MATLAB/ChandLab/dPCA/matlab");

% % for DLPFC data
% b = load('TibsDLPFCVprobeBinFR.mat').binFR;
% 
% d = load('TibsDLPFCNpixBinFR.mat').binFR;
% 
% f = load('VinnieDLPFCVprobeBinFR.mat').binFR;
% 
% h = load('VinnieDLPFCNpixBinFR.mat').binFR;
% 
% 
% 
% firingRatesAverage = [b; d; f; h];
% 


b = load('TibsPMDNpixBinFR.mat').binFR;
d = load('TibsPMDVprobeBinFR.mat').binFR;
f = load('OlafPMDVprobeBinFR.mat').binFR;




pmdFR = [b; d; f];

firingRatesAverage = pmdFR;

tt = 1;

data = firingRatesAverage(:,:,:,:);
firingRatesAverage = [];
firingRatesAverage(:,1,1,:) = data(:,tt,1);
firingRatesAverage(:,1,2,:) = data(:,tt,2);
firingRatesAverage(:,2,1,:) = data(:,tt,3);
firingRatesAverage(:,2,2,:) = data(:,tt,4);

% firingRatesAverage = firingRatesAverage - mean(firingRatesAverage, [2 3 4]);  % Subtract mean across all non-neuron dims


% mu = nanmean(nanmean(firingRatesAverage,2),3);
% firingRatesAverage = firingRatesAverage - repmat(mu, [1 size(firingRatesAverage,[2 3]) 1]);

%%
% combinedParams = {{1, [1 2]}, {2}};
% % margNames = {'Stimulus', 'Decision', 'Condition-independent', 'S/D Interaction'};
% margNames = {'Decision', 'Condition-independent'};

% combinedParams = {{2, [2 3]}, {3}};
% margNames = {'Decision', 'Condition-independent'};

combinedParams = {{1}, {2}, {[1 2]}};  % Stimulus, Decision, Interaction
margNames = {'stimulus', 'decision','interaction'};




margColours = [23 100 171; 187 20 25; 150 150 150; 114 97 171]/256;


binSize = 50;
stepSize = 20;
tStart = -1000;
tEnd = 1000;  
timeAxis = [tStart+binSize:stepSize:tEnd];
tSelected = timeAxis > 50 & timeAxis <= 500;
time = timeAxis(tSelected);

timeEvents = 150;
%%

D = reshape(firingRatesAverage,[size(firingRatesAverage,1) 4]);
D = D(:,randperm(4));
% for k=1:size(firingRatesAverage,1)
%     D(k,:) = D(k,randperm(4));
% end

D = reshape(D,[size(firingRatesAverage,1) 2 2]);
%%

tic
[W,V,whichMarg] = dpca(D, 3, ...
    'combinedParams', combinedParams, 'lambda', 0.1);
toc

explVar = dpca_explainedVariance(firingRatesAverage, W, V, ...
    'combinedParams', combinedParams)
% 
% z = dpca_plot(firingRatesAverage, W, V, @dpca_plot_default, ...
%     'explainedVar', explVar, ...
%     'marginalizationNames', margNames, ...
%     'marginalizationColours', margColours, ...
%     'whichMarg', whichMarg,                 ...
%     'time', time,                        ...
%     'timeEvents', timeEvents,               ...
%     'timeMarginalization', 3, ...
%     'legendSubplot', 16, ...
%     'numCompToShow', 20);

