%% analyze experimental results

clc; clear all; close all;

mydir  = pwd;
idcs   = strfind(mydir, '\');
newdir = mydir(1:idcs(end) - 1);
addpath([newdir, '\funcLibrary'])

set(0, 'DefaultFigureVisible', 'on');

%% settings

% load mat files
mat_file_base_name1 = 'res_50Hz_Ren2';
mat_file_base_name2 = 'res_60Hz_Jisoo7';

fitting_results_flag = 0;

colSelect_mode = 'colRandOnOverall';

col_cnt = 32;

enf_strength_arr = [0 0.08 0.16 0.23 0.52 0.66 0.77];


%% [step 1] perform bootstrap

% Note: if resulting .mat file already exists, running the following function will
% be skipped and error msg will be shown. In that case, skip running this
% section and run the next section

func_performBootstrap_preliminaryVsProposed(mat_file_base_name1, mat_file_base_name2,...
    fitting_results_flag, colSelect_mode, col_cnt, enf_strength_arr);


%% [step 2] compare EERs of preliminary and proposed parametric models

func_compareEERs_preliminaryVsProposed(mat_file_base_name1, mat_file_base_name2, fitting_results_flag, colSelect_mode, col_cnt);




