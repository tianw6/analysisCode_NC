function [modCxt, modColor, modDir, err] = calModAll(modT,modC)

CI = 1.96;
%% context 

modCxt1 = calMod(modC, 'cxt');
modCxt2 = calMod(modT, 'cxt');
modCxt = max(modCxt1, modCxt2);
modCxt = modCxt(~isnan(modCxt));



%% direction  
modDir = calMod(modC, 'dir');
modDir = modDir(~isnan(modDir));


%% color

modColor = calMod(modC, 'color');
modColor = modColor(~isnan(modColor));


err = CI.*[std(modCxt)/sqrt(length(modCxt)) std(modColor)/sqrt(length(modColor)) std(modDir)/sqrt(length(modDir))];

end

