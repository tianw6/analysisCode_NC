function [sigP, cnt] = plotArea(results)


binSize = 50;
stepSize = 20;
tStart = -1000;
tEnd = 1000;  
timeAxis = [tStart+binSize:stepSize:tEnd];
tSelected = timeAxis > 50 & timeAxis <= 500;
        
        
        
t = timeAxis(tSelected);
thres = 0.01;

p_all = [];
cnt = 1;
for id = 1:length(results)
    temp = results(id).anovaResults;
    for idx = 1:length(temp)
        p_all(:,:,cnt) = temp(idx).anova2R;
        cnt = cnt+1;
    end
end


sigP = p_all < thres;

sigPer = (sum(sigP,3)./size(sigP,3));

hold on
% plot context
plot(t, sigPer(3,:), 'k')
% plot color
plot(t, sigPer(1,:), 'm')
% plot choice
plot(t, sigPer(2,:), 'c-')

xlim([t(1), t(end)])
%%

%figure;
mixP = squeeze(sum(sigP,1) > 1);
% plot mixed selectivity
plot(t, sum(mixP,2)./size(sigP,3), 'color', "#D95319", 'linewidth', 2);


legend('cxt', 'col', 'choice', 'mixed')
end

