function func_genEntropyMarginBoxplot(mat_file_base_name1, mat_file_base_name2, fitting_results_flag, ...
    colSelect_mode, col_cnt, enf_strength_arr)


%% parse of fields of results

load(['.\mat_results\' mat_file_base_name1 '_fitting_results_flag' num2str(fitting_results_flag) '_', colSelect_mode, '_cols' num2str(col_cnt) '.mat']);

corr_para_100 =[test_results.corr_para];
corr_entropy_100 =[test_results.corr_entropy];

aug_results_100 = test_results;
for i = 1 : length(test_results)
    [~, enf_strength_level] = func_getExposureTimeEnfStrengthLevelFromFn(test_results(i).filename);
    aug_results_100(i).enf_strength_level =  enf_strength_level; % there's actually a minus sign before encoding
end

load(['.\mat_results\' mat_file_base_name2 '_fitting_results_flag' num2str(fitting_results_flag) '_', colSelect_mode, '_cols' num2str(col_cnt) '.mat']);

corr_para_120 =[test_results.corr_para];
corr_entropy_120 =[test_results.corr_entropy];

aug_results_120 = test_results;
for i = 1 : length(test_results)
    [~, enf_strength_level] = func_getExposureTimeEnfStrengthLevelFromFn(test_results(i).filename);
    aug_results_120(i).enf_strength_level =  enf_strength_level; % there's actually a minus sign before encoding
end

enf_strength_level_arr = sort(unique([aug_results_100(:).enf_strength_level]));
cnt_enf_strength_levels = length(enf_strength_level_arr);


%% calculate entropy margin

len = length(aug_results_100) / length(enf_strength_arr);
entropy_margin_arr = [];


for i = 1 : cnt_enf_strength_levels
    this_level = enf_strength_level_arr(i);
    this_strength = enf_strength_arr(this_level);
    
    logical_100_arr = ([aug_results_100.enf_strength_level] == this_level);
    logical_120_arr = ([aug_results_120.enf_strength_level] == this_level);
    
    results_part_100 = aug_results_100(logical_100_arr);
    results_part_120 = aug_results_120(logical_120_arr);
    
    disp(['enf strength index = ' num2str(this_level)]);
        
    if this_strength ~= 0
        entropy_margin_100 = [results_part_100.entropy_margin];
        entropy_margin_100 = entropy_margin_100(:);
        correctDecision_entropy_100 = [results_part_100.correctDecision_entropy];
        correctDecision_entropy_100 = correctDecision_entropy_100(:);
        
        locations = correctDecision_entropy_100 == 1;
        entropy_margin_100_nan = NaN(len, 1);
        entropy_margin_100_nan(locations) = entropy_margin_100(locations);
        
        entropy_margin_120 = [results_part_120.entropy_margin];
        entropy_margin_120 = entropy_margin_120(:);
        correctDecision_entropy_120 = [results_part_120.correctDecision_entropy];
        correctDecision_entropy_120 = correctDecision_entropy_120(:);
        
        locations = correctDecision_entropy_120 == 1;
        entropy_margin_120_nan = NaN(len, 1);
        entropy_margin_120_nan(locations) = entropy_margin_120(locations);

        entropy_margin_arr(:, i) = [entropy_margin_100_nan(:); entropy_margin_120_nan(:)];
        
    else
        entropy_margin_100 = [results_part_100.entropy_margin];
        entropy_margin_120 = [results_part_120.entropy_margin];
        
        entropy_margin_arr(:, i) = [entropy_margin_100(:); entropy_margin_120(:)];
        
    end
end


plotColors = {[0.55 0.71 0] [0.2 0.4 0.5] 'c' [0.5 0 0.5] 'b' [1 0.5 0]};
width = .6; %// small width to avoid overlap
labels = {'0' '0.5' '0.7' '1' '1.4' '2' '4' '8' '16'};


f = figure;
f.Position = [100 100 540 250];
h1 = boxplot(entropy_margin_arr, 'Color', plotColors{1}, 'boxstyle', 'filled', 'MedianStyle', 'target',...
     'position', (1:numel(labels)), 'widths', width, 'labels', labels); hold on
grid on;
xt = get(gca, 'XTick'); yt = get(gca, 'YTick');
xlabel('ENF amplitude in pel intensity', 'FontSize', 11);
ylabel('Entropy margin', 'FontSize', 11); 


