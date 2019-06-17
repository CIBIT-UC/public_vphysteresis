function [features,nFeatures,featNames,norm_info,CAL_FIT_INDEX,TEST_FIT_INDEX] = extractFeatures(test_curve,cal_curve_i,X_test,nEvents,direction,norm_info)
%EXTRACTFEATURES Function to extract features from simulated data
% This function extracts 2 features:
% 1) AreaUnderCurve difference between the calibration and test curves,
% around the calibration transition value (5 point window), divided by the
% total area under both curves
%   : trapz(calibration - test)
% 2) Value50 difference between the calibration and test curve
%   : value50 is a dots percentage value (x axis)
%
disp('[extractFeatures] Starting feature extraction...')

featNames = {'AUC Ratio A','Value50'};%,'AUC Ratio Total',,'AUC Ratio 1''Value50 Diff',,'Value50 Ratio'};
nFeatures = length(featNames);

features = zeros(nEvents,nFeatures);

% For debug, output the fits
CAL_FIT_INDEX = zeros(nEvents,1);
TEST_FIT_INDEX = zeros(nEvents,1);

% Iterate on the events
for jj = 1:nEvents

    % Find nearest point at y = 50
    switch direction
        case 1 % PC
            cal_value50_index = find(cal_curve_i(jj,:) <= 0.5);
            test_value50_index = find(test_curve(jj,:) <= 0.5);
        case 2 % CP
            cal_value50_index = find(cal_curve_i(jj,:) >= 0.5);
            test_value50_index = find(test_curve(jj,:) >= 0.5);
    end
    
    cal_value50_index = cal_value50_index(1);
    if test_value50_index(1) == 1
        test_value50_index = test_value50_index(2);
    else
        test_value50_index = test_value50_index(1);
    end
    
    CAL_FIT_INDEX(jj) = cal_value50_index;
    TEST_FIT_INDEX(jj) = test_value50_index;
    
    % Find interval of analysis around the calibration inflection point
    interv2 = cal_value50_index-2:cal_value50_index+2;
    if interv2(1)<=0
        interv2 = 1:5; disp('[extractFeatures] Adjusted pre.');
    elseif interv2(end)>length(X_test)
        interv2 = length(X_test)-4:length(X_test);disp('[extractFeatures] Adjusted pos.');
    end
    
    % ----- Calculate features ----- %        
    % AUC Ratio A
    features(jj,1) = (trapz(X_test(interv2),test_curve(jj,interv2))-trapz(X_test(interv2),cal_curve_i(jj,interv2))) / trapz(X_test(interv2),max([test_curve(jj,interv2) ; cal_curve_i(jj,interv2)]));
    
    % Value50 Diff
    features(jj,2) = test_value50_index - cal_value50_index;    
    % ------------------------------ %
    
end

% Normalize features to be between 0 and 1
if isnan(norm_info(1)) % not previously defined
    disp('[extractFeatures] Calculating normalization parameters...')
    norm_info = zeros(nFeatures,2); %mean and std
    for f = 1:nFeatures
        norm_info(f,1) = min(features(:,f));
        features(:,f) = features(:,f) - norm_info(f,1);
        norm_info(f,2) = max(features(:,f));
        features(:,f) = features(:,f) / norm_info(f,2);
    end
else % norm_info already obtained from the training set
    disp('[extractFeatures] Using external normalization parameters...')
    for f = 1:nFeatures
        features(:,f) = features(:,f) - norm_info(f,1);
        features(:,f) = features(:,f) / norm_info(f,2);
    end
end

disp('[extractFeatures] End of feature extraction.')

end
