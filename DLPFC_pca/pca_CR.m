% created by Tian on Jan 26th, 2025. PCA on correct and wrong trials

%% remove condition independent signal: subtract average 

firingRatesAverage = totalDataframe(:,:,:,:,1:1200);

processedFR = [];

for ii = 1:size(firingRatesAverage,1)
    temp = squeeze(firingRatesAverage(ii,:,:,:,:));
    
    %%%%%%%%%%%%% normalize the data (divided by sqrt of 99% ile of each unit separately)
    normFactor = prctile(temp(:), 99) + 2;
    temp = temp./sqrt(normFactor);
    %%%%%%%%%%%%%
    
    average = nanmean(nanmean(nanmean(temp)));
    temp2 = [];
    for jj = 1:2
        for kk = 1:6
            for mm = 1:2
                temp2 = [temp2 squeeze(temp(jj, kk,mm,:) - average)'];
%%%             processedFR(ii,jj,kk,:) = temp(jj, kk,:) - average;
            % no condition independent removal
%             temp2 = [temp2 squeeze(temp(jj, kk,:))'];
            end

        end
    end
    processedFR(ii,:) = temp2;
end


%% pca
test = processedFR';
test(isnan(test))=0;


[coeff, score, latent] = pca(test);

% B = rotatefactors(coeff(:,1:10));

% score = test*B;

m = size(firingRatesAverage,2) * size(firingRatesAverage,3) * size(firingRatesAverage,4);
t = size(firingRatesAverage,5);

orthF = [];
for thi = 1 : m
    orthF(:,:,thi) = (score( (1:t) + (thi-1)*t, :))';
end


%% color

addpath('/Users/tianwang/Documents/MATLAB/ChandLab/DLPFC_PMD/LabCode');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% you adjust the number here to select different PCs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
traj = orthF([1 3 4],:,:);

targetOn = 100;
medianCOn = 800;



cc1 = flipud([
        0.04798154555940023, 0.4964244521337947, 0.2618223760092272;
        0.4, 0.7411764705882353, 0.38823529411764707;
        0.6460592079969245, 0.8488273740868898, 0.4151480199923107;
        0.7411764705882355, 0.8898885044213765, 0.47404844290657455;
        0.8509803921568628, 0.9372549019607844, 0.5450980392156864;
        0.9211072664359863, 0.9667820069204153, 0.6410611303344869;
        0.9678585159554018, 0.9864667435601692, 0.7050365244136871
        ]);  
    
    
cc2 = flipud([
        0.9991541714725106, 0.9737793156478277, 0.7050365244136869;
        0.9979238754325259, 0.9356401384083044, 0.6410611303344866;
        0.996078431372549, 0.8784313725490196, 0.5450980392156862;
        0.993925413302576, 0.7707804690503652, 0.4546712802768165;
        0.9914648212226067, 0.677354863514033, 0.37808535178777386;
        0.9568627450980393, 0.42745098039215684, 0.2627450980392157;
        0.7393310265282584, 0.08858131487889273, 0.1508650519031142
        ]);   

cc = [cc2; cc1];

figure;
% green easiest cxt1 (right)
% plot3(traj(1,:,1), traj(2,:,1),traj(3,:,1),  'linewidth', 2, 'color', cc(end,:));
plot3(traj(1,:,2), traj(2,:,2),traj(3,:,2),  'linewidth', 2, 'color', cc(end,:), 'linestyle', '--');
hold on
% green easiest cxt2 (left)
plot3(traj(1,:,13), traj(2,:,13),traj(3,:,13),  'linewidth', 2, 'color', cc(end,:));
hold on
% plot3(traj(1,:,14), traj(2,:,14),traj(3,:,14),  'linewidth', 2, 'color', cc(end,:), 'linestyle', '--');

% red easiest cxt1 (left)
plot3(traj(1,:,11), traj(2,:,11),traj(3,:,11),  'linewidth', 2, 'color', cc(1,:));
hold on
% plot3(traj(1,:,12), traj(2,:,12),traj(3,:,12),  'linewidth', 2, 'color', cc(1,:), 'linestyle', '--');
% red easiest cxt1 (right)
% plot3(traj(1,:,23), traj(2,:,23),traj(3,:,23),  'linewidth', 2, 'color', cc(1,:));
hold on
plot3(traj(1,:,24), traj(2,:,24),traj(3,:,24),  'linewidth', 2, 'color', cc(1,:), 'linestyle', '--');


%% 


% green mid cxt1 (right)
% plot3(traj(1,:,3), traj(2,:,3),traj(3,:,3), 'g-',  'linewidth', 2, 'color', cc(end-1,:));
% hold on
plot3(traj(1,:,4), traj(2,:,4),traj(3,:,4), 'g',  'linewidth', 2, 'linestyle', '--', 'color', cc(end-1,:));
hold on 
% green mid cxt2 (left)
plot3(traj(1,:,15), traj(2,:,15),traj(3,:,15), 'g-',  'linewidth', 2, 'color', cc(end-1,:));
hold on
% plot3(traj(1,:,16), traj(2,:,16),traj(3,:,16), 'g',  'linewidth', 2, 'linestyle', '--', 'color', cc(end-1,:));

% red mid cxt1 (left)
plot3(traj(1,:,9), traj(2,:,9),traj(3,:,9), 'r-',  'linewidth', 2, 'color', cc(2,:));
hold on
% plot3(traj(1,:,10), traj(2,:,10),traj(3,:,10), 'r',  'linewidth', 2, 'linestyle', '--', 'color', cc(2,:));

% red mid cxt2 (right)
% plot3(traj(1,:,21), traj(2,:,21),traj(3,:,21), 'r-',  'linewidth', 2, 'color', cc(2,:));
hold on
plot3(traj(1,:,22), traj(2,:,22),traj(3,:,22), 'r',  'linewidth', 2, 'linestyle', '--', 'color', cc(2,:));


%% 

% green hard cxt1 (right)
% plot3(traj(1,:,5), traj(2,:,5),traj(3,:,5), 'g-',  'linewidth', 2, 'color', cc(end-4,:));
% hold on
plot3(traj(1,:,6), traj(2,:,6),traj(3,:,6), 'g',  'linewidth', 2, 'linestyle', '--', 'color', cc(end-4,:));
hold on
% green hard cxt2 (left)
plot3(traj(1,:,17), traj(2,:,17),traj(3,:,17), 'g-',  'linewidth', 2, 'color', cc(end-4,:));
hold on
% plot3(traj(1,:,18), traj(2,:,18),traj(3,:,18), 'g',  'linewidth', 2, 'linestyle', '--', 'color', cc(end-4,:));

% red hard cxt1 (left)
plot3(traj(1,:,7), traj(2,:,7),traj(3,:,7), 'r-',  'linewidth', 2, 'color', cc(5,:));
hold on
% plot3(traj(1,:,8), traj(2,:,8),traj(3,:,8), 'r',  'linewidth', 2, 'linestyle', '--', 'color', cc(5,:));

% green hard cxt2 (right)
% plot3(traj(1,:,19), traj(2,:,19),traj(3,:,19), 'r-',  'linewidth', 2, 'color', cc(5,:));
hold on
plot3(traj(1,:,20), traj(2,:,20),traj(3,:,20), 'r',  'linewidth', 2, 'linestyle', '--', 'color', cc(5,:));




%%
% plot time events
for ii = 2:2
    % plot target onset
    plot3(traj(1,targetOn,ii), traj(2,targetOn,ii),traj(3,targetOn,ii),'k.', 'markersize', 30);
    % plot checkerboard onset
    plot3(traj(1,medianCOn,ii), traj(2,medianCOn,ii),traj(3,medianCOn,ii),'m.', 'markersize', 30);
    % plot RT 
%     plot3(traj(1,medianRT,ii), traj(2,medianRT,ii),traj(3,medianRT,ii),'c.', 'markersize', 50);

end



%% 





set(gcf, 'Color', 'w');
axis off; 
axis tight;
set(gca, 'LooseInset', [ 0 0 0 0 ]);
xlabel('PC1');
ylabel('PC4');
zlabel('PC3');
axis vis3d;
axis equal


view([-58 20])

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

% print('-painters','-depsc',['~/Desktop/DLPFC_pcaD','.eps']);


%% plot pc 1 to 4 vs time 
for ii = 1:10
    figure; hold on
    plot(squeeze(orthF(ii, :, 1)), 'r-')
    plot(squeeze(orthF(ii, :, 2)), 'r--')
    plot(squeeze(orthF(ii, :, 3)), 'g-')
    plot(squeeze(orthF(ii, :, 4)), 'g--')
    title(['pc ' num2str(ii)]);
end

%% save pca trajectories

% pcaResult.proj = orthF;
% pcaResult.latent = latent;
% save('DLPFC_pcaResult.mat', 'pcaResult');