function [sigPer, mixRatio, sigP] = plotAnova(data, figHandle, tLim, ylimit)

% inputs: effect size structure 
% output: 
%     sigPer: percentage of significant values
%     mixRatio: ratio of units with more than 1 variable significant
%     sigP: each units anova significance results at each time point 
           

results = data;

t = results(1).time;
        
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

figHandle;

hold on
plot(t, sigPer(1,:), 'm')
plot(t, sigPer(2,:), 'c')
plot(t, sigPer(3,:), 'k')


% plot mixed selectivity
mixP = squeeze(sum(sigP,1) >= 2);
plot(t, sum(mixP,2)./size(sigP,3), 'color', "#D95319", 'linewidth', 2);


mixRatio = sum(mixP,2)./size(sigP,3);

xlim([tLim(1), tLim(end)])
ylim(ylimit)





end

