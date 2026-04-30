function setLineColors(b,j,lw, varargin)
%
% linewidth = 1;
if j==1
    linestyle = '-';
else
    linestyle ='--';
end
assignopts(who, varargin);

Params = getParams;
D = floor(linspace(1,size(Params.posterColors,1),length(b)));
for k=1:length(b)
    set(b(k),'color',Params.posterColors(D(k),:), 'linewidth',lw, 'linestyle',linestyle);
end
set(gca,'visible','off','clipping','off');