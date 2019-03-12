function [ framesCond , framesDots, framesPercentage , nFrames , nVols , condNames , nCond, intervalsPRT ] = extractFramesPRTHyst( path , rr , TR , fps , nDots , blockVols , input_path )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

[ condNames , intervalsPRT , intervals ] = readProtocol( path , sprintf('RunH%i.prt',rr) , TR );

nVols = length(intervals);
nFrames = nVols*fps*TR;
nCond = length(condNames);
nDotsDown = floor(linspace(0,nDots,blockVols));

framesCond = zeros(nFrames,1);
framesDots = zeros(nFrames,1);
framesPercentage = zeros(nFrames,1);
idxInt = 1;

for t = 0:nVols-1
    
    framesCond(t*fps*TR+1:(t+1)*fps*TR) = intervals(t+1);
    
    if intervals(t+1) == 2 % PattDown_Comp
        framesDots(t*fps*TR+1:(t+1)*fps*TR) = 999;
        framesPercentage(t*fps*TR+1:(t+1)*fps*TR) = nDotsDown(end-idxInt+1);
        idxInt = idxInt + 1;
    elseif intervals(t+1) == 3 % Comp_PattDown
        framesDots(t*fps*TR+1:(t+1)*fps*TR) = 999;
        framesPercentage(t*fps*TR+1:(t+1)*fps*TR) = nDotsDown(idxInt);
        idxInt = idxInt + 1;
    else
       idxInt = 1; 
    end
    
end

save(fullfile(input_path,sprintf('Protocols_RunH%i.mat',rr)),...
    'framesCond','framesDots','framesPercentage','nFrames',...
    'condNames','nCond','intervalsPRT');

end
