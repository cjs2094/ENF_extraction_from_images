function func_draw2ndRocCurves_syn(mat_file_base_name1, mat_file_base_name2, fitting_results_flag,...
    colSelect_mode, col_cnt, enf_strength_arr, legendEntries_str, eta1_threshold_opt, gamma1_threshold_opt)

%% settings

% plot style
lineStyle_arr = {':', ':', '-.', '-.', '--', '--', '-', '-'};
color_arr = 'krkrkrkr';
marker_arr = {'s', 'd', '^', 'v', 'p', 'h', '+', 'x', };

fontSize_label = 28;
fontSize_legend = 16;

if isequal(colSelect_mode, 'colRandOnSmooth')
    region = 'on smooth region';
elseif isequal(colSelect_mode, 'colRandOnNonSmooth')
    region = 'on non-smooth region';
elseif isequal(colSelect_mode, 'colRandOnOverall')
    region = 'on overall region';
end


%% parse of fields of results

load(['.\mat_results_syn\' mat_file_base_name1 '_fitting_results_flag'...
    num2str(fitting_results_flag) '_', colSelect_mode, '_cols' num2str(col_cnt) '.mat']);

aug_results_100 = test_results;
for i = 1 : length(test_results)
    [~, enf_strength_level] = func_getExposureTimeEnfStrengthLevel(test_results(i).filename);
    aug_results_100(i).enf_strength_level =  enf_strength_level; 
end

load(['.\mat_results_syn\' mat_file_base_name2 '_fitting_results_flag'...
    num2str(fitting_results_flag) '_', colSelect_mode, '_cols' num2str(col_cnt) '.mat']);

aug_results_120 = test_results;
for i = 1 : length(test_results)
    [~, enf_strength_level] = func_getExposureTimeEnfStrengthLevel(test_results(i).filename);
    aug_results_120(i).enf_strength_level =  enf_strength_level; 
end

enf_strength_level_arr = sort(unique([aug_results_100(:).enf_strength_level]));
cnt_enf_strength_levels = length(enf_strength_level_arr);


%% entropy mini results

EER_entropy_arr = [];

x0 = linspace(0, 1, 100);
y0 = 1 - x0;


