function [entropy_est_total, Iavg, sinusoidalPartEnf_fit, trend_fit, error_fit] = func_estimateEnfAndEntropyUsingFittingResults...
    (img_gray, fitresult, Fe_decided, T_row, m_s, m_t, col_idx_set, num_of_col_to_use)

img_size = size(img_gray);
mRange = m_s : m_t;
mRange = mRange(:);

Iavg = mean(img_gray(m_s : m_t, col_idx_set), 2);

mag_fit = ((fitresult.a_t-fitresult.a_s)/(m_t - m_s)*(mRange - m_s) + fitresult.a_s);
sinusoidalPartEnf_fit = mag_fit .* cos(2*pi*Fe_decided*T_row*mRange + fitresult.phi);
trend_fit = fitresult.k*mRange + fitresult.b;
I_fit = mag_fit.*cos(2*pi*Fe_decided*T_row*mRange + fitresult.phi) + trend_fit;
error_fit = Iavg - I_fit;

pel_level_range = [0 : 255];
signal_set = img_gray(mRange, col_idx_set);
col_residue = signal_set - sinusoidalPartEnf_fit * ones(1, num_of_col_to_use);
entropy_est_arr = zeros(num_of_col_to_use, 1);
for jjj = 1 : num_of_col_to_use
    entropy_est_arr(jjj) = func_computeEntropy(col_residue(:, jjj), pel_level_range);
end
entropy_est_total = mean(entropy_est_arr);