function func_performBootstrap_preliminaryVsProposed(mat_file_base_name1, mat_file_base_name2, fitting_results_flag, colSelect_mode, col_cnt, enf_strength_arr)

fn0 = ['.\mat_results\bootstrap_preliminaryVsProposed_', mat_file_base_name1, '_', ...
    mat_file_base_name2, '_fitting_results_flag', num2str(fitting_results_flag), '_', colSelect_mode, '_cols' num2str(col_cnt) '.mat'];

if exist(fn0)
    error(['Breaking out of function.', newline, fn0 ' already exists']);
end


%% settings
num_of_bootstrap = 10; % number of bootstrapping

%% check files

for ii = 1 : 2
    if ii == 1
        mat_results_fn = '.\mat_results\';
    elseif ii == 2
        mat_results_fn = '.\mat_results_preModel\';
    end
    
    fn1 = [mat_results_fn, mat_file_base_name1, '_fitting_results_flag', num2str(fitting_results_flag), '_', colSelect_mode, '_cols', num2str(col_cnt), '.mat'];
    fn2 = [mat_results_fn, mat_file_base_name2, '_fitting_results_flag', num2str(fitting_results_flag), '_', colSelect_mode, '_cols', num2str(col_cnt), '.mat'];
    
    if ~exist(fn1) && ~exist(fn2)
        error('Error. No prerequired mat files found.')
    end
end


%%

for ii = 1 : 2 % 1: proposed / 2: preliminary
    
    if ii == 1
        mat_results_fn = '.\mat_results\';
    elseif ii == 2
        mat_results_fn = '.\mat_results_preModel\';
    end
    
    
    %% parse of fields of results
    
    load([mat_results_fn, mat_file_base_name1, '_fitting_results_flag', num2str(fitting_results_flag), '_', colSelect_mode, '_cols', num2str(col_cnt), '.mat']);
    
    aug_results_100 = test_results;
    for i = 1 : length(test_results)
        [~, enf_strength_level] = func_getExposureTimeEnfStrengthLevel(test_results(i).filename);
        aug_results_100(i).enf_strength_level =  enf_strength_level; % there's actually a minus sign before encoding
    end
    
    enf_strength_level_arr = sort(unique([aug_results_100(:).enf_strength_level]));
    cnt_enf_strength_levels = length(enf_strength_level_arr);
    
    load([mat_results_fn, mat_file_base_name2, '_fitting_results_flag', num2str(fitting_results_flag), '_', colSelect_mode, '_cols', num2str(col_cnt), '.mat']);
    
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
                eta1_arr = 0 : 0.00005 : 1; %threshold; linspace(-1,1,10000);
                FPR_arr = [];
                TPR_arr = [];
                for k = 1 : length(eta1_arr)
                    eta1 = eta1_arr(k);
                    
                    TN_cnt = eta1_dist_noENF <  eta1;
                    FP_cnt = eta1_dist_noENF >= eta1;
                    TP_cnt = eta1_dist_ENF   >= eta1;
                    FN_cnt = eta1_dist_ENF   <  eta1;
                    
                    TPR = sum(TP_cnt)/(sum(TP_cnt) + sum(FN_cnt));
                    FPR = sum(FP_cnt)/(sum(TN_cnt) + sum(FP_cnt));
                    TPR_arr(k) = TPR;
                    FPR_arr(k) = FPR;
                end
                
                
                %% calculate EER
                [xi, ~] = polyxpoly(x0, y0, FPR_arr, TPR_arr);
                EER = xi(1);
                EER_entropy_arr_1st(jj, i-1) = EER;
                
                %% calculate AUC %%%
                AUC = -trapz(FPR_arr, TPR_arr);
                AUC_entropy_arr_1st(jj, i-1) = AUC;
            end
        end
    end
    
    
    if ii == 1
        EER_entropy_arr_proposed_1st = EER_entropy_arr_1st;
        AUC_entropy_arr_proposed_1st = AUC_entropy_arr_1st;
    elseif ii == 2
        EER_entropy_arr_preliminary_1st = EER_entropy_arr_1st;
        AUC_entropy_arr_preliminary_1st = AUC_entropy_arr_1st;
    end
    
    
end


str_arr = [];
for i = 1 : length(enf_strength_arr)
    temp = enf_strength_arr(i);
    
    if temp ~= 0
        str_arr = [str_arr, temp];
    end
end


save(fn0, 'EER_entropy_arr_proposed_1st', 'AUC_entropy_arr_proposed_1st', ...
    'EER_entropy_arr_preliminary_1st', 'AUC_entropy_arr_preliminary_1st', 'str_arr');
disp('Mat file saved.');


