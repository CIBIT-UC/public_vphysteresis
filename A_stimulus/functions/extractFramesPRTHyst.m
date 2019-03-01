function [ framesCond , framesDots, framesPercentage , nFrames , nVols , condNames , nCond, intervalsPRT ] = extractFramesPRTHyst( path , name , TR , fps , nDots , blockVols )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

[ condNames , intervalsPRT , intervals ] = readProtocol( path , name , TR );

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
%     elseif intervals(t+1) == 4 % Pattern Down
%         framesDots(t*fps*TR+1:(t+1)*fps*TR) = 22;
%         framesPercentage(t*fps*TR+1:(t+1)*fps*TR) = nDotsDown(end);
%         idxInt = 1;
%     elseif intervals(t+1) == 5 % Component
%         framesDots(t*fps*TR+1:(t+1)*fps*TR) = 33;
%         framesPercentage(t*fps*TR+1:(t+1)*fps*TR) = 0;
%         idxInt = 1;
%     elseif intervals(t+1) == 4 % PattRight_Comp
%         framesDots(t*fps*TR+1:(t+1)*fps*TR) = 888;
%         framesPercentage(t*fps*TR+1:(t+1)*fps*TR) = nDotsDown(end-idxInt+1);
%         idxInt = idxInt + 1;
%     elseif intervals(t+1) == 5 % Comp_PattRight
%         framesDots(t*fps*TR+1:(t+1)*fps*TR) = 888;
%         framesPercentage(t*fps*TR+1:(t+1)*fps*TR) = nDotsDown(idxInt);
%         idxInt = idxInt + 1;
%     elseif intervals(t+1) == 6 % PattUp_Comp
%         framesDots(t*fps*TR+1:(t+1)*fps*TR) = 666;
%         framesPercentage(t*fps*TR+1:(t+1)*fps*TR) = nDotsDown(end-idxInt+1);
%         idxInt = idxInt + 1;
%     elseif intervals(t+1) == 7 % Comp_PattUp
%         framesDots(t*fps*TR+1:(t+1)*fps*TR) = 666;
%         framesPercentage(t*fps*TR+1:(t+1)*fps*TR) = nDotsDown(idxInt);
%         idxInt = idxInt + 1;
%     elseif intervals(t+1) == 8 % PattLeft_Comp
%         framesDots(t*fps*TR+1:(t+1)*fps*TR) = 777;
%         framesPercentage(t*fps*TR+1:(t+1)*fps*TR) = nDotsDown(end-idxInt+1);
%         idxInt = idxInt + 1;
%     elseif intervals(t+1) == 9 %Comp_PattLeft
%         framesDots(t*fps*TR+1:(t+1)*fps*TR) = 777;
%         framesPercentage(t*fps*TR+1:(t+1)*fps*TR) = nDotsDown(idxInt);
%         idxInt = idxInt + 1;
    else
       idxInt = 1; 
    end
    
end

end