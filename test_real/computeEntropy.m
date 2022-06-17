function ret_entropy = computeEntropy(x, support)
%% Chau-Wai Wong, Oct. 2016

myEntropy = @(pmf) -pmf(:)'/sum(pmf) * log2(pmf(:)/sum(pmf));

cnt_raw = hist(x, support);
pmf_raw = cnt_raw/sum(cnt_raw);
ret_entropy = myEntropy(pmf_raw(pmf_raw>0));