%%%%%%%%%%%%%%%%%%%%%%%% 
% This code generates Fig1f-g

%% Fig1f: plot snipset of recodings
load("../../analysisData_NC/Fig1/0821snip.mat");
figure('units','normalized','outerposition',[0 1 1 1])
hold on
for ii = 1:size(data,1)
    plot(data(ii,1:4:end)*1.5 + (ii-1).*100, 'color',[0 0.0 0.6 0.7], 'LineWidth',0.25);
end

sgtitle('Fig1F: snip of a segment of neuropixel recording')

set(gca,'visible','off')

%% Fig1g: plot LFP spectrolaminar profile

load('relpow1.mat');
figure('Position', [1000,1000,800,3000]); 
imagesc(relpow1)
colorbar
title('Fig1F: spectrolaminar analysis of one recording session')

%% Fig1g: plot waveforms: modulated units are highlighted; 
load('wfInfo0821.mat')

modUnits = wfInfo0821.modUnits;
allCluId = wfInfo0821.allCluId;
waveform = wfInfo0821.waveform;
depth = wfInfo0821.depth; 


% normalize waveforms
normWaveform = normalize(waveform, 2);

[M, imax] = max(waveform, [], 2);
[m, imin] = min(waveform, [], 2);

% find negative and positive waveforms
negativeWaveform = abs(m) > abs(M);

% specify width scale and height of waveforms 
xScale = 0.03;
yAmp = 15;

figure('Position', [100,2000,400,3000]); hold on
for ip = 1:size(waveform,1)

    xPos = (rand-0.5).*20 + (1:size(waveform,2)).*xScale;
    if negativeWaveform(ip) == 1

        if(ismember(allCluId(ip), modUnits) )
            plot(xPos, (normWaveform(ip,:).*yAmp + depth(ip)), 'Color',[0.9,0,0.7,0.9],'LineWidth',2)
        else
            plot(xPos, (normWaveform(ip,:).*yAmp + depth(ip)), 'Color',[0.9,0,0.7,0.3])
            
        end

    else

        if(ismember(allCluId(ip), modUnits) )
            plot(xPos, normWaveform(ip,:).*yAmp + depth(ip), 'color', 'b','LineWidth',2)
        else
            plot(xPos, normWaveform(ip,:).*yAmp + depth(ip), 'Color',[0,0,1,0.3])
        end

    end
end
    
ylim([-100, 8000])
yticks([linspace(-100,max(yticks),3)])
yticklabels({'0','3840','7680'})
set(gca, 'XTickLabel', {[]}, 'tickDir', 'out')

title('Fig1F: waveforms')
