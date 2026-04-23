% create the bar plot of modulation index
% created by Tian on Nov. 16th, 2023 


% Ziggy burrhole 1: 9/46  
% Ziggy burrhole 2: 8Ad 
% 
% Tiberius burrhole 2: 8Ad 
% Tiberius burrhole 3: 9/46 
% Tiberius burrhole 4: 9/46 
% Tiberius burrhole 5: 9/46
% 
% Tiberius burrhole 6: 9/46V
% 
% Vinni1 burrhole 1: 8B
% Vinni1 burrhole 2: 9/46
% Vinni1 burrhole 3: 9/46

% Tiberius: 1:13
% Tiberius: 14:29
% Tiberius: 30:54
% Tiberius: 55:64
% Tiberius: 65:118

% Ziggy: 1:12
% Ziggy: 13:19

% Vinnie: 1:9
% Vinnie: 10:15
% Vinnie: 19:29

% Vinnie: [16:18, 30:33]



% %% 
% 
% TiberiusT = load('TiberiusCxtTMod.mat').cxtTMod;
% TiberiusC = load('TiberiusCMod.mat').CMod;
% 
% ZiggyT = load('ZiggyCxtTMod.mat').cxtTMod;
% ZiggyC = load('ZiggyCMod.mat').CMod;
%  
% VinnieT = load('VinnieCxtTMod.mat').cxtTMod;
% VinnieC = load('VinnieCMod.mat').CMod;
% 
% T1T = TiberiusT(1:64);
% T1C = TiberiusC(1:64);
% 
% T2T = TiberiusT(65:102);
% T2C = TiberiusC(65:102);
% 
% Z2T = ZiggyT(13:end);
% Z2C = ZiggyC(13:end);
% 
% Z1T = ZiggyT(1:12);
% Z1C = ZiggyC(1:12);
% 
% V1T = VinnieT;
% V1C = VinnieC; 
% 
% 
% %% 
% 
% [a,b,c,vT, v1MI] = calTotal(V1T, V1C);
% 
% % T1: deep
% [a2,b2,c2,tDeepT, tDeepMI] = calTotal(T2T, T2C);
% [a1,b1,c1,zDeepT, zDeepMI] = calTotal(Z1T, Z1C);
% 
% 
% [a,b,c,tSupT, tsupMI] = calTotal(T1T, T1C);
% 
% % Ziggy
% [a,b,c,zT,z1MI] = calTotal(Z2T, Z2C);
% 
% DeepMI = [a2 + a1, b2+b1, c2+c1]./(zDeepT+tDeepT);
% 
% 
% %% bar plot 
% 
% 
% % add an error bar
% 
% X = categorical({'9/46 Anterior','9/46 Deep','9/46 Superficial','Area 8'});
% X = reordercats(X,{'9/46 Anterior', '9/46 Deep','9/46 Superficial','Area 8'});
% 
% y = [v1MI; DeepMI; tsupMI; z1MI];
% 
% 
% figure('position', [1000,1000,600,300]); hold on
% bh = bar(X, y);
% 
% ylabel("modulation percentage")
% title([ 'num units: ' mat2str([vT, zDeepT+tDeepT, tSupT, zT])])
% TestL={'cxt','color','dir'};
% legend(bh, TestL, 'location', 'best') %'northwest'
% 
% % print(['~/Desktop/Cosyne2024/modBar.pdf'],'-dpdf','-bestfit')


%% 


TiberiusT = load('TiberiusCxtTMod.mat').cxtTMod;
TiberiusC = load('TiberiusCMod.mat').CMod;

ZiggyT = load('ZiggyCxtTMod.mat').cxtTMod;
ZiggyC = load('ZiggyCMod.mat').CMod;
 
VinnieT = load('VinnieCxtTMod.mat').cxtTMod;
VinnieC = load('VinnieCMod.mat').CMod;


T1T = TiberiusT(14:64);
T1C = TiberiusC(14:64);

