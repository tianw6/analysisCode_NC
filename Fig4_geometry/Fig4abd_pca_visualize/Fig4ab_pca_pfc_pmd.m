%%%%%%%%%%%%%%%%%%%%
% This code plots Fig 4a-b: activities projected to PC 3 and 7 and pca distance analysis
% Change PC to 4 and 5 to get Fig S3a 

% Also plot Fig S3d-e: surface area of tetrahedron and volume 



% combine pfc and pmd data and do pca together
clear; clc; close all

addpath('../../utils/')


%% load dlpfc Data
a = load('../../../analysisData_NC/Fig4/Tiberius/checkerboardAligned/allBinFRnpix.mat').allBinFR;
b = load('../../../analysisData_NC/Fig4/Vinnie/checkerboardAligned/allBinFRnpix.mat').allBinFR;
c = load('../../../analysisData_NC/Fig4/Tiberius/checkerboardAligned/allBinFRvprobe.mat').allBinFR;
d = load('../../../analysisData_NC/Fig4/Vinnie/checkerboardAligned/allBinFRvprobe.mat').allBinFR;

binFRpfc = [c,a,d,b];

%% load pmd data
a = load('../../../analysisData_NC/Fig4/Tiberius/checkerboardAligned/allBinFRnpixPMD.mat').allBinFR;
b = load('../../../analysisData_NC/Fig4/Tiberius/checkerboardAligned/allBinFRvprobePMD.mat').allBinFR;
c = load('../../../analysisData_NC/Fig4/Olaf/checkerboardAligned/allBinFRvprobePMD.mat').allBinFR;


binFRpmd = [a b c];

%% define time length the analysis 

allTime = binFRpfc(1).time;

tStart = -100;
tEnd = 300; 
tSelected = allTime >= tStart & allTime <= tEnd;

time = allTime(tSelected);



%% 


for ii = 1:length(binFRpfc)
    
    binFRpfc(ii).trials = binFRpfc(ii).trials(:,:,tSelected);
    binFRpfc(ii).time = binFRpfc(ii).time(tSelected);

end

for ii = 1:length(binFRpmd)
    

    binFRpmd(ii).trials = binFRpmd(ii).trials(:,:,tSelected);
    binFRpmd(ii).time = binFRpmd(ii).time(tSelected);
end



%% normalize the data
% don't subtract the aveage FR
subtractCI = 0;
[processedFRpfc, ~] = prepareData(binFRpfc, subtractCI);
[processedFRpmd, ~] = prepareData(binFRpmd, subtractCI);

X = [processedFRpfc; processedFRpmd];
%% pca
test = X';


% [coeff, score, latent] = pca(test);
[coeff, score, latent] = pca(test); % X' is T x units



Zpfc = coeff(1:size(processedFRpfc,1),:)'*processedFRpfc;
Zpmd = coeff(size(processedFRpfc,1) + 1:end,:)'*processedFRpmd;


%% reshape matrix and subtract average signal

m = length(unique(binFRpfc(1).taskLabels));
t = size(processedFRpfc,2)/m;

orthFpfc = reshape(Zpfc, [size(Zpfc,1),t,m]);
orthFpmd = reshape(Zpmd, [size(Zpmd,1),t,m]);

% remove average signal
orthFpfcM = orthFpfc - mean(orthFpfc,3);
orthFpmdM = orthFpmd - mean(orthFpmd,3);


%% Fig 4a: plot DLPFC 2D PCA at each time point (or Fig S3a: choose other 2 pcs)

% specifiy which figure to plot ('Fig4a' or FigS3a)
% Fig4a: plot pc 3 and 7
% FigS3a: plot pc 4 and 5
figHandle = 'FigS3a';

switch figHandle
    case{'Fig4a'}
        selectPC = [3 7];

        x_limit = [-5 5];
        y_limit = [-6 4];
    case{'FigS3a'}
        selectPC = [4 5];

        x_limit = [-6 6];
        y_limit = [-6 6];
