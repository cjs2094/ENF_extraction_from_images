function h = func_subplottight2(n,m,i)
[c,r] = ind2sub([m n], i);
%ax = subplot('Position', [(c-1)/m, 1-(r)/n - 0.09, 1/m, 1/n]);
ax = subplot('Position', [(c - 1)/m + 0.03, 1 - (r)/n, 1/m, 1/n]);
if(nargout > 0)
    h = ax;
end