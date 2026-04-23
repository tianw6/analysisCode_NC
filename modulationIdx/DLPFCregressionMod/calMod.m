function [modulation] = calMod(modC, taskVar)
    

    modulation = [];
    switch(taskVar)
        case{'cxt'}

            for ip = 1:length(modC)
                Midx = modC(ip).R2cxt;    
                modulation = [modulation, max(Midx, [], 2)'];
            end
        
        case{'color'}
            for ip = 1:length(modC)
                Midx = modC(ip).R2color;    
                modulation = [modulation, max(Midx, [], 2)'];
            end
        
        case{'dir'}
            for ip = 1:length(modC)
                Midx = modC(ip).R2dir;    
                modulation = [modulation, max(Midx, [], 2)'];
            end

    end
        

    
end

