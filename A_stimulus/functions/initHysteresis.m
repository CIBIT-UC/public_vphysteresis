function [ S ] = initHysteresis( S , sNumber )
%INITHYSTERESIS Initialise parameters for the hysteresis stimulus protocol.
% Usage: [ S ] = initHysteresis( S , sNumber );
%
% Inputs:
%   : S - struct containing very important info (screen, subject, colors,
%   trigger, response box, eyetracker, etc)
%   : sNumber - screen number (if set to 50, the screen with the highest
%   index is selected)
% Outputs:
%   : S - same as input, a lot fatter :)
%

% --- Define screen number based on input
screens = Screen('Screens');
if sNumber == 50
    S.screenNumber = max(screens);
else
    S.screenNumber = sNumber;
end

% --- Settings
Screen('Preference', 'SkipSyncTests', 0);
KbName('UnifyKeyNames');

% --- Determine screen size and set colors
[S.screenX, S.screenY] = Screen('WindowSize', S.screenNumber);

S.white = WhiteIndex(S.screenNumber);
S.black = BlackIndex(S.screenNumber);
S.grey = S.white / 2;

S.screenBackground = 0;
S.textBackground = 50;
S.lines = 130;

% --- Stimulus/Experiment Settings
S.TR = 1.5; % Repetition time in seconds
S.fps = Screen('FrameRate',S.screenNumber); % Screen Frame Rate
S.dist = 156;  % Distance from eye to screen in cm
S.width = 70; % Width of the screen in cm

% --- Calculate Texture Size in pixels
S.height = angle2pix(S.width,S.screenX(1),S.dist,9);

% --- Folders
S.input_path = fullfile(pwd,'input');
S.output_path = fullfile(pwd,'output');

if ~exist(S.input_path,'dir'); mkdir(S.input_path); end
if ~exist(S.output_path,'dir'); mkdir(S.output_path); end

% --- Open COM Ports for Response box and Trigger
if S.RSPBOX
    S.response_box_handle = IOPort('OpenSerialPort','COM3');
    IOPort('Purge',S.response_box_handle);
end

if S.TRIGGER
    S.syncbox_handle = IOPort('OpenSerialPort', 'COM2', 'BaudRate=57600 DataBits=8 Parity=None StopBits=1 FlowControl=None');
    IOPort('Purge',S.syncbox_handle);
end

end % End function