T2T = TiberiusT(65:102);
T2C = TiberiusC(65:102);

T3T = TiberiusT(1:13);
T3C = TiberiusC(1:13);


Z2T = ZiggyT(13:end);
Z2C = ZiggyC(13:end);

Z1T = ZiggyT(1:12);
Z1C = ZiggyC(1:12);

V1T = VinnieT;
V1C = VinnieC; 

% anterior
[a1,b1,c1,vT, v1MI] = calTotal(V1T, V1C);

% T1: deep
[a2,b2,c2,DeepT, DeepMI] = calTotal([T2T Z1T], [T2C Z1C]);

% superficial
[a3,b3,c3,tSupT, tsupMI] = calTotal(T1T, T1C);

% area 8
[a4,b4,c4,zT,z1MI] = calTotal([T3T Z2T], [T3C Z2C]);

% bar plot 


% add an error bar

X = categorical({'9/46 Anterior','9/46 Deep','9/46 Superficial','Area 8'});
X = reordercats(X,{'9/46 Anterior', '9/46 Deep','9/46 Superficial','Area 8'});

y = [v1MI; DeepMI; tsupMI; z1MI];


figure('position', [1000,1000,600,300]); hold on
bh = bar(X, y);

ylabel("modulation percentage")
title([ 'num units: ' mat2str([vT, DeepT, tSupT, zT])])
TestL={'cxt','color','dir'};
legend(bh, TestL, 'location', 'best') %'northwest'


% print('-painters','-depsc',['~/Desktop/modBar','.eps'], '-r300');


%% plot error bar 
%[vT, DeepT, tSupT, zT]


temp = y.*(1-y);

dataErr(1,:) = sqrt(temp(1,:)./vT)
dataErr(2,:) = sqrt(temp(2,:)./DeepT)
dataErr(3,:) = sqrt(temp(3,:)./tSupT)
dataErr(4,:) = sqrt(temp(4,:)./zT)

dataCI = dataErr.*2.58;
figure('position', [1000,1000,600,300]); hold on

X = categorical({'9/46 Anterior','9/46 Deep','9/46 Superficial','Area 8'});
X = reordercats(X,{'9/46 Anterior', '9/46 Deep','9/46 Superficial','Area 8'});

b = bar(X,y, 'grouped');
% Calculate the number of groups and number of bars in each group
[ngroups,nbars] = size(y);
% Get the x coordinate of the bars
x = nan(nbars, ngroups);
for i = 1:nbars
    x(i,:) = b(i).XEndPoints;
