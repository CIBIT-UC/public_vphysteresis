function [test_curve,test_curve_sem,cal_curve,cal_curve_sem,cal_curve_i,x1,x2,nEvents,labels,subjectNames] = manageKeypressData(keypressdata,direction,blockVols)
%manageKeypressData - Function to extract usefull information from the
%keypress data
%

% Define x vectors and manual labels
% 1 - Adaptation , 2 - Persistence, 3 - Null , 4 - Undefined
switch direction
    case 1
        direction = 'PC';
        x1 = linspace(0.975,0.025,20)';
        %         x1 = linspace(1,0,21)';
        x2 = linspace(1,0,11)';
        labels = reshape([1,1,1,1;2,3,2,3;2,4,4,4;4,2,1,4;3,3,4,3;4,2,4,2;3,4,2,2;1,1,1,1;1,3,1,3;1,1,1,1;3,2,1,1;4,4,4,4;1,1,1,1;1,1,1,1;4,3,2,3;3,3,1,1;4,4,1,4;1,1,1,1;1,4,1,4;4,1,4,2;3,3,3,3;1,1,1,1;1,1,1,1;3,1,1,1;1,3,2,3]',100,1);
    case 2
        direction = 'CP';
        x1 = linspace(0.025,0.975,20)';
        %         x1 = linspace(0,1,21)';
        x2 = linspace(0,1,11)';
        labels = reshape([2,2,2,2;2,2,2,2;4,4,4,4;4,4,2,4;4,4,4,4;2,2,2,2;3,4,3,3;2,2,2,2;4,4,4,4;2,2,2,3;2,3,3,2;4,4,4,3;3,2,2,2;2,2,2,2;4,4,1,3;4,3,3,4;3,3,3,4;2,2,2,2;4,3,3,3;1,4,2,1;3,4,3,4;2,2,2,2;2,2,2,2;2,4,3,2;2,2,2,2]',100,1);
end

% Usefull stuff
subjectNames = extractfield(keypressdata,'Name');
nSubjects = length(subjectNames);
runNames = {'RunH1','RunH2','RunH3','RunH4'};
nRuns = length(runNames);
nEvents = nSubjects*nRuns;

[subjectNames,sub_order]=sort(subjectNames);

% Initialise matrices
test_curve = zeros(nEvents,blockVols);
test_curve_sem = zeros(nEvents,blockVols);
cal_curve = zeros(nEvents,11);
cal_curve_sem = zeros(nEvents,11);

% Iterate on the subjects
idx = 1;
for ss = 1:nSubjects
    
    % Iterate on the runs
    for rr = 1:nRuns
        
        test_curve(idx,:) = keypressdata(sub_order(ss)).(direction).(runNames{rr}).mean;
        test_curve_sem(idx,:) = keypressdata(sub_order(ss)).(direction).(runNames{rr}).sem;
        
        % Depending on the direction, the curve might need to be temporally
        % inverted (case of Pattern -> Component)
        switch direction
            case 'PC' % P-C
                cal_curve(idx,:) = keypressdata(sub_order(ss)).Calibration.mean(end:-1:1);
                cal_curve_sem(idx,:) = keypressdata(sub_order(ss)).Calibration.sem(end:-1:1);
            case 'CP' % C-P
                cal_curve(idx,:) = keypressdata(sub_order(ss)).Calibration.mean;
                cal_curve_sem(idx,:) = keypressdata(sub_order(ss)).Calibration.sem;
        end
        
        idx = idx + 1;
    end % end run iteration
    
end % end subject iteration

% Manual Workaround for NaNs in calibration
switch direction
    case 'PC'
        cal_curve(41:44,4) = 1; cal_curve_sem(41:44,4) = 1; %workaround for NaNs
    case 'CP'
        cal_curve(41:44,8) = 1; cal_curve_sem(41:44,8) = 1; %workaround for NaNs
end

% Interpolate calibration runs
cal_curve_i = zeros(nEvents,blockVols);

for jj = 1:nEvents
    cal_curve_i(jj,:) = interp1(x2,cal_curve(jj,:),x1,'spline');
end

end
