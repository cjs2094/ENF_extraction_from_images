function [exposure_time, enf_strength_level] = func_getExposureTimeEnfStrengthLevel(filename)
%% Jisoo Choi, 11/6/201

str_start = strfind(filename, 'step') + 4;
str_end   = strfind(filename, '_') - 1;
enf_strength_level = str2double(filename(str_start:str_end));

str_start  = strfind(filename, '_') + 1;
dot_pos_set = strfind(filename, '.');
str_end    = dot_pos_set(end) - 1;
exposure_time = str2double(filename(str_start:str_end));