%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%------------------------- HYSTERESIS EXPERIMENT -------------------------%
%------------------------ Keypress Classification ------------------------%
%------------------------------ Version 1.0 ------------------------------%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  ______________________________________________________________________
% |                                                                      |%
% | Authors: Ricardo Martins, Alexandre Sayal, Joao Duarte,              |%
% |          Teresa Sousa, Gabriel Costa                                 |%
% |                                                                      |%
% |                        CIBIT ICNAS 2017-2019                         |%
% |______________________________________________________________________|%
%
% Version 1.0
% - Updated to share
%

%% Clear everything
clear, clc, close all

%% Choose Direction
% 1 for Pattern --> Component
% 2 for Component --> Pattern
direction = 1;

%% Initial Parameter Definition
transition = 0.6;     % P(t) value behond the previous experience effect should decrease
d_min = 0.30;         % Calibration curve inflection minimum value
d_max = 0.70;         % Calibration curve inflection maximum value

% --- Variables of interest
blockVols = 21;          % number of volumes per block
TR = 1.5;                % repetition time
nClasses = 4;            % number of classes
nReps = 4;               % number of repetitions with each set of parameters
nTrialsPerClass = 300;   % number of trials per class
nTotalTrials = nClasses * nTrialsPerClass; % total number of trials

% --- Build x(t) column vector
% Contains the fraction of dots moving downwards (which varies with the direction chosen)
% Define also the initial probability value
switch direction
    case 1
        X = linspace(1,0,blockVols)';
        init_P_coh = 1;
    case 2
        X = linspace(0,1,blockVols)';
        init_P_coh = 0;
end

% --- Build n(t) vector
% Containing the time and the indexes of the time points
N = zeros(blockVols,2);
N(:,1) = (0:TR:30)';
N(:,2) = 1:blockVols;

%% Initialise matrix to save accuracy
% We will use balanced accuracy (one against all)
% 4 classes, so 4 values of accuracy, plus the mean value
% Performing 10 repetitions
nRepetitions = 10;
B_ACC = zeros(nRepetitions,5); % save balaced accuracy
B_CM = zeros(nRepetitions,nClasses,nClasses); % save confusion matrices
B_PRED_LABEL = zeros(100,nRepetitions); % save predicted label

%% Initialise other stuff
% That does not need to be inside the repetitions iteration
nParam = 6;
cParam = {'main_effect', ...       % 1 -> Adaptation || 2 -> Persistence || 0 -> No effect
    'max_w', ...           % Maximum abs value of w (deviation calculated based on previous experience)
    'opposite_effect', ... % Flag to simulate opposite effect
    'max_w_ope', ...       % Maximum abs value of w related to the opposite effect
    'ope_sustain', ...     % Number of time points to sustain oposite effect
    'noise_power'};        % Maximum deviation value due to noise

s = RandStream('mlfg6331_64');
np = 0.2; % maximum noise power

bayes_folds = 10; % number of folds for cross-validation

%% Read Keypress data from experiment
input_folder = fullfile('...','Hysteresis_Paper','output_keypress');
load(fullfile(input_folder,'KeypressData_N25_Smooth2.mat'));
blockVols2 = 20;

[KP_Test,KP_Test_SEM,KP_Cal,KP_Cal_SEM,KP_Cal_I,...
    KP_x_Test,KP_x_Cal,nEvents,labels_test,subjectNames] = ...
    manageKeypressData(KeypressData,direction,blockVols2);

