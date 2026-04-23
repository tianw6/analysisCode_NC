DLPFC = load('/Volumes/TianSSD/TiberiusNpix/checkerboardAligned/20240328DLPFCB1.mat').allData;


%% 

DLPFC = DLPFC([DLPFC.correctness] == 1);

chopTime = 200;
g = normpdf([-0.1:0.001:0.1],0,0.025);


DLPFCFRmatrix = [];
for ii = 1:length(DLPFC)
    raster = double(DLPFC(ii).rasterT);
    for jj = 1:size(raster,1)
        temp = conv(squeeze(raster(jj,:)),g, 'same');
        DLPFCFRmatrix(jj,:,ii) = temp(chopTime+1:end-chopTime);
    end
end


%% 



perf = [DLPFC.DLperformance];
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
    
    title(ip)
    xline([0])
    pause()
    close
end



