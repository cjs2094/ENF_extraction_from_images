function func_genCorrCoeffBoxplot(mat_file_base_name1, mat_file_base_name2, fitting_results_flag, ...
    colSelect_mode, col_cnt, enf_strength_arr)


%% parse of fields of results

load(['.\mat_results_syn\' mat_file_base_name1 '_fitting_results_flag' num2str(fitting_results_flag) '_', colSelect_mode, '_cols' num2str(col_cnt) '.mat']);

aug_results_100 = test_results;
for i = 1 : length(test_results)
    [~, enf_strength_level] = func_getExposureTimeEnfStrengthLevel(test_results(i).filename);
    aug_results_100(i).enf_strength_level =  enf_strength_level; % there's actually a minus sign before encoding
end

load(['.\mat_results_syn\' mat_file_base_name2 '_fitting_results_flag' num2str(fitting_results_flag) '_', colSelect_mode, '_cols' num2str(col_cnt) '.mat']);

aug_results_120 = test_results;
for i = 1 : length(test_results)
    [~, enf_strength_level] = func_getExposureTimeEnfStrengthLevel(test_results(i).filename);
    aug_results_120(i).enf_strength_level =  enf_strength_level; % there's actually a minus sign before encoding
end

enf_strength_level_arr = sort(unique([aug_results_100(:).enf_strength_level]));
cnt_enf_strength_levels = length(enf_strength_level_arr);


%% entropy mini results

len = length(aug_results_100) / length(enf_strength_arr);

ii = 1;
for i = 1 : cnt_enf_strength_levels
    this_level = enf_strength_level_arr(i);
    this_strength = enf_strength_arr(this_level);
    
    logical_100_arr = ([aug_results_100.enf_strength_level] == this_level);
    logical_120_arr = ([aug_results_120.enf_strength_level] == this_level);
    
    results_part_100 = aug_results_100(logical_100_arr);
    results_part_120 = aug_results_120(logical_120_arr);
    
    disp(['enf strength index = ' num2str(this_level)]);
    
    if this_strength ~= 0
        corr_entropy_100 = [results_part_100.corr_entropy];
        corr_entropy_100 = corr_entropy_100(:);
        correctDecision_entropy_100 = [results_part_100.correctDecision_entropy];
        correctDecision_entropy_100 = correctDecision_entropy_100(:);
        
        locations = correctDecision_entropy_100 == 1;
        corr_entropy_100_nan = NaN(len, 1);
        corr_entropy_100_nan(locations) = corr_entropy_100(locations);
        corr_entropy_100_nan_arr(:, ii) = corr_entropy_100_nan;
        
        corr_entropy_120 = [results_part_120.corr_entropy];
        corr_entropy_120 = corr_entropy_120(:);
        correctDecision_entropy_120 = [results_part_120.correctDecision_entropy];
        correctDecision_entropy_120 = correctDecision_entropy_120(:);
        
        locations = correctDecision_entropy_120 == 1;
        corr_entropy_120_nan = NaN(len, 1);
        corr_entropy_120_nan(locations) = corr_entropy_120(locations);
        corr_entropy_120_nan_arr(:, ii) = corr_entropy_120_nan;

        ii = ii + 1;
    end
end


%% curve fitting results

ii = 1;
for i = 1 : cnt_enf_strength_levels
    this_level = enf_strength_level_arr(i);
    this_strength = enf_strength_arr(this_level);
    
    logical_100_arr = ([aug_results_100.enf_strength_level] == this_level);
    logical_120_arr = ([aug_results_120.enf_strength_level] == this_level);
    
    results_part_100 = aug_results_100(logical_100_arr);
    results_part_120 = aug_results_120(logical_120_arr);
    
    disp(['enf strength index = ' num2str(this_level)]);
    
    if this_strength ~= 0
        corr_curve_100 = [results_part_100.corr_curve];
        corr_curve_100 = corr_curve_100(:);
        correctDecision_curve_100 = [results_part_100.correctDecision_curve];
        correctDecision_curve_100 = correctDecision_curve_100(:);
        
        locations = correctDecision_curve_100 == 1;
        corr_curve_100_nan = NaN(len, 1);
        corr_curve_100_nan(locations) = corr_curve_100(locations);
        corr_curve_100_nan_arr(:, ii) = corr_curve_100_nan;
        
        corr_curve_120 = [results_part_120.corr_curve];
        corr_curve_120 = corr_curve_120(:);
        correctDecision_curve_120 = [results_part_120.correctDecision_curve];
        correctDecision_curve_120 = correctDecision_curve_120(:);
        
        locations = correctDecision_curve_120 == 1;
        corr_curve_120_nan = NaN(len, 1);
        corr_curve_120_nan(locations) = corr_curve_120(locations);
        corr_curve_120_nan_arr(:, ii) = corr_curve_120_nan;
        
        ii = ii + 1;
    end
end


%% boxplot
plotColors = {[0.55 0.71 0] [0.2 0.4 0.5] 'c' [0.5 0 0.5] 'b' [1 0.5 0]};

N = 2;
delta = linspace(-.1, .1, N); %// define offsets to distinguish plots
width = .6; %// small width to avoid overlap
labels_nonzero = {'0.5' '0.7' '1' '1.4' '2' '4' '8' '16'};


corr_curve_arr   = [corr_curve_100_nan_arr; corr_curve_120_nan_arr];
corr_entropy_arr = [corr_entropy_100_nan_arr; corr_entropy_120_nan_arr];


f = figure;
f.Position = [100 100 540 250];
h1 = boxplot(corr_curve_arr, 'Color', plotColors{1}, 'boxstyle', 'filled', 'MedianStyle', 'target',...
     'position', (1:numel(labels_nonzero))+delta(1), 'widths', width, 'labels',labels_nonzero); hold on
plot(NaN,1,'color', plotColors{1}); %// dummy plot for legend
xt_dir = get(gca, 'XTick'); yt_dir = get(gca, 'YTick');
%b1 = plot(median(rmmissing(corr_curve_arr)), 'Color', plotColors{1}, 'Marker', 'o');
h2 = boxplot(corr_entropy_arr, 'Color', plotColors{2}, 'boxstyle', 'filled', 'MedianStyle', 'target',...
     'position', (1:numel(labels_nonzero))+delta(2), 'widths', width, 'labels',labels_nonzero);
plot(NaN,1, '--', 'color', plotColors{2}); %// dummy plot for legend
%b2 = plot(median(rmmissing(corr_entropy_arr)), 'Color', plotColors{2}, 'Marker', '*');
xt_zero = get(gca, 'XTick'); yt_zero = get(gca, 'YTick');
yt_max = max([max(yt_dir), max(yt_zero)]);
yt_min = min([min(yt_dir), min(yt_zero)]);
hold off
grid on;
ylim([yt_min - 0.2 yt_max + 0.2]);
%legend([h1(1,1), b1, h2(1,1), b2], legendEntries, 'Location', 'SouthEast', 'FontSize', fontSize-2);
legend([h1(1,1), h2(1,1)], {'curve fitting', 'entropy mini'}, 'Location', 'SouthEast', 'FontSize', 10);
legend boxoff
xlabel('ENF amplitude in pel intensity', 'FontSize', 11);
ylabel('Correlation coefficient', 'FontSize', 11);
%title('Correlation coefficient comparison', 'FontSize', 18);

