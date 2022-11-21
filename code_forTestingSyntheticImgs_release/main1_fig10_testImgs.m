close all; clear all; clc;
set(0, 'DefaultFigureVisible', 'off');

%% settings

img_path = '.\raw_imgs\';

save_mat_flag = true;

img_gen_cnt = 1;

mat_file_base_name = 'res_synthetic_6imgs';

T_readout = 30.9e-3; % sec, read-out time for iPhone 6

T_row = T_readout/2448;

use_relative_or_absolute_mag_flag = 2; % 1: relative, 2: absolute

absolute_mag_arr_y = [0 2^(-1) 2^(-0.5) 2^0 2^(0.5) 2^1 2^2 2^3 2^4];

relative_mag = 0.05; % 0.00625

color_channel_mode = 'rgb'; % 'rgb', 'gray', 'pcaBest'

fitting_results_flag = 0; % 1: use fitting results for initial point for ent mini, or 0: use random inital point

% obj_func_ver = 1; % 1: column mode, or 2: block mode

% colSelect_mode_arr = {'colRandOnOverall', 'colRandOnSmooth', 'colRandOnNonSmooth'};
colSelect_mode_arr = {'colRandOnOverall'};
    
repeat_times = 1; %20;


%% [step 1] generate imgs with syn enf

% Note 1: Folder 'raw_imgs' includes template images that do not contatin
% detectable ENF traces
% Note 2: Generate synthtic ENF traces and add them to the raw images in
% 'raw_imgs' to create ENF-containing images under the folder named
% 'imgs_with_syn_enf'
% Note 3: .mat files are created 

for iii = [50 60]
    ENF = 2*iii;
    mat_file_name = [mat_file_base_name '_' num2str(iii) 'Hz'];
    
    func_genImgsWithEnf(img_path, img_gen_cnt, save_mat_flag, T_row, ...
        use_relative_or_absolute_mag_flag, absolute_mag_arr_y, relative_mag, color_channel_mode, mat_file_name, ENF);
end


%% [step 2] perform curve fitting

for jjj = 1 : length(colSelect_mode_arr)
    colSelect_mode = cell2mat(colSelect_mode_arr(jjj));
    for iii = [50 60]
        mat_file_name = [mat_file_base_name '_' num2str(iii) 'Hz'];
        
        img_db_path = ['.\imgs_with_syn_enf\' mat_file_name '\'];
        
        for num_of_col_to_use = 32 %[1 2 4 8 16 32 64 128]
            func_getFreqEstimatesUsingCurveFitting(save_mat_flag, mat_file_name, img_db_path, colSelect_mode, num_of_col_to_use, repeat_times)
        end
    end
end


%% [step 3] perform entropy minimization using curve fitting results

% Note: Figurative results like fig.10 will be generated and stored under
% .\fig_results\

for jjj = 1 : length(colSelect_mode_arr)
    colSelect_mode = cell2mat(colSelect_mode_arr(jjj));
    for iii = [50 60]
        mat_file_name = [mat_file_base_name '_' num2str(iii) 'Hz'];
        
        img_db_path = ['.\imgs_with_syn_enf\' mat_file_name '\'];
        
        open_mat_fn1 = ['.\mat_results_syn\' mat_file_name '.mat'];
        load(open_mat_fn1)
        
        for num_of_col_to_use = 32 %[1 2 4 8 16 32 64 128]
            open_mat_fn2 = sprintf('%s_fitting_%s_cols%d.mat', mat_file_name, colSelect_mode, num_of_col_to_use);
            
            %open_mat_fn2 = strcat(['.\mat_results\' mat_file_name, '_fitting.mat']);
            load(['.\mat_results_syn\', open_mat_fn2])
            
            func_testRealImgsBatch(img_db_path, mat_file_name, save_mat_flag, fitting_results_flag, colSelect_mode, repeat_times, results, fitting_results_decided, num_of_col_to_use)
        end
    end
end



