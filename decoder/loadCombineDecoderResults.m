function [accT,accC, accM] = loadCombineDecoderResults(area, select)


switch area
    case 'DLPFC'
        TresultsTV = load(['./results/Tiberius/' select 'decodingAccTV.mat']).result;
        TresultsCV = load(['./results/Tiberius/' select 'decodingAccCV.mat']).result;
        TresultsMV = load(['./results/Tiberius/' select 'decodingAccMV.mat']).result;

        TresultsTN = load(['./results/Tiberius/' select 'decodingAccTN.mat']).result;
        TresultsCN = load(['./results/Tiberius/' select 'decodingAccCN.mat']).result;
        TresultsMN = load(['./results/Tiberius/' select 'decodingAccMN.mat']).result;

        % vinnie
        VresultsTV = load(['./results/Vinnie/' select 'decodingAccTV.mat']).result;
        VresultsCV = load(['./results/Vinnie/' select 'decodingAccCV.mat']).result;
        VresultsMV = load(['./results/Vinnie/' select 'decodingAccMV.mat']).result;

        VresultsTN = load(['./results/Vinnie/' select 'decodingAccTN.mat']).result;
        VresultsCN = load(['./results/Vinnie/' select 'decodingAccCN.mat']).result;
        VresultsMN = load(['./results/Vinnie/' select 'decodingAccMN.mat']).result;


        accT = [TresultsTV.accuracy; TresultsTN.accuracy; VresultsTV.accuracy; VresultsTN.accuracy];
        accC = [TresultsCV.accuracy; TresultsCN.accuracy; VresultsCV.accuracy; VresultsCN.accuracy];
        accM = [TresultsMV.accuracy; TresultsMN.accuracy; VresultsMV.accuracy; VresultsMN.accuracy];
        
    
    case 'PMD'
        TresultsTV = load(['./results/Tiberius/PMD/' select 'decodingAccTV.mat']).result;
        TresultsCV = load(['./results/Tiberius/PMD/' select 'decodingAccCV.mat']).result;
        TresultsMV = load(['./results/Tiberius/PMD/' select 'decodingAccMV.mat']).result;

        TresultsTN = load(['./results/Tiberius/PMD/' select 'decodingAccTN.mat']).result;
        TresultsCN = load(['./results/Tiberius/PMD/' select 'decodingAccCN.mat']).result;
        TresultsMN = load(['./results/Tiberius/PMD/' select 'decodingAccMN.mat']).result;

        % olaf
        OresultsTV = load(['./results/Olaf/' select 'decodingAccTV.mat']).result;
        OresultsCV = load(['./results/Olaf/' select 'decodingAccCV.mat']).result;
        OresultsMV = load(['./results/Olaf/' select 'decodingAccMV.mat']).result;


        accT = [TresultsTV.accuracy; TresultsTN.accuracy; OresultsTV.accuracy];
        accC = [TresultsCV.accuracy; TresultsCN.accuracy; OresultsCV.accuracy];
        accM = [TresultsMV.accuracy; TresultsMN.accuracy; OresultsMV.accuracy];



end

