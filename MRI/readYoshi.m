% read NIFTI file

V = niftiread('~/Downloads/X3D_T1_0_7_CS5_NSA8.nii.gz');

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
% temp(:,52 + AP(2)*2,:) = 1;

temp = V_prime(:,30:end,:);

intensity = [0 20 40 120 220 1024];
% alpha = [0 0 0.15 0.3 0.38 0.5];
color = [0 0 0; 43 0 0; 103 37 20; 199 155 97; 216 213 201; 255 255 255]/255;
queryPoints = linspace(min(intensity),max(intensity),256);
alphamap = interp1(intensity,alpha,queryPoints)';
colormap = interp1(intensity,color,queryPoints);

figure('Position', [500,500, 1000,1000])
volshow(temp, Colormap=colormap)
% volshow(temp)