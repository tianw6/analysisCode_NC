TiberiusT = load('./CModDLPFC/TibsCxtTMod.mat').CMod;
TiberiusC = load('./CModDLPFC/TibsCMod.mat').CMod;

ZiggyT = load('./CModDLPFC/ZiggyCxtTMod.mat').CMod;
ZiggyC = load('./CModDLPFC/ZiggyCMod.mat').CMod;
 
VinnieT = load('./CModDLPFC/VinnieCxtTMod.mat').CMod;
VinnieC = load('./CModDLPFC/VinnieCMod.mat').CMod;


TibsPMdT = load('./CModPMd/TibsTPMdMod.mat').CMod;
TibsPMdC = load('./CModPMd/TibsCPMdMod.mat').CMod;

OlafPMdT = load('./CModPMd/OlafTPMdMod.mat').CMod;
OlafPMdC = load('./CModPMd/OlafCPMdMod.mat').CMod;

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


[a2,b2,c2,oPMdT, oPMdMI] = calTotal(OlafPMdT, OlafPMdC);

PMdMI = [a2 + a1, b2+b1, c2+c1]./(tPMdT+oPMdT);



%% effect size failed

TibsES = calAveEffectSize(TiberiusT, TiberiusC);
ZiggyES = calAveEffectSize(ZiggyT, ZiggyC);
VinnieES = calAveEffectSize(VinnieT, VinnieC);

TibsPMdES = calAveEffectSize(TibsPMdT, TibsPMdC);
OlafPMdES = calAveEffectSize(OlafPMdT, OlafPMdC);


dlpfcA = VinnieES;
dlpfcV = TibsES(65:102);
dlpfcD = [TibsES(1:64), ZiggyES(1:12)];
area8 = ZiggyES(13:end);
pmd = [TibsPMdES, OlafPMdES];



a = [dlpfcV.aveCxtEffectSize];
b = [dlpfcV.aveColEffectSize];
c = [dlpfcV.aveDirEffectSize];



d = [max(a), max(b), max(c)]



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
title([ 'num units: ' mat2str([vT, zDeepT+tDeepT, tSupT, zT, tPMdT+oPMdT])])
TestL={'cxt','color','dir'};
legend(bh, TestL, 'location', 'best') %'northwest'

% print(['~/Desktop/modBarDLPFC.pdf'],'-dpdf','-bestfit')


