%% created by Tina on May 29th 

% combine pfc and pmd data and do pca together
% subselect same number of dlpfc and pmd. calculate top 10 pca distance 
% and tetrahedron volume

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

% load('processedFRpfc.mat')
% load('processedFRpmd.mat')

%%
dims = 1:10;
distResultPFC = [];
distResultPMD = [];
surfApfc = [];
volpfc = [];
surfApmd = [];
volpmd = [];

for ii = 1:100
    
    % subselect dlpfc units to be same number as pmd
    select = randsample(size(processedFRpfc, 1), size(processedFRpmd, 1));

%     subselect dlpfc units with putting back
%     select = randsample(size(processedFRpfc, 1), size(processedFRpfc, 1),true);
    
    sFRpfc = processedFRpfc(select,:,:);
    sFRpmd = processedFRpmd;
    X = [sFRpfc; sFRpmd];
    

    
%     % subselect dlpfc units and pmd units
%     select = randsample(size(processedFRpfc, 1), 1000);
%     selectPMD = randsample(size(processedFRpmd, 1), 1000);
% 
%     sFRpfc = processedFRpfc(select,:,:);
%     sFRpmd = processedFRpmd(selectPMD,:,:);
%     
%     X = [sFRpfc; sFRpmd];    
    
    
    %% pca
    test = X';


    [coeff, score, latent] = pca(test);

    Zpfc = coeff(1:size(sFRpfc,1),:)'*sFRpfc;
    Zpmd = coeff(size(sFRpfc,1) + 1:end,:)'*sFRpmd;


%%

    m = length(unique(binFRpfc(1).taskLabels));
    t = size(sFRpfc,2)/m;

    orthFpfc = reshape(Zpfc, [size(Zpfc,1),t,m]);
    orthFpmd = reshape(Zpmd, [size(Zpmd,1),t,m]);
    
    %% distance analysis pfc (choose first 10 dimension)

    distResultPFC(:,:,ii) = calDistance(orthFpfc, dims);
    distResultPMD(:,:,ii) = calDistance(orthFpmd, dims);
    


    %% calculate tetrahedron volume and surface area

    orthFpfc10 = orthFpfc(dims,:,:);
    orthFpmd10 = orthFpmd(dims,:,:);
    for t = 1:size(orthFpfc10,2)
        pts = squeeze(orthFpfc10(:, t, :));  % 10 x 4
        [~, surfApfc(t,ii), volpfc(t,ii)] = tetraGeometry(pts);
    end

    for t = 1:size(orthFpmd10,2)
        pts = squeeze(orthFpmd10(:, t, :));  % 10 x 4
        [~, surfApmd(t,ii), volpmd(t,ii)] = tetraGeometry(pts);
    end


    fprintf('shuffle %d finished\n', ii);

end



%%

a = figure('Position', [20 20 1200 500]);

options.handle = gcf;
options.error = 'std';
options.alpha      = 0.5;
options.line_width = 1;
options.x_axis = time;

