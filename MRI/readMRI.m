%% Vinnie

% read NIFTI file

V = niftiread('~/Downloads/VinnieNIFTI/VinnieAvg_aligned_cropped_brain.nii.gz');

Vmax = max(V, [], 'all');
Vmin = min(V,[], 'all');

V_prime = (V-Vmin)./(Vmax-Vmin);
dim = size(V_prime);





%% frontal, sagittal, horizontal view
% EBZ: (65,53,15)
% X: ML; Y: AP; Z: DV (each voxel might be 0.5mm)
AP = [34 36 36 38.5]+2;
ML = [56 54 59 56];

sliceX = 64;
sliceY = 52 + AP(2)*2;
sliceZ = 15;

%% 3D volumn
temp = V_prime;
temp(:,52 + AP(2)*2,:) = 1;


intensity = [0 20 40 120 220 1024];
alpha = [0 0 0.15 0.3 0.38 0.5];
color = [0 0 0; 43 0 0; 103 37 20; 199 155 97; 216 213 201; 255 255 255]/255;
queryPoints = linspace(min(intensity),max(intensity),256);
alphamap = interp1(intensity,alpha,queryPoints)';
colormap = interp1(intensity,color,queryPoints);

figure('Position', [500,500, 1000,1000])
volshow(temp, Colormap=colormap)

% print(['VinnieMRI.pdf'],'-dpdf','-bestfit')
%% frontal; sagittal; coronal view
frontal = V_prime(:,:,sliceZ);

sagittal = reshape(V_prime(sliceX,:,:), [dim(2), dim(3)]);

coronal = reshape(V_prime(:,sliceY, :), [dim(1), dim(3)]);

figure('Position', [0,0, 1500,600])

subplot(1,3,1), imshow(imrotate(sagittal, 90)); title('sagittal')

subplot(1,3,2), imshow(imrotate(frontal, 90)); title('frontal')

subplot(1,3,3), hold on
imshow(imrotate(coronal, 90)); title('coronal')
xline(64+26, 'r', 'linewidth', 2)
xline(64+30, 'r', 'linewidth', 2)
xline(64+34, 'r', 'linewidth', 2)


%% Ziggy

% read NIFTI file

V = niftiread('~/Downloads/ZiggyNIFTI/ZiggyAvg_copy_cropped_oriented.nii.gz');
V = single(V);
Vmax = max(V, [], 'all');
Vmin = min(V,[], 'all');

V_prime = single((V-Vmin)./(Vmax-Vmin));
dim = size(V_prime);





%% frontal, sagittal, horizontal view
% EBZ: (27,76,80)
% X: DV; Y: AP; Z: ML (each voxel might be 0.5mm)
AP = [33 30.5];
ML = [49 50];

sliceX = 27;
sliceY = 76 + AP(2)*2-2;
sliceZ = 80;

%% 3D volumn
temp = V_prime;
temp(:,sliceY,:) = 1;

figure('Position', [500,500, 1000,1000])
volshow(temp)

%% frontal; sagittal; coronal view
sagittal = V_prime(:,:,sliceZ);

frontal = reshape(V_prime(sliceX,:,:), [dim(2), dim(3)]);

coronal = reshape(V_prime(:,sliceY, :), [dim(1), dim(3)]);

figure('Position', [0,0, 1500,600])

subplot(1,3,1), imshow(imrotate(sagittal, 180)); title('sagittal')

subplot(1,3,2), imshow(imrotate(frontal, 180)); title('frontal')

subplot(1,3,3), hold on
imshow(imrotate(coronal, 180)); title('coronal')
xline(80-15*2, 'r', 'linewidth', 2)




%% Tiberius 

V = niftiread('~/Downloads/Tiberius_38996/Tiberius_38996_NHP_WIP_MPRAGE_0.5mm_iso_SENSE_10_1.nii');

V = single(V);
Vmax = max(V, [], 'all');
Vmin = min(V,[], 'all');

V_prime = single((V-Vmin)./(Vmax-Vmin));
dim = size(V_prime);





%% frontal, sagittal, horizontal view
% EBZ: (27,76,80)
% X: DV; Y: AP; Z: ML (each voxel might be 0.5mm)
AP = [33 30.5];
ML = [49 50];

sliceX = 27;
sliceY = 76 + AP(2)*2+3;
sliceZ = 80;

%% 3D volumn
temp = V_prime;
temp(:,sliceY,:) = 1;

figure('Position', [500,500, 1000,1000])
volshow(temp)

%%

%% frontal; sagittal; coronal view
sagittal = V_prime(:,:,sliceZ);

frontal = reshape(V_prime(sliceX,:,:), [dim(2), dim(3)]);

coronal = reshape(V_prime(:,sliceY, :), [dim(1), dim(3)]);

figure('Position', [0,0, 1500,600])

subplot(1,3,1), imshow(imrotate(sagittal, 180)); title('sagittal')

subplot(1,3,2), imshow(imrotate(frontal, 180)); title('frontal')

subplot(1,3,3), hold on
imshow(imrotate(coronal, 180)); title('coronal')
xline(80-15*2, 'r', 'linewidth', 2)


