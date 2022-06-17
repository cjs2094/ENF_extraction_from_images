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

enf_strength_arr = [0 2^(-1) 2^(-0.5) 2^0 2^(0.5) 2^1 2^2 2^3 2^4];
legendEntries_str = {'str=0.5', 'str=0.7', 'str=1.0', 'str=1.4',...
    'str=2.0', 'str=4.0', 'str=8.0', 'str=16 '};


%% load mat files and parsing of fields of results

load(['.\mat_results\' mat_file_base_name1 '_fitting_results_flag' num2str(fitting_results_flag) '_', colSelect_mode, '_cols' num2str(col_cnt) '.mat']);

corr_curve_100 = [test_results.corr_curve];
corr_entropy_100 = [test_results.corr_entropy];

aug_results_100 = test_results;
for i = 1 : length(test_results)
    [~, enf_strength_level] = getExposureTimeEnfStrengthLevel(test_results(i).filename);
    aug_results_100(i).enf_strength_level =  enf_strength_level; % there's actually a minus sign before encoding
end

enf_strength_level_arr = sort(unique([aug_results_100(:).enf_strength_level]));
cnt_enf_strength_levels = length(enf_strength_level_arr);

load(['.\mat_results\' mat_file_base_name2 '_fitting_results_flag' num2str(fitting_results_flag) '_', colSelect_mode, '_cols' num2str(col_cnt) '.mat']);

corr_curve_120 =[test_results.corr_curve];
corr_entropy_120 =[test_results.corr_entropy];

aug_results_120 = test_results;
for i = 1 : length(test_results)
    [~, enf_strength_level] = getExposureTimeEnfStrengthLevel(test_results(i).filename);
    aug_results_120(i).enf_strength_level =  enf_strength_level; % there's actually a minus sign before encoding
end


% plot style
lineStyle_arr = {':', ':', '-.', '-.', '--', '--', '-', '-'};
color_arr = 'krkrkrkr';
marker_arr = {'s', 'd', '^', 'v', 'p', 'h', '+', 'x', };


%% draw ROC curves for entropy mini results
x0 = linspace(0, 1, 100);
y0 = 1 - x0;
EER_entropy_arr = [];

eta_threshold_operatingPts_arr = [0.0020 0.0040 0.0060]; % set by user

R = 0.5;
alpha_arr = [R R 1 1 1 1 1 1 1]; % should be manually set for visualization

figure(1)
enf_strength_levels_reordered = [1, cnt_enf_strength_levels: -1: 2];
for kk = 1 : length(enf_strength_levels_reordered)
    i = enf_strength_levels_reordered(kk);
    this_level = enf_strength_level_arr(i);
    this_strength = enf_strength_arr(this_level);
    
    disp(['enf strength index = ' num2str(this_level)]);
    
    logical_100_arr = ([aug_results_100.enf_strength_level] == this_level);
    logical_120_arr = ([aug_results_120.enf_strength_level] == this_level);
    
    results_part_100 = aug_results_100(logical_100_arr);
    results_part_120 = aug_results_120(logical_120_arr);
    
    
    %% create test statistics
    if this_strength == 0
        temp1 = [results_part_100.entropy_margin];
        temp2 = [results_part_120.entropy_margin];
        entropy_margin_noENF = [temp1(:); temp2(:)];
    else
        temp1 = [results_part_100.entropy_margin];
        temp2 = [results_part_120.entropy_margin];
        entropy_margin_ENF = [temp1(:); temp2(:)];
        eta_dist_noENF = entropy_margin_noENF;
        eta_dist_ENF = entropy_margin_ENF;
        
        
        %% generate test results
        eta_threshold_arr = -1:0.0001:1; %linspace(-1,1,10000);
        FPR_arr = [];
        TPR_arr = [];
        maxSumOfTPAndFN = 0;
        for k = 1 : length(eta_threshold_arr)
            eta_threshold = eta_threshold_arr(k);
            
            TN_cnt = eta_dist_noENF < eta_threshold;
            FP_cnt = eta_dist_noENF >= eta_threshold;
            TP_cnt = eta_dist_ENF >= eta_threshold;
            FN_cnt = eta_dist_ENF < eta_threshold;
            
            TPR = sum(TP_cnt)/(sum(TP_cnt) + sum(FN_cnt));
            FPR = sum(FP_cnt)/(sum(TN_cnt) + sum(FP_cnt));
            TPR_arr(k) = TPR;
            FPR_arr(k) = FPR;
            
            gmeans(k) = sqrt(TPR * (1 - FPR));
        end
        
%         % locate the index of the largest g-mean
%         if i == 4
%             [~, idx] = max(gmeans);
%             eta_threshold_opt = eta_threshold_arr(idx)
%         end
        

        %% calculate EER 
        [xi, yi] = polyxpoly(x0, y0, FPR_arr, TPR_arr);
        EER = xi(1);
        EER_entropy_arr(i-1) = EER;
        txt = ['\leftarrow EER=', num2str(round(EER,4))];
        
        
        %% plot
        EER_str = sprintf(' (EER=%.2f)', EER);
        legend_current = [legendEntries_str{i-1}, EER_str];
               
        hline = plot(FPR_arr, TPR_arr, 'LineStyle', lineStyle_arr{i-1}, 'Color', color_arr(i-1),...
            'LineWidth', 2.5, 'DisplayName', legend_current); hold on;
        alpha = alpha_arr(this_level);
        if alpha < 1
            linewidth = 1.2;
        else
            linewidth = 2.4;
        end
        hline.LineWidth = linewidth;
        hline.Color = [hline.Color alpha];
        
        for kk = 1 : length(eta_threshold_operatingPts_arr)
            eta_threshold_operatingPts = eta_threshold_operatingPts_arr(kk);
            [~, idx] = min(abs(eta_threshold_arr - eta_threshold_operatingPts));
            
            plot(FPR_arr(idx), TPR_arr(idx), 'Color', color_arr(i-1), 'Marker', marker_arr{kk}, 'LineWidth', 1.8, 'HandleVisibility', 'off');
        end
        
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

set(gcf,'OuterPosition', [50 50 700 700]);
tightfig; % remove side margins of plot
legend('-DynamicLegend');
legend('show');
legend('FontSize', fontSize_legend, 'location', 'SouthEast')
legend box on


%% curve fitting results
x0 = linspace(0,1,100);
y0 = 1 - x0;
EER_curve_arr = [];

eta_threshold_operatingPts_arr = [4 5 6]; % set by user

R = 0.5; % should be manually set for visualization purpose
alpha_arr = [R R R R R R 1 1 1];

figure(2)
enf_strength_levels_reordered = [1, cnt_enf_strength_levels: -1: 2];
for kk = 1 : length(enf_strength_levels_reordered)
    i = enf_strength_levels_reordered(kk);
    this_level = enf_strength_level_arr(i);
    this_strength = enf_strength_arr(this_level);
    
    disp(['enf strength index = ' num2str(this_level)]);
    
    logical_100_arr = ([aug_results_100.enf_strength_level] == this_level);
    logical_120_arr = ([aug_results_120.enf_strength_level] == this_level);
    
    results_part_100 = aug_results_100(logical_100_arr);
    results_part_120 = aug_results_120(logical_120_arr);
    
    
    %% create test statistics
    if this_strength == 0
        temp1 = abs([results_part_100.rmse_100Hz].^2 - [results_part_100.rmse_120Hz].^2);
        temp2 = abs([results_part_120.rmse_100Hz].^2 - [results_part_120.rmse_120Hz].^2);
        mse_margin_noENF = [temp1(:); temp2(:)];
    else
        temp1 = abs([results_part_100.rmse_100Hz].^2 - [results_part_100.rmse_120Hz].^2);
        temp2 = abs([results_part_120.rmse_100Hz].^2 - [results_part_120.rmse_120Hz].^2);
        mse_margin_ENF = [temp1(:); temp2(:)];
        eta_dist_noENF = mse_margin_noENF;
        eta_dist_ENF = mse_margin_ENF;
        
        
        %% generate test results
        eta_threshold_arr = linspace(0, 120, 100000);
        FPR_arr = [];
        TPR_arr = [];
        maxSumOfTPAndFN = 0;
        for k = 1 : length(eta_threshold_arr)
            eta_threshold = eta_threshold_arr(k);
            
            TN_cnt = eta_dist_noENF < eta_threshold;
            FP_cnt = eta_dist_noENF >= eta_threshold;
            TP_cnt = eta_dist_ENF >= eta_threshold;
            FN_cnt = eta_dist_ENF < eta_threshold;
            
            TPR = sum(TP_cnt)/(sum(TP_cnt) + sum(FN_cnt));
            FPR = sum(FP_cnt)/(sum(TN_cnt) + sum(FP_cnt));
            TPR_arr(k) = TPR;
            FPR_arr(k) = FPR;
            
            gmeans(k) = sqrt(TPR * (1 - FPR));
        end
        
%         % locate the index of the largest g-mean
%         if i == 4
%             [~, idx] = max(gmeans);
%             eta_threshold_opt = eta_threshold_arr(idx)
%         end
        

        %% calculate EER
        [xi,yi] = polyxpoly(x0, y0, FPR_arr, TPR_arr);
        EER = xi(1);
        EER_curve_arr(i-1) = EER;
        
        
        %% plot
        EER_str = sprintf(' (EER=%.2f)', EER);
        legend_current = [legendEntries_str{i-1}, EER_str];
      
        hline = plot(FPR_arr, TPR_arr, 'LineStyle', lineStyle_arr{i-1}, 'Color', color_arr(i-1),...
            'LineWidth', 2.5, 'DisplayName', legend_current); hold on;
        alpha = alpha_arr(this_level);
        if alpha < 1
            linewidth = 1.2;
        else
            linewidth = 2.4;
        end
        hline.LineWidth = linewidth;
        hline.Color = [hline.Color alpha];
        for kk = 1 : length(eta_threshold_operatingPts_arr)
            eta_threshold_operatingPts = eta_threshold_operatingPts_arr(kk);
            [~, idx] = min(abs(eta_threshold_arr - eta_threshold_operatingPts));
            
            plot(FPR_arr(idx), TPR_arr(idx), 'Color', color_arr(i-1),...
                'Marker', marker_arr{kk}, 'LineWidth', 1.8, 'HandleVisibility', 'off');           
        end
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

set(gcf,'OuterPosition', [50 50 700 700]);
tightfig; % remove side margins of plot
legend('-DynamicLegend');
legend('show');
legend('FontSize', fontSize_legend, 'location', 'SouthEast');
legend box on

