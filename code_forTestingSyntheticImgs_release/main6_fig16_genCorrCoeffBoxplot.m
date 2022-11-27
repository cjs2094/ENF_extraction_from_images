
clc; clear all; close all;

mydir  = pwd;
idcs   = strfind(mydir, '\');
newdir = mydir(1:idcs(end) - 1);
addpath([newdir, '\funcLibrary'])

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

enf_strength_arr = [0 2^(-1) 2^(-0.5) 2^0 2^(0.5) 2^1 2^2 2^3 2^4]; %[0 0.5 1 2 4 8 16];


%% generate correlation coefficient boxplot for performance comparison of entropy minimization and curve fitting

func_genCorrCoeffBoxplot(mat_file_base_name1, mat_file_base_name2, fitting_results_flag, colSelect_mode, col_cnt, enf_strength_arr);
