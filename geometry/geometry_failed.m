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
b = load('/Volumes/TianSSD/TiberiusNpix/checkerboardAligned/DLPFCtotalDataframeC.mat').totalDataframe;

d = load('/Volumes/TianSSD/TiberiusDLPFCforDPCA/checkerboardAligned/totalDataframeC.mat').totalDataframe;

f = load('/Volumes/TianSSD/VinnieNpix/checkerboardAligned/DLPFCtotalDataframeC.mat').totalDataframe;

h = load('/Volumes/TianSSD/VinnieDLPFCforDPCA/checkerboardAligned/totalDataframeC.mat').totalDataframe;


frTN = b(:,:,:,1:1300);

frTV = d(:,:,:,1:1300);

frVN = f(:,:,:,1:1300);

frVV = h(:,:,:,1:1300);

firingRatesAverage = [frTN; frTV; frVN; frVV];



%% for pmd data 


b = load('/Volumes/TianSSD/PMd/PMdData/Tiberius/PMDtotalDataframeC.mat').totalDataframe;

d = load('/Volumes/TianSSD/PMd/PMdData/Olaf/PMDtotalDataframeC.mat').totalDataframe;

f = load('/Volumes/TianSSD/TiberiusNpix/checkerboardAligned/PMDtotalDataframeC.mat').totalDataframe;


frTN = f(:,:,:,1:1300);

frTV = b(:,:,:,1:1300);

frOV = d(:,:,:,1:1300);

firingRatesAverage = [frTN; frTV; frOV];

%% 
processedFR = preprocess(firingRatesAverage);


%%

figure('Position', [300 300 900 600])
for timePt = 800:100:1300

base = size(processedFR,2)./4;

RL = processedFR(:,timePt);
RR = processedFR(:,base+timePt);
GL = processedFR(:,base*2+timePt);
GR = processedFR(:,base*3+timePt);

% RL = mean(processedFR(end-700:end,timePt-20:timePt), 2);
% RR = mean(processedFR(end-700:end,base+timePt-20: base+timePt), 2);
% GL = mean(processedFR(end-700:end,base*2+timePt - 20: base*2+timePt), 2);
% GR = mean(processedFR(end-700:end,base*3+timePt - 20: base*3+timePt), 2);


data = [RL,RR,GL,GR]';
labels = {'RL', 'RR', 'GL', 'GR'};



%% do PCA 

[coeff, score, latent] = pca(data);

plot3((timePt - 200).*0.2, score(1,1),score(1,2),'r.', 'markersize', 20)
hold on
plot3((timePt - 200).*0.2, score(2,1), score(2,2), 'rd', 'markersize', 10,'MarkerFaceColor','r')
plot3((timePt - 200).*0.2, score(3,1), score(3,2),'g.', 'markersize', 20)
plot3((timePt - 200).*0.2, score(4,1), score(4,2),'gd', 'markersize', 10,'MarkerFaceColor','g')




end


xlabel('time')
ylabel('1')
zlabel('2')

axis equal
%%



% Step 2: Calculate pairwise distances between points
D = pdist(data); % Euclidean distance by default
D_square = squareform(D); % Convert to square matrix format

% Print the distance matrix
fprintf('Distance matrix between points:\n');
disp(D_square);

%%
% Step 3: Perform classical MDS
[Y, eigvals] = cmdscale(D);

% Step 4: Analyze eigenvalues to understand the data structure
figure;
plot(eigvals, 'o-', 'LineWidth', 2);
xlabel('Dimension');
ylabel('Eigenvalue');
title('Scree Plot for MDS');
grid on;

% Calculate percentage of variance explained
totalVar = sum(abs(eigvals));
varExplained = abs(eigvals) / totalVar * 100;
fprintf('Variance explained by first 2 dimensions: %.2f%%\n', sum(varExplained(1:2)));
fprintf('Variance explained by first 3 dimensions: %.2f%%\n', sum(varExplained(1:3)));


%% Step 5: Visualize in 2D
figure;
scatter(Y(:,1), Y(:,2), 100, 'filled');
xlabel('Dimension 1');
ylabel('Dimension 2');
title('MDS Visualization of 4 Points (2D)');
grid on;

% Add labels
for i = 1:4
    text(Y(i,1)+0.01, Y(i,2)+0.01, labels{i}, 'FontSize', 12);
end

% Calculate stress (goodness of fit)
D_reconstructed = pdist(Y(:,1:2));
stress = norm(D - D_reconstructed) / norm(D);
fprintf('Stress for 2D representation: %.4f\n', stress);

%% Step 6: Visualize in 3D if needed
if size(Y, 2) >= 3
    figure;
    scatter3(Y(:,1), Y(:,2), Y(:,3), 100, 'filled');
    xlabel('Dimension 1');
    ylabel('Dimension 2');
    zlabel('Dimension 3');
    title('MDS Visualization of 4 Points (3D)');
    grid on;
    
    % Add labels
    for i = 1:4
        text(Y(i,1)+0.01, Y(i,2)+0.01, Y(i,3)+0.01, labels{i}, 'FontSize', 12);
    end
    
    % Calculate stress for 3D
    D_reconstructed_3d = pdist(Y(:,1:3));
    stress_3d = norm(D - D_reconstructed_3d) / norm(D);
    fprintf('Stress for 3D representation: %.4f\n', stress_3d);
end

%% Step 7: Create color-coded visualization that reflects R/G and L/R groupings
figure;
colormap = [1 0 0;   % Red for RL
            1 0 0;   % Red for RR
            0 1 0;   % Green for GL
            0 1 0];  % Green for GR
            
markerStyles = {'o', 'd', 'o', 'd'}; % Circle for Left, Square for Right

hold on;
for i = 1:4
    scatter(Y(i,1), Y(i,2), 200, colormap(i,:), markerStyles{i}, 'filled');
    text(Y(i,1)+0.01, Y(i,2)+0.01, labels{i}, 'FontSize', 12);
end
xlabel('Dimension 1');
ylabel('Dimension 2');
title('Color-Coded MDS Visualization (Red/Green and Left/Right)');
grid on;
legend('Left (Circle)', 'Right (Square)', 'Location', 'best');
hold off;


