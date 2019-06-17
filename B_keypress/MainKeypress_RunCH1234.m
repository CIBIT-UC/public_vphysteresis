%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%------------------------- HYSTERESIS EXPERIMENT -------------------------%
%------------------------------- Keypress --------------------------------%
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
% - updated to share
% - smooth keypress data optimization: use two points
%

clear, clc

%% Subject data
subjectList = {'TestSubject1','TestSubject2'};
nSubjects = length(subjectList);

%% Smooth parameters
s_volumes = 2; % number of volumes to smooth (2 - don't change!!! code is dumb and the fits will fail)
s_adjust = s_volumes-1; % for convenience (most frequently used value)
s_points = 1.5 * 60 * s_volumes; % number of frames = TR x fps x s_volumes

%% Paths
% Keypress raw data
rawdata_path = fullfile('...','Hysteresis_Paper','input_raw_keypress');

% Protocol data
% This data comes from BuildProtocsMats.m, found in the stimulus folder.
input_path = fullfile(pwd,'input');

% Output folders
output_path = fullfile('...','Hysteresis_Paper','output_keypress');
output_images = fullfile('...','Hysteresis_Paper','output_keypress_images');

%% Settings Dots
nDots = 2750;
blockVolsC = 11; % number of volumes in calibration runs
blockVolsH = 21; % number of volumes in Hyst runs
nDotsDown = floor(linspace(0,nDots,blockVolsH));
nBlocks = 4; % number of blocks per run per condition

%% Initialise structure
KeypressData = struct();

%% Iterate on the subjects
for s = 1:nSubjects
    
    subjectName = subjectList{s};
    KeypressData(s).Name = subjectName;
    
    %% Load Keypress raw data
    fileDir = dir(fullfile(rawdata_path,[subjectName '_Workspace_*.mat']));
    disp(fullfile(fileDir(1).folder,fileDir(1).name));
    load(fullfile(fileDir(1).folder,fileDir(1).name))
    
    %% RunC1234 Data
    runNames = {'RunC1','RunC2','RunC3','RunC4'};
    nRuns = length(runNames);

    KeyPresses = struct();
    
    KeypressData(s).Calibration.data = zeros(nRuns,blockVolsC);
    KeypressData(s).Calibration.mean = zeros(1,blockVolsC);
    KeypressData(s).Calibration.sem = zeros(1,blockVolsC);
    KeypressData(s).Calibration.weight = zeros(1,blockVolsC);
    KeypressData(s).Calibration.sigmoid = struct();
    
    %% Iteration on the C1234 Runs
    idx = 1;
    for r = runNames
        
        % --- Change variable name
        eval(['KeysOrig = Output' r{:} '.Keys;'])
        eval(['KeysOrigCodes = Output' r{:} '.KeyCodes;'])
        
        % --- Load protocol
        load(fullfile(input_path,['Protocols_' r{:} '.mat']));
        
        % --- Convert to continuous key presses
        KeyPresses.(r{:}) = zeros(numFrames,1);
        
        currentKeeper = KeysOrig(1,1);
        
        for t = 2:numFrames
            
            if framesCond(t) == 1
                currentKeeper = 0;
            else
                if (KeysOrig(t,1) ~= 0) && (KeysOrig(t,1) ~= currentKeeper)
                    currentKeeper =  KeysOrig(t,1);
                end
            end
            
            KeyPresses.(r{:})(t) = currentKeeper;
            
        end
        
        % Sequence
        sequence = intervals;
        sequence(sequence == 1) = [];
        sequence(sequence == blockVolsC+2) = [];
        sequence = unique(sequence,'stable');
        
        for ii = sequence
            
            % --- Pattern --> Component Blocks
            aux1 = KeyPresses.(r{:})( (framesCond==ii) ,1);
            aux1 ( aux1==0 ) = [];
            
            KeypressData(s).Calibration.data(idx,ii-1) = sum(KeysOrigCodes(1) == aux1) / length(aux1);
            
        end
        
        idx = idx + 1;
        
    end % end run iteration
    
    KeypressData(s).Calibration.mean = mean(KeypressData(s).Calibration.data);
    KeypressData(s).Calibration.sem = std(KeypressData(s).Calibration.data) / sqrt(nRuns);
    KeypressData(s).Calibration.weight = calcWeight(KeypressData(s).Calibration.sem);
    
    KeypressData(s).Calibration.sigmoid.x = 0:0.1:1;
    [KeypressData(s).Calibration.sigmoid.fit, KeypressData(s).Calibration.sigmoid.y] = ...
            createSigmoidFit(KeypressData(s).Calibration.sigmoid.x,...
                                           KeypressData(s).Calibration.mean,...
                                           KeypressData(s).Calibration.weight);
    
    %% RunH1234 Data
    runNames = {'RunH1','RunH2','RunH3','RunH4'};
    nRuns = length(runNames);
    
    KeyPresses = struct();

    %% Initialise Concat
    KeypressData(s).PC.Concat.data = zeros(nBlocks*nRuns,blockVolsH-s_adjust);
    KeypressData(s).PC.Concat.mean = zeros(1,blockVolsH-s_adjust);
    KeypressData(s).PC.Concat.sem = zeros(1,blockVolsH-s_adjust);
    KeypressData(s).PC.Concat.weight = zeros(1,blockVolsH-s_adjust);
    KeypressData(s).PC.Concat.sigmoid = struct();
    
    KeypressData(s).CP.Concat.data = zeros(nBlocks*nRuns,blockVolsH-s_adjust);
    KeypressData(s).CP.Concat.mean = zeros(1,blockVolsH-s_adjust);
    KeypressData(s).CP.Concat.sem = zeros(1,blockVolsH-s_adjust);
    KeypressData(s).CP.Concat.weight = zeros(1,blockVolsH-s_adjust);
    KeypressData(s).CP.Concat.sigmoid = struct();
    
    %% Iteration on the H1234 Runs
    for r = 1:nRuns
        
        % --- Change variable name
        eval(['KeysOrig = Output' runNames{r} '.Keys;'])
        eval(['KeysOrigCodes = Output' runNames{r} '.KeyCodes;'])
        
        % --- Load protocol
        load(fullfile(input_path,['Protocols_' runNames{r} '.mat']));
        
        % --- Convert to continuous key presses
        KeyPresses.(runNames{r}) = zeros(numFrames,1);
        
        currentKeeper = KeysOrig(1,1);
        
        for t = 2:numFrames
            
            if framesCond(t) == 1
                currentKeeper = 0;
            else
                if (KeysOrig(t,1) ~= 0) && (KeysOrig(t,1) ~= currentKeeper)
                    currentKeeper =  KeysOrig(t,1);
                end
            end
            
            KeyPresses.(runNames{r})(t) = currentKeeper;
            
        end
        
        % --- Initialise matrices
        KeypressData(s).PC.(runNames{r}).data = zeros(nBlocks,blockVolsH-s_adjust);
        KeypressData(s).PC.(runNames{r}).mean = zeros(1,blockVolsH-s_adjust);
        KeypressData(s).PC.(runNames{r}).sem = zeros(1,blockVolsH-s_adjust);
        KeypressData(s).PC.(runNames{r}).weight = zeros(1,blockVolsH-s_adjust);
        KeypressData(s).PC.(runNames{r}).sigmoid = struct();
        
        KeypressData(s).CP.(runNames{r}).data = zeros(nBlocks,blockVolsH-s_adjust);
        KeypressData(s).CP.(runNames{r}).mean = zeros(1,blockVolsH-s_adjust);
        KeypressData(s).CP.(runNames{r}).sem = zeros(1,blockVolsH-s_adjust);
        KeypressData(s).CP.(runNames{r}).weight = zeros(1,blockVolsH-s_adjust);
        KeypressData(s).CP.(runNames{r}).sigmoid = struct();
        
        for ii = 1:blockVolsH - s_adjust % -1 because of the smooth operation
            
            % --- Pattern --> Component Blocks
            aux1 = KeyPresses.(runNames{r})( (framesCond==2 & ismember(framesPercentage,nDotsDown(end-ii+1:-1:end-ii+1-s_adjust)) ) , 1);
            
            % --- Component --> Pattern Blocks
            aux2 = KeyPresses.(runNames{r})( (framesCond==3 & ismember(framesPercentage,nDotsDown(ii:ii+s_adjust)) ) ,1);
            
            % Retrieve percentage per block and volume
            % Example for smooth 2: Each volume has 1.5 seconds --> 1.5 x 60 fps x 2 = 90 data points per
            % volume = 180 data points per 2 volumes
            for bb = 1:nBlocks
                KeypressData(s).PC.(runNames{r}).data(bb,ii) = sum(KeysOrigCodes(1) == aux1((bb-1)*s_points+1:(bb)*s_points)) / sum( aux1((bb-1)*s_points+1:(bb)*s_points) ~= 0);
                KeypressData(s).CP.(runNames{r}).data(bb,ii) = sum(KeysOrigCodes(1) == aux2((bb-1)*s_points+1:(bb)*s_points)) / sum( aux2((bb-1)*s_points+1:(bb)*s_points) ~= 0);
            end
            
            KeypressData(s).PC.(runNames{r}).mean(ii) = mean(KeypressData(s).PC.(runNames{r}).data(:,ii));
            KeypressData(s).PC.(runNames{r}).sem(ii) = std(KeypressData(s).PC.(runNames{r}).data(:,ii)) / sqrt(nBlocks);
            KeypressData(s).PC.(runNames{r}).weight(ii) = calcWeight(KeypressData(s).PC.(runNames{r}).sem(ii));
            
            KeypressData(s).CP.(runNames{r}).mean(ii) = mean(KeypressData(s).CP.(runNames{r}).data(:,ii));
            KeypressData(s).CP.(runNames{r}).sem(ii) = std(KeypressData(s).CP.(runNames{r}).data(:,ii)) / sqrt(nBlocks);
            KeypressData(s).CP.(runNames{r}).weight(ii) = calcWeight(KeypressData(s).CP.(runNames{r}).sem(ii));
            
        end % end block volume iteration
        
        %% Create sigmoid fit of each run
        KeypressData(s).PC.(runNames{r}).sigmoid.x = linspace(0.975,0.025,20);
        [KeypressData(s).PC.(runNames{r}).sigmoid.fit, KeypressData(s).PC.(runNames{r}).sigmoid.y] = ...
            createSigmoidFit(KeypressData(s).PC.(runNames{r}).sigmoid.x,...
                                            KeypressData(s).PC.(runNames{r}).mean,...
                                            KeypressData(s).PC.(runNames{r}).weight);
        
        KeypressData(s).CP.(runNames{r}).sigmoid.x = linspace(0.025,0.975,20);
        [KeypressData(s).CP.(runNames{r}).sigmoid.fit, KeypressData(s).CP.(runNames{r}).sigmoid.y] = ...
            createSigmoidFit(KeypressData(s).CP.(runNames{r}).sigmoid.x,...
                                            KeypressData(s).CP.(runNames{r}).mean,...
                                            KeypressData(s).CP.(runNames{r}).weight);
         
    %% Concatenate
    KeypressData(s).PC.Concat.data((r-1)*nRuns+1:r*nRuns,:) = KeypressData(s).PC.(runNames{r}).data;
    KeypressData(s).CP.Concat.data((r-1)*nRuns+1:r*nRuns,:) = KeypressData(s).CP.(runNames{r}).data;
         
        %% Plot PC                                
        plotBeautiful(KeypressData(s).Calibration.mean,... %cal_mean 
                               KeypressData(s).Calibration.sem,... %cal_sem
                               KeypressData(s).PC.(runNames{r}).mean,... % test_mean
                               KeypressData(s).PC.(runNames{r}).sem,... % sem
                               KeypressData(s).Calibration.sigmoid.y,... % cal_y
                               KeypressData(s).PC.(runNames{r}).sigmoid.y,... % test_y
                               KeypressData(s).PC.(runNames{r}).data,... % test_raw
                               KeypressData(s).Calibration.sigmoid.x,... %cal x
                               KeypressData(s).CP.(runNames{r}).sigmoid.x,... %test x
                               KeypressData(s).Name,... % subjectName
                               runNames{r},... % run name
                               'pc',... % type
                               true,... % export boolean
                               output_images); % export folder

        %% Plot CP
        plotBeautiful(KeypressData(s).Calibration.mean,... %cal_mean 
                               KeypressData(s).Calibration.sem,... %cal_sem            
                               KeypressData(s).CP.(runNames{r}).mean,... % test_mean
                               KeypressData(s).CP.(runNames{r}).sem,... % sem
                               KeypressData(s).Calibration.sigmoid.y,... % cal_y
                               KeypressData(s).CP.(runNames{r}).sigmoid.y,... % test_y
                               KeypressData(s).CP.(runNames{r}).data,... % test_raw
                               KeypressData(s).Calibration.sigmoid.x,... %cal x
                               KeypressData(s).CP.(runNames{r}).sigmoid.x,... %test x                            
                               KeypressData(s).Name,... % subjectName
                               runNames{r},... % run name
                               'cp',... % type
                               true,... % export boolean
                               output_images); % export folder

        %% Plot Both
        plotBeautiful2(KeypressData(s).Calibration.mean,... %cal_mean 
                   KeypressData(s).Calibration.sem,... %cal_sem            
                   KeypressData(s).CP.(runNames{r}).mean,... % test_mean cp
                   KeypressData(s).CP.(runNames{r}).sem,... % sem cp
                   KeypressData(s).PC.(runNames{r}).mean,... % test_mean PC
                   KeypressData(s).PC.(runNames{r}).sem,... % sem PC
                   KeypressData(s).Calibration.sigmoid.y,... % cal_y
                   KeypressData(s).CP.(runNames{r}).sigmoid.y,... % test_y CP
                   KeypressData(s).PC.(runNames{r}).sigmoid.y,... % test_y PC
                   KeypressData(s).Calibration.sigmoid.x,... %cal x
                   KeypressData(s).CP.(runNames{r}).sigmoid.x,... %test x                                   
                   KeypressData(s).Name,... % subjectName
                   runNames{r},... % run name
                   true,... % export boolean
                   output_images); % export folder
                           
    end % end run iteration
    
    %% Operate concatenated runs
    KeypressData(s).PC.Concat.mean = mean(KeypressData(s).PC.Concat.data);
    KeypressData(s).PC.Concat.sem = std(KeypressData(s).PC.Concat.data) / sqrt(nRuns*nBlocks);
    KeypressData(s).PC.Concat.weight = calcWeight(KeypressData(s).PC.Concat.sem);
    
    KeypressData(s).CP.Concat.mean = mean(KeypressData(s).CP.Concat.data);
    KeypressData(s).CP.Concat.sem = std(KeypressData(s).CP.Concat.data) / sqrt(nRuns*nBlocks);
    KeypressData(s).CP.Concat.weight = calcWeight(KeypressData(s).CP.Concat.sem);
    
    % Sigmoid fit
    KeypressData(s).PC.Concat.sigmoid.x = linspace(0.975,0.025,20);
    [KeypressData(s).PC.Concat.sigmoid.fit, KeypressData(s).PC.Concat.sigmoid.y] = ...
            createSigmoidFit(KeypressData(s).PC.Concat.sigmoid.x,...
                                            KeypressData(s).PC.Concat.mean,...
                                            KeypressData(s).PC.Concat.weight);

    KeypressData(s).CP.Concat.sigmoid.x = linspace(0.025,0.975,20);
    [KeypressData(s).CP.Concat.sigmoid.fit, KeypressData(s).CP.Concat.sigmoid.y] = ...
            createSigmoidFit(KeypressData(s).CP.Concat.sigmoid.x,...
                                            KeypressData(s).CP.Concat.mean,...
                                            KeypressData(s).CP.Concat.weight);

    %% Plot concatenated 
    plotBeautiful(KeypressData(s).Calibration.mean,... %cal_mean 
                       KeypressData(s).Calibration.sem,... %cal_sem
                       KeypressData(s).PC.Concat.mean,... % test_mean
                       KeypressData(s).PC.Concat.sem,... % sem
                       KeypressData(s).Calibration.sigmoid.y,... % cal_y
                       KeypressData(s).PC.Concat.sigmoid.y,... % test_y
                       KeypressData(s).PC.Concat.data,... % test_raw
                       KeypressData(s).Calibration.sigmoid.x,... %cal x
                       KeypressData(s).CP.(runNames{r}).sigmoid.x,... %test x                            
                       KeypressData(s).Name,... % subjectName
                       'RunH1234',... % run name
                       'pc',... % type
                       true,... % export boolean
                       output_images); % export folder

   plotBeautiful(KeypressData(s).Calibration.mean,... %cal_mean 
                       KeypressData(s).Calibration.sem,... %cal_sem
                       KeypressData(s).CP.Concat.mean,... % test_mean
                       KeypressData(s).CP.Concat.sem,... % sem
                       KeypressData(s).Calibration.sigmoid.y,... % cal_y
                       KeypressData(s).CP.Concat.sigmoid.y,... % test_y
                       KeypressData(s).CP.Concat.data,... % test_raw
                       KeypressData(s).Calibration.sigmoid.x,... %cal x
                       KeypressData(s).CP.(runNames{r}).sigmoid.x,... %test x                                    
                       KeypressData(s).Name,... % subjectName
                       'RunH1234',... % run name
                       'cp',... % type
                       true,... % export boolean
                       output_images); % export folder
    
end % end subject iteration

%% Export Data
save(fullfile(output_path,['KeypressData_N' num2str(nSubjects) '_Smooth' num2str(s_volumes) '.mat']),'KeypressData');

disp('DONE =D')