end
       


orthFpfcM = orthFpfc - mean(orthFpfc,3);
orthFpmdM = orthFpmd - mean(orthFpmd,3);

traj = orthFpfcM(selectPC,:,:);
traj2 = orthFpmdM(selectPC,:,:);

timePts = [-50, 0, 100, 150, 200, 300];


% plot DLPFC
figure('Position',[100 100 2000 400]); % [x, y, width, height]
 
cnt = 1;

for tt = timePts

    tV = find(time == tt);
    subplot(1,7,cnt); hold on

    A = [traj(1,tV,1),traj(2,tV,1)];
    B = [traj(1,tV,2),traj(2,tV,2)];
    C = [traj(1,tV,3),traj(2,tV,3)];
    D = [traj(1,tV,4),traj(2,tV,4)];

    points = [A;B;C;D];
    plotGeometry(points, tV, 'cyan')


    title(time(tV))

    xlim(x_limit)
    ylim(y_limit)

    axis equal
    axis off 

    cnt = cnt + 1;

end

sgtitle([figHandle ': DLPFC'])

% plot pmd 

figure('Position',[100 100 2000 400]); % [x, y, width, height]
cnt = 1; 
for tt = timePts

    tV = find(time == tt);
    subplot(1,7,cnt); hold on

    A = [traj2(1,tV,1),traj2(2,tV,1)];
    B = [traj2(1,tV,2),traj2(2,tV,2)];
    C = [traj2(1,tV,3),traj2(2,tV,3)];
    D = [traj2(1,tV,4),traj2(2,tV,4)];

    points = [A;B;C;D];
    plotGeometry(points, tV, 'm')

    title(time(tV))


    xlim(x_limit)
    ylim(y_limit)

    axis equal
    axis off 

    cnt = cnt + 1;


end

sgtitle([figHandle ': PMd'])


%% Fig 3a: plot tetrahedron at 200ms

tarTP = 200;   % 200ms time point
% identify the 3 PC dimensions 
dims = [7 4 5];
t = time == tarTP;

ax = plotTetrahedron3D(orthFpfcM, dims, t, 'FaceColor', [0.7 0.9 1], 'FaceAlpha', 0.15);

% % plotTetrahedron3D(orthFpmdM, dims, t, ...
% %     'Ax', ax, 'FaceColor', [1 0.7 0.9], 'FaceAlpha', 0.15);
% % 


set(gcf, 'Color', 'w');
axis off; 
axis tight;
set(gca, 'LooseInset', [ 0 0 0 0 ]);
xlabel(['PC' num2str(dims(1))]);
ylabel(['PC' num2str(dims(2))]);
zlabel(['PC' num2str(dims(3))]);
axis vis3d;
axis equal


view([-17 15]) 


tv = ThreeVector(ax);
tv.axisInset = [1 1]; % in cm [left bottom]
tv.vectorLength = 2; % in cm
tv.fontSize = 15; % font size used for axis labels
tv.fontColor = 'k'; % font color used for axis labels
tv.lineWidth = 3; % line width used for axis vectors
tv.lineColor = 'k'; % line color used for axis vectors
tv.update();
rotate3d on;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% very important: set ax.SortMethod = 'childorder' to solve the dash
%%%%%% line export error
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ax = gca;
ax.SortMethod = 'childorder';

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig4/geometry/tetrahedron_745.eps']);




%% Fig 3b: distance analysis pfc (choose first 10 dimension)

dims = 1:10;
distResult    = computeDistances(orthFpfc, dims);
distResultPMd = computeDistances(orthFpmd, dims);


figure('position', [20 20 1200 500])

subplot(3,1,1), hold on
plot(time, distResult(:,1), 'k')
plot(time, distResultPMd(:,1), 'k--')
xlim([-50 300])

