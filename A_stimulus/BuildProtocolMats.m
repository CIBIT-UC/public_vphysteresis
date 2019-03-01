% clear,clc;

addpath('functions')
addpath('prt')

TR = 1.5;
fps = 60;

input_path = fullfile('E:','Google Drive','GitHub_DATA','ICNAS_VisualPerception','Hysteresis_Paper','input_stim_prtmat');

%% Localiser
[ framesCond , nFrames , nVols , condNames , nCond ] = extractFramesPRTLoc( 'prt' , 'Localiser.prt' , TR , fps );
save(fullfile(input_path,'Protocols_Localiser.mat'),'framesCond','nFrames','condNames','nVols','nCond');

%% Settings Run C
% Make sure it matches with definitions in buildDots.m and prts
nDots = 2750;
blockVols = 11;

%% Run C1
[ framesCond , framesDots, framesPercentage , numFrames , nVols , condNames , nCond, intervalsPRT , intervals ] = extractFramesPRTC( 'prt' , 'RunC1.prt' , TR , fps , nDots , blockVols );
save(fullfile(input_path,'Protocols_RunC1.mat'),'framesCond','framesDots','framesPercentage','numFrames','condNames','nCond','intervalsPRT','intervals');

%% Run C2
[ framesCond , framesDots, framesPercentage , numFrames , nVols , condNames , nCond, intervalsPRT , intervals ] = extractFramesPRTC( 'prt' , 'RunC2.prt' , TR , fps , nDots , blockVols );
save(fullfile(input_path,'Protocols_RunC2.mat'),'framesCond','framesDots','framesPercentage','numFrames','condNames','nCond','intervalsPRT','intervals');

%% Run C3
[ framesCond , framesDots, framesPercentage , numFrames , nVols , condNames , nCond, intervalsPRT , intervals ] = extractFramesPRTC( 'prt' , 'RunC3.prt' , TR , fps , nDots , blockVols );
save(fullfile(input_path,'Protocols_RunC3.mat'),'framesCond','framesDots','framesPercentage','numFrames','condNames','nCond','intervalsPRT','intervals');

%% Run C4
[ framesCond , framesDots, framesPercentage , numFrames , nVols , condNames , nCond, intervalsPRT , intervals ] = extractFramesPRTC( 'prt' , 'RunC4.prt' , TR , fps , nDots , blockVols );
save(fullfile(input_path,'Protocols_RunC4.mat'),'framesCond','framesDots','framesPercentage','numFrames','condNames','nCond','intervalsPRT','intervals');

%% Settings Run H
% Make sure it matches with definitions in buildDots.m and prts
nDots = 2750;
blockVols = 21;

%% Run H1
[ framesCond , framesDots, framesPercentage , numFrames , nVols , condNames , nCond , intervalsPRT ] = extractFramesPRTHyst( 'prt' , 'RunH1.prt' , TR , fps , nDots , blockVols );
save(fullfile(input_path,'Protocols_RunH1.mat'),'framesCond','framesDots','framesPercentage','numFrames','condNames','nCond','intervalsPRT');

%% Run H2
[ framesCond , framesDots, framesPercentage , numFrames , nVols , condNames , nCond , intervalsPRT ] = extractFramesPRTHyst( 'prt' , 'RunH2.prt' , TR , fps , nDots , blockVols );
save(fullfile(input_path,'Protocols_RunH2.mat'),'framesCond','framesDots','framesPercentage','numFrames','condNames','nCond','intervalsPRT');

%% Run H3
[ framesCond , framesDots, framesPercentage , numFrames , nVols , condNames , nCond , intervalsPRT ] = extractFramesPRTHyst( 'prt' , 'RunH3.prt' , TR , fps , nDots , blockVols );
save(fullfile(input_path,'Protocols_RunH3.mat'),'framesCond','framesDots','framesPercentage','numFrames','condNames','nCond','intervalsPRT');

%% Run H4
[ framesCond , framesDots, framesPercentage , numFrames , nVols , condNames , nCond , intervalsPRT ] = extractFramesPRTHyst( 'prt' , 'RunH4.prt' , TR , fps , nDots , blockVols );
save(fullfile(input_path,'Protocols_RunH4.mat'),'framesCond','framesDots','framesPercentage','numFrames','condNames','nCond','intervalsPRT');

%% Clear
clear;
disp('Protocols .mat created.')
