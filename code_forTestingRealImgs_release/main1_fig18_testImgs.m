clear all; close all; clc;

mydir  = pwd;
idcs   = strfind(mydir, '\');
newdir = mydir(1:idcs(end) - 1);
addpath([newdir, '\funcLibrary'])

set(0, 'DefaultFigureVisible', 'off');

%% settings

dataset_base_name_arr = {'60Hz_Jisoo7', '50Hz_Ren2'};

save_mat_flag = true;

repeat_times = 5;

colSelect_mode_arr = {'colRandOnOverall'}; %colSelect_mode_arr = {'colRandOnSmooth', 'colRandOnNonSmooth', 'colRandOnOverall'};


%% [step 1] baseline method - curve fitting

for jjj = 1 : length(colSelect_mode_arr)
    colSelect_mode = cell2mat(colSelect_mode_arr(jjj));
    
    for iii = 1 : length(dataset_base_name_arr)
        dataset_base_name  = cell2mat(dataset_base_name_arr(iii));
        img_folder_name    = ['images_test_', dataset_base_name];
        img_db_path        = ['.\datasets\' , img_folder_name, '\'];
        mat_file_base_name = ['res_', dataset_base_name];
        
        for num_of_col_to_use = 32 %[1 2 4 8 16 32 64 128]
            func_getFreqEstimatesUsingCurveFitting_real(save_mat_flag, mat_file_base_name, img_db_path, colSelect_mode, num_of_col_to_use, repeat_times);
        end
    end
end


%% [step 2] entropy minimization

% Note: Figurative results like fig.18 will be generated and stored under
% .\fig_results\

fitting_results_flag = 0; % 0: use random inital point / 1: use fitting results

for jjj = 1 : length(colSelect_mode_arr)
    colSelect_mode = cell2mat(colSelect_mode_arr(jjj));
    
    for iii = 1 : length(dataset_base_name_arr)
        dataset_base_name  = cell2mat(dataset_base_name_arr(iii));
        img_folder_name    = ['images_test_', dataset_base_name];
        img_db_path        = ['.\datasets\' , img_folder_name, '\'];
        mat_file_base_name = ['res_', dataset_base_name];
        
        for num_of_col_to_use = 32 %[1 2 4 8 16 32 64 128 256]
            open_mat_fn = sprintf('%s_fitting_%s_cols%d.mat', mat_file_base_name, colSelect_mode, num_of_col_to_use);
            load(['.\matResults\', open_mat_fn])
            
            func_testRealImgsBatch(img_db_path, mat_file_base_name, save_mat_flag, fitting_results_flag, colSelect_mode, repeat_times, fitting_results_decided, num_of_col_to_use);
        end
    end
end


