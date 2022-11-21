function [exposure_time, enf_strength_level] = func_getExposureTimeEnfStrengthLevelFromFn(fn)
%% Jisoo Choi, 11/6/201

str_start = strfind(fn, 'step') + 4;
str_end   = strfind(fn, '_') - 1;
enf_strength_level = str2double(fn(str_start:str_end));

str_start  = strfind(fn, '_') + 1;
dot_pos_set = strfind(fn, '.');
str_end    = dot_pos_set(end) - 1;
exposure_time = str2double(fn(str_start:str_end));