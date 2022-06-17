% analyze the experimental results of 1st level
clc; clear all; close all

%% initialize
mat_file_base_name1 = 'res_synthetic_6imgs_50Hz';
mat_file_base_name2 = 'res_synthetic_6imgs_60Hz';

fitting_results_flag = 0;
col_cnt = 32;
colSelect_mode = 'colRandOnSmooth'; % select among 'colRandOnSmooth', 'colRandOnNonSmooth', and 'colRandOnOverall'


if isequal(colSelect_mode, 'colRandOnSmooth')
    region = 'on smooth';
elseif isequal(colSelect_mode, 'colRandOnNonSmooth')
    region = 'on non-smooth';
elseif isequal(colSelect_mode, 'colRandOnOverall')
    region = 'on overall';
end

fontSize_label = 28;
fontSize_legend = 16;

enf_strength_arr = [0 2^(-1) 2^(-0.5) 2^0 2^(0.5) 2^1 2^2 2^3 2^4]; %[0 0.5 1 2 4 8 16];
legendEntries_str = {'str=0.5', 'str=0.7', 'str=1.0', 'str=1.4',...
    'str=2.0', 'str=4.0', 'str=8.0', 'str=16 '};


%% loading mat files and parsing of fields of results

load(['.\mat_results\' mat_file_base_name1 '_fitting_results_flag' num2str(fitting_results_flag) '_', colSelect_mode, '_cols' num2str(col_cnt) '.mat']);

aug_results_100 = test_results;
for i = 1 : length(test_results)
    [~, enf_strength_level] = getExposureTimeEnfStrengthLevel(test_results(i).filename);
    aug_results_100(i).enf_strength_level =  enf_strength_level; % there's actually a minus sign before encoding
end

enf_strength_level_arr = sort(unique([aug_results_100(:).enf_strength_level]));
cnt_enf_strength_levels = length(enf_strength_level_arr);

load(['.\mat_results\' mat_file_base_name2 '_fitting_results_flag' num2str(fitting_results_flag) '_', colSelect_mode, '_cols' num2str(col_cnt) '.mat']);

aug_results_120 = test_results;
for i = 1 : length(test_results)
    [~, enf_strength_level] = getExposureTimeEnfStrengthLevel(test_results(i).filename);
    aug_results_120(i).enf_strength_level =  enf_strength_level; % there's actually a minus sign before encoding
end


% plot style
lineStyle_arr = {':', ':', '-.', '-.', '--', '--', '-', '-'};
color_arr = 'krkrkrkr';


%% draw ROC curves for entropy mini results
x0 = linspace(0,1,100);
y0 = 1 - x0;
EER_entropy_arr = [];

eta_threshold_opt_1st_entropy = 0.0060; % set by user

figure(1)
enf_strength_levels_reordered = [1, cnt_enf_strength_levels: -1: 2];
for kk = 1 : length(enf_strength_levels_reordered)
    i = enf_strength_levels_reordered(kk);
    this_level = enf_strength_level_arr(i);
    this_strength = enf_strength_arr(this_level);
    
    disp(['enf strength index = ' num2str(this_level)]);
    
    if this_strength ~= 0   
        logical_100_arr = ([aug_results_100.enf_strength_level] == this_level);
        logical_120_arr = ([aug_results_120.enf_strength_level] == this_level);
        
        results_part_100 = aug_results_100(logical_100_arr);
        results_part_120 = aug_results_120(logical_120_arr);


        %% select outcomes of 1st level for 2nd level classification
        entropy_margin_100 = [results_part_100.entropy_margin];
        entropy_margin_100 = entropy_margin_100(:);
        obj_100Hz_100 = [results_part_100.obj_100Hz];
        obj_100Hz_100 = obj_100Hz_100(:);
        obj_120Hz_100 = [results_part_100.obj_120Hz];
        obj_120Hz_100 = obj_120Hz_100(:);
        
        locations = entropy_margin_100 > eta_threshold_opt_1st_entropy;
        obj_100Hz_100_cutoff = obj_100Hz_100(locations);
        obj_120Hz_100_cutoff = obj_120Hz_100(locations);    
        
        entropy_margin_120 = [results_part_120.entropy_margin];
        entropy_margin_120 = entropy_margin_120(:);
        obj_100Hz_120 = [results_part_120.obj_100Hz];
        obj_100Hz_120 = obj_100Hz_120(:);
        obj_120Hz_120 = [results_part_120.obj_120Hz];
        obj_120Hz_120 = obj_120Hz_120(:);
        
        locations = entropy_margin_120 > eta_threshold_opt_1st_entropy;
        obj_100Hz_120_cutoff = obj_100Hz_120(locations);
        obj_120Hz_120_cutoff = obj_120Hz_120(locations);
        
        
        %% create test statistics
        obj_100Hz_arr = [obj_100Hz_100_cutoff];
        obj_120Hz_arr = [obj_120Hz_100_cutoff];   
        
        eta_dist_100 = [];
        for j = 1 : length(obj_100Hz_arr)
            eta_dist_100(j) = obj_100Hz_arr(j) - obj_120Hz_arr(j);
        end
        
        obj_100Hz_arr = [obj_100Hz_120_cutoff];
        obj_120Hz_arr = [obj_120Hz_120_cutoff];
        
        eta_dist_120 = [];
        for j = 1 : length(obj_100Hz_arr)
            eta_dist_120(j) = obj_100Hz_arr(j) - obj_120Hz_arr(j);
        end
        
        
        %% generate test results
        eta_threshold_arr = -1:0.0001:1; %linspace(-2,2,20000);
        FP_prob = [];
        TP_prob = [];
        for k = 1 : length(eta_threshold_arr)
            eta_threshold = eta_threshold_arr(k);
            
            TN_cnt = eta_dist_100 < eta_threshold;
            FP_cnt = eta_dist_100 >= eta_threshold;
            TP_cnt = eta_dist_120 >= eta_threshold;
            FN_cnt = eta_dist_120 < eta_threshold;
            
            
            TPR = sum(TP_cnt)/(sum(TP_cnt) + sum(FN_cnt));
            FPR = sum(FP_cnt)/(sum(TN_cnt) + sum(FP_cnt));
            TPR_arr(k) = TPR;
            FPR_arr(k) = FPR;
        end
        
        
        %% calculate EER
        [xi,yi] = polyxpoly(x0, y0, FPR_arr, TPR_arr);
        EER = xi(1);
        EER_entropy_arr(i-1) = EER;
        
        
        %% plot
        EER_str = sprintf(' (EER=%.2f)', EER);
        legend_current = [legendEntries_str{i-1}, EER_str];
        plot(FPR_arr, TPR_arr, 'LineStyle', lineStyle_arr{i-1}, 'Color', color_arr(i-1), 'LineWidth', 2.4, 'DisplayName', legend_current); hold on;
    end
end
plot(x0, y0, 'k--', 'HandleVisibility', 'off'); hold off;
axis equal
grid on;
xlim([0 1]); ylim([0 1]);

% ticks
xticks(0:0.2:1); yticks(0:0.2:1);
xtic = get(gca, 'XTickLabel');
set(gca, 'XTickLabel', xtic, 'fontsize', 15);
ytic = get(gca, 'YTickLabel');
set(gca, 'YTickLabel', ytic, 'fontsize', 15);

% labels
xlabel('False positive rate', 'FontSize', fontSize_label);
ylabel('True positive rate', 'FontSize', fontSize_label);

set(gcf, 'OuterPosition', [50 50 700 700]);
tightfig;
legend('-DynamicLegend');
legend('show');
legend('FontSize', fontSize_legend, 'location', 'SouthEast');
legend box on



%% draw ROC curves for curve fitting results
x0 = linspace(0,1,100);
y0 = 1 - x0;
EER_curve_arr = [];

eta_threshold_opt_1st_curve = 6; % set by user

R = 0.5;
alpha_arr = [R R R R R 1 1 1 1]; % should be manually set

figure(2)
enf_strength_levels_reordered = [1, cnt_enf_strength_levels: -1: 2];
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
        
        
        %% select outcomes of 1st level for 2nd level classification
        mse_margin_100 = abs([results_part_100.rmse_100Hz].^2 - [results_part_100.rmse_120Hz].^2);
        mse_margin_100 = mse_margin_100(:);
        mse_100Hz_100 = [results_part_100.rmse_100Hz].^2;
        mse_100Hz_100 = mse_100Hz_100(:);
        mse_120Hz_100 = [results_part_100.rmse_120Hz].^2;
        mse_120Hz_100 = mse_120Hz_100(:);
        
        locations = mse_margin_100 > eta_threshold_opt_1st_curve; 
        mse_100Hz_100_cutoff = mse_100Hz_100(locations);
        mse_120Hz_100_cutoff = mse_120Hz_100(locations);
    
        mse_margin_120 = abs([results_part_120.rmse_100Hz].^2 - [results_part_120.rmse_120Hz].^2);
        mse_margin_120 = mse_margin_120(:);
        mse_100Hz_120 = [results_part_120.rmse_100Hz].^2;
        mse_100Hz_120 = mse_100Hz_120(:);
        mse_120Hz_120 = [results_part_120.rmse_120Hz].^2;
        mse_120Hz_120 = mse_120Hz_120(:);
        
        locations = mse_margin_120 > eta_threshold_opt_1st_curve; 
        mse_100Hz_120_cutoff = mse_100Hz_120(locations);
        mse_120Hz_120_cutoff = mse_120Hz_120(locations);
        
        
        %% create test statistics
        mse_100Hz_arr = [mse_100Hz_100_cutoff];
        mse_120Hz_arr = [mse_120Hz_100_cutoff];
        
        eta_dist_100 = [];
        for j = 1 : length(mse_100Hz_arr)
            eta_dist_100(j) = mse_100Hz_arr(j) - mse_120Hz_arr(j);
        end
        
        mse_100Hz_arr = [mse_100Hz_120_cutoff];
        mse_120Hz_arr = [mse_120Hz_120_cutoff];
        
        eta_dist_120 = [];
        for j = 1 : length(mse_100Hz_arr)
            eta_dist_120(j) = mse_100Hz_arr(j) - mse_120Hz_arr(j);
        end
        
        
        %% generate test results
        eta_threshold_arr = -170:0.01:170; %-8:0.0001:8;
        FP_prob = [];
        TP_prob = [];
        for k = 1 : length(eta_threshold_arr)
            eta_threshold = eta_threshold_arr(k);
            
            TN_cnt = eta_dist_100 < eta_threshold;
            FP_cnt = eta_dist_100 >= eta_threshold;
            TP_cnt = eta_dist_120 >= eta_threshold;
            FN_cnt = eta_dist_120 < eta_threshold;
            
            FP_prob(k) = sum(FP_cnt)/(sum(TN_cnt) + sum(FP_cnt));
            TP_prob(k) = sum(TP_cnt)/(sum(TP_cnt) + sum(FN_cnt));
        end
        
        
        %% calculate EER
        [xi,yi] = polyxpoly(x0, y0, FP_prob, TP_prob);
        EER = xi(1);
        EER_curve_arr(i-1) = EER;
        
        
        %% plot
        EER_str = sprintf(' (EER=%.2f)', EER);
        legend_current = [legendEntries_str{i-1}, EER_str];
        hline = plot(FP_prob, TP_prob, 'LineStyle', lineStyle_arr{i-1}, 'Color', color_arr(i-1),...
            'LineWidth', 1.2, 'DisplayName', legend_current); hold on;
        alpha = alpha_arr(this_level);
        if alpha < 1
            linewidth = 1.2;
        else
            linewidth = 2.4;
        end
        hline.LineWidth = linewidth;
        hline.Color = [hline.Color alpha];
    end
end
plot(x0, y0, 'k--', 'HandleVisibility', 'off'); hold off;
axis equal
grid on;
xlim([0 1]); ylim([0 1]);

% ticks
xticks(0:0.2:1); yticks(0:0.2:1);
xtic = get(gca, 'XTickLabel');
set(gca, 'XTickLabel', xtic, 'fontsize', 15);
ytic = get(gca, 'YTickLabel');
set(gca, 'YTickLabel', ytic, 'fontsize', 15);

% labels
xlabel('False positive rate', 'FontSize', fontSize_label);
ylabel('True positive rate', 'FontSize', fontSize_label);

set(gcf, 'OuterPosition', [50 50 700 700]);
tightfig;
legend('-DynamicLegend');
legend('show');
legend('FontSize', fontSize_legend, 'location', 'SouthEast');
legend box on


