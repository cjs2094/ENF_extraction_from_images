function func_genHistsForEstimates(imgPath, T_row, relativeStr, absoluteStr, phase0Cnt, fe)

sz1 = 100;
sz2 = 1;
ENF_arr = unifrnd(fe-0.002*fe, fe+0.002*fe, sz1, sz2);

%% synthesize ENF containing images
if exist('enfContainingImages', 'var') ~= 1
    [enfContainingImages, enfSignals, trueParameters] = func_synEnfContainingImgs_slopeIntercept...
        (imgPath, T_row, relativeStr, absoluteStr, phase0Cnt, ENF_arr);
end

idx_initPhase  = 1; % initial phase
idx_img        = 2; % image idx 2
numOfColsToUse = 2^5; % default: 5

x_f120_arr = [];
t_start = tic;
for idx_ENF = 1 : length(ENF_arr)
    f_ENF = ENF_arr(idx_ENF);
    img_with_enf = double(enfContainingImages{idx_initPhase}{idx_ENF}{idx_img});
    img = img_with_enf;
    enfSignal = double(enfSignals{idx_initPhase}{idx_ENF}{idx_img});
    trueParam = double(trueParameters{idx_initPhase}{idx_ENF}{idx_img});
    
    colCnt = size(img, 2);
    col_idx_set = 1 : floor(colCnt/numOfColsToUse) : colCnt;
    
    %%%%%%%%%%%%%%%%%%%%%%%%% ent mini %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    mRange = 1 : size(img, 1);
    [~, hatOfKSet, ~] = func_estimateKBSet(img, mRange, col_idx_set);
    
    fun_100 = @(x) func_entropyCol(img, mRange, col_idx_set, T_row, 100, x(1), x(2), hatOfKSet, x(3));
    fun_120 = @(x) func_entropyCol(img, mRange, col_idx_set, T_row, 120, x(1), x(2), hatOfKSet, x(3));
    
    if trueParam(1) > 0
        LB = [0 0 0];
        UB = [25 25 2*pi];
    else
        LB = [-25 -25 0];
        UB = [0 0 2*pi];
    end
    
    x0 = [10 10 pi/2];
    %[x_f100, fval_100] = fminsearchbnd(fun_100, x0, LB, UB);
    [x_f120, ~] = func_fminsearchbnd(fun_120, x0, LB, UB);
    
    x_f120_arr(idx_ENF, :) = x_f120;
    
    
    %% show progress
    t_passed = toc(t_start);  % in sec
    eta = idx_ENF/length(ENF_arr);
    t_remaining = t_passed/eta - t_passed;
    disp(sprintf('time passed: %.0f secs', t_passed));
    disp(sprintf('time remaining: %.0f secs', t_remaining));
    disp(sprintf('\n'));
end


%% plot

figure;
subplot(1, 3, 1)
h = histogram(x_f120_arr(:, 1)); hold on;
h.FaceColor = [1 1 1];
h.NumBins = 30;
xline(trueParam(1), 'r--', 'LineWidth', 1.5); hold off;
xlim([trueParam(1) - 1.4, trueParam(1) + 0.6]); ylim([0 11]);
grid on;
xlabel('$\hat{a}_\textrm{s}$', 'fontsize', 10, 'Interpreter', 'latex');

subplot(1, 3, 2)
h = histogram(x_f120_arr(:, 2)); hold on;
h.FaceColor = [1 1 1];
h.NumBins = 30;
xline(trueParam(2), 'r--', 'LineWidth', 1.5); hold off;
xlim([trueParam(2) - 0.3, trueParam(2) + 1.1]); ylim([0 18]);
grid on;
xlabel('$\hat{a}_\textrm{t}$', 'fontsize', 10, 'Interpreter', 'latex');

subplot(1, 3, 3)
h = histogram(x_f120_arr(:, 3)); hold on;
h.FaceColor = [1 1 1];
h.NumBins = 30;
yUpper = max(h.Values) * 1.1;
%ylim([0 yUpper]); xlim([-0.4 2.2])
xline(trueParam(5), 'r--', 'LineWidth', 1.5); hold off;
xlim([trueParam(5) - 0.045, trueParam(5) + 0.02]); ylim([0 8]);
grid on;
xlabel('$\hat{\phi}$', 'fontsize', 10, 'Interpreter', 'latex');
set(gcf, 'position', [0, 0, 500, 110]);
func_tightfig;




