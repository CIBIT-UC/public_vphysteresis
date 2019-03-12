function [ ] = extractFramesPRTLoc( path , name , TR , fps , input_path)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

[ condNames , ~ , intervals ] = readProtocol( path , name , TR );

nVols = length(intervals);
nFrames = nVols*fps*TR;
nCond = length(condNames);

framesCond = zeros(nFrames,1);

for t = 0:nVols-1  
    framesCond(t*fps*TR+1:(t+1)*fps*TR) = intervals(t+1);
end

% output
save(fullfile(input_path,'Protocols_Localizer.mat'),...
    'framesCond','nFrames','condNames','nVols','nCond');

end
