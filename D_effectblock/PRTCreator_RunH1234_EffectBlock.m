%% Clear everything
clear, clc;

%% I/O Folders
outputFolder = fullfile('...','ICNAS_VisualPerception','Hysteresis_Paper','PRTs_EffectBlock');
if ~exist(outputFolder,'dir')
    mkdir(outputFolder);
end

% Load value50 information
inputFolder = fullfile('...','ICNAS_VisualPerception','Hysteresis_Paper','output_keypress_sim');

DIR1 = load(fullfile(inputFolder,'Value50Info_DIR1.mat')); % PC Info
DIR2 = load(fullfile(inputFolder,'Value50Info_DIR2.mat')); % CP Info

% Load experiment data
subjectsList = {'TestSubject01','TestSubject02'};
nSubjects = length(subjectsList);
nRuns = 4;

%% PRT Parameters
PRTParameters = struct();

PRTParameters.FileVersion = 2;
PRTParameters.Resolution = 'Volumes';
PRTParameters.ExperimentName = 'VisualPerception_Hysteresis';
PRTParameters.BackgroundColor = [0 0 0];
PRTParameters.TextColor = [255 255 255];
PRTParameters.TimeCourseColor = [1 1 1];
PRTParameters.TimeCourseThick = 3;
PRTParameters.ReferenceFuncColor = [0 0 80];
PRTParameters.ReferenceFuncThick = 2;

condNames = {'Static','Patt_Comp_1','Comp_Patt_1','Patt_Comp_2','Comp_Patt_2','Patt_Comp_3','Comp_Patt_3','Discard'};

blockColor = [190 190 190 ; 150 210 240 ; 150 130 160 ; 170 210 240 ; 170 130 160 ; 170 150 240 ; 100 130 160 ; 130 130 130 ];

PRTParameters.nCond = length(condNames);

blockDuration = zeros(nSubjects*nRuns,PRTParameters.nCond);

%% Sequences
SEQ = [8 1 2 4 6 1 3 5 7 1 2 4 6 1 3 5 7 1 3 5 7 1 2 4 6 1 3 5 7 1 2 4 6 1 8 ; % Run 1
    8 1 2 4 6 1 3 5 7 1 3 5 7 1 2 4 6 1 2 4 6 1 3 5 7 1 3 5 7 1 2 4 6 1 8 ; % Run 2
    8 1 3 5 7 1 2 4 6 1 3 5 7 1 2 4 6 1 2 4 6 1 3 5 7 1 2 4 6 1 3 5 7 1 8 ; % Run 3
    8 1 3 5 7 1 2 4 6 1 2 4 6 1 3 5 7 1 3 5 7 1 2 4 6 1 3 5 7 1 2 4 6 1 8]; % Run 4

SEQNames = {'Eff_RunH1','Eff_RunH2','Eff_RunH3','Eff_RunH4'};

%% Retrieve block duration per subject
effect_block_vols = 5;

idx = 1;

for ss = 1:nSubjects
    
    subjectName = subjectsList{ss};
    
    % Iteration on the runs
    for rr = 1:nRuns
        
        % Watch out for the -1 (experimental!!!)
        trans_pc = DIR1.TEST_FIT_INDEX(idx) - 1;
        trans_cp = DIR2.TEST_FIT_INDEX(idx) - 1;
        
        % Check points
        if(trans_pc <= effect_block_vols)
            trans_pc = effect_block_vols+1;
            fprintf('!! Adjusted (+) trans PC S%i R%i !!\n',ss,rr);
        end
        if(trans_cp <= effect_block_vols)
            trans_cp = effect_block_vols+1;
            fprintf('!! Adjusted (+) trans CP S%i R%i !!\n',ss,rr);
        end
        if(trans_pc > 20)
            trans_pc = 20;
            fprintf('!! Adjusted (-) trans PC S%i R%i !!\n',ss,rr);
        end
        if(trans_cp > 20)
            trans_cp = 20;
            fprintf('!! Adjusted (-) trans CP S%i R%i !!\n',ss,rr);
        end
        
        % Retrieve durations per subject and run
        blockDuration(idx,:) = [10            %Static
            trans_pc - effect_block_vols      %Patt_Comp_1
            trans_cp - effect_block_vols      %Comp_Patt_1
            effect_block_vols                 %Patt_Comp_2
            effect_block_vols                 %Comp_Patt_2
            21 - trans_pc                     %Patt_Comp_3
            21 - trans_cp                     %Comp_Patt_3
            4];                               %Discard
        
        % Check points
        assert(sum(blockDuration(idx,[2 4 6]))==21);
        assert(sum(blockDuration(idx,[3 5 7]))==21);
        
        PRTConditions = struct();
        
        for c = 1:PRTParameters.nCond
            
            PRTConditions.(condNames{c}).Color = blockColor(c,:);
            PRTConditions.(condNames{c}).BlockDuration = blockDuration(idx,c);
            PRTConditions.(condNames{c}).Intervals = [];
            PRTConditions.(condNames{c}).NumBlocks = 0;
            
        end
        
        % Build intervals
        [ PRTConditions ] = buildIntervals( SEQ(rr,:) , PRTConditions );
        
        % Generate PRT
        prtName = [subjectName '_' SEQNames{rr}];  %without extension
        generatePRT( PRTParameters , PRTConditions , prtName , outputFolder );
        
        idx = idx + 1;
        
    end % end run iteration
    
end % end subject iteration
