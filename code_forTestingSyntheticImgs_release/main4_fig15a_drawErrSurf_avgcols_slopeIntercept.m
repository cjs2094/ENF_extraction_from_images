clear all; close all; clc;
set(0, 'DefaultFigureVisible', 'on');

%% settings

T_readout = 30.9e-3; % sec, iPhone 6
T_row = T_readout/2448;

imgPath = [pwd '\raw_imgs\'];
relativeStr = 0.2;
absoluteStr = 2^4; % 2^[0:4]
phase0Cnt = 1;

ENF_arr = [100 120];


%% draw error surfaces when using slope intercept form of B(i) - related to fig.15.(a)

func_drawErrSurf_slopeIntercept(imgPath, T_row, relativeStr, absoluteStr, phase0Cnt, ENF_arr);
