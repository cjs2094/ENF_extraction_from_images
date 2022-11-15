function entropy_estRaw_total = func_entropyCol(img, mRange, colIdxSet, T_row, frequency, a_s, a_t, KSet, phi)
% Jisoo Choi, 4/25/2021

pelLevelRange = [0:255];

mRange = mRange(:);
m_s    = mRange(1);
m_t    = mRange(end);

numOfColUsed = length(colIdxSet);

signalSet = img(m_s:m_t, colIdxSet);

mag = ((a_t - a_s)/(m_t - m_s)*(mRange - m_s) + a_s);

trend = KSet .* mRange;

enfEst = mag .* cos(2*pi*frequency*T_row*mRange + phi) + trend;

colResidue = signalSet - enfEst;
%colResidue = signalSet - enfEst * ones(1, numOfColUsed);

entropy_estRaw_arr = zeros(numOfColUsed, 1);
for i = 1 : numOfColUsed
    entropy_estRaw_arr(i) = func_computeEntropy(colResidue(:,i), pelLevelRange);
end

entropy_estRaw_total = mean(entropy_estRaw_arr);
