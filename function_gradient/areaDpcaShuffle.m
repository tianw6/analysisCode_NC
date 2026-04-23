% subselect 1000 dlpfcV data, do dpca for 100 times, calculate area and
% angle for each area. 

addpath('./DLPFC_dpca/')

clear;clc 

load('areaUnitNums.mat');
area8 = areaUnitNums.area8;
dlpfcD = areaUnitNums.dlpfcD;
dlpfcV = areaUnitNums.dlpfcV;
dlpfcA = areaUnitNums.dlpfcA;
pmd = areaUnitNums.pmd;


a = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/checkerboardAligned/allBinFRvprobe.mat').allBinFR;
b = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Vinnie/checkerboardAligned/allBinFRvprobe.mat').allBinFR;
c = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Ziggy/checkerboardAligned/allBinFRvprobe.mat').allBinFR;

d = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Vinnie/checkerboardAligned/allBinFRnpix.mat').allBinFR;
e = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/checkerboardAligned/allBinFRnpix.mat').allBinFR;
f = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/checkerboardAligned/allBinFRnpixPMD.mat').allBinFR;

binFRpfc = [a,b,c, d,e, f];

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
normalizeData = 1;
[firingRatesAverage] = prepareFRaverage(binFRpfc, normalizeData);
%% 

combinedParams = {{1, [1 3]}, {2, [2 3]}, {3}, {[1 2], [1 2 3]}};
margNames = {'Stimulus', 'Decision', 'Condition-independent', 'S/D Interaction'};

% margNames = {'SC', 'Configuration', 'Condition-independent', 'C/D Interaction'};

margColours = [23 100 171; 187 20 25; 150 150 150; 114 97 171]/256;

% time of combined T and C data
timeEvents = [0];

d1 = 2;
d2 = 3;

subselectNum = 1000;


%%
lengths = [length(area8), length(dlpfcD), length(dlpfcA), length(pmd),subselectNum ];

% Compute cumulative endpoints
endpoints = cumsum(lengths);  % [len_a, len_a+len_b, len_a+len_b+len_c, ...]
startpoints = [1, endpoints(1:end-1)+1];  % [1, len_a+1, len_a+len_b+1, ...]
% Extract segments
units8 = startpoints(1):endpoints(1);
unitsD = startpoints(2):endpoints(2);
unitsA = startpoints(3):endpoints(3);
unitsP = startpoints(4):endpoints(4);
unitsV = startpoints(5):endpoints(5);
    



%%

select1 = [area8, dlpfcD, dlpfcA, pmd];
fr1 = firingRatesAverage(select1,:,:,:);

allArea = [];
allAngle = [];
parfor ii = 1:100

    fr2 = [];
    frCombined = []; 
    
    select2 = dlpfcV(randsample(length(dlpfcV), subselectNum));
    fr2 = firingRatesAverage(select2,:,:,:);
    
    frCombined = [fr1; fr2];
    tic
    [W,V,whichMarg] = dpca(frCombined, 30, ...
        'combinedParams', combinedParams, 'lambda', 1e-9);
    toc

    % explVar = dpca_explainedVariance(firingRatesAverage, W, V, ...
    %     'combinedParams', combinedParams);


%%
    choiceLoad = V(:,find(whichMarg==2,1));
    cxtLoad = V(:,find(whichMarg==4,1));
    colorLoad = V(:,find(whichMarg==1,1));

    allLoad = [choiceLoad, cxtLoad, colorLoad];

%% 


    % area 8
    c22 = cov(allLoad(units8,[d1 d2]));
    [~, a8, angle8] = error_ellipse1(c22,'conf',0.99);


    % dlpfcD
    c22 = cov(allLoad(unitsD,[d1 d2]));
    [~, aD, angleD] = error_ellipse1(c22,'conf',0.99);

    % dlpfcV
    c22 = cov(allLoad(unitsV,[d1 d2]));
    [~, aV, angleV] = error_ellipse1(c22,'conf',0.99);

    % dlpfcA
    c22 = cov(allLoad(unitsA,[d1 d2]));
    [~, aA, angleA] = error_ellipse1(c22,'conf',0.99);

    % pmd
    c22 = cov(allLoad(unitsP,[d1 d2]));
    [~, aP, angleP] = error_ellipse1(c22,'conf',0.99);

    % print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig5_s/', 'errorEllipse_dircxt', '.eps']);

    allAngle(ii,:) = [angleA, angleV, angleD, angle8, angleP];
    allArea(ii,:) = [aA, aV, aD, a8, aP];

end

%%
shuffleAreaDpca.allAngle = allAngle;
shuffleAreaDpca.allArea = allArea;
% save('shuffleAreaDpca_cxtcolor.mat', 'shuffleAreaDpca');


%% 
% allAngle = shuffleAreaDpca.allAngle;
% allArea = shuffleAreaDpca.allArea;
y_all = mean(allArea,1)';
dataCI_all = std(allArea, [], 1);

figure('position', [1000,1000,600,300]); hold on
plotBar(y_all, dataCI_all)
title('area')

absAngle = abs(allAngle);
y_all = mean(absAngle,1)';
dataCI_all = std(absAngle, [], 1);

figure('position', [1000,1000,600,300]); hold on
plotBar(y_all, dataCI_all)
title('angle')