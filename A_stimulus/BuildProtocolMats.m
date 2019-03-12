% This script generates the protocol matrices, based on a .prt file
% (BrainVoyager stimulus/protocol file)
clear,clc;

addpath('functions')

TR = 1.5;
fps = 60;

prt_path = fullfile(pwd,'prt'); % where the .prts are
input_path = fullfile(pwd,'input'); % output folder for the .mats

%% Localizer
extractFramesPRTLoc( prt_path , 'Localizer.prt' , TR , fps , input_path);

%% Settings Run C and H
% Make sure it matches with definitions in buildDots.m and prts
nDots = 2750;
blockVolsC = 11;
blockVolsH = 21;

%% Runs C 1,2,3,4
for rr = 1:4
    
    extractFramesPRTC( prt_path , rr , TR , fps , nDots , blockVolsC , input_path);
    
end

%% Run H 1,2,3,4
for rr = 1:4

    extractFramesPRTHyst( prt_path , rr , TR , fps , nDots , blockVolsH , input_path );

end

%% Clear
clear;
disp('Protocols .mat created.')
