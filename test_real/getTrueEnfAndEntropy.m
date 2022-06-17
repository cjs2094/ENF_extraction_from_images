function [enf_true, sinusoidalPartEnf_true, x_true, entropy_raw_total] = getTrueEnfAndEntropy(Fe_true, T_row, m_s, m_t, results, col_idx_set, num_of_col_to_use)

img_raw = imread(results{:, 2});
img_raw = double(rgb2gray(img_raw));
img_size = size(img_raw);

x_true = results{:, 3};
a_1 = x_true(1);
a_M = x_true(2);
k   = x_true(3);
b   = x_true(4);
phi = x_true(5);

M = img_size(1);
%a_s = a_1*m_s;
a_s = (a_M / M)*m_s
a_t = (a_M / M)*m_t;

mRange = m_s : m_t;
mag = ((a_t - a_s)/(m_t - m_s) * mRange + a_s);
trend = k*mRange + b;
enf_true = mag .* cos(2*pi*Fe_true*T_row*mRange + phi) + trend;
enf_true = enf_true(:);
sinusoidalPartEnf_true = mag .* cos(2*pi*Fe_true*T_row*mRange + phi);
sinusoidalPartEnf_true = sinusoidalPartEnf_true(:);

pel_level_range = [0:255];
col_residue = img_raw(:, col_idx_set);
entropy_raw_arr = zeros(num_of_col_to_use, 1);
for jjj = 1 : num_of_col_to_use
    entropy_raw_arr(jjj) = computeEntropy(col_residue(:,jjj), pel_level_range);
end
entropy_raw_total = mean(entropy_raw_arr);