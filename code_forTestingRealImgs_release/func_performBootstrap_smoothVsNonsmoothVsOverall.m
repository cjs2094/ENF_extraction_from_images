function func_performBootstrap_smoothVsNonsmoothVsOverall(mat_file_base_name1, mat_file_base_name2, fitting_results_flag, colSelect_mode_arr, col_cnt, enf_strength_arr, TP_FN_usage_flag)

fn0 = ['.\matResults\bootstrap_smoothVsNonsmoothVsOverall_', mat_file_base_name1, '_', ...
    mat_file_base_name2, '_fitting_results_flag', num2str(fitting_results_flag), '_cols' num2str(col_cnt) '.mat'];

if exist(fn0)
   error(['Breaking out of function.', newline, fn0 ' already exists. Please skip running this function.']);
end


%% settings
num_of_bootstrap = 100; % number of bootstrapping

%% check files

for ii = 1 : length(colSelect_mode_arr)
    colSelect_mode = cell2mat(colSelect_mode_arr(ii));
    
    fn1 = ['.\matResults\' mat_file_base_name1 '_fitting_results_flag' num2str(fitting_results_flag) '_', colSelect_mode, '_cols' num2str(col_cnt) '.mat'];
    fn2 = ['.\matResults\' mat_file_base_name2 '_fitting_results_flag' num2str(fitting_results_flag) '_', colSelect_mode, '_cols' num2str(col_cnt) '.mat'];
    
    if ~exist(fn1) && ~exist(fn2)
        error('Error. No prerequired mat files found.')
    end
end


%%

for ii = 1 : length(colSelect_mode_arr)
    colSelect_mode = cell2mat(colSelect_mode_arr(ii));
    
    %% parse of fields of results
    
    load(['.\matResults\' mat_file_base_name1 '_fitting_results_flag' num2str(fitting_results_flag) '_', colSelect_mode, '_cols' num2str(col_cnt) '.mat']);
    
    aug_results_100 = test_results;
    for i = 1 : length(test_results)
        [~, enf_strength_level] = func_getExposureTimeEnfStrengthLevel(test_results(i).filename);
        aug_results_100(i).enf_strength_level =  enf_strength_level; % there's actually a minus sign before encoding
    end
    
    enf_strength_level_arr = sort(unique([aug_results_100(:).enf_strength_level]));
    cnt_enf_strength_levels = length(enf_strength_level_arr);
    
    load(['.\matResults\' mat_file_base_name2 '_fitting_results_flag' num2str(fitting_results_flag) '_', colSelect_mode, '_cols' num2str(col_cnt) '.mat']);
    
    aug_results_120 = test_results;
    for i = 1 : length(test_results)
        [~, enf_strength_level] = func_getExposureTimeEnfStrengthLevel(test_results(i).filename);
        aug_results_120(i).enf_strength_level =  enf_strength_level; % there's actually a minus sign before encoding
    end
    
    
    %% entropy mini - 1st level classification
    x0 = linspace(0, 1, 100);
    y0 = 1 - x0;
    EER_entropy_arr_1st = [];
    
    
    enf_strength_levels_reordered = [1, 2 : 1 : cnt_enf_strength_levels];
    for kk = 1 : length(enf_strength_levels_reordered)
        i = enf_strength_levels_reordered(kk);
        this_level = enf_strength_level_arr(i);
        this_strength = enf_strength_arr(this_level);
        
        disp(['enf strength index = ' num2str(this_level)]);
        
        logical_100_arr = ([aug_results_100.enf_strength_level] == this_level);
        logical_120_arr = ([aug_results_120.enf_strength_level] == this_level);
        
        results_part_100 = aug_results_100(logical_100_arr);
        results_part_120 = aug_results_120(logical_120_arr);
        
        if this_strength == 0
            results_part_100_noENF = results_part_100;
            results_part_120_noENF = results_part_120;
            sample_size = length(results_part_100);
        else
            for jj = 1 : num_of_bootstrap
                results_part_100_noENF_bootstrapped = datasample(results_part_100_noENF, sample_size);
                results_part_120_noENF_bootstrapped = datasample(results_part_120_noENF, sample_size);
                results_part_100_bootstrapped = datasample(results_part_100, sample_size);
                results_part_120_bootstrapped = datasample(results_part_120, sample_size);
                
                
                %% create test statistics %%%
                temp1 = [results_part_100_noENF_bootstrapped.entropy_margin];
                temp2 = [results_part_120_noENF_bootstrapped.entropy_margin];
                entropy_margin_noENF = [temp1(:); temp2(:)];
                eta1_dist_noENF = entropy_margin_noENF;
                
                temp1 = [results_part_100_bootstrapped.entropy_margin];
                temp2 = [results_part_120_bootstrapped.entropy_margin];
                entropy_margin_ENF = [temp1(:); temp2(:)];
                eta1_dist_ENF = entropy_margin_ENF;
                
                
                %% generate data for ROC curves
                eta1_threshold_arr = 0 : 0.00005 : 1; %threshold; linspace(-1,1,10000);
                FPR_arr = [];
                TPR_arr = [];
                for k = 1 : length(eta1_threshold_arr)
                    eta1_threshold = eta1_threshold_arr(k);
                    
                    TN_cnt = eta1_dist_noENF <  eta1_threshold;
                    FP_cnt = eta1_dist_noENF >= eta1_threshold;
                    TP_cnt = eta1_dist_ENF   >= eta1_threshold;
                    FN_cnt = eta1_dist_ENF   <  eta1_threshold;
                    
                    TPR = sum(TP_cnt)/(sum(TP_cnt) + sum(FN_cnt));
                    FPR = sum(FP_cnt)/(sum(TN_cnt) + sum(FP_cnt));
                    TPR_arr(k) = TPR;
                    FPR_arr(k) = FPR;
                end
                
                
                %% calculate EER 
                [xi, ~] = polyxpoly(x0, y0, FPR_arr, TPR_arr);
                EER = xi(1);
                EER_entropy_arr_1st(jj, i-1) = EER;                
                %             %% Step4) calculate AUC %%%
                %             AUC = -trapz(FPR_arr, TPR_arr);
                %             AUC_entropy_arr(jj, i-1) = AUC;
            end
        end
    end
    
    
    
    %% entropy mini - 2nd level classification
    
    %%%%%%%% manually chosen %%%%%%%%
    if isequal(colSelect_mode, 'colRandOnSmooth')
        eta1_opt_entropy = 0.015; %on smooth: [0.015 0.020 0.025];
    elseif isequal(colSelect_mode, 'colRandOnNonSmooth')
        eta1_opt_entropy = 0.003; %on non-smooth: [0.003 0.004 0.005];
    elseif isequal(colSelect_mode, 'colRandOnOverall')
        eta1_opt_entropy = 0.0060; % on overall: [0.0060 0.0080 0.0100] % changable
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
    EER_entropy_arr_2nd = [];
    
    enf_strength_levels_reordered = [1, 2 : 1 : cnt_enf_strength_levels];
    for kk = 1 : length(enf_strength_levels_reordered)
        i = enf_strength_levels_reordered(kk);
        this_level = enf_strength_level_arr(i);
        this_strength = enf_strength_arr(this_level);
        
        if this_strength ~= 0
            disp(['enf strength index = ' num2str(this_level)]);
            
            logical_100_arr = ([aug_results_100.enf_strength_level] == this_level);
            logical_120_arr = ([aug_results_120.enf_strength_level] == this_level);
            
            results_part_100 = aug_results_100(logical_100_arr);
            results_part_120 = aug_results_120(logical_120_arr);
            
            for jj = 1 : num_of_bootstrap
                sample_size = length(results_part_100);
                
                results_part_100_bootstrapped = datasample(results_part_100, sample_size);
                results_part_120_bootstrapped = datasample(results_part_120, sample_size);
                
                %% select only true positive outcomes of the 1st level
                
                entropy_margin_100 = [results_part_100_bootstrapped.entropy_margin];
                entropy_margin_100 = entropy_margin_100(:);
                obj_100Hz_100 = [results_part_100_bootstrapped.obj_100Hz];
                obj_100Hz_100 = obj_100Hz_100(:);
                obj_120Hz_100 = [results_part_100_bootstrapped.obj_120Hz];
                obj_120Hz_100 = obj_120Hz_100(:);
                
                if TP_FN_usage_flag == 0
                    locations_100 = entropy_margin_100 > eta1_opt_entropy;
                    obj_100Hz_100_cutoff = obj_100Hz_100(locations_100);
                    obj_120Hz_100_cutoff = obj_120Hz_100(locations_100);
                elseif TP_FN_usage_flag == 1
                    obj_100Hz_100_cutoff = obj_100Hz_100;
                    obj_120Hz_100_cutoff = obj_120Hz_100;
                elseif TP_FN_usage_flag == 2
                    locations_100 = entropy_margin_100 <= eta1_opt_entropy;
                    obj_100Hz_100_cutoff = obj_100Hz_100(locations_100);
                    obj_120Hz_100_cutoff = obj_120Hz_100(locations_100);
                end
                
                entropy_margin_120 = [results_part_120_bootstrapped.entropy_margin];
                entropy_margin_120 = entropy_margin_120(:);
                obj_100Hz_120 = [results_part_120_bootstrapped.obj_100Hz];
                obj_100Hz_120 = obj_100Hz_120(:);
                obj_120Hz_120 = [results_part_120_bootstrapped.obj_120Hz];
                obj_120Hz_120 = obj_120Hz_120(:);
                
                if TP_FN_usage_flag == 0
                    locations_120 = entropy_margin_120 > eta1_opt_entropy;
                    obj_100Hz_120_cutoff = obj_100Hz_120(locations_120);
                    obj_120Hz_120_cutoff = obj_120Hz_120(locations_120);
                elseif TP_FN_usage_flag == 1
                    obj_100Hz_120_cutoff = obj_100Hz_120;
                    obj_120Hz_120_cutoff = obj_120Hz_120;
                elseif TP_FN_usage_flag == 2
                    locations_120 = entropy_margin_120 <= eta1_opt_entropy;
                    obj_100Hz_120_cutoff = obj_100Hz_120(locations_120);
                    obj_120Hz_120_cutoff = obj_120Hz_120(locations_120);
                end
                
                
                %% [step 2] create test statistics
                
                obj_100Hz_arr = [obj_100Hz_100_cutoff];
                obj_120Hz_arr = [obj_120Hz_100_cutoff];
                
                eta2_dist_100 = [];
                for j = 1 : length(obj_100Hz_arr)
                    eta2_dist_100(j) = obj_100Hz_arr(j) - obj_120Hz_arr(j);
                end
                
                obj_100Hz_arr = [obj_100Hz_120_cutoff];
                obj_120Hz_arr = [obj_120Hz_120_cutoff];
                
                eta2_dist_120 = [];
                for j = 1 : length(obj_100Hz_arr)
                    eta2_dist_120(j) = obj_100Hz_arr(j) - obj_120Hz_arr(j);
                end
                
                
                %% data generation for ROC curves
                
                eta2_threshold_arr = -1 : 0.0001 : 1;
                TPR_arr = [];
                FPR_arr = [];
                for k = 1 : length(eta2_threshold_arr)
                    eta2_threshold = eta2_threshold_arr(k);
                    
                    TN_cnt = eta2_dist_100 <  eta2_threshold;
                    FP_cnt = eta2_dist_100 >= eta2_threshold;
                    TP_cnt = eta2_dist_120 >= eta2_threshold;
                    FN_cnt = eta2_dist_120 <  eta2_threshold;
                    
                    TPR = sum(TP_cnt)/(sum(TP_cnt) + sum(FN_cnt));
                    FPR = sum(FP_cnt)/(sum(TN_cnt) + sum(FP_cnt));
                    TPR_arr(k) = TPR;
                    FPR_arr(k) = FPR;
                end
                
                
                %% calculate EER
                if any(isnan(FPR_arr(:))) || any(isnan(FPR_arr(:)))
                    EER = NaN;
                else
                    [xi, ~] = polyxpoly(x0, y0, FPR_arr, TPR_arr);
                    EER = xi(1);
                end
                EER_entropy_arr_2nd(jj, i-1) = EER;
     
            end
        end
    end
    
    
    if isequal(colSelect_mode, 'colRandOnSmooth')
        EER_entropy_arr_smooth_1st    = EER_entropy_arr_1st;
        EER_entropy_arr_smooth_2nd_TP = EER_entropy_arr_2nd;
    elseif isequal(colSelect_mode, 'colRandOnNonSmooth')
        EER_entropy_arr_nonsmooth_1st    = EER_entropy_arr_1st;
        EER_entropy_arr_nonsmooth_2nd_TP = EER_entropy_arr_2nd;
    elseif isequal(colSelect_mode, 'colRandOnOverall')
        EER_entropy_arr_overall_1st    = EER_entropy_arr_1st;
        EER_entropy_arr_overall_2nd_TP = EER_entropy_arr_2nd;
    end
    
    
end


str_arr = [];
for i = 1 : length(enf_strength_arr)
    temp = enf_strength_arr(i);
    
    if temp ~= 0
        str_arr = [str_arr, temp];
    end
end


save(fn0, 'EER_entropy_arr_smooth_1st', 'EER_entropy_arr_smooth_2nd_TP', 'EER_entropy_arr_nonsmooth_1st',...
    'EER_entropy_arr_nonsmooth_2nd_TP', 'EER_entropy_arr_overall_1st', 'EER_entropy_arr_overall_2nd_TP', 'str_arr');
disp('Mat file saved.');






