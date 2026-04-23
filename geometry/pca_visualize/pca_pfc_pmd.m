%% created by Tian on May 29th 

% combine pfc and pmd data and do pca together

% put surface area of tetrahedron and volume in supplementary 4

clear; clc; close all

addpath('..')


%% for dlpfc Data
a = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/checkerboardAligned/allBinFRnpix.mat').allBinFR;



b = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Vinnie/checkerboardAligned/allBinFRnpix.mat').allBinFR;
c = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/checkerboardAligned/allBinFRvprobe.mat').allBinFR;
d = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Vinnie/checkerboardAligned/allBinFRvprobe.mat').allBinFR;

binFRpfc = [c,a,d,b];

%% for pmd data
a = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/checkerboardAligned/allBinFRnpixPMD.mat').allBinFR;
b = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/checkerboardAligned/allBinFRvprobePMD.mat').allBinFR;
c = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Olaf/checkerboardAligned/allBinFRvprobePMD.mat').allBinFR;


binFRpmd = [a b c];

%%

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



%%
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


%%

m = length(unique(binFRpfc(1).taskLabels));
t = size(processedFRpfc,2)/m;

orthFpfc = reshape(Zpfc, [size(Zpfc,1),t,m]);
orthFpmd = reshape(Zpmd, [size(Zpmd,1),t,m]);

% remove average signal
orthFpfcM = orthFpfc - mean(orthFpfc,3);
orthFpmdM = orthFpmd - mean(orthFpmd,3);
%%


% 
% 
% 
% orthFpfc = [];
% for thi = 1 : m
%     orthFpfc(:,:,thi) = (Zpfc( (1:t) + (thi-1)*t, :))';
% end
% 
% orthFpmd = [];
% for thi = 1 : m
%     orthFpmd(:,:,thi) = (Zpmd( (1:t) + (thi-1)*t, :))';
% end

%% 

addpath('/Users/tianwang/Documents/MATLAB/ChandLab/DLPFC_PMD/LabCode');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% you adjust the number here to select different PCs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% selectPC = [1 3 4];
selectPC = [4 3 7];




traj = orthFpfcM(selectPC,:,:);
traj2 = orthFpmdM(selectPC,:,:);


figure;




for tV = [11 21 31 41 46 51 56 61 71 81]

time(tV)

plot3(time(tV), traj(2,tV,1),traj(3,tV,1),'ro', 'markersize', 14, 'linewidth', 2);
hold on
plot3(time(tV), traj(2,tV,2),traj(3,tV,2), 'rd', 'markersize', 14,'MarkerFaceColor','r');
plot3(time(tV), traj(2,tV,3),traj(3,tV,3),'go', 'markersize', 14, 'linewidth', 2);
plot3(time(tV), traj(2,tV,4),traj(3,tV,4),'gd', 'markersize', 14,'MarkerFaceColor','g');


% % RL&RR
% line([time(tV), time(tV)], [traj(2,tV,1), traj(2,tV,3)], [traj(3,tV,1), traj(3,tV,3)] ,'color', 'k')
% % GL&GR
% line([time(tV), time(tV)], [traj(2,tV,2), traj(2,tV,4)], [traj(3,tV,2), traj(3,tV,4)] ,'color', 'k')

line([time(tV), time(tV)], [traj(2,tV,1), traj(2,tV,4)], [traj(3,tV,1), traj(3,tV,4)] ,'color', 'k')
% RR&GL
line([time(tV), time(tV)], [traj(2,tV,2), traj(2,tV,3)], [traj(3,tV,2), traj(3,tV,3)] ,'color', 'k')


% RL&RR
line([time(tV), time(tV)], [traj(2,tV,1), traj(2,tV,2)], [traj(3,tV,1), traj(3,tV,2)] ,'color', 'k')
% GL&GR
line([time(tV), time(tV)], [traj(2,tV,3), traj(2,tV,4)], [traj(3,tV,3), traj(3,tV,4)] ,'color', 'k')




pause;

plot3(time(tV), traj2(2,tV,1),traj2(3,tV,1),'ro', 'markersize', 14, 'linewidth', 2);
hold on
plot3(time(tV), traj2(2,tV,2),traj2(3,tV,2), 'rd', 'markersize', 14,'MarkerFaceColor','r');
plot3(time(tV), traj2(2,tV,3),traj2(3,tV,3),'go', 'markersize', 14, 'linewidth', 2);
plot3(time(tV), traj2(2,tV,4),traj2(3,tV,4),'gd', 'markersize', 14,'MarkerFaceColor','g');