figure;
enf_strength_levels_reordered = [1, cnt_enf_strength_levels: -1: 2];
for kk = 1 : length(enf_strength_levels_reordered)
    i = enf_strength_levels_reordered(kk);
    this_level = enf_strength_level_arr(i);
    this_strength = enf_strength_arr(this_level);
    
    if this_strength ~= 0   
        logical_100_arr = ([aug_results_100.enf_strength_level] == this_level);
        logical_120_arr = ([aug_results_120.enf_strength_level] == this_level);
        
        results_part_100 = aug_results_100(logical_100_arr);
        results_part_120 = aug_results_120(logical_120_arr);

        disp(['enf strength index = ' num2str(this_level)]);
        
        
        %% select outcomes of 1st level for 2nd level classification
        entropy_margin_100 = [results_part_100.entropy_margin];
        entropy_margin_100 = entropy_margin_100(:);
        obj_100Hz_100 = [results_part_100.obj_100Hz];
        obj_100Hz_100 = obj_100Hz_100(:);
        obj_120Hz_100 = [results_part_100.obj_120Hz];
        obj_120Hz_100 = obj_120Hz_100(:);
        
        locations = entropy_margin_100 > eta1_threshold_opt;
        obj_100Hz_100_cutoff = obj_100Hz_100(locations);
        obj_120Hz_100_cutoff = obj_120Hz_100(locations);
        
        
        entropy_margin_120 = [results_part_120.entropy_margin];
        entropy_margin_120 = entropy_margin_120(:);
        obj_100Hz_120 = [results_part_120.obj_100Hz];
        obj_100Hz_120 = obj_100Hz_120(:);
        obj_120Hz_120 = [results_part_120.obj_120Hz];
        obj_120Hz_120 = obj_120Hz_120(:);
        
        locations = entropy_margin_120 > eta1_threshold_opt;
        obj_100Hz_120_cutoff = obj_100Hz_120(locations);
        obj_120Hz_120_cutoff = obj_120Hz_120(locations);

        
        %% create test statistics
        obj_100Hz_arr = [obj_100Hz_100_cutoff];
        obj_120Hz_arr = [obj_120Hz_100_cutoff];
        
        eta2_dist_100 = [];
        for j = 1 : length(obj_100Hz_arr)
            eta2_dist_100(j) = obj_100Hz_arr(j) - obj_120Hz_arr(j);
        end
        
        obj_100Hz_arr = [obj_100Hz_120_cutoff];
        obj_120Hz_arr = [obj_120Hz_120_cutoff];
        
        eta_dist_120 = [];
        for j = 1 : length(obj_100Hz_arr)
            eta_dist_120(j) = obj_100Hz_arr(j) - obj_120Hz_arr(j);
        end
        
        
        eta2_threshold_arr = -1 : 0.0001 : 1;
        FP_prob = [];
        TP_prob = [];
        for k = 1 : length(eta2_threshold_arr)
            eta2_threshold = eta2_threshold_arr(k);
            
            TN_cnt = eta2_dist_100 <  eta2_threshold;
            FP_cnt = eta2_dist_100 >= eta2_threshold;
            TP_cnt = eta_dist_120  >= eta2_threshold;
            FN_cnt = eta_dist_120  <  eta2_threshold;
            
            
            TPR = sum(TP_cnt)/(sum(TP_cnt) + sum(FN_cnt));
            FPR = sum(FP_cnt)/(sum(TN_cnt) + sum(FP_cnt));
            TPR_arr(k) = TPR;
            FPR_arr(k) = FPR;
        end
        
        
        %% calculate EER
        [xi, ~] = polyxpoly(x0, y0, FPR_arr, TPR_arr);
        EER = xi(1);        
        EER_str = sprintf(' (EER=%.2f)', EER);
        legend_current = [legendEntries_str{i-1}, EER_str];
        
        % plot
        plot(FPR_arr, TPR_arr, 'LineStyle', lineStyle_arr{i-1}, 'Color', color_arr(i-1), 'LineWidth', 2.4, 'DisplayName', legend_current); hold on;
     
    end
end
plot(x0, y0, 'k--', 'HandleVisibility', 'off'); hold off;
title({'2nd-level detector', ['Entropy mini ', region]}, 'FontSize', 16);
axis equal
grid on;
xlim([0 1]); ylim([0 1]);
xticks(0 : 0.2 : 1); yticks(0 : 0.2 : 1);
xtic = get(gca, 'XTickLabel');
set(gca, 'XTickLabel', xtic, 'fontsize', 15);
ytic = get(gca, 'YTickLabel');
set(gca, 'YTickLabel', ytic, 'fontsize', 15);
xlabel('False positive rate', 'FontSize', fontSize_label);
ylabel('True positive rate', 'FontSize', fontSize_label);
set(gcf, 'OuterPosition', [50 50 700 700]);
func_tightfig;
legend('-DynamicLegend');
legend('show');
legend('FontSize', fontSize_legend, 'location', 'SouthEast');
legend box on



%% curve fitting results

EER_para_arr = [];

x0 = linspace(0, 1, 100);
y0 = 1 - x0;

R = 0.5;
alpha_arr = [R R R R R 1 1 1 1];


