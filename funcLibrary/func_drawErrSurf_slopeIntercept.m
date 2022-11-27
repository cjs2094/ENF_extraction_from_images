function func_drawErrSurf_slopeIntercept(imgPath, T_row, relativeStr, absoluteStr, phase0Cnt, ENF_arr)

%% synthesize ENF containing images

if exist('enfContainingImages', 'var') ~= 1
    [enfContainingImages, enfSignals, trueParameters] = func_synEnfContainingImgs_slopeIntercept...
        (imgPath, T_row, relativeStr, absoluteStr, phase0Cnt, ENF_arr);
end


%% detailed settings

idx_initPhase = 1; % initial phase
idx_ENF = 2; % enf: 1 (100Hz) or 2 (120Hz)
idx_img = 1; % image idx

numOfColsToUse = 2^5; % default: 5

f_ENF = ENF_arr(idx_ENF);
img_with_enf = double(enfContainingImages{idx_initPhase}{idx_ENF}{idx_img});
img_gray = img_with_enf;
enfSignal = double(enfSignals{idx_initPhase}{idx_ENF}{idx_img});
trueParam = double(trueParameters{idx_initPhase}{idx_ENF}{idx_img});

numOfPts = 50;
if trueParam(1) > 0
    a_sAdditiveRange = linspace(0, 25, numOfPts);
    a_tAdditiveRange = linspace(0, 25, numOfPts);
    a_max = 25;
    a_min = 0;
else
    a_sAdditiveRange = linspace(-25, 0, numOfPts);
    a_tAdditiveRange = linspace(-25, 0, numOfPts);
    a_max = 0;
    a_min = -25;
end

img_size = size(img_gray);
M = img_size(1);

kAdditiveRange = linspace(0, 0.005, numOfPts);
bAdditiveRange = linspace(0, 2, numOfPts);
phaseAdditiveRange = linspace(0, 2*pi, numOfPts);
trueFreq = f_ENF;


% column selection
n_s = 1;
n_t = img_size(2);

% select evenly spaced columns; The further they are apart, the lower the correlation we will have.
num_of_n = n_t - n_s + 1;
maxWidth = floor(num_of_n / numOfColsToUse);
n_s0 = 5; %n_s0 = randsample(n_s : n_s + maxWidth - 1, 1);
col_idx_set = n_s0:maxWidth:n_s0 + maxWidth*(numOfColsToUse - 1);


%% error surfaces for 2 varying paras when other parameters are correct
[g1a_s, g1a_t]   = meshgrid(a_sAdditiveRange, a_tAdditiveRange);
[g2a_s, g2k]     = meshgrid(a_sAdditiveRange, kAdditiveRange);
[g3a_s, g3b]     = meshgrid(a_sAdditiveRange, bAdditiveRange);
[g4a_s, g4phase] = meshgrid(a_sAdditiveRange, phaseAdditiveRange);
[g5a_t, g5k]     = meshgrid(a_tAdditiveRange, kAdditiveRange);
[g6a_t, g6b]     = meshgrid(a_tAdditiveRange, bAdditiveRange);
[g7a_t, g7phase] = meshgrid(a_tAdditiveRange, phaseAdditiveRange);
[g8k, g8b]       = meshgrid(kAdditiveRange, bAdditiveRange);
[g9k, g9phase]   = meshgrid(kAdditiveRange, phaseAdditiveRange);
[g10b, g10phase] = meshgrid(bAdditiveRange, phaseAdditiveRange);


entropy_data1 = [];
entropy_data2 = [];
entropy_data3 = [];
entropy_data4 = [];
entropy_data5 = [];
entropy_data6 = [];
entropy_data7 = [];
entropy_data8 = [];
entropy_data9 = [];
entropy_data10 = [];