% plot dlpfc
options.color_area = [100 100 100]./255;    % black theme
options.color_line = [0 0 0]./255;
subplot(311);
plot_areaerrorbar(squeeze(distResultPFC(:,1,:))', options)

options.color_area = [255 0 255]./255;    % Orange theme
options.color_line = [255 0 255]./255;
subplot(312);
plot_areaerrorbar(squeeze(distResultPFC(:,2,:))', options)

subplot(313);

options.color_area = [0 0 255]./255;    % Orange theme
options.color_line = [0 0 255]./255;
plot_areaerrorbar(squeeze(distResultPFC(:,3,:))', options)

options.color_area = [255 0 0]./255;    % Orange theme
options.color_line = [255 0 0]./255;
plot_areaerrorbar(squeeze(distResultPFC(:,4,:))', options)






% plot pmd
options.color_area = [100 100 100]./255;    % black theme
options.color_line = [0 0 0]./255;
subplot(311);
plot_areaerrorbar(squeeze(distResultPMD(:,1,:))', options)

options.color_area = [255 0 255]./255;    % Orange theme
options.color_line = [255 0 255]./255;
subplot(312);
plot_areaerrorbar(squeeze(distResultPMD(:,2,:))', options)

subplot(313);

options.color_area = [0 0 255]./255;    % Orange theme
options.color_line = [0 0 255]./255;
plot_areaerrorbar(squeeze(distResultPMD(:,3,:))', options)

options.color_area = [255 0 0]./255;    % Orange theme
options.color_line = [255 0 0]./255;
plot_areaerrorbar(squeeze(distResultPMD(:,4,:))', options)





xlim([-50 300])

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig4/geometry/', 'pfcpmdDistanceShuffle', '.eps']);



%% plot volume and surface area


a = figure('Position', [20 20 1200 500]);

options.handle = gcf;
options.error = 'std';
options.alpha      = 0.5;
options.line_width = 1;
options.x_axis = time;


options.color_area = [100 100 100]./255;    % black theme
options.color_line = [0 0 0]./255;
plot_areaerrorbar(volpfc', options)

options.color_area = [255 0 255]./255;    % Orange theme
options.color_line = [255 0 255]./255;
plot_areaerrorbar(volpmd', options)
title('volume')


a = figure('Position', [20 20 1200 500]);
options.handle = gcf;
options.error = 'std';
options.alpha      = 0.5;
options.line_width = 1;
options.x_axis = time;
options.color_area = [0 0 255]./255;    % Orange theme
options.color_line = [0 0 255]./255;
plot_areaerrorbar(surfApfc', options)

options.color_area = [255 0 0]./255;    % Orange theme
options.color_line = [255 0 0]./255;
plot_areaerrorbar(surfApmd', options)
title('surface area')


%% stat test 

tt = time >= 150 & time <= 250;

aveDistpfc = squeeze(mean(distResultPFC(tt,:,:), 1));

aveDistpmd = squeeze(mean(distResultPMD(tt,:,:),1));

aveVolpfc = squeeze(mean(volpfc(tt,:,:), 1));
aveVolpmd = squeeze(mean(volpmd(tt,:,:), 1));

avesurfApfc = squeeze(mean(surfApfc(tt,:,:), 1));
avesurfApmd = squeeze(mean(surfApmd(tt,:,:), 1));

% color
ranksum(aveDistpfc(2,:), aveDistpmd(2,:))

% color x choice
ranksum(aveDistpfc(1,:), aveDistpmd(1,:))

% pfc nlnrchoice vs pure choice
[h, p, ~, stats] = ttest(aveDistpfc(4,:), aveDistpfc(3,:))

% pmd nlnrchoice vs pure choice
[h, p, ~, stats] = ttest(aveDistpmd(4,:), aveDistpmd(3,:))


% volume
ranksum(aveVolpfc, aveVolpmd)
% surface area
ranksum(avesurfApfc, avesurfApmd)


%% 


function distResult = calDistance(orthF, dims)

    for timePt = 1:size(orthF,2)

        TCdistV1 = orthF(dims,timePt, 1) - orthF(dims,timePt, 4);
        TCdistV2 = orthF(dims,timePt, 2) - orthF(dims,timePt, 3);

        T1 = sqrt(sum(TCdistV1.^2));
        T2 = sqrt(sum(TCdistV2.^2));
        T3 = .5*(T1+T2);


        CdistV = mean(orthF(dims,timePt, [1 2]),3) - mean(orthF(dims,timePt, [3 4]),3);
        ChdistV = mean(orthF(dims,timePt, [1 3]),3) - mean(orthF(dims,timePt, [2 4]),3);

    % 
        TargDistV = mean(orthF(dims,timePt, [1 4]),3) - mean(orthF(dims,timePt, [2 3]),3);

        colorDist = sqrt(sum(CdistV.^2));
        choiceDist = sqrt(sum(ChdistV.^2));
        cxtDist = sqrt(sum(TargDistV.^2));

        distResult(timePt, 1) = cxtDist;
        distResult(timePt, 2) = colorDist;
        distResult(timePt, 3) = choiceDist;
        distResult(timePt, 4) = T3;

    end
    
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

