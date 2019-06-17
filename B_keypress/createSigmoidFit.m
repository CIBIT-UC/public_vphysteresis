function [fitresult, fitcurve] = createSigmoidFit(xxx, yyy, www, xxx2)
%CREATESIGMOIDFIT(XXX,YYY,WWW)
%  Create a sigmoid fit based on the equation below.
%
%  Data for sigmoid fit:
%      X Input : xxx
%      Y Output: yyy
%      Weights : www
%      Optional X : xxx2
%  Output:
%      fitresult : a fit object representing the fit.
%      fitcurve : a vector containing the fit applied to xxx2
%%
% 
% $$y(x) = \frac{1}{1 + e^{-a(x-d)}}$$
%
%% If xxx2 is not defined, use xxx
if nargin < 4
    xxx2 = xxx;
end

%% Fit: Sigmoid
[xData, yData, weights] = prepareCurveData( xxx, yyy, www );

%% Set up fittype and options.
ft = fittype( '1 / (1 + exp(-a*(x - d)))', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Weights = weights;

opts.Lower = [0 0.1];
opts.Upper = [100 0.9];
opts.StartPoint = [10 0];

%% Fit model to data. 
fitresult = fit( xData, yData, ft, opts );

fitcurve = fitresult(xxx2);

end