t_start = tic;
for x_ = 1 : length(a_sAdditiveRange)
    for y_ = 1 : length(a_tAdditiveRange)
        g1a_s_ = g1a_s(x_, y_); g1a_t_ = g1a_t(x_, y_);
        g2a_s_ = g2a_s(x_, y_); g2k_ = g2k(x_, y_);
        g3a_s_ = g3a_s(x_, y_); g3b_ = g3b(x_, y_);
        g4a_s_ = g4a_s(x_, y_); g4phase_ = g4phase(x_, y_);
        
        g5a_t_ = g5a_t(x_, y_); g5k_ = g5k(x_, y_);
        g6a_t_ = g6a_t(x_, y_); g6b_ = g6b(x_, y_);
        g7a_t_ = g7a_t(x_, y_); g7phase_ = g7phase(x_, y_);
        
        g8k_ = g8k(x_, y_); g8b_ = g8b(x_, y_);
        g9k_ = g9k(x_, y_); g9phase_ = g9phase(x_, y_);
        
        g10b_ = g10b(x_, y_); g10phase_ = g10phase(x_, y_);
        
        entropy_data1(x_, y_)  = func_objective_imgEntropyCol_slopeIntercept(img_gray, size(img_gray), col_idx_set, T_row, trueFreq, g1a_s_, g1a_t_, trueParam(3), trueParam(4), trueParam(5));
        entropy_data2(x_, y_)  = func_objective_imgEntropyCol_slopeIntercept(img_gray, size(img_gray), col_idx_set, T_row, trueFreq, g2a_s_, trueParam(2), g2k_, trueParam(4), trueParam(5));
        entropy_data3(x_, y_)  = func_objective_imgEntropyCol_slopeIntercept(img_gray, size(img_gray), col_idx_set, T_row, trueFreq, g3a_s_, trueParam(2), trueParam(3), g3b_, trueParam(5));
        entropy_data4(x_, y_)  = func_objective_imgEntropyCol_slopeIntercept(img_gray, size(img_gray), col_idx_set, T_row, trueFreq, g4a_s_, trueParam(2), trueParam(3), trueParam(4), g4phase_);
        
        entropy_data5(x_, y_)  = func_objective_imgEntropyCol_slopeIntercept(img_gray, size(img_gray), col_idx_set, T_row, trueFreq, trueParam(1), g5a_t_, g5k_, trueParam(4), trueParam(5));
        entropy_data6(x_, y_)  = func_objective_imgEntropyCol_slopeIntercept(img_gray, size(img_gray), col_idx_set, T_row, trueFreq, trueParam(1), g6a_t_, trueParam(3), g6b_, trueParam(5));
        entropy_data7(x_, y_)  = func_objective_imgEntropyCol_slopeIntercept(img_gray, size(img_gray), col_idx_set, T_row, trueFreq, trueParam(1), g7a_t_, trueParam(3), trueParam(4), g7phase_);
        
        entropy_data8(x_, y_)  = func_objective_imgEntropyCol_slopeIntercept(img_gray, size(img_gray), col_idx_set, T_row, trueFreq, trueParam(1), trueParam(2), g8k_, g8b_, trueParam(5));
        entropy_data9(x_, y_)  = func_objective_imgEntropyCol_slopeIntercept(img_gray, size(img_gray), col_idx_set, T_row, trueFreq, trueParam(1), trueParam(2), g9k_, trueParam(4), g9phase_);
        
        entropy_data10(x_, y_) = func_objective_imgEntropyCol_slopeIntercept(img_gray, size(img_gray), col_idx_set, T_row, trueFreq, trueParam(1), trueParam(2), trueParam(3), g10b_, g10phase_);
    end
    
    
    %% show progress
    t_passed = toc(t_start);  % in sec
    eta = x_/length(a_sAdditiveRange);
    t_remaining = t_passed/eta - t_passed;
    disp(sprintf('time passed: %.0f secs', t_passed));
    disp(sprintf('time remaining: %.0f secs', t_remaining));
    disp(sprintf('\n'));
end


%% plot - related to fig.15.a of the paper

fontSize_label = 30;

figure('units','normalized','outerposition',[0 0 1 1])
subplot(2, 5, 1);
contourf(a_sAdditiveRange, a_tAdditiveRange, entropy_data1, '--', 'LineWidth', 1.5, 'ShowText', 'on'); hold on;
text(trueParam(1), trueParam(2), '*', 'Color', 'r', 'FontSize', 20); hold off;
xlabel('$a_\textrm{s}$', 'fontsize', fontSize_label, 'interpreter', 'latex');
ylabel('$a_\textrm{t}$', 'fontsize', fontSize_label, 'interpreter', 'latex');
set(gca, 'xtick', [])
set(gca, 'ytick', [])
axis('square')

subplot(2, 5, 2);
contourf(a_sAdditiveRange, kAdditiveRange, entropy_data2, '--', 'LineWidth', 1.5, 'ShowText', 'on'); hold on;
text(trueParam(1), trueParam(3), '*', 'Color', 'r', 'FontSize', 20); hold off;
xlabel('$a_\textrm{s}$', 'fontsize', fontSize_label, 'interpreter', 'latex');
ylabel('$k^E$', 'fontsize', fontSize_label, 'interpreter', 'latex');
set(gca, 'xtick', [])
set(gca, 'ytick', [])
axis('square')

