%%%%%%%%%%%%%%%%%%%%
% This code plots Fig 3b: DLPFC PCA  



addpath('../utils/');

% load DLPFC data
a = load('../../analysisData_NC/Fig3/TiberiusNpix/DLPFCtotalDataframeTcxt.mat').totalDataframe;
b = load('../../analysisData_NC/Fig3/TiberiusNpix/DLPFCtotalDataframeC.mat').totalDataframe;

c = load('../../analysisData_NC/Fig3/TiberiusVprobe/DLPFCtotalDataframeTcxt.mat').totalDataframe;
d = load('../../analysisData_NC/Fig3/TiberiusVprobe/totalDataframeC.mat').totalDataframe;

e = load('../../analysisData_NC/Fig3/VinnieNpix/DLPFCtotalDataframeTcxt.mat').totalDataframe;
f = load('../../analysisData_NC/Fig3/VinnieNpix/DLPFCtotalDataframeC.mat').totalDataframe;

g = load('../../analysisData_NC/Fig3/VinnieVprobe/DLPFCtotalDataframeTcxt.mat').totalDataframe;
h = load('../../analysisData_NC/Fig3/VinnieVprobe/totalDataframeC.mat').totalDataframe;



frTN = cat(4, a(:,:,:,101:900), b(:,:,:,801:1300));

frTV = cat(4, c(:,:,:,501:1300), d(:,:,:,801:1300));

frVN = cat(4, e(:,:,:,101:900), f(:,:,:,801:1300));

frVV = cat(4, g(:,:,:,501:1300), h(:,:,:,801:1300));

firingRatesAverage = [frTN; frTV; frVN; frVV];


%% preprocess data
removeAve = 1;
processedFR = preprocess(firingRatesAverage, removeAve);

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


%% Fig 3b: DLPFC PCA


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% you adjust the number here to select different PCs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
selectPC = [1 3 4];
% selectPC = [1 2 3];

traj = orthF(selectPC,:,:);

targetOn = 100;
medianCOn = 800;
% medianRT = 527+400+735;

figure;

cc = [0,1,0;
    1,0,0;
    0,0.4,0.2;
    0.4,0,0.2];


plot3(traj(1,1:medianCOn,1), traj(2,1:medianCOn,1),traj(3,1:medianCOn,1), 'm',  'linewidth', 2);
hold on
plot3(traj(1,1:medianCOn,2), traj(2,1:medianCOn,2),traj(3,1:medianCOn,2), 'c',  'linewidth', 2);

plot3(traj(1,medianCOn+1:end,1), traj(2,medianCOn+1:end,1),traj(3,medianCOn+1:end,1), 'r',  'linewidth', 2);
hold on
plot3(traj(1,medianCOn+1:end,2), traj(2,medianCOn+1:end,2),traj(3,medianCOn+1:end,2),'color', [0.4 0 0.2], 'linestyle', '--', 'linewidth', 2);
plot3(traj(1,medianCOn+1:end,3), traj(2,medianCOn+1:end,3),traj(3,medianCOn+1:end,3), 'g', 'linewidth', 2);
plot3(traj(1,medianCOn+1:end,4), traj(2,medianCOn+1:end,4),traj(3,medianCOn+1:end,4),'color', [0 0.4 0.2], 'linestyle', '--', 'linewidth', 2);


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


view([27 25])  % dlpfc 1 4 3 
view([154 -9]) % dlpfc 1 3 4
% view([154 42]) % dlpfc 1 3 4


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

% print('-painters','-depsc',['~/Desktop/PMD_pca','.eps']);


title('Fig3b: DLPFC pca')
