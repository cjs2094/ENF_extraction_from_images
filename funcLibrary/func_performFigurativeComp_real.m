function func_performFigurativeComp_real(img_gray, img_size, region, lim, mRange, Fe_hat_curve, Fe_hat_entropy,...
    img_residue_curveFitting, sinusoidalPartEnf_fit, sinusoidalPartEnf_entropy, Iavg, trend_fit,...
    error_fit, img_residue_entMini, ISet, residueSet, trendSet, errorSet, img_file_name)


h = figure('units','normalized','outerposition',[0 0 1 1]);
subplot(3,5,1)
J = imadjust(img_gray, lim, []);
imshow(imresize(J, 1.5/8, 'bicubic'));
title('Image with ENF', 'Interpreter', 'latex');

subplot(3,5,3)
plot(mRange, ISet);
grid on;
xlim([1 img_size(1)]);
ylim([0 255]);
xlabel('Row index i', 'Interpreter', 'latex');
title('Pixel intensity signals of original img $I_j(i)$', 'Interpreter', 'latex')

subplot(3,5,6)
J = imadjust(img_residue_curveFitting, lim, []);
imshow(imresize(J, 1.5/8, 'bicubic'));
title(['Residue image by curveFitting ', region], 'Interpreter', 'latex');

subplot(3,5,7)
plot(mRange, sinusoidalPartEnf_fit, 'b:', 'LineWidth', 1.2);
grid on;
xlim([1 img_size(1)]); ylim([-30 30]);
xlabel('Row index i', 'Interpreter', 'latex');
legend(['est by curve fitting ', region, '($\hat{F}_e=' num2str(Fe_hat_curve) '$)'],...
    'Location', 'Best', 'Interpreter', 'latex');
title('Sinusoidal parts of ENF signals', 'Interpreter', 'latex')

subplot(3,5,8)
plot(mRange, Iavg, 'k-', 'LineWidth', 1.2);
grid on;
xlim([1 img_size(1)]);
ylim([0 255]);
xlabel('Row index i', 'Interpreter', 'latex');
title('Averaged pixel intensity signals $I_\textrm{avg}(i)$', 'Interpreter', 'latex')

subplot(3,5,9)
plot(mRange, trend_fit, 'k-', 'LineWidth', 1.2);
grid on;
xlim([1 img_size(1)]);
ylim([0 255]);
xlabel('Row index i', 'Interpreter', 'latex');
title({['Trend signals $\hat{k} i + \hat{b}$'], ['by curve fitting ', region]}, 'Interpreter', 'latex');

subplot(3,5,10)
plot(mRange, error_fit, 'k-', 'LineWidth', 1.2);
grid on;
xlim([1 img_size(1)]);
ylim([-255 255]);
xlabel('Row index i', 'Interpreter', 'latex');
title({['Error signals $\hat{\epsilon}(i)$'], ['by curve fitting ', region]}, 'Interpreter', 'latex');

subplot(3,5,11)
J = imadjust(img_residue_entMini, lim, []);
imshow(imresize(J, 1.5/8, 'bicubic'));
title(['Residue image by entMini ', region], 'Interpreter', 'latex');

subplot(3,5,12)
plot(mRange, sinusoidalPartEnf_entropy, 'r.', 'LineWidth', 1.2);
grid on;
xlim([1 img_size(1)]); ylim([-30 30]);
xlabel('Row index i', 'Interpreter', 'latex');
legend(['est by entropy mini ', region, '($\hat{F}_e=' num2str(Fe_hat_entropy) '$)'], ...
    'Location', 'Best', 'Interpreter', 'latex');
title('Sinusoidal parts of ENF signals', 'Interpreter', 'latex');

subplot(3,5,13)
plot(mRange, residueSet);
grid on;
xlim([1 img_size(1)]);
ylim([0 255]);
xlabel('Row index i', 'Interpreter', 'latex');
title('Pixel intensity signals of residue img', 'Interpreter', 'latex');

subplot(3,5,14)
plot(mRange, trendSet);
grid on;
xlim([1 img_size(1)]);
ylim([0 255]);
xlabel('Row index i', 'Interpreter', 'latex');
title({'Trend signals $\hat{k}_j i + \hat{b}_j$', ['by entropy mini ', region]}, 'Interpreter', 'latex');

subplot(3,5,15)
plot(mRange, errorSet);
grid on;
xlim([1 img_size(1)]);
ylim([-255 255]);
xlabel('Row index i', 'Interpreter', 'latex');
title({['Error signals $\hat{\epsilon}_j(i)$'], ['by entropy mini ', region]}, 'Interpreter', 'latex');
saveas(h, img_file_name);