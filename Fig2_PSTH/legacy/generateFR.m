function [rFR_LR, rFR_RR, rFR_LG, rFR_RG] = generateFR(currTrials, align, chosenChannel, unitV, tPre, tPost, sessionLabel)

    pre= -1.6;
    preV = abs(pre);
    post = 1.6-0.001;
    t = [pre:0.001:post];
    tIdx = (t > tPre & t < tPost);

    
    
    n = length(pre:0.001:post);
    
    g = normpdf([-0.1:0.001:0.1],0,0.025);

    rLR = zeros(1,n);
    rRR = zeros(1,n);
    rLG = zeros(1,n);
    rRG = zeros(1,n);

    rFR_LR = [];
    rFR_RR = [];
    rFR_LG = [];
    rFR_RG = [];

    lrcnt = 1;
    rrcnt = 1;
    lgcnt = 1;
    rgcnt = 1;

    for f=1:length(currTrials)
        if ~isempty(currTrials(f).spikes)

            D = currTrials(f).contBehavior.PhotoBox;
            cbTime = currTrials(f).contBehavior.t - currTrials(f).events.CheckerboardDrawnTime;
            pBoxOn = find(D(cbTime > 0) > 1,1,'first');

            c = currTrials(f).spikes.channelId;
            u = currTrials(f).spikes.unit;

            if unitV >= 0
                iV = c == chosenChannel & u == unitV;
            else
                iV = c == chosenChannel;
            end

            
            if (strcmp(align, 'move') == 1)
                % align to movement onset
                currSpikes = [currTrials(f).spikes.xPCtimeStamp(iV) - (currTrials(f).events.CheckerboardDrawnTime+pBoxOn + currTrials(f).performance.RT)]./1000;
            elseif (strcmp(align, 'check') == 1)
                % align to checkerboard onset
                currSpikes = [currTrials(f).spikes.xPCtimeStamp(iV) - (currTrials(f).events.CheckerboardDrawnTime+pBoxOn )]./1000;
            elseif (strcmp(align, 'targets') == 1)
                % align to target onset
                currSpikes = [currTrials(f).spikes.xPCtimeStamp(iV) - (currTrials(f).events.TargetsDrawnTime )]./1000;
            end

            delay = currTrials(f).events.CheckerboardDrawnTime - currTrials(f).events.TargetsDrawnTime;


            currIdx = currSpikes > pre & currSpikes < post;
            if ~isempty(currSpikes(currIdx))
                if strcmp(currTrials(f).performance.ChosenSide,'left')==1 && strcmp(currTrials(f).performance.ChosenColor,'red')==1

                    rLR(lrcnt,floor(1000*currSpikes(currIdx))+preV*1000) = 1;
                    rFR_LR(lrcnt,:) = conv(rLR(lrcnt,:),g,'same');
                    lrcnt = lrcnt + 1;

                end

                if strcmp(currTrials(f).performance.ChosenSide,'right')==1 && strcmp(currTrials(f).performance.ChosenColor,'red')==1

                    rRR(rrcnt,floor(1000*currSpikes(currIdx))+preV*1000) = 1;
                    rFR_RR(rrcnt,:) = conv(rRR(rrcnt,:),g,'same');
                    rrcnt = rrcnt + 1;

                end


                 if strcmp(currTrials(f).performance.ChosenSide,'left')==1 && strcmp(currTrials(f).performance.ChosenColor,'green')==1

                    rLG(lgcnt,floor(1000*currSpikes(currIdx))+preV*1000) = 1;
                    rFR_LG(lgcnt,:) = conv(rLG(lgcnt,:),g,'same');
                    lgcnt = lgcnt + 1;

                end

                if strcmp(currTrials(f).performance.ChosenSide,'right')==1 && strcmp(currTrials(f).performance.ChosenColor,'green')==1

                    rRG(rgcnt,floor(1000*currSpikes(currIdx))+preV*1000) = 1;
                    rFR_RG(rgcnt,:) = conv(rRG(rgcnt,:),g,'same');
                    rgcnt = rgcnt + 1;

                end
            else

            end

        else

        end
    end



    alpha = 0.3;

    data = rFR_RR(:,tIdx);
    PSTH_mean = nanmean(data);
    PSTH_sem = std(data)./sqrt(size(data,1));
    patch = fill([t(tIdx) fliplr(t(tIdx))] , [PSTH_mean+PSTH_sem fliplr(PSTH_mean-PSTH_sem)], [0.4 0 0.2]);
    set(patch, 'edgecolor', 'none', 'FaceAlpha', alpha );
    hold on;

    data = rFR_LR(:,tIdx);
    PSTH_mean = nanmean(data);
    PSTH_sem = std(data)./sqrt(size(data,1));
    patch = fill([t(tIdx) fliplr(t(tIdx))] , [PSTH_mean+PSTH_sem fliplr(PSTH_mean-PSTH_sem)], [ 0.8 0 0]);
    set(patch, 'edgecolor', 'none', 'FaceAlpha', alpha );
    hold on;

    data = rFR_RG(:,tIdx);
    PSTH_mean = nanmean(data);
    PSTH_sem = std(data)./sqrt(size(data,1));
    patch = fill([t(tIdx) fliplr(t(tIdx))] , [PSTH_mean+PSTH_sem fliplr(PSTH_mean-PSTH_sem)], [ 0 0.4 0.2]);
    set(patch, 'edgecolor', 'none', 'FaceAlpha', alpha );
    hold on;

    data = rFR_LG(:,tIdx);
    PSTH_mean = nanmean(data);
    PSTH_sem = std(data)./sqrt(size(data,1));
    patch = fill([t(tIdx) fliplr(t(tIdx))] , [PSTH_mean+PSTH_sem fliplr(PSTH_mean-PSTH_sem)], [ 0.0 0.8 0.2]);
    set(patch, 'edgecolor', 'none', 'FaceAlpha', alpha );
    hold on;

    % mean psths
    plot(t(tIdx), nanmean(rFR_RR(:,tIdx)),'--','color',[0.4 0 0.2], 'LineWidth', 2)
    hold on
    plot(t(tIdx), nanmean(rFR_LR(:,tIdx)),'-','color',[ 0.8 0 0], 'LineWidth', 2);
    hold on
    plot(t(tIdx), nanmean(rFR_RG(:,tIdx)),'--','color',[0 0.4 0.2], 'LineWidth', 2)
    hold on
    plot(t(tIdx), nanmean(rFR_LG(:,tIdx)),'-','color',[ 0.0 0.8 0.2], 'LineWidth', 2);
    hold on

    % aligned
    xline(0, 'k--', 'linewidth', 1)
    %legend('Right Red', 'Left Red', 'Right Green' ,'Left Green', '', 'Location', 'southeast')
    title(sessionLabel, 'fontsize', 20)
    set(gcf, 'Color', 'w','renderer','Painters')
    set(gca,'tickdir','out');
    box off;
    %axis on
    axis tight
    hold on;


    xlim([tPre, tPost])
    
    

end

