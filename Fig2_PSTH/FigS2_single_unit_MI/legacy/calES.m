function [meanV,semV, raw] = calES(results, tLim)

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


allTime = results(1).time;
select = allTime >= tLim(1) & allTime <= tLim(2);

p_all = p_all(:,select,:);
ES_all = ES_all(:,select,:);

sigP = p_all < thres;

ES = sigP.* ES_all;


%%

ES(isnan(ES))=0;

% allES = squeeze(max(ES, [], 2));
% ES = squeeze(mean(ES, 2));

allES = [];
allES = squeeze(mean(ES,2));


%% 

aa = allES(1,:);
aa= aa(aa~=0);


% errorbar(mean(aa), (std(aa)./length(aa)))



bb = allES(2,:);
bb= bb(bb~=0);

cc = allES(3,:);
cc= cc(cc~=0);

% figure;
% errorbar([mean(aa), mean(bb), mean(cc)], [(std(aa)./sqrt(length(aa))), (std(bb)./sqrt(length(bb))), (std(cc)./sqrt(length(cc)))])
% hold on


meanV = [mean(aa), mean(bb), mean(cc)];
semV = [(std(aa)./sqrt(length(aa))), (std(bb)./sqrt(length(bb))), (std(cc)./sqrt(length(cc)))];

raw = {aa,bb,cc};

end

