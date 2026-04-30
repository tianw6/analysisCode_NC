function [L, varargin] = drawRestrictedLines(xx,yMinMax, varargin)


lineStyle = '--';
textOffset = -20;
color = 'k';
assignopts(who,varargin);



if ~isempty(xx)
    
    if length(xx) > 1
        L = line([xx; xx], [repmat(yMinMax,[length(xx) 1])]','linestyle',lineStyle, 'color', color,'LineWidth',5);
        
    else
        L = line([xx xx],yMinMax,'color',color,'linestyle',lineStyle,'LineWidth',5);
    end
end




