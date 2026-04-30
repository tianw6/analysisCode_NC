function [accuracy] = binaryDecode(trials,train_y)

    for t = 1:size(trials,3)
        t1 = squeeze(trials(:,:,t));


    %     md1 = fitcsvm(t1, train_y,  'KFold', 5, 'KernelFunction','linear');
        md1 = fitclinear(t1, train_y, 'learner', 'logistic', 'KFold', 5);


        error = kfoldLoss(md1);
        accuracy(t) = 1 - error;
        
%         fprintf('accuracy: %.2f\n', accuracy);

%         fprintf('time: %d, accuracy: %0f\n', time(t), accuracy);
%         fprintf('\n')    
    end


end

