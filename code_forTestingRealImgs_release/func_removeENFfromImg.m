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

sinusoidalPartEnf_entropy = sinusoidalPartEnf_entropy(m_s:m_t);

disp(sprintf('\n'))
