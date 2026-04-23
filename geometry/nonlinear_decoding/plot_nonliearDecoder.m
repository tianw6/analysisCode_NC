
load('nonlinearAcc_vprobe.mat');
load('perm_accVprobe.mat');



binSize = 50;
stepSize = 5;


tStart = -1000;
tEnd = 1000; 
timeAxis = [tStart+binSize:stepSize:tEnd];
tSelected = timeAxis > 50 & timeAxis <= 300;

time = timeAxis(tSelected);


for ii = 1:length(accuracy)

perm_accChoice = perm_acc(ii).perm_accChoice;
choiceAcc =  accuracy(ii).choiceAcc;

prc99 = prctile(perm_accChoice,99,2)';
temp = choiceAcc(20:40);

realChoice(ii,:) = temp.*(temp > prc99);

% plot(time(20:40), realChoice)



%%

perm_accRLGR = perm_acc(ii).perm_accRLGR;
RLGR_acc =  accuracy(ii).RLGR_acc;

prc99 = prctile(perm_accRLGR,99,2)';
temp = RLGR_acc(20:40);

realRLGR(ii,:) = temp.*(temp > prc99);

% plot(time(20:40), realRLGR)

%%
perm_accRRGL = perm_acc(ii).perm_accRRGL;
RRGL_acc =  accuracy(ii).RRGL_acc;



prc99 = prctile(perm_accRRGL,99,2)';
temp = RRGL_acc(20:40);

realRRGL(ii,:) = temp.*(temp > prc99);

% plot(time(20:40), realRRGL)


end


%% 

realChoice(realChoice == 0) = NaN;
realRLGR(realRLGR == 0) = NaN;
realRRGL(realRRGL == 0) = NaN;


figure; hold on
plot(nanmean(realChoice, 1))
plot(nanmean(realRLGR, 1))
plot(nanmean(realRRGL, 1))


%% 

for ii = 1:size(realChoice,1)
    a = realChoice(ii,:)
    b = realRLGR(ii,:)
    c = realRRGL(ii,:)
    
    
    
end
    
