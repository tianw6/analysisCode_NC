totalAcc = [];
parfor m=1:10
    fprintf('\n Repeat:',m);
    allAcc = [];
    
    area = 'pmd';
    type = 'mixe';
    dims = 1:10;
    
    trainFrac = 0.65;
    for k=1:length(allData)
        fprintf('%d.',k);
        currData = allData(k);
        
        beta = [];
        pValues = [];
        rsquared = [];
        switch(area)
            case 'pmd'
                origData = sqrt(currData.pmdX);
            case 'dlpfc'
                origData = sqrt(currData.dlpfcX);
        end
        
        % origData = currData.pmdX;
        choice = currData.choice;
        color = currData.color;
        
        % neuralData = neuralData - repmat(nanmean(neuralData),[size(neuralData,1) 1 1]);
        
        
        accV1 = [];
        cnt = 1;
        for nT=1:1:size(origData,3)
            neuralData = origData(:,:,nT);
            [~,projData] = pca(neuralData);
            
            if strcmp(type,'pure')
                trial1 = choice == 0;
                trial2 = choice == 1;
            else
                trial1 = color == 1 & choice == 0;
                trial2 = color == 0 & choice == 1;
            end
            
            redLeft = projData( trial1,dims);
            greenRight = projData(trial2,dims);
            
            nL = size(redLeft,1);
            nR = size(greenRight,1);
            
            redLeft = redLeft(randperm(nL),:,:);
            greenRight = greenRight(randperm(nR),:,:);
            
            n = min(nL,nR);
            
            
            TrainV = 1:ceil(trainFrac*n);
            TestV = setdiff(1:n,TrainV);
            testGrp = [ones(1,length(TestV)) 2*ones(1,length(TestV))]';
            
            
            
            trainData = [redLeft(TrainV,:); greenRight(TrainV,:)];
            trainGrp = [ones(1,length(TrainV)) 2*ones(1,length(TrainV))]';
            
            c = classify(...
                [redLeft(TestV,:); greenRight(TestV,:)],...
                trainData,trainGrp,'mahalanobis');
            
            accV1(cnt) = nanmean(c==testGrp);
            cnt = cnt + 1;
        end
        
        
        accV2 = [];
        cnt = 1;
        for nT=1:1:size(origData,3)
            neuralData = origData(:,:,nT);
            [~,projData] = pca(neuralData);
            
            if strcmp(type,'pure')
                trial1 =  choice == 0;
                trial2 =  choice == 1;
            else
                trial1 = color == 0 & choice == 1;
                trial2 = color == 1 & choice == 0;
            end
            
            redLeft = projData( trial1 ,dims);
            greenRight = projData(trial2,dims);
            
            
            nL = size(redLeft,1);
            nR = size(greenRight,1);
            
            redLeft = redLeft(randperm(nL),:,:);
            greenRight = greenRight(randperm(nR),:,:);
            
            
            
            n = min(nL,nR);
            
            
            TrainV = 1:ceil(trainFrac*n);
            TestV = setdiff(1:n,TrainV);
            testGrp = [ones(1,length(TestV)) 2*ones(1,length(TestV))]';
            
            
            
            trainData = [redLeft(TrainV,:); greenRight(TrainV,:)];
            trainGrp = [ones(1,length(TrainV)) 2*ones(1,length(TrainV))]';
            
            c = classify(...
                [redLeft(TestV,:); greenRight(TestV,:)],...
                trainData,trainGrp,'mahalanobis');
            
            accV2(cnt) = nanmean(c==testGrp);
            cnt = cnt + 1;
        end
        
        
        allAcc = [allAcc; smooth(0.5*(accV1 + accV2),1)'];
        
        
        
    end
    totalAcc(m,:,:) = allAcc;
   
end
%%
aveAcc = squeeze(nanmean(totalAcc,1));
x = currData.timeAxis(1:1:end);
y = nanmean(aveAcc);
yE = nanstd(aveAcc)./sqrt(size(aveAcc,1));
H = shadedErrorBar(x,y,yE);
set(H(1).edge,'linestyle','none');

set(gca,'tickdir','out');

g(1) = xline(0);
g(2) = yline(0.5);

set(g,'linestyle','--');
