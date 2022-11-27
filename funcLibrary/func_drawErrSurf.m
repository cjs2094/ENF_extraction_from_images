function func_drawErrSurf(imgPath, T_row, relativeStr, absoluteStr, phase0Cnt, ENF_arr)


%% synthesize ENF containing images
if exist('enfContainingImages', 'var') ~= 1
    [enfContainingImages, enfSignals, trueParameters] = func_synEnfContainingImgs_slopeIntercept...
        (imgPath, T_row, relativeStr, absoluteStr, phase0Cnt, ENF_arr);
end


idx_initPhase = 1; % initial phase
idx_ENF = 1; % enf: 1 (100Hz) or 2 (120Hz)
idx_img = 2; % image idx 2

numOfColsToUse = 2^5; % default: 5

f_ENF = ENF_arr(idx_ENF);
img_with_enf = double(enfContainingImages{idx_initPhase}{idx_ENF}{idx_img});
img = img_with_enf;
enfSignal = double(enfSignals{idx_initPhase}{idx_ENF}{idx_img});
trueParam = double(trueParameters{idx_initPhase}{idx_ENF}{idx_img});

colCnt = size(img, 2);
colIdxSetToUse = 1 : floor(colCnt/numOfColsToUse) : colCnt;
%colIdxSetToUse = randsample(3320:colCnt, numOfColsToUse);

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

phaseAdditiveRange = linspace(0, 2*pi, numOfPts);

mRange = 1 : size(img, 1);
[~, hatOfKSet, ~] = func_estimateKBSet(img, mRange, colIdxSetToUse);
f_ENF_true = f_ENF;



%% Error surfaces for 2 varying paras when other parameters are correct

[g1a_s, g1a_t]   = meshgrid(a_sAdditiveRange, a_tAdditiveRange);
[g2a_s, g2phase] = meshgrid(a_sAdditiveRange, phaseAdditiveRange);
[g3a_t, g3phase] = meshgrid(a_tAdditiveRange, phaseAdditiveRange);

entropy_data1 = [];
entropy_data2 = [];
entropy_data3 = [];


t_start = tic;
for x_ = 1 : length(a_sAdditiveRange)
    for y_ = 1 : length(a_tAdditiveRange)
        g1a_s_ = g1a_s(x_, y_); g1a_t_ = g1a_t(x_, y_);
        g2a_s_ = g2a_s(x_, y_); g2phase_ = g2phase(x_, y_);
        g3a_t_ = g3a_t(x_, y_); g3phase_ = g3phase(x_, y_);
        
        entropy_data1(x_, y_)  = func_objective_imgEntropyCol(img, size(img), colIdxSetToUse, T_row, f_ENF_true, g1a_s_, g1a_t_, hatOfKSet, trueParam(5));
        entropy_data2(x_, y_)  = func_objective_imgEntropyCol(img, size(img), colIdxSetToUse, T_row, f_ENF_true, g2a_s_, trueParam(2), hatOfKSet, g2phase_);
        entropy_data3(x_, y_)  = func_objective_imgEntropyCol(img, size(img), colIdxSetToUse, T_row, f_ENF_true, trueParam(1), g3a_t_, hatOfKSet, g3phase_);
    end
    
    
    %% show progress
    t_passed = toc(t_start); % in sec
    eta = x_/length(a_sAdditiveRange);
    t_remaining = t_passed/eta - t_passed;
    disp(sprintf('time passed: %.0f secs', t_passed));
    disp(sprintf('time remaining: %.0f secs', t_remaining));
    disp(sprintf('\n'));
end



% contour plot
labelFontsize = 25;
f = figure;
f.Position = [481.8000 200.2000 574.4000 509.6000]; 
ax1 = subplot(2, 2, 1);
ax1.Position = [0.1300 0.5844 0.3347 0.3406];
contourf(a_sAdditiveRange, a_tAdditiveRange, entropy_data1, '--', 'LineWidth', 1.5); hold on;
text(trueParam(1), trueParam(2), '*', 'Color', 'r', 'FontSize', 20); hold off;
xlabel('$a_\textrm{s}$', 'fontsize', labelFontsize, 'interpreter', 'latex'); 
ylabel('$a_\textrm{t}$', 'fontsize', labelFontsize, 'interpreter', 'latex');
set(gca,'xtick',[])
set(gca,'ytick',[])
axis square

ax2 = subplot(2, 2, 2);
ax2.Position = [0.5203 0.5844 0.3347 0.3406];
contourf(a_sAdditiveRange, phaseAdditiveRange, entropy_data2, '--', 'LineWidth', 1.5); hold on;
text(trueParam(1), trueParam(5), '*', 'Color', 'r', 'FontSize', 20); hold off;
xlabel('$a_\textrm{s}$', 'fontsize', labelFontsize, 'interpreter', 'latex'); 
ylabel('$\phi$', 'fontsize', labelFontsize, 'interpreter', 'latex');
set(gca,'xtick',[])
set(gca,'ytick',[])
axis square

ax3 = subplot(2, 2, 3.5);
ax3.Position = [0.3202 0.1400 0.3347 0.3412]; % [left bottom width height]
contourf(a_tAdditiveRange, phaseAdditiveRange, entropy_data3, '--', 'LineWidth', 1.5); hold on;
text(trueParam(2), trueParam(5), '*', 'Color', 'r', 'FontSize', 20); hold off;
xlabel('$a_\textrm{t}$', 'fontsize', labelFontsize, 'interpreter', 'latex'); 
ylabel('$\phi$', 'fontsize', labelFontsize, 'interpreter', 'latex');
set(gca,'xtick',[])
set(gca,'ytick',[])
print('yourTransparentImage','-depsc');
axis square
func_tightfig;


