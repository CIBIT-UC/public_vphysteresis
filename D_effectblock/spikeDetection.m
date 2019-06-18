function [ spikeIndexes ] = spikeDetection( motionSDM , threshold )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

detrendMotion = detrend(motionSDM.SDMMatrix);

% distance RMS
radius = 65;
RMS = zeros(motionSDM.NrOfDataPoints-1,1);

for i = 1:motionSDM.NrOfDataPoints-1
    mp_bv1 = detrendMotion(i,:)';
    mp_bv2 = detrendMotion(i+1,:)';
    
    T1 = getTrfMatrixBV(mp_bv1);
    T2 = getTrfMatrixBV(mp_bv2);
    
    M = T2/T1 - eye(4);
    A = M(1:3, 1:3);
    
    T = M(1:3,4);
    
    AAt = A * A';
    
    trace = sum( diag(AAt) );
    
    RMS(i) = sqrt(.2 * radius * radius * trace + dot(T, T));
    
end

spikeIndexes = find(RMS > threshold);

end

