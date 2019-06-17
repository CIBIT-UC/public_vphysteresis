function [weights] = calcWeight(curve_sem)
%CALCWEIGHT Calculate weights based on the Standard Error of the Mean (SEM)
%   Detailed explanation goes here

weights = 1./(curve_sem.^2);

% This is necessary to avoid having Inf in the weights - when the error is
% zero. Additionally, because the weights are always considered to the
% sigmoid fit, we chose to attribute them a very high value.
weights(weights == Inf) = 1/(1e-10);

end
