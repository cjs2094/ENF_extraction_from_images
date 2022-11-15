function [v_fitted] = func_genACVolWithVFVA(v, frame_size)
%% 08/06/2019, Jisoo Choi
% frame_size: should be odd number

overlap_ratio = 0.5; % fixed
overlap_amount = ceil(frame_size*overlap_ratio);
shift_amount = frame_size - overlap_amount;
num_of_frames = ceil((length(v) - frame_size + 1)/shift_amount);
len_of_v = frame_size + shift_amount*(num_of_frames - 1);

[win, win_start, win_end] = func_triWindow(1:frame_size);


v_fitted = zeros(1, len_of_v);
starting = 1;
for frame = 1 : num_of_frames
    ending = starting + frame_size - 1;
    v_seg = v(starting:ending);
    [fitresult, ~] = createFit_a1_notFixed(v_seg);
    v_seg_fitted = fitresult.a1*sin(fitresult.b1*[1:frame_size] + fitresult.c1);
    
    if frame == 1
        v_seg_fitted_win = win_start.*v_seg_fitted;    
    elseif frame == num_of_frames
        v_seg_fitted_win = win_end.*v_seg_fitted;    
    else
        v_seg_fitted_win = win.*v_seg_fitted;
    end

    z0 = zeros(1, len_of_v);
    z0(starting : ending) = v_seg_fitted_win;
    
    v_fitted = v_fitted + z0;
    
    display percent
    perc = (frame/num_of_frames)*100;
    disp([num2str(perc) '% done.']);
    
    starting = starting + shift_amount;
end

v_fitted = v_fitted(:);

    
function [fitresult, gof] = createFit_a1_notFixed(v)
%CREATEFIT(V)
%  Create a fit.
%
%  Data for 'untitled fit 1' fit:
%      Y Output: v
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  See also FIT, CFIT, SFIT.

%  Auto-generated by MATLAB on 06-Aug-2019 21:07:24


%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( [], v );

% Set up fittype and options.
ft = fittype( 'sin1' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
% opts.Lower = [0.060 0.008541427645474 -Inf]; % freq_range = 2*pi*[60-0.05 60+0.05]/Fs
% opts.StartPoint = [0.07 0.00855244388943172 1.48628663343297];
% opts.Upper = [0.080 0.008555675231205 Inf];
opts.Lower = [0.060 0.008463065923956 -Inf]; % freq_range = 2*pi*[60-0.6 60+0.6]/Fs
opts.StartPoint = [0.070 0.00855244388943172 1.48628663343297];
opts.Upper = [0.080 0.008634036952723 Inf];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

% % Plot fit with data.
% figure( 'Name', 'untitled fit 1' );
% h = plot( fitresult, xData, yData );
% legend( h, 'v', 'untitled fit 1', 'Location', 'NorthEast' );
% % Label axes
% ylabel v
% grid on