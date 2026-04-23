TiberiusT = load('./CModDLPFC/TibsCxtTMod.mat').CMod;
TiberiusC = load('./CModDLPFC/TibsCMod.mat').CMod;

ZiggyT = load('./CModDLPFC/ZiggyCxtTMod.mat').CMod;
ZiggyC = load('./CModDLPFC/ZiggyCMod.mat').CMod;
 
VinnieT = load('./CModDLPFC/VinnieCxtTMod.mat').CMod;
VinnieC = load('./CModDLPFC/VinnieCMod.mat').CMod;


TibsPMdT = load('./CModPMd/TibsnpixCxt50ms.mat').CMod;
TibsPMdC = load('./CModPMd/TibsnpixMod50ms.mat').CMod;


%%


T1T = TiberiusT(1:64);
T1C = TiberiusC(1:64);

T2T = TiberiusT(65:102);
T2C = TiberiusC(65:102);

Z2T = ZiggyT(13:end);
Z2C = ZiggyC(13:end);

Z1T = ZiggyT(1:12);
Z1C = ZiggyC(1:12);

V1T = VinnieT;
V1C = VinnieC; 


%% 

[a,b,c,vT, v1MI] = calTotal(V1T, V1C);

% T1: deep
[a2,b2,c2,tDeepT, tDeepMI] = calTotal(T2T, T2C);
[a1,b1,c1,zDeepT, zDeepMI] = calTotal(Z1T, Z1C);


[a,b,c,tSupT, tsupMI] = calTotal(T1T, T1C);

% Ziggy
[a,b,c,zT,z1MI] = calTotal(Z2T, Z2C);

DeepMI = [a2 + a1, b2+b1, c2+c1]./(zDeepT+tDeepT);


% PMd
[a1,b1,c1,tPMdT, tPMdMI] = calTotal(TibsPMdT, TibsPMdC);



PMdMI = [a1, b1, c1]./(tPMdT);



% %% effect size failed
% 
% TibsES = calAveEffectSize(TiberiusT, TiberiusC);
% ZiggyES = calAveEffectSize(ZiggyT, ZiggyC);
% VinnieES = calAveEffectSize(VinnieT, VinnieC);
% 
% TibsPMdES = calAveEffectSize(TibsPMdT, TibsPMdC);
% 
% 
% dlpfcA = VinnieES;
% dlpfcV = TibsES(65:102);
% dlpfcD = [TibsES(1:64), ZiggyES(1:12)];
% area8 = ZiggyES(13:end);
% pmd = [TibsPMdES, OlafPMdES];
% 
% 
% 
% a = [dlpfcV.aveCxtEffectSize];
% b = [dlpfcV.aveColEffectSize];
% c = [dlpfcV.aveDirEffectSize];
% 
% 
% 
% d = [max(a), max(b), max(c)]



%% bar plot 


% add an error bar

X = categorical({'9/46 Anterior','9/46 Deep','9/46 Superficial','Area 8'});
X = reordercats(X,{'9/46 Anterior', '9/46 Deep','9/46 Superficial','Area 8'});

y = [v1MI; DeepMI; tsupMI; z1MI];


figure('position', [1000,1000,600,300]); hold on
bh = bar(X, y);

ylabel("modulation percentage")
title([ 'num units: ' mat2str([vT, zDeepT+tDeepT, tSupT, zT])])
TestL={'cxt','color','dir'};
legend(bh, TestL, 'location', 'best') %'northwest'

% print(['~/Desktop/modBarDLPFC.pdf'],'-dpdf','-bestfit')

% add an error bar

X = categorical({'9/46 Anterior','9/46 Deep','9/46 Superficial','Area 8', 'PMd'});
X = reordercats(X,{'9/46 Anterior', '9/46 Deep','9/46 Superficial','Area 8', 'PMd'});

y = [v1MI; DeepMI; tsupMI; z1MI; PMdMI];


figure('position', [1000,1000,600,300]); hold on
bh = bar(X, y);

ylabel("modulation percentage")
title([ 'num units: ' mat2str([vT, zDeepT+tDeepT, tSupT, zT, tPMdT])])
TestL={'cxt','color','dir'};
legend(bh, TestL, 'location', 'best') %'northwest'

% print(['~/Desktop/modBarDLPFC.pdf'],'-dpdf','-bestfit')


%% error bar 

DeepT = tDeepT+ zDeepT;
temp = y.*(1-y);

dataErr(1,:) = sqrt(temp(1,:)./vT)
dataErr(2,:) = sqrt(temp(2,:)./DeepT)
dataErr(3,:) = sqrt(temp(3,:)./tSupT)
dataErr(4,:) = sqrt(temp(4,:)./zT)
dataErr(5,:) = sqrt(temp(5,:)./tPMdT)

dataCI = dataErr.*2.58;
figure('position', [1000,1000,600,300]); hold on

X = categorical({'9/46 Anterior','9/46 Deep','9/46 Superficial','Area 8', 'pmd'});
X = reordercats(X,{'9/46 Anterior', '9/46 Deep','9/46 Superficial','Area 8', 'pmd'});

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
title([ 'num units: ' mat2str([vT, DeepT, tSupT, zT, tPMdT])])
TestL={'cxt','color','dir'};
legend(b, TestL, 'location', 'best') %'northwest'

ylim([0 1])

% print(['~/Desktop/modBar.pdf'],'-dpdf','-bestfit')
