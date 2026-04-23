%% This section creates toy data.
%
% It should be replaced by actual experimental data. The data should be
% joined in three arrays of the following sizes (for the Romo-like task):
%
% trialNum: N x S x D
% firingRates: N x S x D x T x maxTrialNum
% firingRatesAverage: N x S x D x T
%
% N is the number of neurons
% S is the number of stimuli conditions (F1 frequencies in Romo's task)
% D is the number of decisions (D=2)
% T is the number of time-points (note that all the trials should have the
% same length in time!)
%
% trialNum -- number of trials for each neuron in each S,D condition (is
% usually different for different conditions and different sessions)
%
% firingRates -- all single-trial data together, massive array. Here
% maxTrialNum is the maximum value in trialNum. E.g. if the number of
% trials per condition varied between 1 and 20, then maxTrialNum = 20. For
% the neurons and conditions with less trials, fill remaining entries in
% firingRates with zeros or nans.
%
% firingRatesAverage -- average of firingRates over trials (5th dimension).
% If the firingRates is filled up with nans, then it's simply
%    firingRatesAverage = nanmean(firingRates,5)
% If it's filled up with zeros (as is convenient if it's stored on hard 
% drive as a sparse matrix), then 
%    firingRatesAverage = bsxfun(@times, mean(firingRates,5), size(firingRates,5)./trialNum)

clear all; close all; 

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


temp = squeeze(firingRatesAverage(:,1,:));
aveFR = mean(temp,2);

RL = temp(:,1) - aveFR;
RR = temp(:,2) - aveFR;
GL = temp(:,3) - aveFR;
GR = temp(:,4) - aveFR;


u = [RL,RR,GL,GR]';


temp = squeeze(firingRatesAverage(:,11,:));
aveFR = mean(temp,2);

RL = temp(:,1) - aveFR;
RR = temp(:,2) - aveFR;
GL = temp(:,3) - aveFR;
GR = temp(:,4) - aveFR;


v = [RL,RR,GL,GR]';

u = squeeze(firingRatesAverage(:,1,:))';
v = squeeze(firingRatesAverage(:,2,:))';



[v_aligned, transformation] = customAlignMatrices(u, v, true);







%% 

scoreAll = scoreAll(:,1:2,:);

u = scoreAll(:,:,1);                      % Reference matrix
v = scoreAll(:,:,11);                  % Create a transformed version

% Align v to match u
[v_aligned, transformation] = customAlignMatrices(u, v, true);

% Visualize the results
% figure;
% subplot(1,3,1), imagesc(u), title('Reference Matrix (u)');
% subplot(1,3,2), imagesc(v), title('Original Matrix (v)');
% subplot(1,3,3), imagesc(v_aligned), title('Aligned Matrix');
% colorbar;


timePt = 1;
figure('Position', [300 300 1100 500])
plot3(t(timePt), u(1,dim1),u(1,dim2),'ro', 'markersize', 10, 'linewidth', 2)
hold on
plot3(t(timePt), u(2,dim1), u(2,dim2), 'rd', 'markersize', 10,'MarkerFaceColor','r')
plot3(t(timePt), u(3,dim1), u(3,dim2),'go', 'markersize', 10, 'linewidth', 2)
plot3(t(timePt), u(4,dim1), u(4,dim2),'gd', 'markersize', 10,'MarkerFaceColor','g')

line([t(timePt), t(timePt)], [u(1,dim1), u(3,dim1)], [u(1,dim2), u(3,dim2)] ,'color', 'k')
line([t(timePt), t(timePt)], [u(2,dim1), u(4,dim1)], [u(2,dim2), u(4,dim2)] ,'color', 'k')


timePt2 = 5;
plot3(t(timePt2), v_aligned(1,dim1),v_aligned(1,dim2),'ro', 'markersize', 10, 'linewidth', 2)
hold on
plot3(t(timePt2), v_aligned(2,dim1), v_aligned(2,dim2), 'rd', 'markersize', 10,'MarkerFaceColor','r')
plot3(t(timePt2), v_aligned(3,dim1), v_aligned(3,dim2),'go', 'markersize', 10, 'linewidth', 2)
plot3(t(timePt2), v_aligned(4,dim1), v_aligned(4,dim2),'gd', 'markersize', 10,'MarkerFaceColor','g')

line([t(timePt2), t(timePt2)], [v_aligned(1,dim1), v_aligned(3,dim1)], [v_aligned(1,dim2), v_aligned(3,dim2)] ,'color', 'k')
line([t(timePt2), t(timePt2)], [v_aligned(2,dim1), v_aligned(4,dim1)], [v_aligned(2,dim2), v_aligned(4,dim2)] ,'color', 'k')



% timePt2 = 9;
% plot3(t(timePt2), v(1,dim1),v(1,dim2),'ro', 'markersize', 10, 'linewidth', 2)
% hold on
% plot3(t(timePt2), v(2,dim1), v(2,dim2), 'rd', 'markersize', 10,'MarkerFaceColor','r')
% plot3(t(timePt2), v(3,dim1), v(3,dim2),'go', 'markersize', 10, 'linewidth', 2)
% plot3(t(timePt2), v(4,dim1), v(4,dim2),'gd', 'markersize', 10,'MarkerFaceColor','g')
% 
% line([t(timePt2), t(timePt2)], [v(1,dim1), v(3,dim1)], [v(1,dim2), v(3,dim2)] ,'color', 'k')
% line([t(timePt2), t(timePt2)], [v(2,dim1), v(4,dim1)], [v(2,dim2), v(4,dim2)] ,'color', 'k')





