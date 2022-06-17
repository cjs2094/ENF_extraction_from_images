function [ratio] = ENFStrength(t_exp, nominalENF)
%% Jisoo Choi, 08/09/2021

omega_0 = 2*pi*nominalENF;
ratio = abs(sin(omega_0*t_exp)./(omega_0*t_exp))


% omega_0 = 2*pi*60;
% t_exp = [1/30 1/55 1/100 1/150 1/203 1/250 1/311];
% 
% omega_0 = 2*pi*50;
% t_exp = [1/25 1/46 1/83 1/125 1/170 1/208 1/258];
% 
% ratio = abs(sin(omega_0*t_exp)./(omega_0*t_exp));

