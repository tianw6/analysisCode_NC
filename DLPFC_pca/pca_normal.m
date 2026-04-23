% created by Tian on Jan 27th, 2025 normal PCA, aligned to
% checkerboard

%% remove condition independent signal: subtract average 


% load dlpfc data 

a = load('/Volumes/TianSSD/TiberiusNpix/checkerboardAligned/DLPFCtotalDataframeC.mat').totalDataframe;

b = load('/Volumes/TianSSD/TiberiusDLPFCforDPCA/checkerboardAligned/totalDataframeC.mat').totalDataframe;

c = load('/Volumes/TianSSD/VinnieNpix/checkerboardAligned/DLPFCtotalDataframeC.mat').totalDataframe;

d = load('/Volumes/ZiggySSD/VinnieDLPFCforDPCA/checkerboardAligned/totalDataframeC.mat').totalDataframe;

%% 
% a = load('/Volumes/TianSSD/TiberiusNpix/targetAligned/DLPFCtotalDataframeT.mat').totalDataframe;
% 
% b = load('/Volumes/TianSSD/TiberiusDLPFCforDPCA/TargetAligned/totalDataframeT.mat').totalDataframe;
% 
% c = load('/Volumes/TianSSD/VinnieNpix/TargetAligned/DLPFCtotalDataframeT.mat').totalDataframe;
% 
% d = load('/Volumes/ZiggySSD/VinnieDLPFCforDPCA/TargetAligned/totalDataframeT.mat').totalDataframe;
% 


frTN = a(:,:,:,1:1300);

frTV = b(:,:,:,1:1300);

frVN = c(:,:,:,1:1300);

frVV = d(:,:,:,1:1300);

firingRatesAverage = [frTN; frTV; frVN; frVV];



%% load PMD data:

a = load('/Volumes/TianSSD/PMd/PMdData/Tiberius/PMDtotalDataframeC.mat').totalDataframe;
b = load('/Volumes/TianSSD/PMd/PMdData/Olaf/PMDtotalDataframeC.mat').totalDataframe;
c = load('/Volumes/TianSSD/TiberiusNpix/checkerboardAligned/PMDtotalDataframeC.mat').totalDataframe;


frTN = c(:,:,:,1:1300);
frTV = a(:,:,:,1:1300);
frOV = b(:,:,:,1:1300);

firingRatesAverage = [frTN; frTV; frOV];



%%
processedFR = preprocess(firingRatesAverage);



%% pca
test = processedFR';


[coeff, score, latent] = pca(test);

% B = rotatefactors(coeff(:,1:10));

% score = test*B;

m = size(firingRatesAverage,2) + size(firingRatesAverage,3);
t = size(firingRatesAverage,4);

orthF = [];
for thi = 1 : m
    orthF(:,:,thi) = (score( (1:t) + (thi-1)*t, :))';
end


%% 

addpath('/Users/tianwang/Documents/MATLAB/ChandLab/DLPFC_PMD/LabCode');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% you adjust the number here to select different PCs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
selectPC = [1 4 3];
traj = orthF(selectPC,:,:);

targetOn = 100;
medianCOn = 800;
% medianRT = 527+400+735;

figure;

cc = [0,1,0;
    1,0,0;
    0,0.4,0.2;
    0.4,0,0.2];



plot3(traj(1,:,1), traj(2,:,1),traj(3,:,1), 'r',  'linewidth', 2);
hold on
plot3(traj(1,:,2), traj(2,:,2),traj(3,:,2),'color', [0.4 0 0.2], 'linestyle', '--', 'linewidth', 2);
plot3(traj(1,:,3), traj(2,:,3),traj(3,:,3), 'g', 'linewidth', 2);
plot3(traj(1,:,4), traj(2,:,4),traj(3,:,4),'color', [0 0.4 0.2], 'linestyle', '--', 'linewidth', 2);


% plot time events
for ii = 1:m
    % plot target onset
    plot3(traj(1,targetOn,ii), traj(2,targetOn,ii),traj(3,targetOn,ii),'k.', 'markersize', 50);
    % plot checkerboard onset
    plot3(traj(1,medianCOn,ii), traj(2,medianCOn,ii),traj(3,medianCOn,ii),'m.', 'markersize', 50);
    % plot RT 
%     plot3(traj(1,medianRT,ii), traj(2,medianRT,ii),traj(3,medianRT,ii),'c.', 'markersize', 50);

end


set(gcf, 'Color', 'w');
axis off; 
axis tight;
set(gca, 'LooseInset', [ 0 0 0 0 ]);
xlabel(['PC' num2str(selectPC(1))]);
ylabel(['PC' num2str(selectPC(2))]);
zlabel(['PC' num2str(selectPC(3))]);
axis vis3d;
axis equal


view([-32 20])

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

% print('-painters','-depsc',['~/Desktop/DLPFC_pcaT','.eps']);


 %%
 
 for ii = 1:6
    figure; hold on
    plot(squeeze(orthF(ii, :, 1)), 'r-')
    plot(squeeze(orthF(ii, :, 2)), 'r--')
    plot(squeeze(orthF(ii, :, 3)), 'g-')
    plot(squeeze(orthF(ii, :, 4)), 'g--')
    title(['pc ' num2str(ii)]);
end

