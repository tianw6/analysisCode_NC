
Tibs = load('/Users/tianwang/Documents/MATLAB/ChandLab/DLPFC_analysis/createDataInfo/DLPFC_neurons.mat').database;

Vinnie = load('/Users/tianwang/Documents/MATLAB/ChandLab/Vinnie_DLPFC/createDataInfo/DLPFC_neurons.mat').database;

a = struct2table(Tibs);
b = struct2table(Vinnie);

c = [a(:,1); b(:,1)];

Channels = table2struct(c);


cnt = 1;


allAP = [];
allDepth = [];


for ii = 1:length(Channels)
    units = length(Channels(ii).channelID);
    
    channelId = Channels(ii).channelID;
    
    depth1Day = depth(ii) - (32-channelId)./10;
    AP1Day = AP(ii) + rand(units,1).*0.4-0.2;
    
    allDepth = [allDepth; depth1Day];
    allAP = [allAP; AP1Day];
        
    cnt = cnt+units;
    
end
 


%% 

[choiceES, I] = sort(ES(2,:));

allAP = allAP(I);
allDepth = allDepth(I);


cmap = cool(1000); 

figure; hold on
for ii = 1:length(allAP)
    
        data_norm = choiceES(ii)./max(ES(2,:));
        
        color_idx = round(1 + (size(cmap,1)-1) * data_norm);
        color_idx = min(max(color_idx, 1), size(cmap,1));  % ensure within bounds
        plot(allAP(ii), allDepth(ii), '.', 'markersize', 20, 'color', cmap(color_idx,:));    
    
end

set(gca, 'YDir','reverse')

title('choice')


%% 

[cxtES, I] = sort(ES(3,:));

allAP = allAP(I);
allDepth = allDepth(I);


cmap = cool(1000); 

figure; hold on
for ii = 1:length(allAP)
    
        data_norm = cxtES(ii)./max(ES(2,:));
        
        color_idx = round(1 + (size(cmap,1)-1) * data_norm);
        color_idx = min(max(color_idx, 1), size(cmap,1));  % ensure within bounds
        plot(allAP(ii), allDepth(ii), '.', 'markersize', 20, 'color', cmap(color_idx,:));    
    
end

set(gca, 'YDir','reverse')

title('cxt')


%% 

[colorES, I] = sort(ES(1,:));

allAP = allAP(I);
allDepth = allDepth(I);


cmap = cool(1000); 

figure; hold on
for ii = 1:length(allAP)
    
        data_norm = colorES(ii)./max(ES(1,:));
        
        color_idx = round(1 + (size(cmap,1)-1) * data_norm);
        color_idx = min(max(color_idx, 1), size(cmap,1));  % ensure within bounds
%         plot(allAP(ii), allDepth(ii), '.', 'markersize', 20, 'color', cmap(color_idx,:));    
        scatter(allAP(ii), allDepth(ii),  20, cmap(color_idx,:), 'filled');    
    
end

set(gca, 'YDir','reverse')


%% 

data_norm = colorES./max(colorES);
% data_norm = choiceES./max(choiceES);
% data_norm = cxtES./max(cxtES);

color_idx = round(1 + (size(cmap,1)-1) * data_norm);
color_idx = min(max(color_idx, 1), size(cmap,1));

scatter(allAP, allDepth, 20, cmap(color_idx,:), 'filled', 'markerfacealpha', 0.8)
title('color')

set(gca, 'YDir','reverse')
