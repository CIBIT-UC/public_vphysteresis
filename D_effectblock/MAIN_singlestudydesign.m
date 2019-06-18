 %% Clear Command Window / Clear Workspace / Close / Add Paths
clear , clc , close all;

%% ============================= Settings ============================== %%

datasetConfigs.path = '';
datasetConfigs.AnalysisPath = '';
addpath(datasetConfigs.path);

functionalRuns = {'runH1','runH2','runH3','runH4'};
subjectsList = {'TestSubject01','TestSubject02'};
subjectsList = sort(subjectsList);
nSubjects = length(subjectsList);
nRuns = 4;

bvqx = actxserver('BrainVoyager.BrainVoyagerScriptAccess.1');

efFolder = fullfile(datasetConfigs.AnalysisPath,'EffectBlock');
sdmFolder = fullfile(efFolder,'SDMs');
prtFolder = fullfile(efFolder,'PRTs');
mdmFolder = fullfile(efFolder,'MDMs');
glmFolder = fullfile(efFolder,'GLMs');

spikeThreshold = 0.25; % Spike Threshold

sdmList = cell(1,nRuns*nSubjects);
vtcList = cell(1,nRuns*nSubjects);
idxList = 1;

%% Iterate on subjects/runs - Create SDMs

for sub = 1:nSubjects
    
    subjectName = subjectsList{sub};
            
    vmrDir = dir(fullfile(datasetConfigs.path,subjectName,'anatomical','PROJECT','*TAL.vmr'));    
    vmrProject = bvqx.OpenDocument( fullfile(vmrDir.folder,vmrDir.name) );
    
    for r = 1:nRuns
        
        vmrProject.LinkVTC( fullfile(datasetConfigs.AnalysisPath,'VTC-data-SS6',...
            ['run-' functionalRuns{r} '-data'],...
            [subjectName '_' functionalRuns{r} '_SCCAI_3DMCTS_LTR_THPGLMF2c_TAL_SD3DVSS6.00mm.vtc']));
        
        vtcList{idxList} = vmrProject.FileNameOfCurrentVTC;
        
        success = vmrProject.LinkStimulationProtocol(fullfile(prtFolder,[subjectName '_Eff_' functionalRuns{r} '.prt']));
        
        nVols = vmrProject.NrOfVolumes;
        
        vmrProject.ClearDesignMatrix;
        
        prtFile = xff(fullfile(prtFolder,[subjectName '_Eff_' functionalRuns{r} '.prt']));
        condNames = prtFile.ConditionNames;
        prtFile.ClearObject;
        
        for p = 1:length(condNames)
            
            conditionName = condNames{p};
            if conditionName (end) == ' '
                conditionName (end) = [];
            end
            
            vmrProject.AddPredictor(conditionName);
            
            vmrProject.SetPredictorValuesFromCondition(...
                conditionName,...
                conditionName,...
                1.0);
            
            vmrProject.ApplyHemodynamicResponseFunctionToPredictor(conditionName);
            
        end
        
        vmrProject.SDMContainsConstantPredictor = true;
        
        vmrProject.FirstConfoundPredictorOfSDM = p + 1;
        
        motionSDMpath = fullfile(datasetConfigs.path,subjectName,['run-' functionalRuns{r} '-data'],'PROJECT','PROCESSING');
        motionSDMname = dir(fullfile(motionSDMpath,'*3DMC.sdm'));
        
        motionSDM = xff(fullfile(motionSDMpath,motionSDMname.name));
        
        % Detrend and z-normalize motion parameters
        detrendNormMotion = zscore(detrend(motionSDM.SDMMatrix));
        
        for i = 1:6
            
            aux_detrendNormMotion = normalize_var(detrendNormMotion(:,i),-1,1); % Normalise between -1 and 1
            
            vmrProject.AddPredictor([motionSDM.PredictorNames{i} ' Detrended']);
            
            for j = 1:nVols
                vmrProject.SetPredictorValues([motionSDM.PredictorNames{i} ' Detrended'],j,j,aux_detrendNormMotion(j));
            end
            
        end
        
        [ spikeIndexes ] = spikeDetection( motionSDM , spikeThreshold );
        
        for i = 1:length(spikeIndexes)
            
            vmrProject.AddPredictor(['Spike ' num2str(spikeIndexes(i))]);
            
            for j = 1:nVols
                if j == spikeIndexes(i)
                    value = 1;
                else
                    value = 0;
                end
                vmrProject.SetPredictorValues(['Spike ' num2str(spikeIndexes(i))],j,j,value);
            end
            
        end
        
        % -- Add Constant Predictor
        vmrProject.AddPredictor('Constant');
        vmrProject.SetPredictorValues('Constant', 1, vmrProject.NrOfVolumes, 1.0);
        
        % Save SDM
        sdmPathName = fullfile( sdmFolder,[ subjectName '_' functionalRuns{r} '_3DMC_SPK.sdm' ] );
        vmrProject.SaveSingleStudyGLMDesignMatrix( sdmPathName );
        
        sdmList{idxList} = sdmPathName;
        
        idxList = idxList + 1;
    end
    
    vmrProject.Close;
    
end

%% Save sdm and vtc list
save(fullfile(efFolder,'lists.mat'),'sdmList','vtcList');
% load(fullfile(splitFolder,'lists.mat'));

%% Create MDM and run RFX-GLM
vmrProject = bvqx.OpenDocument( fullfile(vmrDir.folder,vmrDir.name) );

vmrProject.ClearMultiStudyGLMDefinition;

vmrProject.ZTransformStudies = 0;
vmrProject.PSCTransformStudies = 1;
vmrProject.CorrectForSerialCorrelations = 1;
vmrProject.SeparationOfStudyPredictors = 0;
vmrProject.SeparationOfSubjectPredictors = 1;

for idx = 1:length(sdmList)
    
   vmrProject.LinkVTC(vtcList{idx});
   
   vmrProject.AddStudyAndDesignMatrix(vtcList{idx},sdmList{idx});
    
end

vmrProject.SaveMultiStudyGLMDefinitionFile(fullfile(mdmFolder,'RFX_RunH1234.mdm'))
vmrProject.LoadMultiStudyGLMDefinitionFile(fullfile(mdmFolder,'RFX_RunH1234.mdm'));

vmrProject.ComputeRFXGLM;
vmrProject.SaveGLM(fullfile(glmFolder,'RFX_RunH1234.glm'));

%% Close COM
bvqx.delete;
disp('Analysis Completed.')