subplot(2, 5, 3);
contourf(a_sAdditiveRange, bAdditiveRange, entropy_data3, '--', 'LineWidth', 1.5, 'ShowText', 'on'); hold on;
text(trueParam(1), trueParam(4), '*', 'Color', 'r', 'FontSize', 20); hold off;
xlabel('$a_\textrm{s}$', 'fontsize', fontSize_label, 'interpreter', 'latex');
ylabel('$b^E$', 'fontsize', fontSize_label, 'interpreter', 'latex');
set(gca, 'xtick', [])
set(gca, 'ytick', [])
axis('square')

subplot(2, 5, 4);
contourf(a_sAdditiveRange, phaseAdditiveRange, entropy_data4, '--', 'LineWidth', 1.5, 'ShowText', 'on'); hold on;
text(trueParam(1), trueParam(5), '*', 'Color', 'r', 'FontSize', 20); hold off;
xlabel('$a_\textrm{s}$', 'fontsize', fontSize_label, 'interpreter', 'latex');
ylabel('$\phi$', 'fontsize', fontSize_label, 'interpreter', 'latex');
set(gca, 'xtick', [])
set(gca, 'ytick', [])
axis('square')

subplot(2, 5, 5);
contourf(a_tAdditiveRange, kAdditiveRange, entropy_data5, '--', 'LineWidth', 1.5, 'ShowText', 'on'); hold on;
text(trueParam(2), trueParam(3), '*', 'Color', 'r', 'FontSize', 20); hold off;
xlabel('$a_\textrm{t}$', 'fontsize', fontSize_label, 'interpreter', 'latex');
ylabel('$k^E$', 'fontsize', fontSize_label, 'interpreter', 'latex');
set(gca, 'xtick', [])
set(gca, 'ytick', [])
axis('square')

subplot(2, 5, 6);
contourf(a_tAdditiveRange, bAdditiveRange, entropy_data6, '--', 'LineWidth', 1.5, 'ShowText', 'on'); hold on;
text(trueParam(2), trueParam(4), '*', 'Color', 'r', 'FontSize', 20); hold off;
xlabel('$a_\textrm{t}$', 'fontsize', fontSize_label, 'interpreter', 'latex');
ylabel('$b^E$', 'fontsize', fontSize_label, 'interpreter', 'latex');
set(gca, 'xtick', [])
set(gca, 'ytick', [])
axis('square')

subplot(2, 5, 7);
contourf(a_tAdditiveRange, phaseAdditiveRange, entropy_data7, '--', 'LineWidth', 1.5, 'ShowText', 'on'); hold on;
text(trueParam(2), trueParam(5), '*', 'Color', 'r', 'FontSize', 20); hold off;
xlabel('$a_\textrm{t}$', 'fontsize', fontSize_label, 'interpreter', 'latex');
ylabel('$\phi$', 'fontsize', fontSize_label, 'interpreter', 'latex');
axis('square')

subplot(2, 5, 8);
contourf(kAdditiveRange, bAdditiveRange, entropy_data8, '--', 'LineWidth', 1.5, 'ShowText', 'on'); hold on;
text(trueParam(3), trueParam(4), '*', 'Color', 'r', 'FontSize', 20); hold off;
xlabel('$k^E$', 'fontsize', fontSize_label, 'interpreter', 'latex');
ylabel('$b^E$', 'fontsize', fontSize_label, 'interpreter', 'latex');
set(gca, 'xtick', [])
set(gca, 'ytick', [])
axis('square')

subplot(2, 5, 9);
contourf(kAdditiveRange, phaseAdditiveRange, entropy_data9, '--', 'LineWidth', 1.5, 'ShowText', 'on'); hold on;
text(trueParam(3), trueParam(5), '*', 'Color', 'r', 'FontSize', 20); hold off;
xlabel('$k^E$', 'fontsize', fontSize_label, 'interpreter', 'latex');
ylabel('$\phi$', 'fontsize', fontSize_label, 'interpreter', 'latex');
set(gca, 'xtick', [])
set(gca, 'ytick', [])
axis('square')

subplot(2, 5, 10);
contourf(bAdditiveRange, phaseAdditiveRange, entropy_data10, '--', 'LineWidth', 1.5, 'ShowText', 'on'); hold on;
text(trueParam(4), trueParam(5), '*', 'Color', 'r', 'FontSize', 20); hold off;
xlabel('$b^E$', 'fontsize', fontSize_label, 'interpreter', 'latex');
ylabel('$\phi$', 'fontsize', fontSize_label, 'interpreter', 'latex');
set(gca, 'xtick', [])
set(gca, 'ytick', [])
axis('square')
func_tightfig;

