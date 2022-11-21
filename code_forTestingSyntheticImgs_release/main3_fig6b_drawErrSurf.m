clc; clear all; close all;
set(0, 'DefaultFigureVisible', 'on');

%% settings

T_readout = 30.9e-3; % sec, iPhone 6
numOfRows = 2448;
T_row = T_readout/numOfRows;

imgPath = [pwd '\raw_imgs\'];
relativeStr = 0.2;
absoluteStr = 2^4; % 2^[0:4]
phase0Cnt = 1;

ENF_arr = [100 120];


%% draw error surfaces - ralated to fig6.(b) of the paper

func_drawErrSurf(imgPath, T_row, relativeStr, absoluteStr, phase0Cnt, ENF_arr);