%% Major iteration on the number of repetitions
for rrr = 1:nRepetitions
    fprintf('------REPETITION %02i/%02i------\n',rrr,nRepetitions);
    
    %% CREATE PARAMETER SET FOR SIMULATION
    p_set = zeros(nTotalTrials,nParam);
    
    for jj = 1:nTotalTrials
        if jj < nTrialsPerClass+1 % Class 1 - Adaptation
            p_set(jj,:) = [ 1 0.05+(0.15-0.05)*rand 0 0 0 0.5*np];
        elseif jj >= nTrialsPerClass+1 && jj < nTrialsPerClass*2+1 % Class 2 - Persistence
            p_set(jj,:) = [ 2 0.1+(0.25-0.1)*rand 0 0 0 np];
        elseif jj >= nTrialsPerClass*2+1 && jj < nTrialsPerClass*3+1 % Class 3 - Null
            p_set(jj,:) = [ 0 0 0 0 0 0.5*np];
        elseif jj >= nTrialsPerClass*3+1 % Class 4 - Undefined
            p_set(jj,:) = [ 1 0.05+(0.10-0.05)*rand 1 0.1+(0.2-0.1)*rand randsample(s,[2 4 6],1) 0.5*np];
        end
    end
    
    %% CREATE RESPONSE CURVES
    P_Sim = zeros(nTotalTrials,blockVols);       % Simulated keypress curves
    P_Sim_SEM = zeros(nTotalTrials,blockVols);   % Simulated keypress curves SEM
    W_Sim = zeros(nTotalTrials,blockVols);       % Simulated W
    W_Sim_SEM = zeros(nTotalTrials,blockVols);   % Simulated W SEM
    C_Sim = zeros(nTotalTrials,blockVols);       % Simulated calibration curve
    
    P_Sim_Label = [ones(nTrialsPerClass,1) ;
        2*ones(nTrialsPerClass,1) ;
        3*ones(nTrialsPerClass,1) ;
        4*ones(nTrialsPerClass,1)];
    
    for jj = 1:nTotalTrials
        
        d = randsample(s,d_min:0.05:d_max,1); % Calibration curve inflection value
        
        P_aux = zeros(nReps,blockVols);
        W_aux = zeros(nReps,blockVols);
        
        for rr = 1:nReps
            [P_aux(rr,:),W_aux(rr,:),C_Sim(jj,:)] = ...
                simKeys(X, direction, p_set(jj,1), d, init_P_coh,p_set(jj,2), ...
                p_set(jj,4), transition, p_set(jj,3), p_set(jj,5), p_set(jj,6));
        end
        
        P_Sim(jj,:) = mean(P_aux,1);
        P_Sim_SEM(jj,:) = std(P_aux,1) / sqrt(nReps);
        
        W_Sim(jj,:) = mean(W_aux,1);
        W_Sim_SEM(jj,:) = std(W_aux,1) / sqrt(nReps);
        
    end
    
    %% FEATURE EXTRACTION - TRAIN SET
    norm_info = nan(2,1); %initialize normalisation parameters (mean and std) as nan
    [features,nFeatures,featNames,norm_info] = ...
        extractFeatures(P_Sim,C_Sim,X,nTotalTrials,direction,norm_info);
    
    %% FEATURE EXTRACTION - TEST SET
    % Normalisation parameters (mean and std) of the train set will be used
    [features_test,~,~,~,CAL_FIT_INDEX,TEST_FIT_INDEX] = extractFeatures(KP_Test,KP_Cal_I,KP_x_Test,nEvents,direction,norm_info);
    
    %% BAYES CLASSIFIER
    [best_performance_bayes,best_model_bayes] = cv_bayes(features,P_Sim_Label,bayes_folds);
    
    %% TEST WITH BAYES CLASSIFIER
    bayes_predicted_label = predict(best_model_bayes,features_test);
    
    B_PRED_LABEL(:,rrr) = bayes_predicted_label;
    
    %% CALCULATE BALANCED ACCURACY
    % Performance ( Balanced Acc (one-against-all) )
    % b_acc = ( TP/P + TN/N ) * 0.5
    CM = confusionmat(labels_test,bayes_predicted_label);
    B_CM(rrr,:,:) = CM;
    
    % 1 vs (2&3&4)
    B_ACC(rrr,1) = 0.5*( ( CM(1,1) / sum(CM(1,:)) ) + ( (CM(2,2)+CM(3,3)+CM(4,4)) / sum(sum(CM([2 3 4],:))) ));
    % 2 vs (1&3&4)
    B_ACC(rrr,2) = 0.5*( ( CM(2,2) / sum(CM(2,:)) ) + ( (CM(1,1)+CM(3,3)+CM(4,4)) / sum(sum(CM([1 3 4],:))) ));
    % 3 vs (1&2&4)
    B_ACC(rrr,3) = 0.5*( ( CM(3,3) / sum(CM(3,:)) ) + ( (CM(1,1)+CM(2,2)+CM(4,4)) / sum(sum(CM([1 2 4],:))) ));
    % 4 vs (1&2&3)
    B_ACC(rrr,4) = 0.5*( ( CM(4,4) / sum(CM(4,:)) ) + ( (CM(1,1)+CM(2,2)+CM(3,3)) / sum(sum(CM([1 2 3],:))) ));
    % Mean
    B_ACC(rrr,5) = mean(B_ACC(rrr,1:4));
    
    disp('----------------------------');
