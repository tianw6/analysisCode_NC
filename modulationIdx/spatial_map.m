% create the raster plot of modulation index
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



%% 

TiberiusT = load('TiberiusCxtTMod.mat').cxtTMod;
TiberiusC = load('TiberiusCMod.mat').CMod;

ZiggyT = load('ZiggyCxtTMod.mat').cxtTMod;
ZiggyC = load('ZiggyCMod.mat').CMod;
 
VinnieT = load('VinnieCxtTMod.mat').cxtTMod;
VinnieC = load('VinnieCMod.mat').CMod;

T1T = TiberiusT(1:13);
T1C = TiberiusC(1:13);

T2T = TiberiusC(14:29);
T2C = TiberiusC(14:29);

T3T = TiberiusT(30:54);
T3C = TiberiusC(30:54);

T4T = TiberiusT(55:64);
T4C = TiberiusC(55:64);

T5T = TiberiusT(65:102);
T5C = TiberiusC(65:102);


Z1T = ZiggyT(1:12);
Z1C = ZiggyC(1:12);

Z2T = ZiggyT(13:19);
Z2C = ZiggyC(13:19);

V1T = VinnieT(1:9);
V1C = VinnieC(1:9); 

V2T = VinnieT(10:15);
V2C = VinnieC(10:15);

V3T = VinnieT(19:25);
V3C = VinnieC(19:25);

V4T = VinnieT([16:18, 30:33]);
V4C = VinnieC([16:18, 30:33]);

%% 

[a,b,c,d, v1MI] = calTotal(V2T, V2C);
[a,b,c,d, v2MI] = calTotal(V1T, V1C);
[a,b,c,d, v3MI] = calTotal(V3T, V3C);
[a,b,c,d, v4MI] = calTotal(V4T, V4C);

[a,b,c,d, t4MI] = calTotal(T2T, T2C);
[a,b,c,d, t3MI] = calTotal(T3T, T3C);
[a,b,c,d, t2MI] = calTotal(T4T, T4C);
% T1: deep
[a,b,c,d, t1MI] = calTotal(T5T, T5C);

[a,b,c,d, z1MI] = calTotal(Z1T, Z1C);

[a,b,c,d,t5MI] = calTotal(T1T, T1C);
[a,b,c,d, z2MI] = calTotal(Z2T, Z2C);


%% 

aa = [v1MI; v2MI; v3MI; v4MI; t2MI; t3MI; t1MI; t4MI; t5MI; z1MI; z2MI];

cxtRange = (aa(:,1) - min(aa(:,1))) / ( max(aa(:,1)) - min(aa(:,1)) )+0.001;

colRange = (aa(:,2) - min(aa(:,2))) / ( max(aa(:,2)) - min(aa(:,2)) )+0.001;

dirRange = (aa(:,3) - min(aa(:,3))) / ( max(aa(:,3)) - min(aa(:,3)) )+0.001;

%% direction raw

figure(); hold on

plot(6,4, '.', 'markersize', 30, 'color', [1,1,1].*v1MI(3))
plot(7,5, '.', 'markersize', 30, 'color', [1,1,1].*v2MI(3))
plot(7,4, '.', 'markersize', 30, 'color', [1,1,1].*v3MI(3))
plot(8,4, '.', 'markersize', 30, 'color', [1,1,1].*v4MI(3))



plot(10,4, '.', 'markersize', 30, 'color', [1,1,1].*t2MI(3))
plot(11,3, '.', 'markersize', 30, 'color', [1,1,1].*t3MI(3))
plot(11.5,1, '.', 'markersize', 30, 'color', [1,1,1].*t1MI(3))

plot(12,4, '.', 'markersize', 30, 'color', [1,1,1].*t4MI(3))
plot(13,4, '.', 'markersize', 30, 'color', [1,1,1].*t5MI(3))

plot(13,5, '.', 'markersize', 30, 'color', [1,1,1].*z1MI(3))
plot(14,4, '.', 'markersize', 30, 'color', [1,1,1].*z1MI(3))





%% direction 
factor = 5000;
figure(); hold on

scatter(6,4, factor*dirRange(1), 'k.')
scatter(7,5, factor*dirRange(2), 'k.')
scatter(7,4, factor*dirRange(3), 'k.')
scatter(8,4, factor*dirRange(4), 'k.')



