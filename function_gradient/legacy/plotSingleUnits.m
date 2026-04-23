

Tibs = load('/Users/tianwang/Documents/MATLAB/ChandLab/DLPFC_analysis/createDataInfo/DLPFC_neurons.mat').database;

Vinnie = load('/Users/tianwang/Documents/MATLAB/ChandLab/Vinnie_DLPFC/createDataInfo/DLPFC_neurons.mat').database;

a = struct2table(Tibs);
b = struct2table(Vinnie);

c = [a(:,1); b(:,1)];

Channels = table2struct(c);


cnt = 1;

figure; hold on

for ii = 1:length(Channels)
    units = length(Channels(ii).channelID);
    
    channelId = Channels(ii).channelID;
    
    depth1Day = depth(ii) - (32-channelId)./10;
    AP1Day = AP(ii) + rand(units,1).*0.4-0.2;
    
%         sessionLoads(ii,1) = mean(abs(choiceLoad(cnt:cnt+units-1)));
%         sessionLoads(ii,2) = mean(abs(cxtLoad(cnt:cnt+units-1)));
%         sessionLoads(ii,3) = mean(abs(colorLoad(cnt:cnt+units-1)));

    
    choiceLoad1Day = abs(choiceLoad(cnt:cnt+units-1));
    cxtLoad1Day = abs(cxtLoad(cnt:cnt+units-1));
    colorLoad1Day = abs(colorLoad(cnt:cnt+units-1));
    
    for jj = 1:length(channelId)
        if choiceLoad1Day(jj) > 0
            plot(AP1Day(jj), depth1Day(jj), '.', 'markersize', choiceLoad1Day(jj).*400, 'color', 'b');
        end
    end
        
    cnt = cnt+units;
    
end
 

ylim([0 12])
set(gca, 'YDir','reverse')

title('choice')





%% 

cnt = 1;

figure; hold on

for ii = 1:length(Channels)
    units = length(Channels(ii).channelID);
    
    channelId = Channels(ii).channelID;
    
    depth1Day = depth(ii) - (32-channelId)./10;
    AP1Day = AP(ii) + rand(units,1).*0.4-0.2;
   
    
    choiceLoad1Day = abs(choiceLoad(cnt:cnt+units-1));
    cxtLoad1Day = abs(cxtLoad(cnt:cnt+units-1));
    colorLoad1Day = abs(colorLoad(cnt:cnt+units-1));
    
    for jj = 1:length(channelId)
        if cxtLoad1Day(jj) > 0
            plot(AP1Day(jj), depth1Day(jj), '.', 'markersize', cxtLoad1Day(jj).*400, 'color', 'k');
        end
    end
        
    cnt = cnt+units;
    
end
 
ylim([0 12])

set(gca, 'YDir','reverse')

title('cxt')


% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig5/', 'gradientCxt', '.eps']);

%% 


cnt = 1;

figure; hold on

for ii = 1:length(Channels)
    units = length(Channels(ii).channelID);
    
    channelId = Channels(ii).channelID;
    
    depth1Day = depth(ii) - (32-channelId)./10;
    AP1Day = AP(ii) + rand(units,1).*0.4-0.2;
   
    
    choiceLoad1Day = abs(choiceLoad(cnt:cnt+units-1));
    cxtLoad1Day = abs(cxtLoad(cnt:cnt+units-1));
    colorLoad1Day = abs(colorLoad(cnt:cnt+units-1));
    
    for jj = 1:length(channelId)
        if colorLoad1Day(jj) > 0
            plot(AP1Day(jj), depth1Day(jj), '.', 'markersize', colorLoad1Day(jj).*400, 'color', 'm');
        end
    end
        
    cnt = cnt+units;
    
end
 
ylim([0 12])

set(gca, 'YDir','reverse')

title('color')
