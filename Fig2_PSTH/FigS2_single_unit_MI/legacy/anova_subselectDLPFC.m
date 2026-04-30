% created by Tian on Sep 20th. Subselect DLPFC units and calculate anova
% results
clear
dlpfc = load('ESresultsDLPFC').results;
pmd = load('ESresultsPMD').results;

% results = load('/Users/tianwang/Documents/MATLAB/ChandLab/DLPFC_PMD/geometry/single_unit_mix_selectivity/ESresultsAll.mat').results;

results = dlpfc;

thres = 0.01;

p_all = [];
cnt = 1;
for id = 1:length(results)
    temp = results(id).anovaResults;
    for idx = 1:length(temp)
        p_all(:,:,cnt) = temp(idx).anova2R;
        ES_all(:,:,cnt) = temp(idx).effect_size;
        cnt = cnt+1;
    end
end




tLim = [150,400];

allTime = results(1).time;
select = allTime >= tLim(1) & allTime <= tLim(2);

p_all = p_all(:,select,:);

%% 
sigP = p_all < thres;

sigPer = (sum(sigP,3)./size(sigP,3));
real_sigPer = mean(sigPer,2)

figure
bar(real_sigPer)
hold on
%%
num_rand = 100;

subselect = zeros(3,num_rand);

for ii = 1:num_rand
    
    randSample = randsample(size(p_all,3),1686);
    
    sigP = p_all(:,:,randSample) < thres;
    
    sigPer = (sum(sigP,3)./size(sigP,3));
    
    subselect(:,ii) = mean(sigPer,2);
    
end

%%

a = mean(subselect,2);

b = std(subselect,[],2);


figure;
b_handle = bar(a);  % Create bar graph
hold on;
errorbar(1:length(a), a, b, 'k.', 'LineWidth', 1.5);  % Add error bars
hold off;