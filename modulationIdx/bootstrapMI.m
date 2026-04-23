function [totalCxtMI, totalColMI, totalDirMI] = bootstrapMI(cxtList, colList, dirList, numUnits)

    for ii = 1:500
       totalCxtMI(ii) = sum(randsample(cxtList, numUnits))./numUnits; 
       totalColMI(ii) = sum(randsample(colList, numUnits)) ./ numUnits; 
       totalDirMI(ii) = sum(randsample(dirList, numUnits))./numUnits; 
        
    end

    totalCxtMI = [prctile(totalCxtMI, 1), prctile(totalCxtMI,99)];
    totalColMI = [prctile(totalColMI, 1), prctile(totalColMI,99)];
    totalDirMI = [prctile(totalDirMI, 1), prctile(totalDirMI,99)];

end

