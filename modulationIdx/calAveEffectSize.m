function [aveEffectSize] = calAveEffectSize(TiberiusT,TiberiusC)

% aveEffectSize = struct;
% 
%     for ii = 1:length(TiberiusT)
%         a = TiberiusT(ii).cxtModulation;
%         b = TiberiusC(ii).cxtModulation;
% 
%         cxtTE = TiberiusT(ii).cxtEffectSize;
%         cxtCE = TiberiusC(ii).cxtEffectSize;
% 
%         cxt = [a,b];
%         cxtE = [cxtTE cxtCE];
% 
%         validCxtE = cxtE.*cxt;
%         aveEffectSize(ii).aveCxtEffectSize = (sum(validCxtE,2)./sum(cxt,2))';
% 
% 
% 
%         color = TiberiusC(ii).colModulation;
%         colorE = TiberiusC(ii).colEffectSize;
%         validColE = color.*colorE;
%         aveEffectSize(ii).aveColEffectSize = (sum(validColE,2)./sum(color,2))';
% 
% 
% 
%         choice = TiberiusC(ii).dirModulation;
%         choiceE = TiberiusC(ii).dirEffectSize;
%         validDirE = choice.*choiceE;
%         aveEffectSize(ii).aveDirEffectSize = (sum(validDirE,2)./sum(choice,2))';
% 
%     end



aveEffectSize = struct;

for ii = 1:length(TiberiusT)

    cxt = TiberiusC(ii).cxtModulation;
    cxtE = TiberiusC(ii).cxtEffectSize;

    aveEffectSize(ii).aveCxtEffectSize = (nanmean(cxtE,2).*sum(cxt,2))';



    color = TiberiusC(ii).colModulation;
    colorE = TiberiusC(ii).colEffectSize;
    aveEffectSize(ii).aveColEffectSize = (nanmean(colorE,2)./sum(color,2))';



    choice = TiberiusC(ii).dirModulation;
    choiceE = TiberiusC(ii).dirEffectSize;
    aveEffectSize(ii).aveDirEffectSize = (nanmean(choiceE,2)./sum(choice,2))';

end

end

