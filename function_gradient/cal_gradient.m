% calculate functional gradients with dpca 


clear; clc


%% for dlpfc Data

a = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/checkerboardAligned/allBinFRvprobe.mat').allBinFR;
b = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Vinnie/checkerboardAligned/allBinFRvprobe.mat').allBinFR;
c = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Ziggy/checkerboardAligned/allBinFRvprobe.mat').allBinFR;

d = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Vinnie/checkerboardAligned/allBinFRnpix.mat').allBinFR;
e = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/checkerboardAligned/allBinFRnpix.mat').allBinFR;
f = load('/Users/tianwang/Documents/MATLAB/ChandLab/TFBinFRdata/Tiberius/checkerboardAligned/allBinFRnpixPMD.mat').allBinFR;


binFRpfc = [a,b,c,d,e,f];

%% 

allTime = binFRpfc(1).time;

tStart = -100;
tEnd = 400; 
tSelected = allTime >= tStart & allTime <= tEnd;

time = allTime(tSelected);

for ii = 1:length(binFRpfc)
    
    binFRpfc(ii).trials = binFRpfc(ii).trials(:,:,tSelected);
    binFRpfc(ii).time = binFRpfc(ii).time(tSelected);

end


%%
normalizeData = 0;
[firingRatesAverage] = prepareFRaverage(binFRpfc, normalizeData);

%% 

combinedParams = {{1, [1 3]}, {2, [2 3]}, {3}, {[1 2], [1 2 3]}};
margNames = {'Stimulus', 'Decision', 'Condition-independent', 'S/D Interaction'};

% margNames = {'SC', 'Configuration', 'Condition-independent', 'C/D Interaction'};

margColours = [23 100 171; 187 20 25; 150 150 150; 114 97 171]/256;

% time of combined T and C data
timeEvents = [0];


%%

tic
[W,V,whichMarg] = dpca(firingRatesAverage, 30, ...
    'combinedParams', combinedParams, 'lambda', 1e-9);
toc

explVar = dpca_explainedVariance(firingRatesAverage, W, V, ...
    'combinedParams', combinedParams);

z = dpca_plot(firingRatesAverage, W, V, @dpca_plot_default, ...
    'explainedVar', explVar, ...
    'marginalizationNames', margNames, ...
    'marginalizationColours', margColours, ...
    'whichMarg', whichMarg,                 ...
    'time', time,                        ...
    'timeEvents', timeEvents,               ...
    'timeMarginalization', 3, ...
    'legendSubplot', 16, ...
    'numCompToShow', 20);

%% 
choiceLoad = abs(V(:,3));
cxtLoad = abs(V(:,5));
colorLoad = abs(V(:,7));

loads.colorLoad = colorLoad;
loads.cxtLoad = cxtLoad;
loads.choiceLoad = choiceLoad;

% save('loads_nonorm.mat', 'loads');
%%












