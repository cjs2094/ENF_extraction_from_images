function [fitresult, gof] = func_myFit(x, I, Fe, T_row, boundFlag)

[xData, yData] = prepareCurveData(x, I);

% Set up fittype and options.
F0 = Fe * T_row;
ft = fittype( ['((a_t - a_s)/(' num2str(x(end)) '-' num2str(x(1)) ')*(x-' num2str(x(1)) ') + a_s)*(cos(2*pi*' num2str(F0) '*x + phi)) + k*x + b'], 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
if boundFlag == 'L'
    opts.Lower = [0 0 -Inf -Inf -Inf];
    opts.Upper = [Inf Inf Inf Inf Inf];
elseif boundFlag == 'U'
    opts.Lower = -[Inf Inf Inf Inf Inf];
    opts.Upper = [0 0 Inf Inf Inf];
end
opts.Robust = 'Bisquare';
opts.StartPoint = [0 0 0 mean(I) pi/2];

% Fit model to data.
[fitresult, gof] = fit(xData, yData, ft, opts);