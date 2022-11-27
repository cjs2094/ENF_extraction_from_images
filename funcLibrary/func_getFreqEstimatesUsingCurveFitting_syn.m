function func_getFreqEstimatesUsingCurveFitting_syn(save_mat_flag, mat_file_name, img_db_path, colSelect_mode, num_of_col_to_use, repeat_times)

clc
clear fitting_results_all
clear fitting_results_decided

output_mat_fn = sprintf('%s_fitting_%s_cols%d.mat', mat_file_name, colSelect_mode, num_of_col_to_use);
img_paths_cell = func_getAllImagePaths(img_db_path);
%freq_arr = [100, 120, -1]; % 100 Hz vs 120 Hz vs cannot decide
%T_ro_db = getReadoutTimeDB();
img_cnt = length(img_paths_cell);
%ENF_arr = [100, 120];
Fe_true = 2*str2num(mat_file_name(end - 3 : end - 2));

fitting_results_all = {'img_file_location', 'Fe_set', 'bound_flag', 'fitresult', 'rmse', 'Fe_true', 'Fe_hat_curve'};
fitting_results_decided = {'img_file_location', 'Fe_set', 'bound_flag', 'fitresult',...
    'rmse_100Hz', 'rmse_120Hz', 'Fe_true', 'Fe_hat_curve', 'col_idx_set', 'region: [m_s, m_t, n_s, n_t]'};

