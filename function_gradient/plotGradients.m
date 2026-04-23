% a = xlsread('insert_locations.xlsx');

% grid 6: 8.5mm; grid 8:12mm  

opts = detectImportOptions('insert_locations.xlsx');

% Set column types
% 'string' for text columns
% 'double' for numeric columns
opts.VariableTypes{1} = 'string';   % 1st column string
opts.VariableTypes{2} = 'double';   % 2nd column number
opts.VariableTypes{3} = 'double';   % 3rd column number
opts.VariableTypes{4} = 'double';   % 4th column number
opts.VariableTypes{6} = 'string';   % 6th column string

% Read the table with specified options
data = readtable('insert_locations.xlsx', opts);

monkey = data{:,6};    % 1st column strings


%% 
% addpath('~/Documents/MATLAB/ChandLab/DLPFC_PMD/geometry/results/')
addpath('/Users/tianwang/Documents/MATLAB/ChandLab/DLPFC_analysis/createDataInfo/');
% TibsDLPFC = [load('TibsVprobeDLPFC.mat').results, load('TibsNpixDLPFC.mat').results];


s46 = struct;
ps = struct;

% add vprobe data
% TibsVprobeDLPFC = load('TibsVprobeDLPFC.mat').results;
% load('DLPFC_neurons');
TibsDataVprobe = data(1:129, 1:6);

cnt46S = 1;
cntPS = 1;
for ii = 14:length(TibsVprobeDLPFC)

    channelId = database(ii).channelID;
    anovaResults = TibsVprobeDLPFC(ii).anovaResults;
    thresh = TibsDataVprobe{ii,2};
    
    up = TibsDataVprobe{ii,3};
    down = TibsDataVprobe{ii,4};  
    
    divide = channelId <= thresh;

    
    if (thresh == 32)
        if up == 3
            s46(cnt46S).anovaResults = TibsVprobeDLPFC(ii).anovaResults;            
            s46(cnt46S).name = TibsVprobeDLPFC(ii).name;
            cnt46S = cnt46S + 1;
        else
            ps(cntPS).anovaResults = TibsVprobeDLPFC(ii).anovaResults;            
            ps(cntPS).name = TibsVprobeDLPFC(ii).name;
            cntPS = cntPS + 1;            
        end
        
    else
        s46(cnt46S).anovaResults = anovaResults(divide);        
        s46(cnt46S).name = TibsVprobeDLPFC(ii).name;
        ps(cntPS).anovaResults = anovaResults(~divide);        
        ps(cntPS).name = TibsVprobeDLPFC(ii).name;
        cntPS = cntPS + 1;
        cnt46S = cnt46S + 1;
        
    end
         
end


%%

% add neuropixel data
% TibsNpixDLPFC = load('TibsNpixDLPFC.mat').results;
TibsDataNpix = data(186:204, 1:6);

% temp = TibsNpixDLPFC([16 17 19 20]);
% 
% tempS46 = struct;
% tempPS = struct; 




ps = [ps, TibsNpixDLPFC([1:7, 9, 11:20])];

s46 = [s46, TibsNpixDLPFC([8 10 16 17 19 20])];



ps(85).anovaResults = ps(85).anovaResults(1:45);
ps(86).anovaResults = ps(86).anovaResults(1:57);
ps(88).anovaResults = ps(88).anovaResults(1:14);
ps(89).anovaResults = ps(89).anovaResults(1:28);

s46(61).anovaResults = s46(61).anovaResults(46:end);
s46(62).anovaResults = s46(62).anovaResults(58:end);
s46(63).anovaResults = s46(63).anovaResults(15:end);
s46(64).anovaResults = s46(64).anovaResults(29:end);


% aa = load('/Volumes/TianSSD/TiberiusNpix/waveforms/20240821_DLPFCwaveforms.mat')

%% 
anterior = [load('VinnieVprobeDLPFC.mat').results, load('VinnieNpixDLPFC.mat').results];
% pmd = [load('OlafVprobePMD.mat').results, load('TibsVprobePMD.mat').results, load('TibsNpixPMD.mat').results];
pmd = [load('TibsNpixPMD.mat').results];

area8 = TibsVprobeDLPFC(1:13);

%% plot each area 

figure; 
[~, pmdNum] = plotArea(pmd)
ylim([0 0.7])
xlabel('ms after checkerboard')
ylabel('ratio')
title(['pmd ' num2str(pmdNum) ' units'])

figure; 
[~, area8Num] = plotArea(area8)
ylim([0 0.7])
xlabel('ms after checkerboard')
ylabel('ratio')
title(['8Ad ' num2str(area8Num) ' units'])

figure; 
[~, s46Num] = plotArea(s46)
ylim([0 0.7])
xlabel('ms after checkerboard')
ylabel('ratio')
title(['s46 ' num2str(s46Num) ' units'])

figure; 
[~, anteriorNum] = plotArea(anterior)
ylim([0 0.7])
xlabel('ms after checkerboard')
ylabel('ratio')
title(['anterior ' num2str(anteriorNum) ' units'])


figure; 
[~, psNum] = plotArea(ps)
ylim([0 0.7])
xlabel('ms after checkerboard')
ylabel('ratio')
title(['ps ' num2str(psNum) ' units'])

% figure; 
% [~, psNum] = plotArea(ps(1:71))
% ylim([0 0.7])
% title('ps')
% 
% 
% figure; 
% [~, psNum] = plotArea(ps(71:89))
% ylim([0 0.7])
% title('ps')




