function [X, y, stdA] = plotmultiBar(dpcaV, loadName)


colorLoad = [];
choiceLoad = [];
cxtLoad = [];
for ii = 1:length(dpcaV)
    
    whichMarg = dpcaV(ii).whichMarg;
    V = dpcaV(ii).V;

    colorDim = find(whichMarg == 1);
    choiceDim = find(whichMarg == 2);
    cxtDim = find(whichMarg == 4);

    colorLoad = [colorLoad, abs(V(:, colorDim(1)))];
    choiceLoad  = [choiceLoad, abs(V(:, choiceDim(1)))];
    cxtLoad  = [cxtLoad, abs(V(:, cxtDim(1)))];

    
end

switch loadName
    case {'cxt'}
        dpcaLoad = cxtLoad;
    case {'choice'}
        dpcaLoad = choiceLoad;
    case {'color'}
        dpcaLoad = colorLoad;
end

   
a = dpcaLoad(1:100,:);
b = dpcaLoad(101:200,:);
c = dpcaLoad(201:300,:);
d = dpcaLoad(301:400,:);

A = [a(:), b(:), c(:), d(:)];

stdA = std(A)./sqrt(size(A,1));



y = mean(A);

X = categorical({'1','2','3','4'});
X = reordercats(X,{'1','2','3','4'});



end

