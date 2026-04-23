addpath('../../utils/')

% this code plot each stimulus decoder results on color and choice, plus
% correct and wrong. This code uses results from decodeCtestW3.m and
% decode_variables_stimulus.m
acc2easiest = load('choice_colorAcc_2easiest.mat').accuracy;
accCW = load('projectWonC_accuracy.mat').accuracy;

time = -50:5:500;


choiceAcc = [];
colorAcc = [];

for ip = 1:length(acc2easiest)
    
    choiceAcc(:,1,ip) = acc2easiest(ip).choiceAcc(:,1);
    choiceAcc(:,2,ip) = acc2easiest(ip).choiceAcc(:,2);
    choiceAcc(:,3,ip) = accCW(ip).choiceAccC;
    choiceAcc(:,4,ip) = accCW(ip).choiceAccW;

    
    
    
    colorAcc(:,1,ip) = acc2easiest(ip).colorAcc(:,1);
    colorAcc(:,2,ip) = acc2easiest(ip).colorAcc(:,2);
    colorAcc(:,3,ip) = accCW(ip).colorAccC;
    colorAcc(:,4,ip) = accCW(ip).colorAccW;
      
    
end




%% plot choice 
a = figure('Position', [10 10 900 500]);

options.handle = a;
options.error = 'sem';
options.alpha      = 0.7;
options.line_width = 2;
options.x_axis = time;

options.color_area = [40 160 120]./255;    % green theme
options.color_line = [6 160 80]./255;
% plot_areaerrorbar(squeeze(choiceAcc(:,1,:))', options)
% 
% options.alpha      = 0.4;
% plot_areaerrorbar(squeeze(choiceAcc(:,2,:))', options)
% 
options.alpha      = 0.2;
plot_areaerrorbar(squeeze(choiceAcc(:,3,:))', options)


options.color_area = [221 50 150]./255;    % red theme
options.color_line = [221 29 121]./255;
plot_areaerrorbar(squeeze(choiceAcc(:,4,:))', options)

ylim([0.45 1])
xlim([time(1), time(end)])

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig4/', 'choiceDecoder_CW', '.eps']);


%% plot color 
a = figure('Position', [10 10 900 500]);

options.handle = a;
options.error = 'sem';
options.alpha      = 0.7;
options.line_width = 2;
options.x_axis = time;

options.color_area = [40 160 120]./255;    % green theme
options.color_line = [6 160 80]./255;
% plot_areaerrorbar(squeeze(colorAcc(:,1,:))', options)

% options.alpha      = 0.4;
% plot_areaerrorbar(squeeze(colorAcc(:,2,:))', options)
% 
options.alpha      = 0.2;
plot_areaerrorbar(squeeze(colorAcc(:,3,:))', options)


options.color_area = [221 50 150]./255;    % red theme
options.color_line = [221 29 121]./255;
plot_areaerrorbar(squeeze(colorAcc(:,4,:))', options)

ylim([0.45 0.75])
xlim([time(1), time(end)])

% print('-painters','-depsc',['~/Documents/chandlab/paperFigures/Fig4/', 'colorDecoder_CW', '.eps']);


%% statistical test of color and choice which shows up first

result = [];
for jj = 1:3
    for t = 1:size(choiceAcc,1)
        choiceAcc1 = squeeze(choiceAcc(t,jj,:));
        colorAcc1 = squeeze(colorAcc(t,jj,:));
        
        result(t, jj) = signrank(colorAcc1, choiceAcc1, 'tail', 'right');
        
    end
end


figure; hold on 

plot(time, result(:,3))

plot(time, (result(:,3) < 0.05), '*', 'markersize', 5)

%% color anova test [100,300]

tt = time >= 100 & time <= 300;

colorAcc1 = squeeze(mean(colorAcc(tt,1:3,:),1));
choiceAcc1 = squeeze(mean(choiceAcc(tt,1:3,:),1));


[p, tbl, stats] = anova1(colorAcc1');


%% color vs choice t test, [100,200]
result = [];
tt = time >= 100 & time <= 200;

colorAcc1 = squeeze(mean(colorAcc(tt,:,:),1));
choiceAcc1 = squeeze(mean(choiceAcc(tt,:,:),1));

for jj = 1:4
    [h, result(jj)] = ttest(colorAcc1(jj,:), choiceAcc1(jj,:), 'tail', 'right');
    
end

%% color vs choice hardest [200,500]
result = [];
tt = time >= 200 & time <= 500;

colorAcc1 = squeeze(mean(colorAcc(tt,:,:),1));
choiceAcc1 = squeeze(mean(choiceAcc(tt,:,:),1));

[h, p, ci, stat] = ttest(colorAcc1(3,:), colorAcc1(4,:))