%% 

dim3 = 3;
u = scoreAll(:,:,1);                      % Reference matrix
v = scoreAll(:,:,2);                  % Create a transformed version

% Align v to match u
[v_aligned, transformation] = customAlignMatrices(u, v, true);

% Visualize the results
% figure;
% subplot(1,3,1), imagesc(u), title('Reference Matrix (u)');
% subplot(1,3,2), imagesc(v), title('Original Matrix (v)');
% subplot(1,3,3), imagesc(v_aligned), title('Aligned Matrix');
% colorbar;



timePt = 1;
figure('Position', [300 300 1100 500])
plot3(u(1,dim3), u(1,dim1),u(1,dim2),'ro', 'markersize', 10, 'linewidth', 2)
hold on
plot3(u(2,dim3), u(2,dim1), u(2,dim2), 'rd', 'markersize', 10,'MarkerFaceColor','r')
plot3(u(3,dim3), u(3,dim1), u(3,dim2),'go', 'markersize', 10, 'linewidth', 2)
plot3(u(4,dim3), u(4,dim1), u(4,dim2),'gd', 'markersize', 10,'MarkerFaceColor','g')

line([u(1,dim3), u(3,dim3)], [u(1,dim1), u(3,dim1)], [u(1,dim2), u(3,dim2)] ,'color', 'k')
line([u(2,dim3), u(4,dim3)], [u(2,dim1), u(4,dim1)], [u(2,dim2), u(4,dim2)] ,'color', 'k')
axis equal
timePt2 = 5;
plot3(v_aligned(1,dim3), v_aligned(1,dim1),v_aligned(1,dim2),'ro', 'markersize', 10, 'linewidth', 2)
hold on
plot3(v_aligned(2,dim3), v_aligned(2,dim1), v_aligned(2,dim2), 'rd', 'markersize', 10,'MarkerFaceColor','r')
plot3(v_aligned(3,dim3), v_aligned(3,dim1), v_aligned(3,dim2),'go', 'markersize', 10, 'linewidth', 2)
plot3(v_aligned(4,dim3), v_aligned(4,dim1), v_aligned(4,dim2),'gd', 'markersize', 10,'MarkerFaceColor','g')

line([v_aligned(1,dim3), v_aligned(3,dim3)], [v_aligned(1,dim1), v_aligned(3,dim1)], [v_aligned(1,dim2), v_aligned(3,dim2)] ,'color', 'k')
line([v_aligned(2,dim3), v_aligned(4,dim3)], [v_aligned(2,dim1), v_aligned(4,dim1)], [v_aligned(2,dim2), v_aligned(4,dim2)] ,'color', 'k')




timePt2 = 9;
plot3(v(1,dim3), v(1,dim1),v(1,dim2),'ro', 'markersize', 10, 'linewidth', 2)
hold on
plot3(v(2,dim3), v(2,dim1), v(2,dim2), 'rd', 'markersize', 10,'MarkerFaceColor','r')
plot3(v(3,dim3), v(3,dim1), v(3,dim2),'go', 'markersize', 10, 'linewidth', 2)
plot3(v(4,dim3), v(4,dim1), v(4,dim2),'gd', 'markersize', 10,'MarkerFaceColor','g')

line([v(1,dim3), v(3,dim3)], [v(1,dim1), v(3,dim1)], [v(1,dim2), v(3,dim2)] ,'color', 'k')
line([v(2,dim3), v(4,dim3)], [v(2,dim1), v(4,dim1)], [v(2,dim2), v(4,dim2)] ,'color', 'k')




%%

scoreAll = scoreAll(:,1:2,:);


u = scoreAll(:,:,1);                      % Reference matrix

figure('Position', [300 300 1100 500])
% figure;
for timePt = 1:1:size(scoreAll,3)
% Create example matrices
v = scoreAll(:,:,timePt);                  % Create a transformed version

% Align v to match u
[v_aligned, transformation] = customAlignMatrices(u, v, true);

% Visualize the results
% figure;
% subplot(1,3,1), imagesc(u), title('Reference Matrix (u)');
% subplot(1,3,2), imagesc(v), title('Original Matrix (v)');
% subplot(1,3,3), imagesc(v_aligned), title('Aligned Matrix');
% colorbar;

plot3(t(timePt), v_aligned(1,1),v_aligned(1,2),'ro', 'markersize', 10, 'linewidth', 2)
hold on
plot3(t(timePt), v_aligned(2,1), v_aligned(2,2), 'rd', 'markersize', 10,'MarkerFaceColor','r')
plot3(t(timePt), v_aligned(3,1), v_aligned(3,2),'go', 'markersize', 10, 'linewidth', 2)
plot3(t(timePt), v_aligned(4,1), v_aligned(4,2),'gd', 'markersize', 10,'MarkerFaceColor','g')

line([t(timePt), t(timePt)], [v_aligned(1,1), v_aligned(3,1)], [v_aligned(1,2), v_aligned(3,2)] ,'color', 'k')
line([t(timePt), t(timePt)], [v_aligned(2,1), v_aligned(4,1)], [v_aligned(2,2), v_aligned(4,2)] ,'color', 'k')


u = v_aligned;
end


