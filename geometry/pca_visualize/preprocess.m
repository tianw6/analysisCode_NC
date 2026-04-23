function [processedFR] = preprocess(firingRatesAverage, removeAve)
    
    removeAve
    processedFR = [];

    for ii = 1:size(firingRatesAverage,1)
        temp = squeeze(firingRatesAverage(ii,:,:,:));

        %%%%%%%%%%%%% normalize the data (divided by sqrt of 99% ile of each unit separately. maybe add this 2 is too much)
        normFactor = prctile(temp(:), 99) + 0.01;
        temp = temp./sqrt(normFactor);
        
        % try another way of normalizing
%         normFactor = max(temp(:)) - min(temp(:)) + 0.0001;
%         temp = (temp - min(temp(:)))./normFactor;
        %%%%%%%%%%%%%

        average = nanmean(nanmean(temp));
        temp2 = [];
        for jj = 1:size(firingRatesAverage,2)
            for kk = 1:size(firingRatesAverage,3)
                
                if removeAve
                    temp2 = [temp2 squeeze(temp(jj, kk,:) - average)'];
                else
                    % no condition independent removal
                    temp2 = [temp2 squeeze(temp(jj, kk,:))'];
                end

            end
        end
        processedFR(ii,:) = temp2;
    end


end