scatter(10,4, factor*dirRange(5), 'k.')
scatter(11,3, factor*dirRange(6), 'k.')

scatter(11.5,1,factor*dirRange(7), 'k.')

scatter(12,4, factor*dirRange(8), 'k.')
scatter(13,4, factor*dirRange(9), 'k.')

scatter(13,5, factor*dirRange(10), 'k.')
scatter(14,4, factor*dirRange(11), 'k.')


%% cxt raw


figure(); hold on

plot(6,4, '.', 'markersize', 30, 'color', [1,1,1].*v1MI(1))
plot(7,5, '.', 'markersize', 30, 'color', [1,1,1].*v2MI(1))
plot(7,4, '.', 'markersize', 30, 'color', [1,1,1].*v3MI(1))
plot(8,4, '.', 'markersize', 30, 'color', [1,1,1].*v4MI(1))



plot(10,4, '.', 'markersize', 30, 'color', [1,1,1].*t2MI(1))
plot(11,3, '.', 'markersize', 30, 'color', [1,1,1].*t3MI(1))
% deep
plot(11.5,1, '.', 'markersize', 30, 'color', [1,1,1].*t1MI(1))
plot(12,4, '.', 'markersize', 30, 'color', [1,1,1].*t4MI(1))
plot(13,4, '.', 'markersize', 30, 'color', [1,1,1].*t5MI(1))

plot(13,5, '.', 'markersize', 30, 'color', [1,1,1].*z1MI(1))
plot(14,4, '.', 'markersize', 30, 'color', [1,1,1].*z1MI(1))




%% cxt 

factor = 5000;
figure(); hold on

scatter(6,4, factor*cxtRange(1), 'k.')
scatter(7,5, factor*cxtRange(2), 'k.')
scatter(7,4, factor*cxtRange(3), 'k.')
scatter(8,4, factor*cxtRange(4), 'k.')



scatter(10,4, factor*cxtRange(5), 'k.')
scatter(11,3, factor*cxtRange(6), 'k.')

scatter(11.5,1,factor*cxtRange(7), 'k.')

scatter(12,4, factor*cxtRange(8), 'k.')
scatter(13,4, factor*cxtRange(9), 'k.')

scatter(13,5, factor*cxtRange(10), 'k.')
scatter(14,4, factor*cxtRange(11), 'k.')



%% color raw

figure(); hold on

plot(6,4, '.', 'markersize', 30, 'color', [1,1,1].*v1MI(2))
plot(7,5, '.', 'markersize', 30, 'color', [1,1,1].*v2MI(2))
plot(7,4, '.', 'markersize', 30, 'color', [1,1,1].*v3MI(2))
plot(8,4, '.', 'markersize', 30, 'color', [1,1,1].*v4MI(2))


plot(11.5,1, '.', 'markersize', 30, 'color', [1,1,1].*t1MI(2))

plot(10,4, '.', 'markersize', 30, 'color', [1,1,1].*t2MI(2))
plot(11,3, '.', 'markersize', 30, 'color', [1,1,1].*t3MI(2))
plot(12,4, '.', 'markersize', 30, 'color', [1,1,1].*t4MI(2))
plot(13,4, '.', 'markersize', 30, 'color', [1,1,1].*t5MI(2))

plot(13,5, '.', 'markersize', 30, 'color', [1,1,1].*z1MI(2))
plot(14,4, '.', 'markersize', 30, 'color', [1,1,1].*z1MI(2))


%% color 

factor = 5000;
figure(); hold on

scatter(6,4, factor*colRange(1), 'k.')
scatter(7,5, factor*colRange(2), 'k.')
scatter(7,4, factor*colRange(3), 'k.')
scatter(8,4, factor*colRange(4), 'k.')



scatter(10,4, factor*colRange(5), 'k.')
scatter(11,3, factor*colRange(6), 'k.')

scatter(11.5,1,factor*colRange(7), 'k.')

scatter(12,4, factor*colRange(8), 'k.')
scatter(13,4, factor*colRange(9), 'k.')

scatter(13,5, factor*colRange(10), 'k.')
scatter(14,4, factor*colRange(11), 'k.')

