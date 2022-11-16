function [x0, LB, UB] = func_initForFminsearchbnd(lll)

if mod(lll, 2) == 1
    a_s = unifrnd(0, 25);
    a_t = a_s;
    phi = 2*pi*rand;
    
    x0 = [a_s a_t phi];
    LB = [0 0 0];
    UB = [25 25 2*pi];
else
    a_s = unifrnd(-25, 0);
    a_t = a_s;
    phi = 2*pi*rand;
    
    x0 = [a_s a_t phi];
    LB = [-25 -25 0];
    UB = [0 0 2*pi];
end
