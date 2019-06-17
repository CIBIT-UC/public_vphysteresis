%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%------------------------- HYSTERESIS EXPERIMENT -------------------------%
%------------------------------- Stimulus --------------------------------%
%------------------------------ Version 3.0 ------------------------------%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  ______________________________________________________________________
% |                                                                      |%
% | Authors: Ricardo Martins, Alexandre Sayal, Joao Duarte,              |%
% |          Teresa Sousa, Gabriel Costa                                 |%
% |                                                                      |%
% |                        CIBIT ICNAS 2017-2019                         |%
% |______________________________________________________________________|%
%
%
% Version 3.0
% - Updated to share
%
% Version 2.1.1
% - Changed I/O folders
%
% Version 2.1
% - Added Run C0. Goal is to define a calibration/control curve
% - Back to original protocol in run1234 (without adaptation before and
% after the transition block), but now with 21 volumes
%
% Version 2.0 (29/05/2017)
% - Texture file name now includes aperture size and colors
% - Background color is now grey
% - Protocol now includes adapt before and after each transition
%
% Version 1.1
% - Increased number of dots to 2800 in runs 1234 and in the Loc to 350
% - Aperture size 10 deg
% - Increase fixation cross size


clear; clc; Screen('CloseAll'); IOPort('CloseAll');

addpath('functions')
addpath('functions_mri')

S = struct();

Outputs = struct();

%% Input
% --- Subject Name
S.SUBJECT = 'TestSubject';
S.SUBJECT_ID = 'TS'; % 2 characters exactly

% --- Eyetracker, Trigger, Response box
S.EYETRACKER = false;
S.TRIGGER = false;
S.RSPBOX = false;

% --- Screen number
% Set this to 50 to choose the screen with the highest index.
screenNumber = 50;

%% Initialize
[ S ] = initHysteresis( S , screenNumber );

%% Load or Create Textures
texture_file = fullfile(S.input_path,sprintf('Textures_%i_sB%i_tB%i_l%i.mat',...
    S.height,S.screenBackground,S.textBackground,S.lines));

if exist(texture_file,'file') ~= 2
    [ T ] = buildTextures( S );
else
    load(texture_file);
end

%% Localizer
Outputs.Loc = runLocalizer( S );

%% Run C1
Outputs.RunC1 = runHyst1234( 'RunC1' , S , T );

%% Run C2
Outputs.RunC2 = runHyst1234( 'RunC2' , S , T );

%% Run C3
Outputs.RunC3 = runHyst1234( 'RunC3' , S , T );

%% Run C4
Outputs.RunC4 = runHyst1234( 'RunC4' , S , T );

%% Run H1
Outputs.RunH1 = runHyst1234( 'RunH1' , S , T );

%% Run H2
Outputs.RunH2 = runHyst1234( 'RunH2' , S , T );

%% Run H3
Outputs.RunH3 = runHyst1234( 'RunH3' , S , T );

%% Run H4
Outputs.RunH4 = runHyst1234( 'RunH4' , S , T );

%% Save Workspace
save(fullfile(S.output_path,...
    [ S.SUBJECT '_Workspace_' datestr(now,'HHMM_ddmmmmyyyy')]),...
    'S','Outputs');

%% Close COMs
% Just because you are cool.
IOPort('Close',S.response_box_handle);
IOPort('Close',S.syncbox_handle);
