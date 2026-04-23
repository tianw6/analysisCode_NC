modT = load('~/Documents/MATLAB/ChandLab/DLPFC_PMd/modulationIdx/DLPFCregressionMod/resultsStructT.mat').resultsStruct;
modC = load('~/Documents/MATLAB/ChandLab/DLPFC_PMd/modulationIdx/DLPFCregressionMod/resultsStructC.mat').resultsStruct;

CI = 1.96;

supMod = modC(1:64);
deepMod = modC(65:102);


modColor = [];

for ip = 1:length(supMod)
    Midx = supMod(ip).R2color;    
    modColor = [modColor, max(Midx, [], 2)'];
end

modColor = modColor(~isnan(modColor));
modColorDeep = [];

for ip = 1:length(deepMod)
    Midx = deepMod(ip).R2color;    
    modColorDeep = [modColorDeep, max(Midx, [], 2)'];
end

% color 
stm = std(modColor)./sqrt(length(modColor));
lwBd = stm.*1.96;
upBd = stm.*1.96;

stmDeep = std(modColorDeep)./sqrt(length(modColorDeep));
lwBdDeep = stmDeep.*1.96;
upBdDeep = stmDeep.*1.96;

data = [mean(modColor), mean(modColorDeep)];
errLow = [lwBd, lwBdDeep];
errHigh = [upBd, upBdDeep];
x = [1 2];

figure; hold on
bar(x, data)
errorbar(x, data,errLow,errHigh, 'LineStyle', 'none', 'linewidth', 3);    

xNames={'superficial'; 'deep'};
set(gca,'xtick', x, 'xticklabel',xNames)

%% context 

modCxt1 = calMod(modC(1:64), 'cxt');
modCxtDeep1 = calMod(modC(65:102), 'cxt');

modCxt2 = calMod(modT(1:64), 'cxt');
modCxtDeep2 = calMod(modT(65:102), 'cxt');

modCxt = max(modCxt1, modCxt2);
modCxtDeep = max(modCxtDeep1, modCxtDeep2);

x = [1 2];
data = [mean(modCxt), mean(modCxtDeep)];
errCxt = [std(modCxt)/sqrt(length(modCxt))*CI, std(modCxtDeep)/sqrt(length(modCxtDeep))*CI];

figure; hold on
bar(x, data)
errorbar(x, data,errCxt, errCxt, 'LineStyle', 'none', 'linewidth', 3);    

xNames={'superficial'; 'deep'};
set(gca,'xtick', x, 'xticklabel',xNames)

%% direction  
modDir = calMod(modC(1:64), 'dir');
modDir = modDir(~isnan(modDir));
modDirDeep = calMod(modC(65:102), 'dir');

x = [1 2];
data = [mean(modDir), mean(modDirDeep)];
errDir = [std(modDir)/sqrt(length(modDir))*CI, std(modDirDeep)/sqrt(length(modDirDeep))*CI];

figure; hold on
bar(x, data)
errorbar(x, data,errDir, errDir, 'LineStyle', 'none', 'linewidth', 3);    

xNames={'superficial'; 'deep'};
set(gca,'xtick', x, 'xticklabel',xNames)

%% color

modColor = calMod(modC(1:64), 'color');
modColor = modColor(~isnan(modColor));
modColorDeep = calMod(modC(65:102), 'color');

x = [1 2];
data = [mean(modColor), mean(modColorDeep)];
errColor = [std(modColor)/sqrt(length(modColor))*CI, std(modColorDeep)/sqrt(length(modColorDeep))*CI];

figure; hold on
bar(x, data)
errorbar(x, data,errColor, errColor, 'LineStyle', 'none', 'linewidth', 3);    

xNames={'superficial'; 'deep'};
set(gca,'xtick', x, 'xticklabel',xNames)

%% together 


data = [mean(modCxt), mean(modColor), mean(modDir); mean(modCxtDeep), mean(modColorDeep), mean(modDirDeep)];
err = [errCxt; errColor; errDir]';

figure; hold on
b = bar(data);

% Calculate the number of groups and number of bars in each group
[ngroups,nbars] = size(data);
% Get the x coordinate of the bars
x = nan(nbars, ngroups);
for i = 1:nbars
    x(i,:) = b(i).XEndPoints;
end
% Plot the errorbars
errorbar(x',data,err,'k','linestyle','none', 'linewidth', 1.5);

xNames={'superficial'; 'deep'};
set(gca,'xtick', [1 2], 'xticklabel',xNames)





%% all monkeys data

TmodT = load('~/Documents/MATLAB/ChandLab/DLPFC_PMd/modulationIdx/DLPFCregressionMod/TresultsStructT0.mat').resultsStruct;
TmodC = load('~/Documents/MATLAB/ChandLab/DLPFC_PMd/modulationIdx/DLPFCregressionMod/TresultsStructC0.mat').resultsStruct;
ZmodT = load('~/Documents/MATLAB/ChandLab/DLPFC_PMd/modulationIdx/DLPFCregressionMod/ZresultsStructT.mat').resultsStruct;
ZmodC = load('~/Documents/MATLAB/ChandLab/DLPFC_PMd/modulationIdx/DLPFCregressionMod/ZresultsStructC.mat').resultsStruct;
VmodT = load('~/Documents/MATLAB/ChandLab/DLPFC_PMd/modulationIdx/DLPFCregressionMod/VresultsStructT.mat').resultsStruct;
VmodC = load('~/Documents/MATLAB/ChandLab/DLPFC_PMd/modulationIdx/DLPFCregressionMod/VresultsStructC.mat').resultsStruct;

CI = 1.96;


posteriorT = [TmodT(1:13) ZmodT(13:end)];
superficialT = TmodT(14:64);
deepT = [TmodT(65:end) ZmodT(1:12)];
anteriorT = VmodT;

posteriorC = [TmodC(1:13) ZmodC(13:end)];
superficialC = TmodC(14:64);
deepC = [TmodC(65:end) ZmodC(1:12)];
anteriorC = VmodC;

[pCxt, pColor, pDir, pErr] = calModAll(posteriorT, posteriorC);
[sCxt, sColor, sDir, sErr] = calModAll(superficialT, superficialC);
[dCxt, dColor, dDir, dErr] = calModAll(deepT, deepC);
[aCxt, aColor, aDir, aErr] = calModAll(anteriorT, anteriorC);

data = [mean(aCxt), mean(aColor), mean(aDir);
    mean(dCxt), mean(dColor), mean(dDir);
    mean(sCxt), mean(sColor), mean(sDir);
    mean(pCxt), mean(pColor), mean(pDir)];


err = [aErr; dErr; sErr; pErr];

figure; hold on
b = bar(data);

% Calculate the number of groups and number of bars in each group
[ngroups,nbars] = size(data);
% Get the x coordinate of the bars
x = nan(nbars, ngroups);
for i = 1:nbars
    x(i,:) = b(i).XEndPoints;
end
% Plot the errorbars
errorbar(x',data,err,'k','linestyle','none', 'linewidth', 1.5);

xNames={'anterior', 'deep', 'superficial', '8Ad'};
set(gca,'xtick', 1:4, 'xticklabel',xNames)


%% 


modIdx = struct;
for ii = 1:length(TmodC)
    
    modIdx(ii).color = find(sum(TmodC(ii).R2color,2) > 0);
    modIdx(ii).dir = find(sum(TmodC(ii).R2dir,2) > 0);
    cxt1 = find(sum(TmodC(ii).R2cxt,2) > 0);
    cxt2 = find(sum(TmodT(ii).R2cxt,2) > 0);
    modIdx(ii).cxt = union(cxt1, cxt2);
    
end
