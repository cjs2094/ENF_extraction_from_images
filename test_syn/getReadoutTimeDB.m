function T_ro_db = getReadoutTimeDB()
%% Database of estimated read out time of rolling shutter cameras
%  Estimated with the help of ~180 Hz screen frequency using Tor_est.m
%
%  To obtain read out time for iPhone 6s, use either of the following
%  notations: 
%    
%     T_ro{'iPhone6s', 'time'}, or
%
%     T_ro.time('iPhone6s').
%  
%  Chau-Wai Wong, 11/2/2016


time        = [19.8e-3;    30.9e-3;   22.6e-3  ];
num_of_rows   = [3024;       2448;      2448     ];
side        = {'back';     'back';    'back'   };
camera_model = {'iPhone6s'; 'iPhone6'; 'iPhone5'};

T_ro_db = table(time, num_of_rows, side, 'RowNames', camera_model);
