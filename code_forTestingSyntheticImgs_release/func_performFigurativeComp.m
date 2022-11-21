function func_performFigurativeComp(img_gray, img_size, region, lim, mRange, enf_true, x_true, Fe_true, Fe_hat_para, Fe_hat_entropy,...
img_residue_paraFitting, sinusoidalPartEnf_true, sinusoidalPartEnf_fit, sinusoidalPartEnf_entropy, Iavg, trend_fit,...
    error_fit, img_residue_entMini, ISet, trendSet, errorSet, img_file_name)


h = figure('units','normalized','outerposition',[0 0 1 1]);
subplot(3, 5, 1)
J = imadjust(img_gray, lim, []);
imshow(imresize(J, 1.5/8, 'bicubic'));
title('Image with ENF', 'Interpreter', 'latex');

subplot(3, 5, 2)
plot(mRange, enf_true, 'k-', 'LineWidth', 1.2);
grid on;
xlim([1 img_size(1)]); ylim([-30 30]);
xlabel('Row index i', 'Interpreter', 'latex');
legend(['$a_s=$', num2str(x_true(1)),...
    ', $a_t=$', num2str(x_true(2)), ', $k=$', num2str(x_true(3)),...
    ', $b=$', num2str(x_true(4)), ', $\phi=$', num2str(x_true(5))], 'Location', 'Best', 'Interpreter', 'latex');
title('True syn ENF signal', 'Interpreter', 'latex')


subplot(3, 5, 6)
J = imadjust(img_residue_paraFitting, lim, []);
imshow(imresize(J, 1.5/8, 'bicubic'));
title(['Residue image by curveFitting ', region], 'Interpreter', 'latex');

subplot(3, 5, 7)
plot(mRange, sinusoidalPartEnf_true, 'k-', 'LineWidth', 1.2); hold on;
plot(mRange, sinusoidalPartEnf_fit, 'b:', 'LineWidth', 1.2); hold off;
grid on;
xlim([1 img_size(1)]); ylim([-30 30]);
xlabel('Row index i', 'Interpreter', 'latex');
legend(['true ($F_e=', num2str(Fe_true), '$)'], ['est by curve fitting ', region, '($\hat{F}_e=' num2str(Fe_hat_para) '$)'],...
    'Location', 'Best', 'Interpreter', 'latex');
title('Sinusoidal parts of ENF signals', 'Interpreter', 'latex')

subplot(3, 5, 8)
plot(mRange, Iavg, 'k-', 'LineWidth', 1.2);
grid on;
xlim([1 img_size(1)]);
ylim([0 255]);
xlabel('Row index i', 'Interpreter', 'latex');
title('Averaged pixel intensity signals $I_\textrm{avg}(i)$', 'Interpreter', 'latex')

subplot(3, 5, 9)
plot(mRange, trend_fit, 'k-', 'LineWidth', 1.2);
grid on;
xlim([1 img_size(1)]);
ylim([0 255]);
xlabel('Row index i', 'Interpreter', 'latex');
title({['Trend signals $\hat{k} i + \hat{b}$'], ['by curve fitting ', region]}, 'Interpreter', 'latex');

subplot(3, 5, 10)
plot(mRange, error_fit, 'k-', 'LineWidth', 1.2);
grid on;
xlim([1 img_size(1)]);
ylim([-255 255]);
xlabel('Row index i', 'Interpreter', 'latex');
title({['Error signals $\hat{\epsilon}(i)$'], ['by curve fitting ', region]}, 'Interpreter', 'latex');


subplot(3, 5, 11)
J = imadjust(img_residue_entMini, lim, []);
imshow(imresize(J, 1.5/8, 'bicubic'));
title(['Residue image by entMini ', region], 'Interpreter', 'latex');

subplot(3, 5, 12)
plot(mRange, sinusoidalPartEnf_true, 'k-', 'LineWidth', 1.2); hold on;
plot(mRange, sinusoidalPartEnf_entropy, 'r.', 'LineWidth', 1.2); hold off;
grid on;
xlim([1 img_size(1)]); ylim([-30 30]);
xlabel('Row index i', 'Interpreter', 'latex');
legend(['true ($F_e=', num2str(Fe_true), '$)'], ['est by entropy mini ', region, '($\hat{F}_e=' num2str(Fe_hat_entropy) '$)'], ...
    'Location', 'Best', 'Interpreter', 'latex');
title('Sinusoidal parts of ENF signals', 'Interpreter', 'latex')

subplot(3, 5, 13)
plot(mRange, ISet);
grid on;
xlim([1 img_size(1)]);
ylim([0 255]);
xlabel('Row index i', 'Interpreter', 'latex');
title('Pixel intensity signals $I_j(i)$', 'Interpreter', 'latex')

subplot(3, 5, 14)
plot(mRange, trendSet);
grid on;
xlim([1 img_size(1)]);
ylim([0 255]);
xlabel('Row index i', 'Interpreter', 'latex');
title({['Trend signals $\hat{k}_j i + \hat{b}_j$'], ['by entropy mini ', region]}, 'Interpreter', 'latex')

subplot(3, 5, 15)
plot(mRange, errorSet);
grid on;
xlim([1 img_size(1)]);
ylim([-255 255]);
xlabel('Row index i', 'Interpreter', 'latex');
title({['Error signals $\hat{\epsilon}_j(i)$'], ['by entropy mini ', region]}, 'Interpreter', 'latex')
%set(gcf,'Position',[100 100 500 500])
saveas(h, img_file_name);