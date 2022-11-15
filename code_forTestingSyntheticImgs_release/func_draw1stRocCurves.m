function func_draw1stRocCurves(mat_file_base_name1, mat_file_base_name2, fitting_results_flag,...
    colSelect_mode, col_cnt, enf_strength_arr, legendEntries_str, eta1_threshold_opt_arr, gamma1_threshold_opt_arr)

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

load(['.\mat_results\' mat_file_base_name1 '_fitting_results_flag'...
    num2str(fitting_results_flag) '_', colSelect_mode, '_cols' num2str(col_cnt) '.mat']);

aug_results_100 = test_results;
for i = 1 : length(test_results)
    [~, enf_strength_level] = func_getExposureTimeEnfStrengthLevelFromFn(test_results(i).filename);
    aug_results_100(i).enf_strength_level =  enf_strength_level; 
end

load(['.\mat_results\' mat_file_base_name2 '_fitting_results_flag'...
    num2str(fitting_results_flag) '_', colSelect_mode, '_cols' num2str(col_cnt) '.mat']);

aug_results_120 = test_results;
for i = 1 : length(test_results)
    [~, enf_strength_level] = func_getExposureTimeEnfStrengthLevelFromFn(test_results(i).filename);
    aug_results_120(i).enf_strength_level =  enf_strength_level; 
end

enf_strength_level_arr = sort(unique([aug_results_100(:).enf_strength_level]));
cnt_enf_strength_levels = length(enf_strength_level_arr);


%% entropy mini results

x0 = linspace(0, 1, 100);
y0 = 1 - x0;

R = 0.5;
alpha_arr = [R R 1 1 1 1 1 1 1];

len = length(aug_results_100) / length(enf_strength_arr);
entropy_margin_arr = [];

figure;
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
    
    if this_strength == 0
        temp1 = [results_part_100.entropy_margin];
        temp2 = [results_part_120.entropy_margin];
        entropy_margin_noENF = [temp1(:); temp2(:)];
    else
        temp1 = [results_part_100.entropy_margin];
        temp2 = [results_part_120.entropy_margin];
        entropy_margin_ENF = [temp1(:); temp2(:)];
        
        eta1_dist_noENF = entropy_margin_noENF;
        eta1_dist_ENF = entropy_margin_ENF;
        
        eta1_threshold_arr = -1 : 0.0001 : 1;
        FPR_arr = [];
        TPR_arr = [];
        for k = 1 : length(eta1_threshold_arr)
            eta1_threshold = eta1_threshold_arr(k);
            
            TN_cnt = eta1_dist_noENF < eta1_threshold;
            FP_cnt = eta1_dist_noENF >= eta1_threshold;
            TP_cnt = eta1_dist_ENF >= eta1_threshold;
            FN_cnt = eta1_dist_ENF < eta1_threshold;
            
            TPR = sum(TP_cnt)/(sum(TP_cnt) + sum(FN_cnt));
            FPR = sum(FP_cnt)/(sum(TN_cnt) + sum(FP_cnt));
            TPR_arr(k) = TPR;
            FPR_arr(k) = FPR;
            
            gmeans(k) = sqrt(TPR*(1 - FPR));
        end
        
        
%         %% locate the index of the largest g-mean
%         if i == 4
%             [~, idx] = max(gmeans);
%             eta1_threshold_opt = eta1_threshold_arr(idx);
%         end
        
        
        %% calculate EER
        [xi, ~] = polyxpoly(x0, y0, FPR_arr, TPR_arr);
        EER = xi(1);        
       
        
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
        
        for kk = 1 : length(eta1_threshold_opt_arr)
            eta1_threshold_operatingPts = eta1_threshold_opt_arr(kk);
            [~, idx] = min(abs(eta1_threshold_arr - eta1_threshold_operatingPts));
            
            plot(FPR_arr(idx), TPR_arr(idx), 'Color', color_arr(i-1), 'Marker', marker_arr{kk}, 'LineWidth', 1.8, 'HandleVisibility', 'off');
        end
    end
    
end
plot(x0, y0, 'k--', 'HandleVisibility', 'off'); hold off;
title({'1st-level detector', ['Entropy mini ', region, ' - ROC curves']}, 'FontSize', 16);
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
set(gcf,'OuterPosition', [50 50 700 700]);
func_tightfig; % remove side margins of plot
legend('-DynamicLegend');
legend('show');
legend('FontSize', fontSize_legend, 'location', 'SouthEast')
legend box on


