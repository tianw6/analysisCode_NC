
tic
nPerm = 100;

perm_acc = struct;

for dayn = 1:1%length(allBinFR)
    
    %% permutation test (choice)

    trials = allBinFR(dayn).trials;
    taskLabels = allBinFR(dayn).taskLabels;
    train_y = (taskLabels == 0 | taskLabels == 2)';

    parfor t = 20:40


        t1 = trials(:,:,t);

        perm_accChoice(t-19, :) = permutation_test(t1, train_y, nPerm);

        % acc_perm = zeros(nPerm, 1);
        % 
        % for i = 1:nPerm
        %     y_perm = train_y(randperm(length(train_y)));  % shuffle labels
        % 
        %     % Train on permuted labels
        %     model_perm = fitclinear(t1, y_perm, 'learner', 'logistic', 'KFold', 5);
        %         
        %     
        %     error = kfoldLoss(model_perm);
        % 
        %     % Save accuracy
        %     perm_acc(i) = 1-error;
        % end


    end
    toc


    %% permutation test (RLGR)


    % use 1st bin as example 
    trials = allBinFR(dayn).trials;
    taskLabels = allBinFR(dayn).taskLabels;

    select = (taskLabels == 0 | taskLabels == 3);

    trials = trials(select,:,:);
    train_y = taskLabels(select)';

    parfor t = 20:40


        t1 = trials(:,:,t);

        perm_accRLGR(t-19, :) = permutation_test(t1, train_y, nPerm);

        % acc_perm = zeros(nPerm, 1);
        % 
        % for i = 1:nPerm
        %     y_perm = train_y(randperm(length(train_y)));  % shuffle labels
        % 
        %     % Train on permuted labels
        %     model_perm = fitclinear(t1, y_perm, 'learner', 'logistic', 'KFold', 5);
        %         
        %     
        %     error = kfoldLoss(model_perm);
        % 
        %     % Save accuracy
        %     perm_acc(i) = 1-error;
        % end


    end


    %% permutation test (RRGL)


    % use 1st bin as example 
    trials = allBinFR(dayn).trials;
    taskLabels = allBinFR(dayn).taskLabels;


    select = (taskLabels == 1 | taskLabels == 2);

    trials = trials(select,:,:);
    train_y = taskLabels(select)';

    parfor t = 20:40


        t1 = trials(:,:,t);

        perm_accRRGL(t-19, :) = permutation_test(t1, train_y, nPerm);

        % acc_perm = zeros(nPerm, 1);
        % 
        % for i = 1:nPerm
        %     y_perm = train_y(randperm(length(train_y)));  % shuffle labels
        % 
        %     % Train on permuted labels
        %     model_perm = fitclinear(t1, y_perm, 'learner', 'logistic', 'KFold', 5);
        %         
        %     
        %     error = kfoldLoss(model_perm);
        % 
        %     % Save accuracy
        %     perm_acc(i) = 1-error;
        % end


    end

    perm_acc(dayn).perm_accChoice = perm_accChoice;
    perm_acc(dayn).perm_accRLGR = perm_accRLGR;
    perm_acc(dayn).perm_accRRGL = perm_accRRGL;



    fprintf('dayn: %d finished\n', dayn)

end

save('~/Desktop/perm_acc.mat', 'perm_acc');

%% 
