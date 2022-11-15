function h = func_subplottight(n, m, i)
[c,r] = ind2sub([m n], i);
% [(c-1)/m, 1-(r)/n, 1/m, 1/n]
ax = subplot('Position', [(c-1)/m, 1-(r)/n, 1/m, 1/n]);
if(nargout > 0)
    h = ax;
end