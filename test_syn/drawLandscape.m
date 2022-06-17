function drawLandscape(test_result, i)

set(0, 'DefaultFigureVisible', 'off');

%% subtract true ENF and see how the entropy increases

numOfColsToUse = length(test_result.col_idx_set);

ENF = test_result.Fe_true;

img = double(imread(test_result.unique_filename));

T_row = test_result.T_row;

trueParam = test_result.param_true;

dim = test_result.img_size;

yRange = 0 : (dim(1)-1);

mag = ((trueParam(2) - trueParam(1))/(dim(1)-1)*yRange + trueParam(1));

trend = trueParam(3)*yRange + trueParam(4);

enfSignal = mag .* cos(2*pi*ENF*T_row*yRange + trueParam(5)) + trend;

colIdxSetToUse = test_result.col_idx_set;



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

if trueParam(3) > 0
    kAdditiveRange = linspace(0, 1e-3, numOfPts);
    %kAdditiveRange = linspace(0, 10e-3, numOfPts);
else
    kAdditiveRange = linspace(-1e-3, 0, numOfPts);
    %kAdditiveRange = linspace(-10e-3, 0, numOfPts);
end
phaseAdditiveRange = linspace(0, 2*pi, numOfPts);
[hatOfKSet, ~] = estimateKBSet(img, size(img), colIdxSetToUse);



%% Error surfaces for 1 varying para when other parameters are correct

for x_ = 1 : length(a_sAdditiveRange)
        a_s_   = a_sAdditiveRange(x_);
        a_t_   = a_tAdditiveRange(x_);
        k_     = kAdditiveRange(x_);
        phase_ = phaseAdditiveRange(x_);   

        entropy_data1(x_) = objective_imgEntropyCol_VAVB(img, size(img), colIdxSetToUse, T_row, ENF, a_s_, trueParam(2), trueParam(3), trueParam(5));
        entropy_data2(x_) = objective_imgEntropyCol_VAVB(img, size(img), colIdxSetToUse, T_row, ENF, trueParam(1), a_t_, trueParam(3), trueParam(5));
        entropy_data3(x_) = objective_imgEntropyCol_VAVB(img, size(img), colIdxSetToUse, T_row, ENF, trueParam(1), trueParam(2), k_, trueParam(5));
        entropy_data4(x_) = objective_imgEntropyCol_VAVB(img, size(img), colIdxSetToUse, T_row, ENF, trueParam(1), trueParam(2), trueParam(3), phase_);
end

figure(1)
subplot(1,2,1);
imshow(uint8(img));
title('Image with synthetic ENF signal');

subplot(1,2,2);
plot(enfSignal);
grid on;
xlim([0, length(enfSignal)-1]);
ylim([-30, 30]);
legend({['$a_s$=', num2str(trueParam(1)), ', $a_t$=', num2str(trueParam(2))...
    10 '$\phi$=', num2str(trueParam(3))]}, 'interpreter', 'latex', 'fontsize', 14) 
xlabel('Row index');
absoluteStr = 0.5*abs(trueParam(1) + trueParam(2));
title(['Avg ENF mag = ', num2str(absoluteStr, 2), ' (out of 255)']);


% 1d plot
img_file_name = ['./landscape_results/1dLandscape_' num2str(i) '.png'];

h1 = figure('units','normalized','outerposition',[0 0 1 1])
subplot(2,2,1);
plot(a_sAdditiveRange, entropy_data1); hold on
xline(trueParam(1), 'r'); hold off
legend('entropy w.r.t varying $a_s$', 'true $a_s$ line', 'interpreter', 'latex', 'fontsize', 14)
grid on
xlabel('$a_s$', 'fontsize', 14, 'interpreter', 'latex', 'fontsize', 14); 
ylabel('Entropy', 'fontsize', 14);

subplot(2,2,2);
plot(a_tAdditiveRange, entropy_data2); hold on
xline(trueParam(2), 'r'); hold off
legend('entropy w.r.t varying $a_t$', 'true $a_t$ line', 'interpreter', 'latex', 'fontsize', 14)
grid on
xlabel('$a_t$', 'fontsize', 14, 'interpreter', 'latex', 'fontsize', 14); 
ylabel('Entropy', 'fontsize', 14);

subplot(2,2,3);
plot(kAdditiveRange, entropy_data3); hold on
xline(trueParam(3), 'r'); hold off
legend('entropy w.r.t varying k', 'true k line', 'interpreter', 'latex', 'fontsize', 14)
grid on
xlim([kAdditiveRange(1) kAdditiveRange(end)])
xlabel('$k$', 'fontsize', 14, 'interpreter', 'latex'); 
ylabel('Entropy', 'fontsize', 14);
sgtitle('Cost func of one parameter');

subplot(2,2,4);
plot(phaseAdditiveRange, entropy_data4); hold on
xline(trueParam(5), 'r'); hold off
legend('entropy w.r.t varying $\phi$', 'true $\phi$ line', 'interpreter', 'latex', 'fontsize', 14)
grid on
xlim([phaseAdditiveRange(1) phaseAdditiveRange(end)])
xlabel('$\phi$', 'fontsize', 14, 'interpreter', 'latex'); 
ylabel('Entropy', 'fontsize', 14);
sgtitle('Cost func of one parameter');
saveas(h1, img_file_name);


%% Error surfaces for 2 varying paras when other parameters are correct

[g1a_s, g1a_t]   = meshgrid(a_sAdditiveRange, a_tAdditiveRange);
[g2a_s, g2k]     = meshgrid(a_sAdditiveRange, kAdditiveRange);
[g3a_s, g3phase] = meshgrid(a_sAdditiveRange, phaseAdditiveRange);
[g4a_t, g4k]     = meshgrid(a_tAdditiveRange, kAdditiveRange);
[g5a_t, g5phase] = meshgrid(a_tAdditiveRange, phaseAdditiveRange);
[g6k, g6phase]   = meshgrid(kAdditiveRange, phaseAdditiveRange);

for x_ = 1 : length(a_sAdditiveRange)
    x_
    for y_ = 1 : length(a_tAdditiveRange)
        g1a_s_ = g1a_s(x_, y_); g1a_t_ = g1a_t(x_, y_);
        g2a_s_ = g2a_s(x_, y_); g2k_ = g2k(x_, y_);
        g3a_s_ = g3a_s(x_, y_); g3phase_ = g3phase(x_, y_);
        g4a_t_ = g4a_t(x_, y_); g4k_ = g4k(x_, y_);
        g5a_t_ = g5a_t(x_, y_); g5phase_ = g5phase(x_, y_);
        g6k_ = g6k(x_, y_);     g6phase_ = g6phase(x_, y_);
        
        entropy_data1(x_, y_)  = objective_imgEntropyCol_VAVB(img, size(img), colIdxSetToUse, T_row, ENF, g1a_s_, g1a_t_, trueParam(3), trueParam(5));
        entropy_data2(x_, y_)  = objective_imgEntropyCol_VAVB(img, size(img), colIdxSetToUse, T_row, ENF, g2a_s_, trueParam(2), g2k_, trueParam(5));
        entropy_data3(x_, y_)  = objective_imgEntropyCol_VAVB(img, size(img), colIdxSetToUse, T_row, ENF, g3a_s_, trueParam(2), trueParam(3), g3phase_);
        entropy_data4(x_, y_)  = objective_imgEntropyCol_VAVB(img, size(img), colIdxSetToUse, T_row, ENF, trueParam(1), g4a_t_, g4k_, trueParam(5));
        entropy_data5(x_, y_)  = objective_imgEntropyCol_VAVB(img, size(img), colIdxSetToUse, T_row, ENF, trueParam(1), g5a_t_, trueParam(3), g5phase_);
        entropy_data6(x_, y_)  = objective_imgEntropyCol_VAVB(img, size(img), colIdxSetToUse, T_row, ENF, trueParam(1), trueParam(2), g6k_, g6phase_);
    end
end