subplot(3,1,2), hold on
plot(time, distResult(:,2), 'm')
plot(time, distResultPMd(:,2), 'm--')
xlim([-50 300])

subplot(3,1,3), hold on
plot(time, distResult(:,3), 'b')
plot(time, distResultPMd(:,3), 'b--')

plot(time, distResult(:,4), 'r')
plot(time, distResultPMd(:,4), 'r--')

xlim([-50 300])


sgtitle('Fig 3b')
% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig4/geometry/', 'pfcpmdDistance3', '.eps']);


%% Fig S3d-e tetrahedron volume and surface area
dims = 1:10;
orthFpfc10 = orthFpfc(dims,:,:);
orthFpmd10 = orthFpmd(dims,:,:);
for t = 1:size(orthFpfc10,2)
    pts = squeeze(orthFpfc10(:, t, :));  % 10 x 4
    [perimpfc(t), surfApfc(t), volpfc(t)] = tetraGeometry(pts);
end

for t = 1:size(orthFpmd10,2)
    pts = squeeze(orthFpmd10(:, t, :));  % 10 x 4
    [perimpmd(t), surfApmd(t), volpmd(t)] = tetraGeometry(pts);
end


figure('Position', [10 10 1500 400]); 

subplot(1,2,1)
hold on
plot(time, volpfc)
plot(time, volpmd)
xlim([-50 300])
title('volume')
set(gca, 'TickDir', 'out'); % For current axes
% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig4_s/', 'vol_tetrahedron', '.eps']);

subplot(1,2,2)
hold on
plot(time, surfApfc)
plot(time, surfApmd)
title('surface area')
xlim([-50 300])
set(gca, 'TickDir', 'out'); % For current axes
legend('DLPFC', 'PMd')
% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig4_s/', 'surfA_tetrahedron', '.eps']);

sgtitle('Fig S3d-e')
%% 


function distResult = computeDistances(orthF, dims)

    %   Inputs:
    %       orthF : dims x time x 4
    %       dims  : PC dimensions to use 
    %
    %   Output:
    %       distResult : time x 4  (1=cxt, 2=color, 3=choice, 4=T3)

    distResult = zeros(size(orthF, 2), 4);

    for timePt = 1:size(orthF, 2)

        TCdistV1 = orthF(dims, timePt, 1) - orthF(dims, timePt, 4);   % distance between RL & GR
        TCdistV2 = orthF(dims, timePt, 2) - orthF(dims, timePt, 3);   % distance between RR & GL
        T3 = 0.5 * (sqrt(sum(TCdistV1.^2)) + sqrt(sum(TCdistV2.^2))); 

        CdistV   = mean(orthF(dims, timePt, [1 2]), 3) - mean(orthF(dims, timePt, [3 4]), 3);  % distance between R & G
        ChdistV  = mean(orthF(dims, timePt, [1 3]), 3) - mean(orthF(dims, timePt, [2 4]), 3);  % distance between L & R
        TargDistV = mean(orthF(dims, timePt, [1 4]), 3) - mean(orthF(dims, timePt, [2 3]), 3); % distance between RLGR & RRGL

        distResult(timePt, 1) = sqrt(sum(TargDistV.^2));   % cxt
        distResult(timePt, 2) = sqrt(sum(CdistV.^2));      % color
        distResult(timePt, 3) = sqrt(sum(ChdistV.^2));     % choice
        distResult(timePt, 4) = T3;                        % target
    end

end


function ax = plotTetrahedron3D(orthFpfcM, dims, t, varargin)
% plotTetrahedron3D  Plot a 3D tetrahedron from 4 conditions.
%
% ax = plotTetrahedron3D(orthFpfcM, dims, t, 'Name', value)
%
% Required
%   orthFpfcM : (D x T x 4)
%   dims      : [d1 d2 d3]
%   t         : time index
%
% Optional
%   'Ax'        : axes handle (default: new)
%   'FaceColor' : RGB (default: light gray)
%   'FaceAlpha' : transparency (default: 0.25)

