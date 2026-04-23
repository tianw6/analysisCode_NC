%% 
clear; clc; close all
addpath('/Users/tianwang/Documents/MATLAB/ChandLab/Dynamics2022/utils');

% Tiberius restretching data: aligned to target (-0.4:3.6)
TData = load('/Volumes/TianSSD/TiberiusDLPFCforDPCA/all_new/totalDataframeA.mat').totalDataframe;
% VData = load('/Volumes/ZiggySSD/VinnieDLPFCforDPCA/all/totalDataframeA.mat').totalDataframe;
ZData = load('/Volumes/ZiggySSD/ZiggyDLPFCforDPCA/all_T/totalDataframeAZ.mat').totalDataframe;
VData = load('/Volumes/ZiggySSD/VinnieDLPFCforDPCA/checkerboardAligned/totalDataframeC.mat').totalDataframe;

TtfAveAll = [TData; ZData]; 
% choose before and after target onset
segment = [-100, 1200];
TtfMS = TtfAveAll(:,:,:,400+segment(1)+1:400+segment(2));

TtfMS = [TtfMS; VData(:,:,:,1:end-300)];


% TF shows up slower thand CFD, add some compensation
% dur = 500;
% Ttf = TtfAveAll(:,:,:,250:250+dur);
% I1 = reshape(Ttf, [size(Ttf,1) 4 size(Ttf,4)]);
% I1 = squeeze(nanmean(I1,2));
% I2(:,1,1,:) = I1;
% TtfMS = Ttf - repmat(I2,[1 2 2 1]);

dur = segment(2) - segment(1);




%% first way of removal: remove the averaging 
firingRatesAverage = TtfMS;

processedFR = [];

for ii = 1:size(firingRatesAverage,1)
    temp = squeeze(firingRatesAverage(ii,:,:,:));
    
    %%%%%%%%%%%%% normalize the data (divided by sqrt of 99% ile of each unit separately)
    normFactor = prctile(temp(:), 99) + 2;
    temp = temp./sqrt(normFactor);
    %%%%%%%%%%%%%
    
    average = mean(mean(temp));
    temp2 = [];
    for jj = 1:2
        for kk = 1:2
            temp2 = [temp2 squeeze(temp(jj, kk,:) - average)'];
%%%             processedFR(ii,jj,kk,:) = temp(jj, kk,:) - average;
            % no condition independent removal
%             temp2 = [temp2 squeeze(temp(jj, kk,:))'];

        end
    end
    processedFR(ii,:) = temp2;
end



test = processedFR';


[coeff, score, latent] = pca(test);

% B = rotatefactors(coeff(:,1:10));

% score = test*B;

m = size(firingRatesAverage,2) + size(firingRatesAverage,3);
t = size(firingRatesAverage,4);

orthF1 = [];
for thi = 1 : m
    orthF1(:,:,thi) = (score( (1:t) + (thi-1)*t, :))';
end


%% 

% 1st stim epoch: dpc 1,2
[TtfU, TtfV, TtfWhichMarg, TtfexplVar] = dpcaAnalysis(TtfMS, dur);


%% 

% project back 

% TtfMS
% CcfdMS
% CtfMS
% TcfdMS

TtfP = [];

for ii = 1:size(TtfMS,2)
    for jj = 1:size(TtfMS,3)
        TtfP(:,ii, jj, :) = TtfV(:,[4 8 9 11 13 14 15 18 19 20]) * TtfU(:,[4 8 9 11 13 14 15 18 19 20])' * squeeze(TtfMS(:,ii, jj, :));
    end
end


%% do pca 


processedFRTF = preprocess(TtfP);

test = processedFRTF';

[coeff, score, latent] = pca(test);

m = size(TtfP,2) + size(TtfP,3);
t = size(TtfP,4);
score1 = score(1:t*m, :);

% orthF1: TF low dimensional traj
orthF1 = [];
for thi = 1 : m
    orthF1(:,:,thi) = (score1( (1:t) + (thi-1)*t, :))';
end


%% 
% processedFRTF = preprocess(TtfP);
% 
% test = processedFRTF';
% 
% 
% [coeff, score, latent] = pca(test);
% 
% % B = rotatefactors(coeff(:,1:10));
% 
% % score = test*B;
% 
% m = size(TtfP,2) + size(TtfP,3);
% t = size(TtfP,4);
% 
% orthF = [];
% for thi = 1 : m
%     orthF(:,:,thi) = (score( (1:t) + (thi-1)*t, :))';
% end



%%


% plot them 
On = 100;
Cue = On + 735;

traj = orthF1([1 3 4],:,:);


figure;

plot3(traj(1,:,1), traj(2,:,1),traj(3,:,1), 'r',  'linewidth', 2);
hold on
plot3(traj(1,:,2), traj(2,:,2),traj(3,:,2),'r--', 'linestyle', '--', 'linewidth', 2);
plot3(traj(1,:,3), traj(2,:,3),traj(3,:,3), 'g', 'linewidth', 2);
plot3(traj(1,:,4), traj(2,:,4),traj(3,:,4),'g--', 'linestyle', '--', 'linewidth', 2);

% % % plot 1st cue
plot3(traj(1,On,1), traj(2,On,1),traj(3,On,1),'k.', 'markersize', 30);
plot3(traj(1,On,2), traj(2,On,2),traj(3,On,2),'k.', 'markersize', 30);
plot3(traj(1,On,3), traj(2,On,3),traj(3,On,3),'k.', 'markersize', 30);
plot3(traj(1,On,4), traj(2,On,4),traj(3,On,4),'k.', 'markersize', 30);

% plot 2nd cue
plot3(traj(1,Cue,1), traj(2,Cue,1),traj(3,Cue,1),'m.', 'markersize', 30);
plot3(traj(1,Cue,2), traj(2,Cue,2),traj(3,Cue,2),'m.', 'markersize', 30);
plot3(traj(1,Cue,3), traj(2,Cue,3),traj(3,Cue,3),'m.', 'markersize', 30);
plot3(traj(1,Cue,4), traj(2,Cue,4),traj(3,Cue,4),'m.', 'markersize', 30);

view([-39, 32])

% cosmetic code

set(gcf, 'Color', 'w');
axis off; 
axis tight;
set(gca, 'LooseInset', [ 0 0 0 0 ]);
xlabel('PC1');
ylabel('PC3');
zlabel('PC4');
axis vis3d;
axis equal


tv = ThreeVector(gca);
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

% print('-painters', '-depsc', '~/Desktop/Cosyne2024/PCA_all2.eps', '-r300')



%% plot tf trajs

for ii = 1:5
    
    figure; hold on
    
    plot(orthF1(ii,:,1), 'r',  'linewidth', 2);
    plot(orthF1(ii,:,2),'r--', 'linestyle', '--', 'linewidth', 2);
    plot(orthF1(ii,:,3), 'g', 'linewidth', 2);
    plot(orthF1(ii,:,4),'g--', 'linestyle', '--', 'linewidth', 2);
    xline(On, 'k--')
    xline(Cue, 'k--')
end

