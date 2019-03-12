function [ ] = extractFramesPRTC( path , rr , TR , fps , nDots , blockVols , input_path)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

[ condNames , intervalsPRT , intervals ] = readProtocol( path , sprintf('RunC%i.prt',rr) , TR );

nVols = length(intervals);
nFrames = nVols*fps*TR;
nCond = length(condNames);
nDotsDown = floor(linspace(0,nDots,blockVols));

framesCond = zeros(nFrames,1);
framesDots = zeros(nFrames,1);
framesPercentage = zeros(nFrames,1);

sequence = intervals;
sequence(sequence == 1) = [];
sequence(sequence == blockVols+2) = [];
sequence = unique(sequence,'stable');
idx = 0;
first = true;

for t = 0:nVols-1
    
    framesCond(t*fps*TR+1:(t+1)*fps*TR) = intervals(t+1);
    
    if all(intervals(t+1) ~= [1,blockVols+2])
        framesDots(t*fps*TR+1:(t+1)*fps*TR) = 999;
        framesPercentage(t*fps*TR+1:(t+1)*fps*TR) = nDotsDown(sequence(idx)-1);
        first = true;
    elseif intervals(t+1) == 1 && first
        idx = idx+1;
        first = false;
    end
    
end

save(fullfile(input_path,sprintf('Protocols_RunC%i.mat',rr)),...
    'framesCond','framesDots','framesPercentage','nFrames',...
    'condNames','nCond','intervalsPRT','intervals');

end
