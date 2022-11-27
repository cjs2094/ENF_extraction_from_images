%% analyze experimental results

clc; clear all; close all;

mydir  = pwd;
idcs   = strfind(mydir, '\');
newdir = mydir(1:idcs(end) - 1);
addpath([newdir, '\funcLibrary'])

set(0, 'DefaultFigureVisible', 'on');

%% settings

mat_file_base_name1 = 'res_50Hz_Ren2';
mat_file_base_name2 = 'res_60Hz_Jisoo7';

fitting_results_flag = 0;

colSelect_mode = 'colRandOnOverall'; % select among 'colRandOnSmooth', 'colRandOnNonSmooth', and 'colRandOnOverall'

col_cnt = 32;

enf_strength_arr = [0 0.08 0.16 0.23 0.52 0.66 0.77];
legendEntries_str = {'str=0.08', 'str=0.16', 'str=0.23', 'str=0.52', 'str=0.66', 'str=0.77'};


%% [step 1] draw roc curves for 1st level

eta1_threshold_opt_arr = [0.0060 0.0080 0.0100]; % on overall; manually chosen
gamma1_threshold_opt_arr = [10 20 25]; % on overall; manually chosen

% eta1_threshold_opt_arr = [0.003 0.004 0.005]; % on non-smooth; manually chosen
% gamma1_threshold_opt_arr = [4 12 20]; % on non-smooth; manually chosen
% 
% eta1_threshold_opt_arr = [0.015 0.020 0.025]; % on smooth; manually chosen
% gamma1_threshold_opt_arr = [4 12 20]; % on smooth; manually chosen

func_draw1stRocCurves_real(mat_file_base_name1, mat_file_base_name2, fitting_results_flag,...
    colSelect_mode, col_cnt, enf_strength_arr, legendEntries_str, eta1_threshold_opt_arr, gamma1_threshold_opt_arr);


%% [step 2] draw roc curves for 2nd level

FN_usage_flag = 0; % flag for false negative (0: not use FN results, 1: use FN + TP results of 1st level)

eta1_threshold_opt = 0.0100; % manually chosen; changable
gamma1_threshold_opt = 25;   % manually chosen; changable

func_draw2ndRocCurves_real(mat_file_base_name1, mat_file_base_name2, fitting_results_flag,...
    colSelect_mode, col_cnt, enf_strength_arr, legendEntries_str, eta1_threshold_opt, gamma1_threshold_opt, FN_usage_flag);

