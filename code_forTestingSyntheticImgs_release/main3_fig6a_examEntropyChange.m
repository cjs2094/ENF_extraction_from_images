clear all; close all; clc;

mydir  = pwd;
idcs   = strfind(mydir, '\');
newdir = mydir(1:idcs(end) - 1);
addpath([newdir, '\funcLibrary'])

set(0, 'DefaultFigureVisible', 'on');

%% settings

T_readout = 30.9e-3; % sec, iPhone 6
numOfRows = 2448;

T_row = T_readout/numOfRows;
imgPath = [pwd '\daily_imgs\'];


%% exam entropy change - related to fig6.(a) of the paper

func_examEntropyChange(T_row, imgPath);
