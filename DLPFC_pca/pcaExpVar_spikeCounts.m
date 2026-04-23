%% created by Tina on May 29th 

% calculated the DLPFC and PMd variance explaind by pca 
% subsample DLPFC units. Use binned spike counts
clear; clc; close all

addpath('../utils/')


%% for dlpfc Data
a = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/checkerboardAligned/allBinFRnpix.mat').allBinFR;



b = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Vinnie/checkerboardAligned/allBinFRnpix.mat').allBinFR;
c = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/checkerboardAligned/allBinFRvprobe.mat').allBinFR;
d = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Vinnie/checkerboardAligned/allBinFRvprobe.mat').allBinFR;

binFRpfc = [c,a,d,b];

%% for pmd data
a = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/checkerboardAligned/allBinFRnpixPMD.mat').allBinFR;
b = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/checkerboardAligned/allBinFRvprobePMD.mat').allBinFR;
c = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Olaf/checkerboardAligned/allBinFRvprobePMD.mat').allBinFR;


binFRpmd = [a b c];

%%

allTime = binFRpfc(1).time;

tStart = -100;
tEnd = 300; 
tSelected = allTime >= tStart & allTime <= tEnd;

time = allTime(tSelected);



%% 


for ii = 1:length(binFRpfc)
    
    binFRpfc(ii).trials = binFRpfc(ii).trials(:,:,tSelected);
    binFRpfc(ii).time = binFRpfc(ii).time(tSelected);

end

for ii = 1:length(binFRpmd)
    

    binFRpmd(ii).trials = binFRpmd(ii).trials(:,:,tSelected);
    binFRpmd(ii).time = binFRpmd(ii).time(tSelected);
end



%%
% don't subtract the aveage FR
[processedFRpfc, ~] = prepareData(binFRpfc, 1);
[processedFRpmd, ~] = prepareData(binFRpmd, 1);

%%
DLPFClatentAll = [];
for ii = 1:100
    
    select = randsample(size(processedFRpfc, 1), size(processedFRpmd, 1));

    sFRpfc = processedFRpfc(select,:,:);
    
    % pca
    test = sFRpfc';


    [coeff, score, latent] = pca(test);


    DLPFClatentAll(ii,:) = latent;

end


%%

DLPFClatentAll = [];
PMdlatentAll = [];
cnt = 1;
DimV = [];
% S = floor(10.^(1.5:0.2:3.2));
S = 50:150:1600;
for j=1:100
    
    cnt = 1;
    fprintf('.');
    
    for ii = S
        
        select = randsample(size(processedFRpfc,1), ii);
        
        sFRpfc = processedFRpfc(select,:,:);
        
        % pca
        test = sFRpfc';
        
        
        [coeff, score, latent] = pca(test);
        
        Vpfc =  cumsum(latent(1:30)./sum(latent));;
        DLPFClatentAll(j,cnt,:) = Vpfc;
        
        
           
        select = randsample(size(processedFRpmd,1), ii);
        
        sFRpmd = processedFRpmd(select,:,:);
        
        test = sFRpmd';
        
        [coeff, score, PMDlatent] = pca(test);
         Vpmd = cumsum(PMDlatent(1:30)./sum(PMDlatent));
         PMdlatentAll(j,cnt,:) = Vpmd;
        
        
        DimV(j,cnt,1) = find(Vpfc > 0.9,1,'first');
        DimV(j,cnt,2) = find(Vpmd > 0.9,1,'first');
        cnt = cnt + 1;
        
        
        
    end
    
end


%% 

figure; hold on
errorbar(S, nanmean(DimV(:,:,1)), nanstd(DimV(:,:,1)))
errorbar(S, nanmean(DimV(:,:,2)), nanstd(DimV(:,:,2)))

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig3/', 'dimensions_CI', '.eps']);
%%

% pmd latent
test = processedFRpmd';

[coeff, score, PMDlatent] = pca(test);


%% 
DLPFCvar = [];
for ii = 1:size(DLPFClatentAll,1)
   temp = DLPFClatentAll(ii,:);
   DLPFCvar(ii,:) = cumsum(temp(1:30))./sum(temp); 
   
end
%%

a = figure('Position', [20 20 1200 500]);

options.handle = gcf;
options.error = 'std';
options.alpha      = 0.5;
options.line_width = 1;
options.x_axis = 1:30;

options.color_area = [100 100 100]./255;    % black theme
options.color_line = [0 0 0]./255;

plot_areaerrorbar(DLPFCvar, options)
%% 



plot(cumsum(PMDlatent(1:30))./sum(PMDlatent))

