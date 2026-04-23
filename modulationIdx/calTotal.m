function [totalCxt, totalCol, totalDir, totalUnits, MI] = calTotal(TiberiusT,TiberiusC)


    totalCol = 0;
    totalCxt = 0;
    totalDir = 0;
    totalUnits = 0;

    for ii = 1:length(TiberiusT)
        a = TiberiusT(ii).cxtUnits;
%         b = TiberiusC(ii).cxtUnits;
% 
%         cxt = union(a, b);
        cxt = a;
        color = TiberiusC(ii).colUnits;
        choice = TiberiusC(ii).dirUnits;

        totalCxt = totalCxt + length(cxt);
        totalCol = totalCol + length(color);
        totalDir = totalDir + length(choice);
        totalUnits = totalUnits + TiberiusC(ii).totalUnits;

    end

    col_per = totalCol/totalUnits;
    cxt_per = totalCxt/totalUnits;
    dir_per = totalDir/totalUnits;
    
    MI = [cxt_per, col_per, dir_per];

end