end
% Plot the errorbars
errorbar(x',y,dataCI,'k','linestyle','none', 'linewidth', 1.5);
hold off


ylabel("modulation percentage")
title([ 'num units: ' mat2str([vT, DeepT, tSupT, zT])])
TestL={'cxt','color','dir'};
legend(b, TestL, 'location', 'best') %'northwest'

% print('-painters','-depsc',['~/Desktop/modBar','.eps'], '-r300');


%% chi square test 

% cxt expect
cxtP = (a1+a2+a3+a4)/(vT+DeepT+tSupT+zT);
colorP = (b1+b2+b3+b4)/(vT+DeepT+tSupT+zT);
dirP = (c1+c2+c3+c4)/(vT+DeepT+tSupT+zT);

cxtE = cxtP.*[vT,DeepT,tSupT,zT];
colorE = colorP.*[vT,DeepT,tSupT,zT];
dirE = dirP.*[vT,DeepT,tSupT,zT];

variable = 'dir';

% Define observed frequencies for 4 categories
totalMod = [a1,a2,a3,a4;b1,b2,b3,b4;c1,c2,c3,c4];


switch(variable) 
    case{'cxt'}
        % Define expected frequencies (null hypothesis)
        observed = totalMod(1,:)
        expected = cxtE
        % Perform chi-square test
        [h, p] = chi2gof(1:numel(observed), 'frequency', observed, 'expected', expected);
  
    case{'color'}
        % Define expected frequencies (null hypothesis)
        observed = totalMod(2,:)
        expected = colorE
        % Perform chi-square test
        [h, p] = chi2gof(1:numel(observed), 'frequency', observed, 'expected', expected);
        
    case{'dir'}
        % Define expected frequencies (null hypothesis)
        observed = totalMod(3,:)
        expected = dirE
        % Perform chi-square test
        [h, p] = chi2gof(1:numel(observed), 'frequency', observed, 'expected', expected);
end


% Display results
if h == 0
    disp('The null hypothesis cannot be rejected.');
else
    disp('The null hypothesis is rejected.');
end

disp(['p-value: ', num2str(p)]);


%% bootstrap test 

totalT = [TiberiusT, ZiggyT, VinnieT];
totalC = [TiberiusC, ZiggyC, VinnieC];

cxtList = [];
colList = [];
dirList = [];
for id = 1:length(totalT)
    cxt1 = totalT(id).cxtUnits;
    cxt2 = totalC(id).cxtUnits;
    cxtUnits = union(cxt1, cxt2);
    colUnits = totalC(id).colUnits;
    dirUnits = totalC(id).dirUnits;
    
    cxtListUnits = zeros(1,totalC(id).totalUnits);
    colListUnits = zeros(1,totalC(id).totalUnits);
    dirListUnits = zeros(1,totalC(id).totalUnits);
    
    cxtListUnits(cxtUnits) = 1;
    colListUnits(colUnits) = 1;
    dirListUnits(dirUnits) = 1;
    
    cxtList = [cxtList cxtListUnits];
    colList = [colList colListUnits];
    dirList = [dirList dirListUnits];
    
    
end

% bootstrap
% [anteriorCxtS,anteriorColS,anteriorDirS] = bootstrapMI(cxtList, colList, dirList, 517);
% [deepCxtS,deepColS,deepDirS] = bootstrapMI(cxtList, colList, dirList, 1503);
% [superficialCxtS,superficialColS,superficialDirS] = bootstrapMI(cxtList, colList, dirList, 1357);
% [posteriorCxtS,posteriorColS,posteriorDirS] = bootstrapMI(cxtList, colList, dirList, 353);

% subsample
[anteriorCxtS,anteriorColS,anteriorDirS] = bootstrapMI(cxtList, colList, dirList, 1055);
[deepCxtS,deepColS,deepDirS] = bootstrapMI(cxtList, colList, dirList, 1055);
[superficialCxtS,superficialColS,superficialDirS] = bootstrapMI(cxtList, colList, dirList, 1055);
[posteriorCxtS,posteriorColS,posteriorDirS] = bootstrapMI(cxtList, colList, dirList, 1055);

% plot bootstrap results

figure; hold on

plot(1:3, v1MI, '.', 'markersize', 50)
plot(1, anteriorCxtS, 'k.', 'markersize', 50)
plot(2, anteriorColS, 'k.', 'markersize', 50)
plot(3, anteriorDirS, 'k.', 'markersize', 50)

figure; hold on

plot(1:3, DeepMI, '.', 'markersize', 50)
plot(1, deepCxtS, 'k.', 'markersize', 50)
plot(2, deepColS, 'k.', 'markersize', 50)
plot(3, deepDirS, 'k.', 'markersize', 50)

figure; hold on

plot(1:3, tsupMI, '.', 'markersize', 50)
plot(1, superficialCxtS, 'k.', 'markersize', 50)
plot(2, superficialColS, 'k.', 'markersize', 50)
plot(3, superficialDirS, 'k.', 'markersize', 50)

figure; hold on

plot(1:3, z1MI, '.', 'markersize', 50)
plot(1, posteriorCxtS, 'k.', 'markersize', 50)
plot(2, posteriorColS, 'k.', 'markersize', 50)
plot(3, posteriorDirS, 'k.', 'markersize', 50)