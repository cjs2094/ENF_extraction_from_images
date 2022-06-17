function [img_syn, trueParam] = synEnfContainingImg_VAVB_two_point(img, param)
% This function add synthetic ENF signal to a rolling shutter image
% Jisoo Choi, 4/4/2021, 

f_ENF       = param.f_ENF;
T_row       = param.T_row;
%phi         = param.phi;
useRelative = param.useRelative;
relativeMag = param.relativeMag;
absoluteMag = param.absoluteMag;

dim = size(img);
if dim(1) > dim(2)
    error('Image is not in the landscape mode. Please rotate it before call this function.')
end
img = double(img);
M = dim(1);
mRange = 1 : M;

mu_img = mean(img(:));
if useRelative == 1  % 1: relative, 2: absolute
    mag = relativeMag * mu_img;
elseif useRelative == 2
    mag = absoluteMag;
else
    error('useRelative must be 1 or 2');
end

%[a_1, a_M, b_1, b_M, phi] = func_assignParam(mag);
a_1 = -11.8762;
a_M = -20.1238;
b_1 = 1;
b_M = 4;
phi = 2.4644;

trueParam = [a_1, a_M, b_1, b_M, phi];

mag = ((a_M - a_1)/(M - 1)*(mRange - 1) + a_1);

trend = ((b_M - b_1)/(M - 1)*(mRange - 1) + b_1);

enfSignal = mag .* cos(2*pi*f_ENF*T_row*mRange + phi) + trend;

% enfSignal_sinusoidalPart = mag .* cos(2*pi*f_ENF*T_row*mRange + phi);

mag = abs(mean(mag(:)));
disp(sprintf('ENF magnitude = %.2f (out of 255)', mag));
disp(sprintf('MSNR = %.2f dB', 20*log10(mu_img/mag)));

img_syn = zeros(size(img));
enfComp = enfSignal(:)* ones(1, dim(2));
if length(dim) == 2
    img_syn = img + enfComp;
else
    for i = 1 : dim(3)
        img_syn(:,:,i) = img(:,:,i) + enfComp;
    end
end

clipLogSet1 = img_syn > 255;
clipLogSet2 = img_syn < 0;
clipPerc = mean(clipLogSet1(:)) + mean(clipLogSet2(:));
disp(sprintf('clipped perc = %.1f%%', clipPerc*100));

img_syn = uint8(img_syn);

disp(sprintf('\n'))

end


function [a_1, a_M, b_1, b_M, phi] = func_assignParam(mag)

delta = unifrnd(-mag, mag);
a_1 = mag - 0.5*delta;
a_M = mag + 0.5*delta;

if rand > 0.5
    a_1 = -a_1;
    a_M = -a_M;
end

if mag == 0
    b_1 = 0;
    b_M = 0;
    phi = 0;
else
    b_1 = 1; %unifrnd(-2, 2);
    b_M = 5; %unifrnd(-2, 2);
    phi = 2*pi*rand;
end

end