% %% only choose sessions larger than 10 units
% 
% 
% Tibs = load('/Users/tianwang/Documents/MATLAB/ChandLab/DLPFC_analysis/createDataInfo/DLPFC_neurons.mat').database;
% 
% Vinnie = load('/Users/tianwang/Documents/MATLAB/ChandLab/Vinnie_DLPFC/createDataInfo/DLPFC_neurons.mat').database;
% 
% cnt = 1;
% 
% sessionLoads = [];
% for ii = 1:length(Tibs)
%     units = length(Tibs(ii).channelID);
%     
%     if (units > 5)
%         sessionLoads(ii,1) = mean(abs(choiceLoad(cnt:cnt+units-1)));
%         sessionLoads(ii,2) = mean(abs(cxtLoad(cnt:cnt+units-1)));
%         sessionLoads(ii,3) = mean(abs(colorLoad(cnt:cnt+units-1)));
%     else
%         sessionLoads(ii,1) = 0;
%         sessionLoads(ii,2) = 0;
%         sessionLoads(ii,3) = 0;
%     end
%     
%     cnt = cnt+units;
%     
% end
%  
% for ii = 1:length(Vinnie)
%     units = length(Vinnie(ii).channelID);
%     
%     if (units > 5)
%         sessionLoads(ii + length(Tibs),1) = mean(abs(choiceLoad(cnt:cnt+units-1)));
%         sessionLoads(ii + length(Tibs),2) = mean(abs(cxtLoad(cnt:cnt+units-1)));
%         sessionLoads(ii + length(Tibs),3) = mean(abs(colorLoad(cnt:cnt+units-1)));
%     else
%         sessionLoads(ii+ length(Tibs),1) = 0;
%         sessionLoads(ii+ length(Tibs),2) = 0;
%         sessionLoads(ii+ length(Tibs),3) = 0;        
%     end
%     
%     cnt = cnt+units;
%     
% end
% 
% % plot gradients 
% figure; hold on
% 
% for ii = 1:length(AP)
%     if (sessionLoads(ii,1) > 0)
%     plot(AP(ii), depth(ii), '.', 'markersize', sessionLoads(ii,1).*2000, 'color', 'b')
%     end
% end
% set(gca, 'YDir','reverse')
% 
% title('choice')
% 
% 
% figure; hold on
% 
% for ii = 1:length(AP)
%     if (sessionLoads(ii,2) > 0)
% 
%     plot(AP(ii), depth(ii), '.', 'markersize', sessionLoads(ii,2).*2000, 'color', 'k')
%     end
% end
% set(gca, 'YDir','reverse')
% 
% title('cxt')
% 
% 
% figure; hold on
% 
% for ii = 1:length(AP)
%     if (sessionLoads(ii,3) > 0)
%     
%     plot(AP(ii), depth(ii), '.', 'markersize', sessionLoads(ii,3).*2000, 'color', 'm')
%     end
% end
% set(gca, 'YDir','reverse')
% 
% title('color')
% 
% %% 
% 
% Tibs = load('/Users/tianwang/Documents/MATLAB/ChandLab/DLPFC_analysis/createDataInfo/DLPFC_neurons.mat').database;
% 
% Vinnie = load('/Users/tianwang/Documents/MATLAB/ChandLab/Vinnie_DLPFC/createDataInfo/DLPFC_neurons.mat').database;
% 
% cnt = 1;
% 
% sessionLoads = [];
% for ii = 1:length(Tibs)
%     units = length(Tibs(ii).channelID);
%     
%     
%     sessionLoads(ii,1) = mean(abs(choiceLoad(cnt:cnt+units-1)));
%     sessionLoads(ii,2) = mean(abs(cxtLoad(cnt:cnt+units-1)));
%     sessionLoads(ii,3) = mean(abs(colorLoad(cnt:cnt+units-1)));
%     
%     
%     cnt = cnt+units;
%     
% end
%  
% for ii = 1:length(Vinnie)
%     units = length(Vinnie(ii).channelID);
%     
%     sessionLoads(ii + length(Tibs),1) = mean(abs(choiceLoad(cnt:cnt+units-1)));
%     sessionLoads(ii + length(Tibs),2) = mean(abs(cxtLoad(cnt:cnt+units-1)));
%     sessionLoads(ii + length(Tibs),3) = mean(abs(colorLoad(cnt:cnt+units-1)));
%     
%     
%     cnt = cnt+units;
%     
% end
% 
% % plot gradients 
% figure; hold on
% 
% for ii = 1:length(AP)
%     plot(AP(ii), depth(ii), '.', 'markersize', sessionLoads(ii,1).*2000, 'color', 'b')
% end
% set(gca, 'YDir','reverse')
% 
% title('choice')
% 
% 
% figure; hold on
% 
% for ii = 1:length(AP)
%     plot(AP(ii), depth(ii), '.', 'markersize', sessionLoads(ii,2).*2000, 'color', 'k')
% end
% set(gca, 'YDir','reverse')
% 
% title('cxt')
% 
% 
% figure; hold on
% 
% for ii = 1:length(AP)
%     plot(AP(ii), depth(ii), '.', 'markersize', sessionLoads(ii,3).*1000, 'color', 'm')
% end
% set(gca, 'YDir','reverse')
% 
% title('color')
% 
% %% 
% 
% 
% figure; hold on
% 
% for ii = 1:length(AP)
%     plot(AP(ii), depth(ii), '.', 'markersize', 30, 'color', [sessionLoads(ii,1)*5000 0 0]./255)
% end
% set(gca, 'YDir','reverse')
% 
% title('choice')
% 
% 
% figure; hold on
% 
% for ii = 1:length(AP)
%     plot(AP(ii), depth(ii), '.', 'markersize', 30, 'color', [sessionLoads(ii,2)*5000  0 0]./255)
% end
% set(gca, 'YDir','reverse')
% 
% title('cxt')
% 
% 
% figure; hold on
% 
% for ii = 1:length(AP)
%     plot(AP(ii), depth(ii), '.', 'markersize', 30, 'color', [sessionLoads(ii,3)*5000  0 0]./255)
% end
% set(gca, 'YDir','reverse')
% 
% title('color')