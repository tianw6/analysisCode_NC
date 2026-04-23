function plotBar(meanV,stdV, options)

    % input: meanV (n categories by m groups.) 
    %               m bars are plotted together to form a category.
    %               There are n categories
    %        stdV (n categories by m groups)
    
    
    
    
%     b = bar(meanV);     
%     hold on;
% 
%     [ngroups, nbars] = size(meanV);   % ngroups = 3, nbars = 2
%     x = nan(ngroups, nbars);
% 
%     for i = 1:nbars
%         x(:,i) = b(i).XEndPoints;     % x-locations of bars
%     end
% 
%     % ---- Add error bars ----
%     errorbar(x, meanV, stdV, 'k', 'linestyle', 'none');
% 
%     hold off;
    
    

    if nargin < 3
        categorySpacing = 2; 
        barWidth   = 0.9;   % how "wide" each group is
    else
        categorySpacing = options.categorySpacing;
        barWidth = options.barWidth;
    end


    ngroups = size(meanV,1);
    x = (1:ngroups) * categorySpacing;   % category centers


    % ---- grouped bar chart with custom x and custom bar width ----
    b = bar(x, meanV, 'BarWidth', barWidth);

    hold on;

    % ---- extract bar centers for errorbars ----
    [~, nbars] = size(meanV);
    xb = nan(ngroups, nbars);
    for k = 1:nbars
        xb(:,k) = b(k).XEndPoints;
    end

    % ---- apply error bars ----
    errorbar(xb, meanV, stdV, 'k', 'linestyle', 'none');

    hold off;


end

