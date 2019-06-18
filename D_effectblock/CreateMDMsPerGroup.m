clc,clear

datasetConfigs.path = '';
datasetConfigs.AnalysisPath = '';

datasetConfigs.subjects = {'TestSubject01','TestSubject02'};

bvqx = actxserver('BrainVoyager.BrainVoyagerScriptAccess.1');

% Load list of vtc's and sdm's from effect block folder
efFolder = fullfile(datasetConfigs.AnalysisPath,'EffectBlock');
load(fullfile(efFolder,'lists.mat'))

% Folders
mdmFolder = fullfile(efFolder,'MDMs');
glmFolder = fullfile(efFolder,'GLMs');

% Load classification
% Adaptation 1, Persistence 2
PC_class = [1,1,1,1,2,3,2,3,2,4,4,4,4,2,1,4,3,3,4,3,4,2,4,2,3,4,2,2,1,1,1,1,1,3,1,3,1,1,1,1,3,2,1,1,4,4,4,4,1,1,1,1,1,1,1,1,4,3,2,3,3,3,1,1,4,4,1,4,1,1,1,1,1,4,1,4,4,1,4,2,3,3,3,3,1,1,1,1,1,1,1,1,3,1,1,1,1,3,2,3];
CP_class = [2,2,2,2,2,2,2,2,4,4,4,4,4,4,2,4,4,4,4,4,2,2,2,2,3,4,3,3,2,2,2,2,4,4,4,4,2,2,2,3,2,3,3,2,4,4,4,3,3,2,2,2,2,2,2,2,4,4,1,3,4,3,3,4,3,3,3,4,2,2,2,2,4,3,3,3,1,4,2,1,3,4,3,4,2,2,2,2,2,2,2,2,2,4,3,2,2,2,2,2];

% new lists
vtcList_Adaptation = vtcList(PC_class==1);
vtcList_Persistence = vtcList(CP_class == 2);

sdmList_Adaptation = sdmList(PC_class==1);
sdmList_Persistence = sdmList(CP_class == 2);

%% Create MDM and run RFX-GLM for Adaptation runs
vmrDir = dir(fullfile(datasetConfigs.path,datasetConfigs.subjects{1},'anatomical','PROJECT','*TAL.vmr'));    
vmrProject = bvqx.OpenDocument( fullfile(vmrDir.folder,vmrDir.name) );

vmrProject.ClearMultiStudyGLMDefinition;

vmrProject.ZTransformStudies = 0;
vmrProject.PSCTransformStudies = 1;
vmrProject.CorrectForSerialCorrelations = 1;
vmrProject.SeparationOfStudyPredictors = 0;
vmrProject.SeparationOfSubjectPredictors = 1;

for idx = 1:length(sdmList_Adaptation)
    
   vmrProject.LinkVTC(vtcList_Adaptation{idx});
   
   vmrProject.AddStudyAndDesignMatrix(vtcList_Adaptation{idx},sdmList_Adaptation{idx});
    
end

vmrProject.SaveMultiStudyGLMDefinitionFile(fullfile(mdmFolder,'RFX_Adaptation_RunH1234.mdm'));
vmrProject.LoadMultiStudyGLMDefinitionFile(fullfile(mdmFolder,'RFX_Adaptation_RunH1234.mdm'));

vmrProject.ComputeRFXGLM;
vmrProject.SaveGLM(fullfile(glmFolder,'RFX_Adaptation_RunH1234.glm'));

vmrProject.Close;

%% Create MDM and run RFX-GLM for Persistence runs
vmrDir = dir(fullfile(datasetConfigs.path,datasetConfigs.subjects{1},'anatomical','PROJECT','*TAL.vmr'));    
vmrProject = bvqx.OpenDocument( fullfile(vmrDir.folder,vmrDir.name) );

vmrProject.ClearMultiStudyGLMDefinition;

vmrProject.ZTransformStudies = 0;
vmrProject.PSCTransformStudies = 1;
vmrProject.CorrectForSerialCorrelations = 1;
vmrProject.SeparationOfStudyPredictors = 0;
vmrProject.SeparationOfSubjectPredictors = 1;

for idx = 1:length(sdmList_Persistence)
    
   vmrProject.LinkVTC(vtcList_Persistence{idx});
   
   vmrProject.AddStudyAndDesignMatrix(vtcList_Persistence{idx},sdmList_Persistence{idx});
    
end

vmrProject.SaveMultiStudyGLMDefinitionFile(fullfile(mdmFolder,'RFX_Persistence_RunH1234.mdm'))
vmrProject.LoadMultiStudyGLMDefinitionFile(fullfile(mdmFolder,'RFX_Persistence_RunH1234.mdm'));

vmrProject.ComputeRFXGLM;
vmrProject.SaveGLM(fullfile(glmFolder,'RFX_Persistence_RunH1234.glm'));

%% Close COM
bvqx.delete;
disp('Analysis Completed.')
