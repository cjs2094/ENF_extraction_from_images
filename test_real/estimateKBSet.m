function [ISet, hatOfKSet, hatOfBSet] = estimateKBSet(img, mRange, colIdxSet)

mRange = mRange(:);

ISet = img(mRange, colIdxSet);

N = 1 ;
maxDistance = 5;
hatOfKSet = [];
for i = 1 : length(colIdxSet)
    I = ISet(:, i);
%   [hatOfBeta, ~] = linearReg(x, y);
    I = I(:);

    [P, ~] = fitPolynomialRANSAC([mRange, I], N, maxDistance);
    
    hatOfBSet(i) = P(2);
    hatOfKSet(i) = P(1);
end


