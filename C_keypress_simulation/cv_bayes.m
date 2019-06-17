function [best_performance,best_model] = cv_bayes(features,labels,folds)
%CV_BAYES Naive Bayes Classifier implementation with kfold cross validation
%   Detailed explanation goes here

disp('[CV_bayes] Starting Bayes classifier training...')

cv = cvpartition(length(labels),'kfold',folds);

best_performance = 0;
for jj = 1:folds
    
    % Train and Test set for this fold
    data_train = features(cv.training(jj),:);
    labels_train = labels(cv.training(jj),:);
    data_test = features(cv.test(jj),:);
    labels_test = labels(cv.test(jj),:);
    
    % Train Bayes classifier
    model = fitcnb(data_train,labels_train);
    
    % Test
    pred_labels_test = predict(model,data_test);
    
    % Performance ( Balanced Acc (one-against-all) )
    % b_acc = ( TP/P + TN/N ) * 0.5
    CM = confusionmat(labels_test,pred_labels_test);
    b_acc = zeros(4,1);
    % 0 vs (1&2&3)
    b_acc(1) = 0.5*( ( CM(1,1) / sum(CM(1,:)) ) + ( (CM(2,2)+CM(3,3)+CM(4,4)) / sum(sum(CM(2:4,:))) ));
    % 1 vs (0&2&3)
    b_acc(2) = 0.5*( ( CM(2,2) / sum(CM(2,:)) ) + ( (CM(1,1)+CM(3,3)+CM(4,4)) / sum(sum(CM([1 3 4],:))) ));
    % 2 vs (0&1&3)
    b_acc(3) = 0.5*( ( CM(3,3) / sum(CM(3,:)) ) + ( (CM(1,1)+CM(2,2)+CM(4,4)) / sum(sum(CM([1 2 4],:))) ));
    % 3 vs (0&1&2)
    b_acc(4) = 0.5*( ( CM(4,4) / sum(CM(4,:)) ) + ( (CM(1,1)+CM(2,2)+CM(3,3)) / sum(sum(CM([1 2 3],:))) ));
    
    performance = mean(b_acc);
    
    if performance > best_performance
        best_performance = performance;
        best_model = model;
        fprintf('[CV_bayes] Fold %02i | Performance = %.2f%% \n',jj,performance*100);
    end
    
end

disp('[CV_bayes] Ended bayes classifier.')

end