% % RL&RR
% line([time(tV), time(tV)], [traj2(2,tV,1), traj2(2,tV,3)], [traj2(3,tV,1), traj2(3,tV,3)] ,'color', 'k')
% % GL&GR
% line([time(tV), time(tV)], [traj2(2,tV,2), traj2(2,tV,4)], [traj2(3,tV,2), traj2(3,tV,4)] ,'color', 'k')

% RL&GR
line([time(tV), time(tV)], [traj2(2,tV,1), traj2(2,tV,4)], [traj2(3,tV,1), traj2(3,tV,4)] ,'color', 'k')
% RR&GL
line([time(tV), time(tV)], [traj2(2,tV,2), traj2(2,tV,3)], [traj2(3,tV,2), traj2(3,tV,3)] ,'color', 'k')

% RL&RR
line([time(tV), time(tV)], [traj2(2,tV,1), traj2(2,tV,2)], [traj2(3,tV,1), traj2(3,tV,2)] ,'color', 'k')
% GL&GR
line([time(tV), time(tV)], [traj2(2,tV,3), traj2(2,tV,4)], [traj2(3,tV,3), traj2(3,tV,4)] ,'color', 'k')



pause;
end



%% plot tetrahedron
dims = [7 4 5];
t = 61;

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


%% plot in 2D 

% selectPC = [3 7];
% 
% x_limit = [-5 5];
% y_limit = [-3 3];

selectPC = [7 3];

x_limit = [-5 5];
y_limit = [-6 4];


orthFpfcM = orthFpfc - mean(orthFpfc,3);
orthFpmdM = orthFpmd - mean(orthFpmd,3);

traj = orthFpfcM(selectPC,:,:);
traj2 = orthFpmdM(selectPC,:,:);


for tV = [11 21 31 41 51  61  81]

figure; hold on

A = [traj(1,tV,1),traj(2,tV,1)];
B = [traj(1,tV,2),traj(2,tV,2)];
C = [traj(1,tV,3),traj(2,tV,3)];
D = [traj(1,tV,4),traj(2,tV,4)];

points = [A;B;C;D];
plotGeometry(points, tV, 'cyan')


title(time(tV))



axis equal

xlim(x_limit)
ylim(y_limit)


% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig4_s/geometry_45/', 'pfc' num2str(time(tV)), '.eps']);

end

%%

for tV = [11 21 31 41  51  61  81]



figure; hold on

A = [traj2(1,tV,1),traj2(2,tV,1)];
B = [traj2(1,tV,2),traj2(2,tV,2)];
C = [traj2(1,tV,3),traj2(2,tV,3)];
D = [traj2(1,tV,4),traj2(2,tV,4)];

points = [A;B;C;D];
plotGeometry(points, tV, 'm')

title(time(tV))

axis equal

xlim(x_limit)
ylim(y_limit)


% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig4_s/geometry_45/', 'pmd' num2str(time(tV)), '.eps']);

end

%% 

for ii = 1:9
    figure; hold on
    plot(time, squeeze(orthFpfcM(ii, :, 1)), 'r-')
    plot(time, squeeze(orthFpfcM(ii, :, 2)), 'r--')
    plot(time, squeeze(orthFpfcM(ii, :, 3)), 'g-')
    plot(time, squeeze(orthFpfcM(ii, :, 4)), 'g--')
    pause
    
    plot(time, squeeze(orthFpmdM(ii, :, 1)), 'r-')
    plot(time, squeeze(orthFpmdM(ii, :, 2)), 'r--')
    plot(time, squeeze(orthFpmdM(ii, :, 3)), 'g-')
    plot(time, squeeze(orthFpmdM(ii, :, 4)), 'g--')    
    
    pause
    title(['pc ' num2str(ii)]);
        
 end





%% distance analysis pfc (choose first 10 dimension)
distResult = [];
dims = 1:10;