end

%% PLOT B_ACC
B_ACC_MEAN = 100*mean(B_ACC,1);
B_ACC_STD = 100*std(B_ACC,1);

TrialLabels = {'A VS All','P VS All','N VS All','Un VS All','Mean'};
clrMap = lines;

fig1 = figure('Name','Balanced Accuracy','Position',[100 100 500 500]);
for ii = 1:5
    errorbar(ii,B_ACC_MEAN(ii),B_ACC_STD(ii))
    hold on
    b = bar(ii,B_ACC_MEAN(ii),'FaceColor',clrMap(ii,:),'BarWidth',0.9);
    hold on
    text(ii,70,sprintf('%.1f',B_ACC_MEAN(ii)),'HorizontalAlignment','center')
    hold on
end
hold off

xticks(1:5)
xticklabels(TrialLabels)
ylim([0 100])
ylabel('Balanced Accuracy (%)')

%% Plot B_CM
B_CM_MEAN = round(squeeze(mean(B_CM,1)));
B_CM_STD = squeeze(std(B_CM,1));

%% Find winning (most common) predicted label
B_PRED_LABEL_W = mode(B_PRED_LABEL,2);
B_CM_MODE = confusionmat(labels_test,B_PRED_LABEL_W);
B_ACC_W = zeros(1,6);

% 1 vs (2&3&4)
B_ACC_W(1) = 0.5*( ( B_CM_MODE(1,1) / sum(B_CM_MODE(1,:)) ) + ( (B_CM_MODE(2,2)+B_CM_MODE(3,3)+B_CM_MODE(4,4)) / sum(sum(B_CM_MODE([2 3 4],:))) ));
% 2 vs (1&3&4)
B_ACC_W(2) = 0.5*( ( B_CM_MODE(2,2) / sum(B_CM_MODE(2,:)) ) + ( (B_CM_MODE(1,1)+B_CM_MODE(3,3)+B_CM_MODE(4,4)) / sum(sum(B_CM_MODE([1 3 4],:))) ));
% 3 vs (1&2&4)
B_ACC_W(3) = 0.5*( ( B_CM_MODE(3,3) / sum(B_CM_MODE(3,:)) ) + ( (B_CM_MODE(1,1)+B_CM_MODE(2,2)+B_CM_MODE(4,4)) / sum(sum(B_CM_MODE([1 2 4],:))) ));
% 4 vs (1&2&3)
B_ACC_W(4) = 0.5*( ( B_CM_MODE(4,4) / sum(B_CM_MODE(4,:)) ) + ( (B_CM_MODE(1,1)+B_CM_MODE(2,2)+B_CM_MODE(3,3)) / sum(sum(B_CM_MODE([1 2 3],:))) ));
% Mean
B_ACC_W(5) = mean(B_ACC_W(1:4));
B_ACC_W(6) = std(B_ACC_W(1:4));

%% Output information
% Output the transition value of the calibration and hyst curves
% This will be needed for the neuro imaging analysis
outputFolder = fullfile('...','Hysteresis_Paper','output_keypress_sim');
save([outputFolder 'Value50Info_DIR' num2str(direction) '.mat'],'CAL_FIT_INDEX','TEST_FIT_INDEX');

%% End
disp('Script Ended.')