ind_for_fitting_results_all = 2;
ind_for_fitting_results_decided = 2;
t_start = tic;
for i = 1 : img_cnt
    for idx_repeat = 1 : repeat_times
        camera_model = img_paths_cell{i, 2};
        img_file_location = img_paths_cell{i, 3};
        img_rgb = imread(img_file_location);
        [img_rgb, ~] = func_putImgToLandscape(img_rgb);
        img_gray = double(rgb2gray(img_rgb));
        img_size = size(img_gray);
        
        y_s_smooth = img_paths_cell{i, 5}(1);
        y_t_smooth = img_paths_cell{i, 5}(2);
        x_s_smooth = img_paths_cell{i, 5}(3);
        x_t_smooth = img_paths_cell{i, 5}(4);
        
        y_s_nonsmooth = img_paths_cell{i, 6}(1);
        y_t_nonsmooth = img_paths_cell{i, 6}(2);
        x_s_nonsmooth = img_paths_cell{i, 6}(3);
        x_t_nonsmooth = img_paths_cell{i, 6}(4);
        
        
        if isequal(colSelect_mode, 'colRandOnOverall')  % random column index set from overall regions
            m_s = 1;
            m_t = img_size(1);
            n_s = 1;
            n_t = img_size(2);
            
            % randomly select columns
            % col_idx_set = randsample(x_s:x_t, num_of_col_to_use);
            
            % select evenly spaced columns; The further they are apart, the lower the correlation we will have.
            num_of_n = n_t - n_s + 1;
            maxWidth = floor(num_of_n/num_of_col_to_use);
            n_s0 = randsample(n_s : n_s + maxWidth - 1, 1);
            col_idx_set = n_s0 : maxWidth:n_s0 + maxWidth*(num_of_col_to_use - 1);
        elseif isequal(colSelect_mode, 'colRandOnSmooth') % random column index set from only smooth regions
            m_s = y_s_smooth;
            m_t = y_t_smooth;
            n_s = x_s_smooth;
            n_t = x_t_smooth;
            
            % randomly select columns
            % col_idx_set = randsample(x_s:x_t, num_of_col_to_use);
            
            % select evenly spaced columns; The further they are apart, the lower the correlation we will have.
            num_of_n = n_t - n_s + 1;
            maxWidth = floor(num_of_n/num_of_col_to_use);
            n_s0 = randsample(n_s : n_s + maxWidth - 1, 1);
            col_idx_set = n_s0 : maxWidth:n_s0 + maxWidth*(num_of_col_to_use - 1);
        elseif isequal(colSelect_mode, 'colRandOnNonSmooth') % random column index set from only smooth regions
            m_s = y_s_nonsmooth;
            m_t = y_t_nonsmooth;
            n_s = x_s_nonsmooth;
            n_t = x_t_nonsmooth;
            
            % randomly select columns
            % col_idx_set = randsample(x_s:x_t, num_of_col_to_use);
            
            % select evenly spaced columns; The further they are apart, the lower the correlation we will have.
            num_of_n = n_t - n_s + 1;
            maxWidth = floor(num_of_n/num_of_col_to_use);
            n_s0 = randsample(n_s : n_s + maxWidth - 1, 1);
            col_idx_set = n_s0:maxWidth:n_s0 + maxWidth*(num_of_col_to_use - 1);
        end
        
        I = mean(img_gray(m_s : m_t, col_idx_set), 2);
        I = I(:);
        mRange = m_s : m_t;
        
        
        %% curve fitting
        [fitting_results_all, ind_for_fitting_results_all] = func_curveFitting...
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
        
        if save_mat_flag
            save(['.\mat_results_syn\', output_mat_fn], 'fitting_results_all', 'fitting_results_decided');
        else
            disp('Intermediate results NOT saved, but can be seen in workspace.');
        end
        
        %     fitting_results_current = fitting_results_all(ind_for_fitting_results_all - 4 : ind_for_fitting_results_all - 1, :);
        %
        %
        %     close all;
        %     h1 = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
        %     for j = 1 : 4
        %         if mod(j, 2) == 1
        %             part_of_title = '$\hat{A}_{fit}(i) > 0$';
        %         elseif mod(j, 2) == 0
        %             part_of_title = '$\hat{A}_{fit}(i) < 0$';
        %         end
        %
        %         rmse = fitting_results_current{j, 11};
        %         freq = fitting_results_current{j, 13};
        %
        %         subplot(2, 2, j)
        %         plot(x, hat_of_I, 'k-'); hold on;
        %         plot(x, fitting_results_current{j, 7}, '--', 'LineWidth', 1.5);
        %         plot(x, fitting_results_current{j, 8}, ':',  'LineWidth', 1.5);
        %         plot(x, fitting_results_current{j, 9}, '-.', 'LineWidth', 1.5);
        %         plot(x, fitting_results_current{j, 10}, '-', 'LineWidth', 1.5); hold off;
        %         grid on;
        %         xlabel('Row index i', 'FontSize', 14', 'Interpreter', 'latex');
        %         legend({'$\hat{I}(i)$', '$\hat{I}_{fit}(i)$', '$\hat{A}_{fit}(i)$', '$\hat{trend}_{fit}(i)$',...
        %             '$\cos$ $\Big($2$\pi$ $\frac{ \hat{f}_{ENF, fit} }{f_{row}}$ $\cdot$ $i$ + $\hat{\phi}_{fit}$ $\Big)$'},...
        %             'fontsize', 10, 'Interpreter', 'latex', 'Location', 'Best');
        %         xlim([y_s y_t]); %ylim([-30 yRange]);
        %         title({['Parametric fitting with ' part_of_title ],[' (freq = ' num2str(freq) ' Hz, rmse=' num2str(rmse) ')']}, 'Interpreter', 'latex')
        %     end
        %     fn1 = ['./fig_results/fig_' mat_file_name '_fitting_img' num2str(i) '_Fe_decided_' num2str(Fe_decided) '.png'];
        %     saveas(h1, fn1, 'png');
        %
        %
        %     h2 = figure; %figure('units','normalized','outerposition',[0 0 1 1]);
        %     plot(x, fitting_results_decided{i+1, 6}, 'k-'); hold on;
        %     plot(x, fitting_results_decided{i+1, 7}, '--', 'LineWidth', 1.5);
        %     plot(x, fitting_results_decided{i+1, 8}, ':',  'LineWidth', 1.5);
        %     plot(x, fitting_results_decided{i+1, 9}, '-.', 'LineWidth', 1.5);
        %     plot(x, fitting_results_decided{i+1, 10}, '-', 'LineWidth', 1.5); hold off;
        %     grid on;
        %     xlabel('Row index $i$', 'FontSize', 14', 'Interpreter', 'latex')
        %     legend({'$\hat{I}(i)$', '$\hat{I}_{fit}(i)$', '$\hat{A}_{fit}(i)$', '$\hat{trend}_{fit}(i)$',...
        %             '$\cos$ $\Big($2$\pi$ $\frac{ \hat{f}_{ENF, fit} }{f_{row}}$ $\cdot$ $i$ + $\hat{\phi}_{fit}$ $\Big)$'},...
        %             'fontsize', 10, 'Interpreter', 'latex', 'Location', 'Best');
        %     xlim([y_s y_t]); %ylim([-30 yRange]);
        %     set(gcf, 'Position',  [100, 100, 500, 400])
        %
        %     fn2 = ['./fig_results/fitting/fig_' mat_file_name '_best_fitting_img' num2str(i) '.png'];
        %     saveas(h2, fn2, 'png');
        
        %% show progress
        current_idx_of_processed_imgs = (i-1)*repeat_times + idx_repeat;       
        t_passed = toc(t_start)/60;  % in min
        eta = current_idx_of_processed_imgs/(img_cnt*repeat_times);
        t_remaining = t_passed/eta - t_passed;
        disp(sprintf('time passed: %.2f hrs %.2f mins', floor(t_passed/60), mod(t_passed, 60)));
        disp(sprintf('time remaining: %.2f hrs %.2f mins', floor(t_remaining/60), mod(t_remaining, 60)));
        disp(sprintf('\n'));
        
        
    end
    
    
end

disp('Mat file results saved.')

