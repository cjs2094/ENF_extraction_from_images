function func_compareEERs_preliminaryVsProposed(mat_file_base_name1, mat_file_base_name2, fitting_results_flag, colSelect_mode, col_cnt)

%% settings

fontsize_xy = 16;
fontsize_legend = 15;
linewidth = 1.5;


%% load

fn0 = ['.\mat_results\bootstrap_preliminaryVsProposed_', mat_file_base_name1, '_', ...
    mat_file_base_name2, '_fitting_results_flag', num2str(fitting_results_flag), '_', colSelect_mode, '_cols' num2str(col_cnt) '.mat'];

load(fn0);

x = str_arr;


%% EER
f = figure;
f.Position = [100 100 540 320];
e = std(EER_entropy_arr_proposed_1st);
y = mean(EER_entropy_arr_proposed_1st);
xconf = [x x(end:-1:1)];
econf = [e -e(end:-1:1)];
yconf = [y y(end:-1:1)] + econf;
p = fill(xconf, yconf, 'k');    
p.FaceColor = [0.82 0.82 0.82];
p.FaceAlpha = 0.4;
p.EdgeColor = 'none'; 
hold on;
ha = plot(x, y, '-ko', 'linewidth', linewidth); 
e = std(EER_entropy_arr_preliminary_1st);
y = mean(EER_entropy_arr_preliminary_1st);
econf = [e -e(end:-1:1)];
yconf = [y y(end:-1:1)] + econf;
p = fill(xconf, yconf, 'b');    
p.FaceColor = [0.67 0.84 0.95];      
p.FaceAlpha = 0.4;
p.EdgeColor = 'none';
hb = plot(x, y, '--bd', 'linewidth', linewidth); hold off
xlabel('Relative strength of ENF (w/o scaling factor)', 'FontSize', fontsize_xy);
ylabel('Equal error rate (EER)', 'FontSize', fontsize_xy); grid on;
xlim([x(1), x(end)]); ylim([0 0.7]);
legend ([ha hb], 'proposed model', 'preliminary model', 'Location', 'NorthEast', 'FontSize', fontsize_legend);
func_tightfig;



%%
f = figure;
f.Position = [100 100 540 320];
e = std(AUC_entropy_arr_proposed_1st);
y = mean(AUC_entropy_arr_proposed_1st);
xconf = [x x(end:-1:1)];
econf = [e -e(end:-1:1)];
yconf = [y y(end:-1:1)] + econf;
p = fill(xconf, yconf, 'k');    
p.FaceColor = [0.82 0.82 0.82];
p.FaceAlpha = 0.4;
p.EdgeColor = 'none'; 
hold on;
ha = plot(x, y, '-ko', 'linewidth', linewidth); 
e = std(AUC_entropy_arr_preliminary_1st);
y = mean(AUC_entropy_arr_preliminary_1st);
econf = [e -e(end:-1:1)];
yconf = [y y(end:-1:1)] + econf;
p = fill(xconf, yconf, 'b');    
p.FaceColor = [0.67 0.84 0.95];      
p.FaceAlpha = 0.4;
p.EdgeColor = 'none';
hb = plot(x, y, '--bd', 'linewidth', linewidth); hold off
xlabel('Relative strength of ENF (w/o scaling factor)', 'FontSize', fontsize_xy);
ylabel('Area under curve (AUC)', 'FontSize', fontsize_xy); grid on;
xlim([str_arr(1), x(end)]); ylim([0.3 1]);
legend ([ha hb], 'proposed model', 'preliminary model', 'Location', 'SouthEast', 'FontSize', fontsize_legend)
func_tightfig;







