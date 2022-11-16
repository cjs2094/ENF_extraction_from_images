function [fitresult, gof] = func_myFit_preModel(x, I, Fe, T_row, boundFlag)

[xData, yData] = prepareCurveData(x, I);

% Set up fittype and options.
F0 = Fe * T_row;
ft = fittype( ['a*cos(2*pi*' num2str(F0) '*x + phi)'], 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
if boundFlag == 'L'
    opts.Lower = [0 -Inf];
    opts.Upper = [Inf Inf];
elseif boundFlag == 'U'
    opts.Lower = -[Inf Inf];
    opts.Upper = [0 Inf];
end
opts.Robust = 'Bisquare';
opts.StartPoint = [0 pi/2];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );