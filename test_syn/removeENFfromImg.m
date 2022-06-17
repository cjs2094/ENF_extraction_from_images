function [originalImgEstimate, sinusoidalPartEnf_entropy] = removeENFfromImg(img, imgSize, T_row, frequency, m_s, m_t, a_s, a_t, phi)
%% 
%  Jisoo Choi, 07/19/2019

mRange = 1:imgSize(1);
mRange = mRange(:);
M = mRange(end);

a_1 = a_s / m_s;
a_M = M*a_t/m_t;

mag = ((a_M - a_1)/(M - 1)*(mRange - 1) + a_1);

sinusoidalPartEnf_entropy = mag .* cos(2*pi*frequency*T_row*mRange + phi);

numOfTotalCols = imgSize(2);

originalImgEstimate = img - sinusoidalPartEnf_entropy * ones(1, numOfTotalCols);

clipLogSet1 = originalImgEstimate > 255;
clipLogSet2 = originalImgEstimate < 0;
clipPerc = mean(clipLogSet1(:)) + mean(clipLogSet2(:));
disp(sprintf('clipped perc = %.1f%%', clipPerc*100));

originalImgEstimate = uint8(originalImgEstimate);
% originalImgEstimate = uint8(255*normalize(originalImgEstimate, 'range', [0 1]));

sinusoidalPartEnf_entropy = sinusoidalPartEnf_entropy(m_s:m_t);

disp(sprintf('\n'))

% function [originalImgEstimate, enfEst] = func_removeENFfromImg(img, imgSize, T_row, a1_l, a1_r, a2, b2, c2, frequency, phi)
% %% 
% %  Jisoo Choi, 07/19/2019
% 
% yRange = [0 : (imgSize(1)-1)]';
% 
% scaling = ((a1_r-a1_l)/(imgSize(1)-1)*yRange + a1_l);
% 
% bias = a2*yRange.^2 + b2*yRange + c2;
% 
% enfEst = scaling .* cos(2*pi*frequency*T_row*yRange + phi) + bias;
% 
% numOfTotalCol = imgSize(2);
% 
% originalImgEstimate = img - enfEst * ones(1, numOfTotalCol);
% 
% clipLogSet = originalImgEstimate > 255;
% clipPerc = mean(clipLogSet(:));
% disp(sprintf('clipped perc = %.1f%%', clipPerc*100));
% 
% originalImgEstimate = uint8(originalImgEstimate);
% % originalImgEstimate = uint8(255*normalize(originalImgEstimate, 'range', [0 1]));
% 
% disp(sprintf('\n'))

