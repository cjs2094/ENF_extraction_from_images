function [x0, LB, UB] = func_initForFminsearchbnd_preModel(lll)

if mod(lll, 2) == 1
    a = unifrnd(0, 25);
    phi = 2*pi*rand;
 
    x0 = [a phi];
    LB = [0 0];
    UB = [25 2*pi];
else
    a = unifrnd(-25, 0);
    phi = 2*pi*rand;
    
    x0 = [a phi];
    LB = [-25 0];
    UB = [0 2*pi];
end