plotColors = {[0.55 0.71 0] [0.2 0.4 0.5] 'c' [0.5 0 0.5] 'b' [1 0.5 0]};
width = .6; %// small width to avoid overlap


f = figure;
f.Position = [100 100 540 250];
h1 = boxplot(entropy_margin_arr, 'Color', plotColors{1}, 'boxstyle', 'filled', 'MedianStyle', 'target',...
     'position', (1:numel(labels)), 'widths', width, 'labels',labels); hold on
%b1 = plot(mean(rmmissing(entropy_margin_arr)), 'k*-'); hold off
grid on;
xt = get(gca, 'XTick'); yt = get(gca, 'YTick');
%legend([h1(1,1), b1(1,1)], legendEntries_methods, 'Location', 'NorthWest', 'FontSize', fontSize-2);
%legend([h1(1,1)], legendEntries_methods, 'Location', 'NorthWest', 'FontSize', fontSize-2);
xlabel('ENF amplitude in pel intensity', 'FontSize', 11);
ylabel('Entropy margin', 'FontSize', 11); 
%title({['Entropy mini ', region], ' - Entropy margin (100&120 Hz incorporated)'}, 'FontSize', fontSize);




%% curve fitting results

x0 = linspace(0, 1, 100);
y0 = 1 - x0;

R = 0.5;
alpha_arr = [R R R R R R 1 1 1];


figure;
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
    
    if this_strength == 0
        temp1 = abs([results_part_100.rmse_100Hz].^2 - [results_part_100.rmse_120Hz].^2);
        temp2 = abs([results_part_120.rmse_100Hz].^2 - [results_part_120.rmse_120Hz].^2);
        mse_margin_noENF = [temp1(:); temp2(:)];
        gamma1_dist_noENF = mse_margin_noENF;
    else
        temp1 = abs([results_part_100.rmse_100Hz].^2 - [results_part_100.rmse_120Hz].^2);
        temp2 = abs([results_part_120.rmse_100Hz].^2 - [results_part_120.rmse_120Hz].^2);
        mse_margin_ENF = [temp1(:); temp2(:)];
        gamma1_dist_ENF = mse_margin_ENF;
        
        gamma1_threshold_arr = linspace(0, 120, 100000);
        FPR_arr = [];
        TPR_arr = [];
        for k = 1 : length(gamma1_threshold_arr)
            gamma1_threshold = gamma1_threshold_arr(k);
            
            TN_cnt = gamma1_dist_noENF < gamma1_threshold;
            FP_cnt = gamma1_dist_noENF >= gamma1_threshold;
            TP_cnt = gamma1_dist_ENF >= gamma1_threshold;
            FN_cnt = gamma1_dist_ENF < gamma1_threshold;
            
            TPR = sum(TP_cnt)/(sum(TP_cnt) + sum(FN_cnt));
            FPR = sum(FP_cnt)/(sum(TN_cnt) + sum(FP_cnt));
            TPR_arr(k) = TPR;
            FPR_arr(k) = FPR;
            
            gmeans(k) = sqrt(TPR * (1 - FPR));
        end
        
        
        %% locate the index of the largest g-mean
        if i == 4
            [~, idx] = max(gmeans);
            gamma1_threshold_opt = gamma1_threshold_arr(idx);
        end
        
        
        %% calculate EER
        [xi, ~] = polyxpoly(x0, y0, FPR_arr, TPR_arr);
        EER = xi(1);

        
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

        for kk = 1 : length(gamma1_threshold_opt_arr)
            gamma1_threshold_operatingPts = gamma1_threshold_opt_arr(kk);
            [~, idx] = min(abs(gamma1_threshold_arr - gamma1_threshold_operatingPts));
            
            plot(FPR_arr(idx), TPR_arr(idx), 'Color', color_arr(i-1),...
                'Marker', marker_arr{kk}, 'LineWidth', 1.8, 'HandleVisibility', 'off');           
        end
    end
    
end
plot(x0, y0, 'k--', 'HandleVisibility', 'off'); hold off;
title({'1st-level detector', ['Curve fitting ', region]}, 'FontSize', 16);
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
set(gcf,'OuterPosition', [50 50 700 700]);
func_tightfig; % remove side margins of plot
legend('-DynamicLegend');
legend('show');
legend('FontSize', fontSize_legend, 'location', 'SouthEast')
legend box on