% ---- defaults ----
faceColor = [0.85 0.85 0.85];
faceAlpha = 0.25;
ax = [];

% ---- parse minimal options ----
for k = 1:2:numel(varargin)
    switch lower(varargin{k})
        case 'ax'
            ax = varargin{k+1};
        case 'facecolor'
            faceColor = varargin{k+1};
        case 'facealpha'
            faceAlpha = varargin{k+1};
    end
end

% ---- axes ----
if isempty(ax)
    figure; ax = axes;
end
hold(ax,'on');

% ---- extract points (4 x 3) ----
P = squeeze(orthFpfcM(dims, t, :)).';

% ---- tetrahedron faces & edges ----
faces = [1 2 3; 1 2 4; 1 3 4; 2 3 4];
edges = [1 2; 1 3; 1 4; 2 3; 2 4; 3 4];

% ---- shaded faces ----
patch(ax, 'Vertices', P, 'Faces', faces, ...
    'FaceColor', faceColor, 'FaceAlpha', faceAlpha, ...
    'EdgeColor', 'none');

% ---- edges (fixed style) ----
for k = 1:size(edges,1)
    i = edges(k,1); j = edges(k,2);
    plot3(ax, P([i j],1), P([i j],2), P([i j],3), ...
        'color',[1,1,1].*0.5, 'LineWidth', 1);
end

% ---- condition markers ----
markers = {'o','d','o','d'};
colors  = {[0.95 0.10 0.10],[0.65 0.08 0.20],[0.10 0.82 0.10],[0.08 0.65 0.18]};



for c = 1:4
    scatter3(ax, P(c,1), P(c,2), P(c,3), 500, ...
        'Marker', markers{c}, ...
        'MarkerFaceColor', colors{c}, ...
        'MarkerEdgeColor', colors{c});
end

% ---- view & labels ----
axis(ax,'equal');
grid(ax,'on');
view(ax,3);
xlabel(ax, sprintf('Dim %d', dims(1)));
ylabel(ax, sprintf('Dim %d', dims(2)));
zlabel(ax, sprintf('Dim %d', dims(3)));

end






function [perimeter, surfaceArea, volume] = tetraGeometry(pts10D)
% pts10D: 10 x 4 matrix where columns are p1, p2, p3, p4

p1 = pts10D(:,1);
p2 = pts10D(:,2);
p3 = pts10D(:,3);
p4 = pts10D(:,4);

%% --- Compute all 6 edge lengths ---
d12 = norm(p1 - p2);
d13 = norm(p1 - p3);
d14 = norm(p1 - p4);
d23 = norm(p2 - p3);
d24 = norm(p2 - p4);
d34 = norm(p3 - p4);

perimeter = d12 + d13 + d14 + d23 + d24 + d34;

%% --- Surface area: sum of areas of 4 triangular faces ---
surfaceArea = triangleArea(p1,p2,p3) + ...
              triangleArea(p1,p2,p4) + ...
              triangleArea(p1,p3,p4) + ...
              triangleArea(p2,p3,p4);

%% --- Volume: 3-simplex volume = sqrt(det(Gram)) / 6
v1 = p2 - p1;
v2 = p3 - p1;
v3 = p4 - p1;

G = [dot(v1,v1) dot(v1,v2) dot(v1,v3);
     dot(v2,v1) dot(v2,v2) dot(v2,v3);
     dot(v3,v1) dot(v3,v2) dot(v3,v3)];

volume = sqrt(max(det(G),0)) / 6;

end


%% Helper function: triangle area in n-dimensions
function A = triangleArea(a,b,c)
u = b - a;
v = c - a;

G2 = [dot(u,u) dot(u,v);
      dot(v,u) dot(v,v)];

A = 0.5 * sqrt(max(det(G2),0));
end