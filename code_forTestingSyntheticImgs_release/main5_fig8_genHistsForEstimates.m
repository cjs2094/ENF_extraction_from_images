clear all; close all; clc;
set(0, 'DefaultFigureVisible', 'on');

%% settings
T_readout = 30.9e-3; % sec, iPhone 6
T_row = T_readout/2448;

imgPath = '.\raw_imgs\';
relativeStr = 0.2;
absoluteStr = 2^4; % 2^[0:4]
phase0Cnt = 1;

fe = 120; % ENF

%% generate histograms for estimates - related to fig.8 of the paper

func_genHistsForEstimates(imgPath, T_row, relativeStr, absoluteStr, phase0Cnt, fe);

