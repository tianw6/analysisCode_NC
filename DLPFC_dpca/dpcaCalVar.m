function dpcaVar = dpcaCalVar(data,combinedParams)

    [W,V,whichMarg] = dpca(data, 30, ...
        'combinedParams', combinedParams);
    explVar = dpca_explainedVariance(data, W, V, ...
        'combinedParams', combinedParams);
    dpcaVar = explVar.totalMarginalizedVar / explVar.totalVar * 100;


end

