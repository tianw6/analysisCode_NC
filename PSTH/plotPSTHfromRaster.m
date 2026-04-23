DLPFC = load('/Volumes/TianSSD/TiberiusDLPFCPMD/TiberiusDLPFC20240430TFC.mat').dataframe;

% PMd = load('/Volumes/TianSSD/TiberiusDLPFCPMD/TiberiusPMd20240430TFC.mat').allData;
PMd = load('~/Desktop/TiberiusPMd20240430TFC.mat').allData;

%% 

DLPFC = DLPFC([PMd.correctness] == 1);
PMd = PMd([PMd.correctness] == 1);

chopTime = 200;
g = normpdf([-0.1:0.001:0.1],0,0.025);


DLPFCFRmatrix = [];
for ii = 1:length(DLPFC)
    raster = double(DLPFC(ii).rasterC);
    for jj = 1:size(raster,1)
        temp = conv(squeeze(raster(jj,:)),g, 'same');
        DLPFCFRmatrix(jj,:,ii) = temp(chopTime+1:end-chopTime);
    end
end

PMdFRmatrix = [];

for ii = 1:length(PMd)
    raster = double(PMd(ii).rasterT);
    for jj = 1:size(raster,1)
        temp = conv(squeeze(raster(jj,:)),g, 'same');
        PMdFRmatrix(jj,:,ii) = temp(chopTime+1:end-chopTime);
    end
end
%% 



perf = [DLPFC.performance];
perfTable = struct2table(perf);
a = perfTable(:,{'ChosenSide'});
b = table2cell(a);
left = strcmp(b, 'left')';
right = strcmp(b, 'right')';

a = perfTable(:,{'ChosenColor'});
b = table2cell(a);
red = strcmp(b, 'red')';
green = strcmp(b, 'green')';


RLdlpfc = DLPFCFRmatrix(:,:,left&red);
RRdlpfc = DLPFCFRmatrix(:,:, right&red);
GLdlpfc = DLPFCFRmatrix(:,:,left&green);
GRdlpfc = DLPFCFRmatrix(:,:,right&green);


RLpmd = PMdFRmatrix(:,:,left&red);
RRpmd = PMdFRmatrix(:,:, right&red);
GLpmd = PMdFRmatrix(:,:,left&green);
GRpmd = PMdFRmatrix(:,:,right&green);
%%

t = linspace(-0.8, 0.8, 1600);

for ip = 1:size(DLPFCFRmatrix, 1)
    figure; hold on

    data = squeeze(RLdlpfc(ip,:,:))';
    PSTH_mean = nanmean(data);
    PSTH_sem = std(data)./sqrt(size(data,1));
    patch = fill([t fliplr(t)] , [PSTH_mean+PSTH_sem fliplr(PSTH_mean-PSTH_sem)], [0.8 0 0.2]);
    set(patch, 'edgecolor', 'none', 'FaceAlpha', 0.5);
    plot(t, PSTH_mean, 'r-', 'linewidth', 2)
    
    
    data = squeeze(RRdlpfc(ip,:,:))';
    PSTH_mean = nanmean(data);
    PSTH_sem = std(data)./sqrt(size(data,1));
    patch = fill([t fliplr(t)] , [PSTH_mean+PSTH_sem fliplr(PSTH_mean-PSTH_sem)], [0.4 0 0.2])
    set(patch, 'edgecolor', 'none', 'FaceAlpha', 0.5);
    plot(t, PSTH_mean, 'r--', 'linewidth', 2)
    
    
    data = squeeze(GLdlpfc(ip,:,:))';
    PSTH_mean = nanmean(data);
    PSTH_sem = std(data)./sqrt(size(data,1));
    patch = fill([t fliplr(t)] , [PSTH_mean+PSTH_sem fliplr(PSTH_mean-PSTH_sem)], [0 0.8 0.2]);
    set(patch, 'edgecolor', 'none', 'FaceAlpha', 0.5);
    plot(t, PSTH_mean, 'g-', 'linewidth', 2)

    data = squeeze(GRdlpfc(ip,:,:))';
    PSTH_mean = nanmean(data);
    PSTH_sem = std(data)./sqrt(size(data,1));
    patch = fill([t fliplr(t)] , [PSTH_mean+PSTH_sem fliplr(PSTH_mean-PSTH_sem)], [0 0.4 0.2]);
    set(patch, 'edgecolor', 'none', 'FaceAlpha', 0.5);
    plot(t, PSTH_mean, 'g--', 'linewidth', 2)
    
    
    xline([0])
    pause()
    close
end

%%
for ip = [1 3 4 33 34] %1:size(PMdFRmatrix, 1)
    figure; hold on
    plot(t, squeeze(nanmean(RLpmd(ip,:,:),3)), 'r');
    plot(t, squeeze(nanmean(RRpmd(ip,:,:),3)), 'r--');
    plot(t, squeeze(nanmean(GLpmd(ip,:,:),3)), 'g');
    plot(t, squeeze(nanmean(GRpmd(ip,:,:),3)), 'g--');
    xline(0)
    title(mat2str(ip))
    set(gca, 'tickDir', 'out')
%     print(['~/Desktop/DLPFCPMD/PMd' num2str(ip) '.pdf'], '-dpdf','-bestfit')
    close
end
   
%%
for ip = [1 2 3 5 13 14]% 1:size(DLPFCFRmatrix, 1)
    figure; hold on
    plot(t,squeeze(nanmean(RLdlpfc(ip,:,:),3)), 'r');
    plot(t,squeeze(nanmean(RRdlpfc(ip,:,:),3)), 'r--');
    plot(t,squeeze(nanmean(GLdlpfc(ip,:,:),3)), 'g');
    plot(t,squeeze(nanmean(GRdlpfc(ip,:,:),3)), 'g--');
    xline([0])
    title(mat2str(ip))
    set(gca, 'tickDir', 'out')
%     print(['~/Desktop/DLPFCPMD/DLPFC' num2str(ip) '.pdf'], '-dpdf','-bestfit')
    close
end
    


