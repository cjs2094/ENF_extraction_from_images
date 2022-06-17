function [hatOfBeta, hatOfY] = linearReg(x, y)

x = x(:);
y = y(:);

X = [ones(length(x), 1) x];
Y = [y];

hatOfBeta = (X' * X) \ (X' * Y);
hatOfY = X * hatOfBeta;