for timePt = 1:size(orthFpfc,2)
    t = time(timePt);

    TCdistV1 = orthFpfc(dims,timePt, 1) - orthFpfc(dims,timePt, 4);
    TCdistV2 = orthFpfc(dims,timePt, 2) - orthFpfc(dims,timePt, 3);

    T1 = sqrt(sum(TCdistV1.^2));
    T2 = sqrt(sum(TCdistV2.^2));
    T3 = .5*(T1+T2);


    
    CdistV = mean(orthFpfc(dims,timePt, [1 2]),3) - mean(orthFpfc(dims,timePt, [3 4]),3);
    ChdistV = mean(orthFpfc(dims,timePt, [1 3]),3) - mean(orthFpfc(dims,timePt, [2 4]),3);
    
% 
    TargDistV = mean(orthFpfc(dims,timePt, [1 4]),3) - mean(orthFpfc(dims,timePt, [2 3]),3);
    
    colorDist = sqrt(sum(CdistV.^2));
    choiceDist = sqrt(sum(ChdistV.^2));
    cxtDist = sqrt(sum(TargDistV.^2));

    distResult(timePt, 1) = cxtDist;
    distResult(timePt, 2) = colorDist;
    distResult(timePt, 3) = choiceDist;
    distResult(timePt, 4) = T3;
    
end


figure('position', [20 20 1200 500]); hold on

plot(time, distResult(:,1), 'k')
plot(time, distResult(:,2), 'm')
plot(time, distResult(:,3), 'b')
plot(time, distResult(:,4), 'r')


% distance analysis pmd (choose first 10 dimension)

distResultPMd = [];
for timePt = 1:size(orthFpmd,2)
    t = time(timePt);

    TCdistV1 = orthFpmd(dims,timePt, 1) - orthFpmd(dims,timePt, 4);
    TCdistV2 = orthFpmd(dims,timePt, 2) - orthFpmd(dims,timePt, 3);

    T1 = sqrt(sum(TCdistV1.^2));
    T2 = sqrt(sum(TCdistV2.^2));
    T3 = .5*(T1+T2);


    
    CdistV = mean(orthFpmd(dims,timePt, [1 2]),3) - mean(orthFpmd(dims,timePt, [3 4]),3);
    ChdistV = mean(orthFpmd(dims,timePt, [1 3]),3) - mean(orthFpmd(dims,timePt, [2 4]),3);
    
% 
    TargDistV = mean(orthFpmd(dims,timePt, [1 4]),3) - mean(orthFpmd(dims,timePt, [2 3]),3);
    
    colorDist = sqrt(sum(CdistV.^2));
    choiceDist = sqrt(sum(ChdistV.^2));
    cxtDist = sqrt(sum(TargDistV.^2));

    distResultPMd(timePt, 1) = cxtDist;
    distResultPMd(timePt, 2) = colorDist;
    distResultPMd(timePt, 3) = choiceDist;
    distResultPMd(timePt, 4) = T3;
    
end



% plot(time, distResultPMd(:,1), 'k')
% plot(time, distResultPMd(:,2), 'm')
% plot(time, distResultPMd(:,3), 'b')
% plot(time, distResultPMd(:,4), 'r')
% 
% xlim([-50 300])

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig4/geometry/', 'pfcpmdDistance', '.eps']);


%% plot in 3 panals 

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

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig4/geometry/', 'pfcpmdDistance3', '.eps']);

%% plot volume and perimeter of the tetrahedran 
% dims = 1:10;
% orthFpfc10 = orthFpfc(dims,:,:);
% orthFpmd10 = orthFpmd(dims,:,:);
% 
% % assume the region bounded as quatilateral
% [Ppfc,Vpfc, Apfc] = calGeometry(orthFpfc10);
% [Ppmd,Vpmd, Apmd] = calGeometry(orthFpmd10);
% 
% PSpfc = calPlaneScore(orthFpfc10);
% PSpmd = calPlaneScore(orthFpmd10);
% 
% %% 
% figure; hold on
% plot(time, Ppfc)
% plot(time, Ppmd)
% title('perimeter')
% 
% figure; hold on
% plot(time, Vpfc)
% plot(time, Vpmd)
% title('volume')
% 
% figure; hold on
% plot(time, PSpfc)
% plot(time, PSpmd)
% title('planarity')
% 
% figure; hold on
% plot(time, Apfc)
% plot(time, Apmd)
% title('area')
% 
% % volume to area ratio
% VARpfc = Vpfc ./ (Apfc.^(3/2));
% VARpmd = Vpmd ./ (Apmd.^(3/2));
% figure; hold on
% plot(time, VARpfc)
% plot(time, VARpmd)
% title('volume to area ratio')


