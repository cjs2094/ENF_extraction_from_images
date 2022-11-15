function func_compareEERs_smoothVsNonsmoothVsOverall(mat_file_base_name1, mat_file_base_name2, fitting_results_flag, col_cnt)

%% settings

fontsize_xy = 16;
fontsize_legend = 15;
linewidth = 1.5;

%% load

fn0 = ['.\mat_results\bootstrap_smoothVsNonsmoothVsOverall_', mat_file_base_name1, '_', ...
    mat_file_base_name2, '_fitting_results_flag', num2str(fitting_results_flag), '_cols' num2str(col_cnt) '.mat'];

load(fn0);

x = str_arr;

%% 1st-level
f = figure(1);
f.Position = [100 100 540 320];
e = std(EER_entropy_arr_smooth_1st);
y = mean(EER_entropy_arr_smooth_1st);
xconf = [x x(end:-1:1)];
econf = [e -e(end:-1:1)];
yconf = [y y(end:-1:1)] + econf;
p = fill(xconf, yconf, 'r');    
p.FaceColor = [1 0.8 0.8];
p.FaceAlpha = 0.4;
p.EdgeColor = 'none'; 
hold on;
ha = plot(x, y, '-.r+', 'linewidth', linewidth); 
e = std(EER_entropy_arr_nonsmooth_1st);
y = mean(EER_entropy_arr_nonsmooth_1st);
econf = [e -e(end:-1:1)];
yconf = [y y(end:-1:1)] + econf;
p = fill(xconf, yconf, 'b');    
p.FaceColor = [0.67 0.84 0.95];      
p.FaceAlpha = 0.4;
p.EdgeColor = 'none';
hb = plot(x, y, '--bd', 'linewidth', linewidth);
e = std(EER_entropy_arr_overall_1st);
y = mean(EER_entropy_arr_overall_1st);
econf = [e -e(end:-1:1)];
yconf = [y y(end:-1:1)] + econf;
p = fill(xconf, yconf, 'k');    
p.FaceColor = [0.82 0.82 0.82];
p.FaceAlpha = 0.4;
p.EdgeColor = 'none';
hc = plot(x, y, '-ko', 'linewidth', linewidth); hold off;
xlabel('Relative strength of ENF (w/o scaling factor)', 'FontSize', fontsize_xy);
ylabel('Equal error rate (EER)', 'FontSize', fontsize_xy); grid on;
xlim([x(1), x(end)]); ylim([0 0.5]);
legend ([ha hb hc],'smooth', 'nonsmooth', 'both', 'Location', 'NorthEast', 'FontSize', fontsize_legend);
func_tightfig;



%% 2nd-level
f = figure;
f.Position = [100 100 540 320];
e = std(EER_entropy_arr_smooth_2nd_TP);
y = mean(EER_entropy_arr_smooth_2nd_TP);
xconf = [x x(end:-1:1)];
econf = [e -e(end:-1:1)];
yconf = [y y(end:-1:1)] + econf;
p = fill(xconf, yconf, 'r');    
p.FaceColor = [1 0.8 0.8];
p.FaceAlpha = 0.4;
p.EdgeColor = 'none'; 
hold on;
ha = plot(x, y, '-.r+', 'linewidth', linewidth); 
e = std(EER_entropy_arr_nonsmooth_2nd_TP);
y = mean(EER_entropy_arr_nonsmooth_2nd_TP);
econf = [e -e(end:-1:1)];
yconf = [y y(end:-1:1)] + econf;
p = fill(xconf, yconf, 'b');    
p.FaceColor = [0.67 0.84 0.95];      
p.FaceAlpha = 0.4;
p.EdgeColor = 'none';
hb = plot(x, y, '--bd', 'linewidth', linewidth);
e = std(EER_entropy_arr_overall_2nd_TP);
y = mean(EER_entropy_arr_overall_2nd_TP);
econf = [e -e(end:-1:1)];
yconf = [y y(end:-1:1)] + econf;
p = fill(xconf, yconf, 'k');    
p.FaceColor = [0.82 0.82 0.82];      
p.FaceAlpha = 0.4;
p.EdgeColor = 'none';
hc = plot(x, y, '-ko', 'linewidth', linewidth); hold off;
xlabel('Relative strength of ENF (w/o scaling factor)', 'FontSize', fontsize_xy);
ylabel('Equal error rate (EER)', 'FontSize', fontsize_xy); grid on;
xlim([x(1), x(end)]); ylim([0 1]);
legend ([ha hb hc],'smooth', 'nonsmooth', 'both', 'Location', 'NorthEast', 'FontSize', fontsize_legend);
func_tightfig;


