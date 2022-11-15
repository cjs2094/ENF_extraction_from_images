function func_testRealImgsBatch(img_db_path, mat_file_base_name, save_mat_flag, fitting_results_flag, colSelect_mode, repeat_times, fitting_results_decided, num_of_col_to_use)
%% This code test the entropy minimization algorithm on syn images
% Chau-Wai Wong, Oct.-Nov. 2016
% Jisoo Choi, 4/4/2021

%%  Settings
clc
clear test_results

output_mat_fn = sprintf('%s_fitting_results_flag%d_%s_cols%d.mat',...
    mat_file_base_name, fitting_results_flag, colSelect_mode, num_of_col_to_use);

img_paths_cell = func_getAllImagePaths(img_db_path);
T_ro_db = func_getReadoutTimeDB();
img_cnt = length(img_paths_cell);
Fe_true = 2*str2num(mat_file_base_name(5:6));

myFolder = '.\fig_results';
if ~exist(myFolder, 'dir')
    mkdir(myFolder);
end

skip_flag = false;

j = 1;
t_start = tic;
for i = 1 : img_cnt
    for idx_repeat = 1 : repeat_times
        camera_model = img_paths_cell{i,2};
        T_readout = T_ro_db.time(camera_model); % in sec
        T_row = T_readout/T_ro_db.num_of_rows(camera_model); % in # of rows
        
        disp(['Processing img' num2str(i) ' ...'])
        disp(sprintf('Taken by %s, T_ro = %.1f ms, #rows = %d', camera_model, T_readout*1000, T_ro_db.num_of_rows(camera_model)));
        disp(sprintf('repeat #%d/%d', idx_repeat, repeat_times));
        
        img_file_location = img_paths_cell{i,3};
        img_rgb = imread(img_file_location);
        img_rgb = func_putImgToLandscape(img_rgb);
        img_gray = double(rgb2gray(img_rgb));
        img_size = size(img_gray);
        
        m_s = fitting_results_decided{j+1, 10}(1);
        m_t = fitting_results_decided{j+1, 10}(2);
        
        col_idx_set = fitting_results_decided{j+1, 9};
        
        mRange = m_s : m_t;
        [ISet, hatOfKSet, hatOfBSet] = func_estimateKBSet(img_gray, mRange, col_idx_set);
        
        fun_100 = @(x) func_entropyCol(img_gray, mRange, col_idx_set, T_row, 100, x(1), x(2), hatOfKSet, x(3));
        fun_120 = @(x) func_entropyCol(img_gray, mRange, col_idx_set, T_row, 120, x(1), x(2), hatOfKSet, x(3));
        
        
        if ~skip_flag
            %% load ENF est results from curve fitting
            fitresult = fitting_results_decided{j+1, 4};
            Fe_hat_curve = fitting_results_decided{j+1, 8};
            rmse_100 = fitting_results_decided{j+1, 5};
            rmse_120 = fitting_results_decided{j+1, 6};
            
            [~, Iavg, sinusoidalPartEnf_fit, trend_fit, error_fit]...
                = func_estimateEnfAndEntropyUsingFittingResults(img_gray, fitresult, Fe_hat_curve, T_row, m_s, m_t, col_idx_set, num_of_col_to_use);
            
            if Fe_true == Fe_hat_curve
                correctDecision_curve = 1; % 1: correct / 0: incorrect
            else
                correctDecision_curve = 0;
            end
            
            %% set initial point for entropy mini when fitting_results_flag = 1
            if fitting_results_flag == 1
                x0 = [fitresult.a_s fitresult.a_t fitresult.k fitresult.b fitresult.phi];
                ci = confint(fitresult, 0.9); % 0.01 -> 0.9
                LB = [ci(1,1) ci(1,2) -inf -inf ci(1,6)];
                UB = [ci(2,1) ci(2,2) inf inf ci(2,6)];
            end
            
            
            %% perform entropy mini
            search_result_cell = cell(2,1);
            for i_par = 1 : 2
                x_f100 = nan; fval_100 = nan;
                x_f120 = nan; fval_120 = nan;
                if i_par == 1
                    if fitting_results_flag == 1
                        [x_f100, fval_100] = func_fminsearchbnd(fun_100, x0, LB, UB);
                        
                    elseif fitting_results_flag == 0
                        fval_100 = 10^10;
                        %
                        for lll = 1 : 6 % try 6 random initial points, then select best result
                            [x0, LB, UB] = func_initForFminsearchbnd(lll);
                            [x_f100_temp, fval_100_temp] = func_fminsearchbnd(fun_100, x0, LB, UB);
                            
                            if fval_100_temp < fval_100
                                x_f100 = x_f100_temp;
                                fval_100 = fval_100_temp;
                            end
                        end
                        %
                    end
                    search_result_cell{i_par} = [x_f100 fval_100];
                    
                elseif i_par == 2
                    if fitting_results_flag == 1
                        [x_f120, fval_120] = func_fminsearchbnd(fun_120, x0, LB, UB);
                        
                    elseif fitting_results_flag == 0
                        fval_120 = 10^10;
                        %
                        for lll = 1 : 6 % try 6 random initial points, then select best result
                            [x0, LB, UB] = func_initForFminsearchbnd(lll);
                            [x_f120_temp, fval_120_temp] = func_fminsearchbnd(fun_120, x0, LB, UB);
                            
                            if fval_120_temp < fval_120
                                x_f120 = x_f120_temp;
                                fval_120 = fval_120_temp;
                            end
                        end
                        %
                    end
                    search_result_cell{i_par} = [x_f120 fval_120];
                end
            end
            
            x_f100   = search_result_cell{1}(1:3); fval_100 = search_result_cell{1}(4);
            x_f120   = search_result_cell{2}(1:3); fval_120 = search_result_cell{2}(4);
            entropy_margin = abs(fval_100 - fval_120);
            
            disp('## estimates:')
            disp(sprintf('a_s = %.2f, a_t = %.2f, phi = %.2f, obj = %.4f [100Hz]', x_f100(1), x_f100(2), x_f100(3), fval_100));
            disp(sprintf('a_s = %.2f, a_t = %.2f, phi = %.2f, obj = %.4f [120Hz]', x_f120(1), x_f120(2), x_f120(3), fval_120));
            
            j_decided = 3;
            if fval_100 < fval_120
                disp('decide 100 Hz');
                disp(sprintf('margin for obj: %.4f', entropy_margin))
                j_decided = 1;
                Fe_hat_entropy = 100;
                
                [img_residue_entMini, sinusoidalPartEnf_entropy] = func_removeENFfromImg...
                    (img_gray, img_size, T_row, 100, m_s, m_t, x_f100(1), x_f100(2), x_f100(3));
            elseif fval_100 > fval_120
                disp('decide 120 Hz');
                disp(sprintf('margin for obj: %.4f', entropy_margin))
                j_decided = 2;
                Fe_hat_entropy = 120;
                
                [img_residue_entMini, sinusoidalPartEnf_entropy] = func_removeENFfromImg...
                    (img_gray, img_size, T_row, 120, m_s, m_t, x_f120(1), x_f120(2), x_f120(3));
            else
                disp('cannot decide.')
            end
            
            
            %%
            if Fe_true == Fe_hat_entropy
                correctDecision_entropy = 1;
            else
                correctDecision_entropy = 0;
            end
            
            signalSet = img_gray(m_s:m_t, col_idx_set);
            signalSet = signalSet';
            trendSet = hatOfKSet(:)*[m_s : m_t] + hatOfBSet(:) * ones(1, m_t - m_s + 1);
            errorSet = signalSet - trendSet - sinusoidalPartEnf_entropy';
            residueSet = img_residue_entMini(mRange, col_idx_set);
            
            
            %% generate residue image by curve fitting
            [img_residue_curveFitting, ~] = func_removeENFfromImg...
                (img_gray, img_size, T_row, Fe_hat_curve, m_s, m_t, fitresult.a_s, fitresult.a_t, fitresult.phi);
            
            
            %% show results in one image
            if j_decided ~= 3
                output_img_fn1 = sprintf('fig_%s_total_results_fitting_results_flag%d_%s_cols%d_img%d_repeat%d',...
                    mat_file_base_name, fitting_results_flag, colSelect_mode, num_of_col_to_use, i, idx_repeat);
                img_file_name = ['./fig_results/' output_img_fn1 '.png'];
                
                if exist(img_file_name)
                    delete(img_file_name);
                end
                
                img_gray = uint8(img_gray);
                lim1 = stretchlim(img_gray);
                lim2 = stretchlim(img_residue_curveFitting);
                lim3 = stretchlim(img_residue_entMini);
                
                lim = [];
                lim(1) = min([lim1(1) lim2(1) lim3(1)]);
                lim(2) = max([lim1(2) lim2(2) lim3(2)]);
                
                
                %                 func_performFigurativeComp(img_gray, img_size, region, lim, mRange, Fe_hat_curve, Fe_hat_entropy,...
                %                     img_residue_curveFitting, sinusoidalPartEnf_fit, sinusoidalPartEnf_entropy, Iavg, trend_fit,...
                %                     error_fit, img_residue_entMini, ISet, residueSet, trendSet, errorSet, img_file_name)
                
                
                set(gcf, 'renderer', 'Painters');
                h = figure;
                set(h, 'Position', [100 100 750 170]); % %h.Position = [100 100 840 200];
                func_subplottight(1, 3, 1)
                J = imadjust(img_gray, lim, []);
                imshow(J);
                
                func_subplottight(1,3,2)
                J = imadjust(img_residue_entMini, lim, []);
                imshow(J);
                
                func_subplottight2(1,3,3)
                plot(mRange, sinusoidalPartEnf_entropy, 'k-', 'LineWidth', 1.2); grid on;
                legend(['estimated ($\hat{f}=' num2str(Fe_hat_entropy) ', f=', num2str(Fe_true),'$)'], ...
                    'Location', 'north', 'Interpreter', 'latex', 'fontSize', 8);
                xlim([1 img_size(1)]); ylim([-30 30]);
                xlabel('Row index i', 'Interpreter', 'latex', 'fontSize', 12);
                func_tightfig;
                saveas(h, img_file_name);
                img_file_name = ['./fig_results/' output_img_fn1 '.fig'];
                saveas(h, img_file_name);
                
            end
            
        else
            x_f100 = nan(1,3); fval_100 = nan;
            x_f120 = nan(1,3); fval_120 = nan;
            j_decided = 3;
            entropy_margin = nan;
        end
        
        
        %% save data
        current_idx_of_processed_imgs = (i-1)*repeat_times + idx_repeat;
        
        test_results(current_idx_of_processed_imgs) = struct(...
            'filename', img_paths_cell{i,1}, ...
            'unique_filename', [img_db_path img_paths_cell{i,4}], ...
            'img_size', img_size, ...
            'T_row', T_row, ...
            'col_idx_set', col_idx_set, ...
            'param_est_100Hz', x_f100, ...
            'rmse_100Hz', rmse_100, ...
            'obj_100Hz', fval_100, ...
            'param_est_120Hz', x_f120, ...
            'rmse_120Hz', rmse_120, ...
            'obj_120Hz', fval_120, ...
            'entropy_margin', entropy_margin, ...
            'Fe_true', Fe_true, ...
            'Fe_hat_curve', Fe_hat_curve, ...
            'Fe_hat_entropy', Fe_hat_entropy, ...
            'correctDecision_curve', correctDecision_curve, ...
            'correctDecision_entropy', correctDecision_entropy);
        %'sinusoidalPartEnf_entropy', sinusoidalPartEnf_entropy);
        
        if save_mat_flag
            save(['mat_results/' output_mat_fn], 'test_results');
            disp('Mat file with intermediate results saved.')
        else
            disp('Intermediate results NOT saved, but can be seen in workspace.');
        end
        
        j = j + 1;
        
        %% show progress
        t_passed = toc(t_start) / 60;  % in min
        eta = current_idx_of_processed_imgs / (img_cnt * repeat_times);
        t_remaining = t_passed / eta - t_passed;
        disp(sprintf('time passed: %.0f hrs %.0f mins', floor(t_passed/60), mod(t_passed, 60)));
        disp(sprintf('time remaining: %.0f hrs %.0f mins', floor(t_remaining/60), mod(t_remaining, 60)));
        disp(sprintf('\n'));
        
    end
end

