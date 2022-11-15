function ret_entropy = func_computeEntropy(x, support)
%% Chau-Wai Wong, Oct. 2016

myEntropy = @(pmf) -pmf(:)'/sum(pmf) * log2(pmf(:)/sum(pmf));

cnt_raw = hist(x, support);
pmf_raw = cnt_raw/sum(cnt_raw);
ret_entropy = myEntropy(pmf_raw(pmf_raw>0));

% myEntropy =@(pmf) -pmf(:)'/sum(pmf) * log2(pmf(:)/sum(pmf));
% 
% normx = x - min(x(:));
% normx = 255*normx ./ max(normx(:));
% 
% cnt_raw = hist(normx, support);
% pmf_raw = cnt_raw/sum(cnt_raw);
% retEntropy = myEntropy(pmf_raw(pmf_raw>0));