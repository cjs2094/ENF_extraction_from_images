function func_getFreqEstimatesUsingCurveFitting_preModel(save_mat_flag, mat_file_name, img_db_path, colSelect_mode, num_of_col_to_use, repeat_times)

clc
clear fitting_results_all
clear fitting_results_decided

output_mat_fn = sprintf('%s_fitting_%s_cols%d.mat', mat_file_name, colSelect_mode, num_of_col_to_use);
img_paths_cell = func_getAllImagePaths(img_db_path);
img_cnt = length(img_paths_cell);
Fe_true = 2*str2num(mat_file_name(5:6));

fitting_results_all = {'img_file_location', 'Fe_set', 'bound_flag', 'fitresult', 'rmse', 'Fe_true', 'Fe_hat_curve'};
fitting_results_decided = {'img_file_location', 'Fe_set', 'bound_flag', 'fitresult',...
    'rmse_100Hz', 'rmse_120Hz', 'Fe_true', 'Fe_hat_curve', 'col_idx_set', 'region: [m_s, m_t, n_s, n_t]'};

ind_for_fitting_results_all = 2;
ind_for_fitting_results_decided = 2;
for i = 1 : img_cnt
    for idx_repeat = 1 : repeat_times
        camera_model = img_paths_cell{i,2};
        img_file_location = img_paths_cell{i,3};
        img_rgb = imread(img_file_location);
        [img_rgb, ~] = func_putImgToLandscape(img_rgb);
        img_gray = double(rgb2gray(img_rgb));
        img_size = size(img_gray);
        
        y_s_smooth = img_paths_cell{i,5}(1);
        y_t_smooth = img_paths_cell{i,5}(2);
        x_s_smooth = img_paths_cell{i,5}(3);
        x_t_smooth = img_paths_cell{i,5}(4);      
        y_s_nonsmooth = img_paths_cell{i,6}(1);
        y_t_nonsmooth = img_paths_cell{i,6}(2);
        x_s_nonsmooth = img_paths_cell{i,6}(3);
        x_t_nonsmooth = img_paths_cell{i,6}(4);
         
        if isequal(colSelect_mode, 'colRandOnOverall')  % random column index set from overall regions
            m_s = 1;
            m_t = img_size(1);
            n_s = 1;
            n_t = img_size(2);       
        elseif isequal(colSelect_mode, 'colRandOnSmooth') % random column index set from only smooth regions
            m_s = y_s_smooth;
            m_t = y_t_smooth;
            n_s = x_s_smooth;
            n_t = x_t_smooth;   
        elseif isequal(colSelect_mode, 'colRandOnNonSmooth') % random column index set from only smooth regions
            m_s = y_s_nonsmooth;
            m_t = y_t_nonsmooth;
            n_s = x_s_nonsmooth;
            n_t = x_t_nonsmooth;
        end
        
        %% select evenly spaced columns; The further they are apart, the lower the correlation we will have.
        num_of_n = n_t - n_s + 1;
        maxWidth = floor(num_of_n/num_of_col_to_use);
        n_s0 = randsample(n_s : n_s + maxWidth - 1, 1);
        col_idx_set = n_s0 : maxWidth:n_s0 + maxWidth*(num_of_col_to_use - 1);
        
        I = mean(img_gray(m_s:m_t, col_idx_set), 2);
        I = I(:);
        mRange = m_s : m_t;
        
        %% curve fitting
        [fitting_results_all, ind_for_fitting_results_all] = func_curveFitting_preModel...
            (img_file_location, camera_model, Fe_true, mRange, I, fitting_results_all, ind_for_fitting_results_all);
        
        
        %% save as "fitting_results_decided"
        rmse_arr = cell2mat(fitting_results_all(ind_for_fitting_results_all - 4 : ind_for_fitting_results_all - 1, 5));
        Fe_hat_curve_arr = cell2mat(fitting_results_all(ind_for_fitting_results_all - 4 : ind_for_fitting_results_all - 1, 7));
        [~, ind_for_smallest_rmse] = min(rmse_arr);
        rmse_100Hz = min(rmse_arr(1:2));
        rmse_120Hz = min(rmse_arr(3:4));
        Fe_hat_curve = Fe_hat_curve_arr(ind_for_smallest_rmse);
        
        ind_temp = ind_for_fitting_results_all - 5 + ind_for_smallest_rmse;
        cell_temp = [fitting_results_all(ind_temp, 1:4), rmse_100Hz, rmse_120Hz, ...
            Fe_true, Fe_hat_curve, col_idx_set, [m_s, m_t, n_s, n_t]];
        
        fitting_results_decided(ind_for_fitting_results_decided, :) = cell_temp;
        ind_for_fitting_results_decided = ind_for_fitting_results_decided + 1;
        
        myFolder = '.\mat_results_preModel';
        if ~exist(myFolder, 'dir')
            mkdir(myFolder);
        end
        
        if save_mat_flag
            save(['.\mat_results_preModel\', output_mat_fn], 'fitting_results_all', 'fitting_results_decided');
        else
            disp('Intermediate results NOT saved, but can be seen in workspace.');
        end
        
        
    end
end

disp('Mat file results saved.')

