function [perm_acc] = permutation_test(t1,train_y, nPerm)


acc_perm = zeros(nPerm, 1);

for i = 1:nPerm
    y_perm = train_y(randperm(length(train_y)));  % shuffle labels

    % Train on permuted labels
    model_perm = fitclinear(t1, y_perm, 'learner', 'logistic', 'KFold', 5);
        
    
    error = kfoldLoss(model_perm);

    % Save accuracy
    perm_acc(i) = 1-error;
end



end

