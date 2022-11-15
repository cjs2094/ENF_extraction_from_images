%% analyze experimental results

clc; clear all; close all;
set(0, 'DefaultFigureVisible', 'on');

%% settings

% load mat files
mat_file_base_name1 = 'res_synthetic_6imgs_50Hz';
mat_file_base_name2 = 'res_synthetic_6imgs_60Hz';

fitting_results_flag = 0;

%colSelect_mode = 'colRandOnSmooth';
%colSelect_mode = 'colRandOnNonSmooth';
colSelect_mode = 'colRandOnOverall';

col_cnt = 32;

enf_strength_arr = [0 2^(-1) 2^(-0.5) 2^0 2^(0.5) 2^1 2^2 2^3 2^4];
legendEntries_str = {'str=0.5', 'str=0.7', 'str=1.0', 'str=1.4',...
    'str=2.0', 'str=4.0', 'str=8.0', 'str=16 '};


%% [step 1] draw roc curves for 1st level

eta1_threshold_opt_arr = [0.0020 0.0040 0.0060]; % manually chosen
gamma1_threshold_opt_arr = [4 5 6]; % manually chosen

func_draw1stRocCurves(mat_file_base_name1, mat_file_base_name2, fitting_results_flag,...
    colSelect_mode, col_cnt, enf_strength_arr, legendEntries_str, eta1_threshold_opt_arr, gamma1_threshold_opt_arr);


%% [step 2] draw roc curves for 2nd level

eta1_threshold_opt = 0.0040; % manually chosen
gamma1_threshold_opt = 5; % manually chosen

func_draw2ndRocCurves(mat_file_base_name1, mat_file_base_name2, fitting_results_flag,...
    colSelect_mode, col_cnt, enf_strength_arr, legendEntries_str, eta1_threshold_opt, gamma1_threshold_opt);