% 3d plot
% figure(3)
% subplot(1,3,1);
% surf(a_sAdditiveRange, a_tAdditiveRange, entropy_data1, 'EdgeColor', 'none'); hold on;
% plot3(trueParam(1), trueParam(2), entropy_true, 'r*', 'MarkerSize', 10); hold off;
% xlabel('$a_s$', 'fontsize', 14, 'interpreter', 'latex'); 
% ylabel('$a_t$', 'fontsize', 14, 'interpreter', 'latex');
% zlabel('Entropy', 'fontsize', 14)
% 
% subplot(1,3,2);
% surf(a_sAdditiveRange, phaseAdditiveRange, entropy_data2, 'EdgeColor', 'none'); hold on;
% plot3(trueParam(1), trueParam(5), entropy_true, 'r*', 'MarkerSize', 10); hold off;
% xlabel('$a_s$', 'fontsize', 14, 'interpreter', 'latex'); 
% ylabel('$\phi$', 'fontsize', 14, 'interpreter', 'latex');
% zlabel('Entropy', 'fontsize', 14)
% 
% subplot(1,3,3);
% surf(a_tAdditiveRange, phaseAdditiveRange, entropy_data3, 'EdgeColor', 'none'); hold on;
% plot3(trueParam(2), trueParam(5), entropy_true, 'r*', 'MarkerSize', 10); hold off; 
% xlabel('$a_t$', 'fontsize', 14, 'interpreter', 'latex'); 
% ylabel('$\phi$', 'fontsize', 14, 'interpreter', 'latex');
% zlabel('Entropy', 'fontsize', 14)
% sgtitle('Cost func of two parameters - surf plot');


img_file_name = ['./landscape_results/2dLandscape_' num2str(i) '.png'];

% contour plot
h2 = figure('units','normalized','outerposition',[0 0 1 1])
subplot(2,3,1);
contourf(a_sAdditiveRange, a_tAdditiveRange, entropy_data1, '--', 'LineWidth', 1.5, 'ShowText', 'on'); hold on;
text(trueParam(1), trueParam(2), '*', 'Color', 'r', 'FontSize', 20); hold off;
colorbar('southoutside')
xlabel('$a_s$', 'fontsize', 14, 'interpreter', 'latex'); 
ylabel('$a_t$', 'fontsize', 14, 'interpreter', 'latex');

subplot(2,3,2);
contourf(a_sAdditiveRange, kAdditiveRange, entropy_data2, '--', 'LineWidth', 1.5, 'ShowText', 'on'); hold on;
text(trueParam(1), trueParam(3), '*', 'Color', 'r', 'FontSize', 20); hold off;
colorbar('southoutside')
xlabel('$a_s$', 'fontsize', 14, 'interpreter', 'latex'); 
ylabel('$k$', 'fontsize', 14, 'interpreter', 'latex');

subplot(2,3,3);
contourf(a_sAdditiveRange, phaseAdditiveRange, entropy_data3, '--', 'LineWidth', 1.5, 'ShowText', 'on'); hold on;
text(trueParam(1), trueParam(5), '*', 'Color', 'r', 'FontSize', 20); hold off;
colorbar('southoutside')
xlabel('$a_s$', 'fontsize', 14, 'interpreter', 'latex'); 
ylabel('$\phi$', 'fontsize', 14, 'interpreter', 'latex');

subplot(2,3,4);
contourf(a_tAdditiveRange, kAdditiveRange, entropy_data4, '--', 'LineWidth', 1.5, 'ShowText', 'on'); hold on;
text(trueParam(2), trueParam(3), '*', 'Color', 'r', 'FontSize', 20); hold off;
colorbar('southoutside')
xlabel('$a_t$', 'fontsize', 14, 'interpreter', 'latex'); 
ylabel('$k$', 'fontsize', 14, 'interpreter', 'latex');

subplot(2,3,5);
contourf(a_tAdditiveRange, phaseAdditiveRange, entropy_data5, '--', 'LineWidth', 1.5, 'ShowText', 'on'); hold on;
text(trueParam(2), trueParam(5), '*', 'Color', 'r', 'FontSize', 20); hold off;
colorbar('southoutside')
xlabel('$a_t$', 'fontsize', 14, 'interpreter', 'latex'); 
ylabel('$\phi$', 'fontsize', 14, 'interpreter', 'latex');

subplot(2,3,6);
contourf(kAdditiveRange, phaseAdditiveRange, entropy_data6, '--', 'LineWidth', 1.5, 'ShowText', 'on'); hold on;
text(trueParam(3), trueParam(5), '*', 'Color', 'r', 'FontSize', 20); hold off;
colorbar('southoutside')
xlabel('$k$', 'fontsize', 14, 'interpreter', 'latex'); 
ylabel('$\phi$', 'fontsize', 14, 'interpreter', 'latex');
sgtitle('Cost func of two parameters - contour plot');
saveas(h2, img_file_name);