%% assume the region bounded as quatilateral
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

% figure; hold on
% plot(time, perimpfc)
% plot(time, perimpmd)
% title('perimeter')

figure('Position', [10 10 900 400]);
hold on
plot(time, surfApfc)
plot(time, surfApmd)
title('surface area')
xlim([-50 300])
set(gca, 'TickDir', 'out'); % For current axes
% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig4_s/', 'surfA_tetrahedron', '.eps']);

figure('Position', [10 10 900 400]); hold on
plot(time, volpfc)
plot(time, volpmd)
xlim([-50 300])
title('volume')
set(gca, 'TickDir', 'out'); % For current axes
% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig4_s/', 'vol_tetrahedron', '.eps']);

%% 
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



%% 
% function [planarity_norm] = calPlaneScore(orthFpfc10)
%     [nDim, T, nPts] = size(orthFpfc10);
%     assert(nDim == 10 && nPts == 4, 'Expected size 10 x T x 4');
% 
%     planarity_raw  = zeros(T,1);  % s3 (absolute)
%     planarity_norm = zeros(T,1);  % s3 / (s1 + s2 + s3)
% 
%     for t = 1:T
%         % 10 x 4
%         pts = squeeze(orthFpfc10(:, t, :));
%         p1 = pts(:,1);
% 
%         % Build 10 x 3 matrix of edge vectors from p1
%         V = [pts(:,2)-p1, pts(:,3)-p1, pts(:,4)-p1];
% 
%         % SVD: V = U * S * V'
%         [~, S, ~] = svd(V, 'econ');
%         s = diag(S);   % s(1) >= s(2) >= s(3) >= 0
% 
%         planarity_raw(t)  = s(end);                 % absolute "out-of-plane" scale
%         planarity_norm(t) = s(end) / (sum(s) + eps);% scale-free score
%     end
% 
% end
% 
% 
% function [perimeter, volume, quadArea] = calGeometry(orthFpfc10)
% 
% [nDim, T, nPts] = size(orthFpfc10);
% assert(nDim == 10 && nPts == 4, 'Expected size 10 x T x 4');
% 
% perimeter = zeros(T,1);
% volume    = zeros(T,1);
% quadArea  = zeros(T,1);   % area of quadrilateral at each time
% 
% for t = 1:T
%     % 10 x 4: columns are p1..p4
%     pts = squeeze(orthFpfc10(:, t, :));
%     p1 = pts(:,1);
%     p2 = pts(:,2);
%     p3 = pts(:,3);
%     p4 = pts(:,4);
%     
%     %% --- Perimeter of quadrilateral p1-p2-p3-p4-p1 ---
%     d12 = norm(p1 - p2);
%     d23 = norm(p2 - p3);
%     d34 = norm(p3 - p4);
%     d41 = norm(p4 - p1);
%     perimeter(t) = d12 + d23 + d34 + d41;
%     
%     %% --- Volume of tetrahedron (3-simplex in 10D) ---
%     v1 = p2 - p1;
%     v2 = p3 - p1;
%     v3 = p4 - p1;
%     
%     G3 = [dot(v1,v1) dot(v1,v2) dot(v1,v3); 
%           dot(v2,v1) dot(v2,v2) dot(v2,v3);
%           dot(v3,v1) dot(v3,v2) dot(v3,v3)];
%     
%     % Tetrahedron volume: V = sqrt(det(G3)) / 6
%     volume(t) = sqrt(max(det(G3),0)) / 6;
%     
%     %% --- Area of quadrilateral as sum of two triangles ---
%     % Triangle 1: (p1, p2, p3)
%     u = p2 - p1;
%     v = p3 - p1;
%     G2_1 = [dot(u,u) dot(u,v);
%             dot(v,u) dot(v,v)];
%     A123 = 0.5 * sqrt(max(det(G2_1), 0));
%     
%     % Triangle 2: (p1, p3, p4)
%     u = p3 - p1;
%     v = p4 - p1;
%     G2_2 = [dot(u,u) dot(u,v);
%             dot(v,u) dot(v,v)];
%     A134 = 0.5 * sqrt(max(det(G2_2), 0));
%     
%     quadArea(t) = A123 + A134;   % total quadrilateral area
% end
% 
% end


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