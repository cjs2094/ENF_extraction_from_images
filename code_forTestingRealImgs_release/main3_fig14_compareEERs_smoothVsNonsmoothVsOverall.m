%% analyze experimental results

clc; clear all; close all;
set(0, 'DefaultFigureVisible', 'on');

%% settings

% load mat files
mat_file_base_name1 = 'res_50Hz_Ren2';
mat_file_base_name2 = 'res_60Hz_Jisoo7';

fitting_results_flag = 0;

colSelect_mode_arr = {'colRandOnSmooth', 'colRandOnNonSmooth', 'colRandOnOverall'};

col_cnt = 32;

enf_strength_arr = [0 0.08 0.16 0.23 0.52 0.66 0.77];

TP_FN_usage_flag = 0; % TP
%TP_FN_usage_flag = 1; % combined (TP+FN)
%TP_FN_usage_flag = 2; % FN

%% [step 1] perform bootstrap

% Note: if resulting .mat file already exists, running the following function will
% be skipped and error msg will be shown. In that case, skip running this
% section and run the next section

func_performBootstrap_smoothVsNonsmoothVsOverall(mat_file_base_name1, mat_file_base_name2,...
    fitting_results_flag, colSelect_mode_arr, col_cnt, enf_strength_arr, TP_FN_usage_flag);


%% [step 2] compare EERs of entropy minimization applied to smooth, nonsmooth, and overall regions of images

func_compareEERs_smoothVsNonsmoothVsOverall...
    (mat_file_base_name1, mat_file_base_name2, fitting_results_flag, col_cnt);


