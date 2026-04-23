% failed, since PC2 and PC3 captured basically noise

clear;clc;close all

load("~/Desktop/allBinFR_T50_5.mat");

dayn = 1;

binSize = 50;
stepSize = 5;
tStart = -1000;
tEnd = 1000;  
timeAxis = [tStart+binSize:stepSize:tEnd];
tSelected = timeAxis > 50 & timeAxis <= 300;

time = timeAxis(tSelected);

t = 50;
trials = allBinFR(dayn).trials;
taskLabels = allBinFR(dayn).taskLabels;

c1 = mean(trials((taskLabels == 0),:,t), 1);
c3 = mean(trials((taskLabels == 1),:,t), 1);
c4 = mean(trials((taskLabels == 2),:,t), 1);
c2 = mean(trials((taskLabels == 3),:,t), 1);

data = [c1', c2', c3', c4'];
%% 2 inputs: A (cxt) 0 is RL&GR, 1 is RR&GL; B (color) 0 is red, 1 is green. output: choice or A X B

X1 = data;
X1_centered = X1 - mean(X1, 2);
% X1_centered = X1;

[coeff1, score1, ~, ~, expl1] = pca(X1_centered');  % PCs on conditions

U1 = coeff1(:, 1:3);
%%

figure;
scatter3(score1(1,1), score1(1,2), score1(1,3), 100, 'ro', 'filled'); hold on;
scatter3(score1(2,1), score1(2,2), score1(2,3), 100, 'gd', 'filled'); hold on;
scatter3(score1(3,1), score1(3,2), score1(3,3), 100, 'rd', 'filled'); hold on;
scatter3(score1(4,1), score1(4,2), score1(4,3), 100, 'go', 'filled'); hold on;

xlabel('PC1'); ylabel('PC2'); zlabel('PC3')
expl1




%% calculate vectors 


% Compute population coding vectors
v_A  = 0.5 * ((c3 - c1) + (c4 - c2));         % main effect of A
v_B  = 0.5 * ((c2 - c1) + (c4 - c3));         % main effect of B
v_AB = 0.25 * (c4 - c3 - c2 + c1);            % A×B interaction (nonlinear term)

% Normalize for interpretability (optional)
v_A  = v_A / norm(v_A);
v_B  = v_B / norm(v_B);
v_AB = v_AB / norm(v_AB);

% Optional: check orthogonality
fprintf('Dot(v_A, v_B)  = %.3f\n', dot(v_A, v_B));
fprintf('Dot(v_A, v_AB) = %.3f\n', dot(v_A, v_AB));
fprintf('Dot(v_B, v_AB) = %.3f\n', dot(v_B, v_AB));

% Optional: report vector norms before normalization
raw_v_A  = 0.5 * ((c3 - c1) + (c4 - c2));
raw_v_B  = 0.5 * ((c2 - c1) + (c4 - c3));
raw_v_AB = 0.25 * (c4 - c3 - c2 + c1);

fprintf('Norm(v_A)  = %.3f\n', norm(raw_v_A));
fprintf('Norm(v_B)  = %.3f\n', norm(raw_v_B));
fprintf('Norm(v_AB) = %.3f\n', norm(raw_v_AB));


%% 

% Project all 4 conditions onto v_A, v_B, v_AB
cond_matrix = data;  % [50 x 4]

% Compute population coding vectors
v_A  = 0.5 * ((c3 - c1) + (c4 - c2));         % main effect of A
v_B  = 0.5 * ((c2 - c1) + (c4 - c3));         % main effect of B
v_AB = 0.25 * (c4 - c3 - c2 + c1);            % A×B interaction (nonlinear term)


proj_A  = v_A  * cond_matrix;   % [1 x 4]
proj_B  = v_B  * cond_matrix;
proj_AB = v_AB * cond_matrix;

% Plot
figure;
subplot(1,3,1); bar(proj_A);  title('Projection on v_A');
subplot(1,3,2); bar(proj_B);  title('Projection on v_B');
subplot(1,3,3); bar(proj_AB); title('Projection on v_{AB}');