figure;
enf_strength_levels_reordered = [1, cnt_enf_strength_levels: -1: 2];
for kk = 1 : length(enf_strength_levels_reordered)
    i = enf_strength_levels_reordered(kk);
    this_level = enf_strength_level_arr(i);
    this_strength = enf_strength_arr(this_level);
    
    if this_strength ~= 0   
        logical_100_arr = ([aug_results_100.enf_strength_level] == this_level);
        logical_120_arr = ([aug_results_120.enf_strength_level] == this_level);
        
        results_part_100 = aug_results_100(logical_100_arr);
        results_part_120 = aug_results_120(logical_120_arr);
        
        disp(['enf strength index = ' num2str(this_level)]);
        
        
        %% select outcomes of 1st level for 2nd level classification
        mse_margin_100 = abs([results_part_100.rmse_100Hz].^2 - [results_part_100.rmse_120Hz].^2);
        mse_margin_100 = mse_margin_100(:);
        mse_100Hz_100 = [results_part_100.rmse_100Hz].^2;
        mse_100Hz_100 = mse_100Hz_100(:);
        mse_120Hz_100 = [results_part_100.rmse_120Hz].^2;
        mse_120Hz_100 = mse_120Hz_100(:);
        
        locations = mse_margin_100 > gamma1_threshold_opt; 
        mse_100Hz_100_cutoff = mse_100Hz_100(locations);
        mse_120Hz_100_cutoff = mse_120Hz_100(locations);

        
        mse_margin_120 = abs([results_part_120.rmse_100Hz].^2 - [results_part_120.rmse_120Hz].^2);
        mse_margin_120 = mse_margin_120(:);
        mse_100Hz_120 = [results_part_120.rmse_100Hz].^2;
        mse_100Hz_120 = mse_100Hz_120(:);
        mse_120Hz_120 = [results_part_120.rmse_120Hz].^2;
        mse_120Hz_120 = mse_120Hz_120(:);
        
        locations = mse_margin_120 > gamma1_threshold_opt; 
        mse_100Hz_120_cutoff = mse_100Hz_120(locations);
        mse_120Hz_120_cutoff = mse_120Hz_120(locations);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        mse_100Hz_arr = [mse_100Hz_100_cutoff];
        mse_120Hz_arr = [mse_120Hz_100_cutoff];
        
        
        gamma2_dist_100 = [];
        for j = 1 : length(mse_100Hz_arr)
            gamma2_dist_100(j) = mse_100Hz_arr(j) - mse_120Hz_arr(j);
        end
        
        mse_100Hz_arr = [mse_100Hz_120_cutoff];
        mse_120Hz_arr = [mse_120Hz_120_cutoff];
        
        gamma2_dist_120 = [];
        for j = 1 : length(mse_100Hz_arr)
            gamma2_dist_120(j) = mse_100Hz_arr(j) - mse_120Hz_arr(j);
        end
        
        
        gamma2_threshold_arr = -170 : 0.01 : 170; % changeable
        FP_prob = [];
        TP_prob = [];
        for k = 1 : length(gamma2_threshold_arr)
            gamma2_threshold = gamma2_threshold_arr(k);
            
            TN_cnt = gamma2_dist_100 <  gamma2_threshold;
            FP_cnt = gamma2_dist_100 >= gamma2_threshold;
            TP_cnt = gamma2_dist_120 >= gamma2_threshold;
            FN_cnt = gamma2_dist_120 <  gamma2_threshold;
            
            FP_prob(k) = sum(FP_cnt)/(sum(TN_cnt) + sum(FP_cnt));
            TP_prob(k) = sum(TP_cnt)/(sum(TP_cnt) + sum(FN_cnt));
        end
        
        [xi, ~] = polyxpoly(x0, y0, FP_prob, TP_prob);
        EER = xi(1);
%         EER_para_arr(i - 1) = EER;
        
        EER_str = sprintf(' (EER=%.2f)', EER);
        legend_current = [legendEntries_str{i - 1}, EER_str];
        % plot
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
title({'2nd-level detector', ['Curve fitting ', region]}, 'FontSize', 16);
axis equal
grid on;
xlim([0 1]); ylim([0 1]);
xticks(0 : 0.2 : 1); yticks(0 : 0.2 : 1);
xtic = get(gca, 'XTickLabel');
set(gca, 'XTickLabel', xtic, 'fontsize', 15);
ytic = get(gca, 'YTickLabel');
set(gca, 'YTickLabel', ytic, 'fontsize', 15);
xlabel('False positive rate', 'FontSize', fontSize_label);
ylabel('True positive rate', 'FontSize', fontSize_label);
set(gcf, 'OuterPosition', [50 50 700 700]);
func_tightfig;
legend('-DynamicLegend');
legend('show');
legend('FontSize', fontSize_legend, 'location', 'SouthEast');
legend box on


