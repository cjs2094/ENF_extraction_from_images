function genImgsWithEnf(img_path, img_gen_cnt, save_mat_flag, T_row, use_relative_or_absolute_mag_flag, absolute_mag_arr_y, relative_mag, color_channel_mode, mat_file_name, ENF)
%% Generate images with synthesized ENF traces
%
%  ENF variation along pixel location in y can be modeled as
%
%    e(y) = cos(2*pi*f_ENF*T_row*y + \phi_offset), y = 0, ..., img_height-1.
%
%  Jisoo Choi, 4/4/2021

fl0 = ['.\imgs_with_syn_enf\' mat_file_name];
mkdir (fl0)

%% synthesize ENF containing images
D = dir([img_path '*.jpg']);
rng('default');
img_cnt = length(D);

absolute_mag_cnt = length(absolute_mag_arr_y);
cell_ind = 2;

mag0_arr = zeros(img_cnt, 1);
results = {'img_file_location' 'img_raw_location' 'trueParam: [a_1, a_M, k, b, phi]' };
for i = 1 : img_cnt
    disp(['reading image ' D(i).name ' ...'])
    img_rgb = imread([img_path D(i).name]);
    img_rgb = putImgToLandscape(img_rgb);
    
    fl1 = [fl0 '\' D(i).name(1:end-4)];
    mkdir (fl1)
    
    switch lower(color_channel_mode)
        case 'rgb'
            best_channel = img_rgb;
        case 'gray'
            best_channel = rgb2ycbcr(img_rgb);
        otherwise % 'pcaBest'
            best_channel = uint8(0.5*extractBestChannelWithPCA(img_rgb));
    end
    
    img_raw = best_channel;
    
    for j = 1 : length(absolute_mag_arr_y)
        absolute_mag = absolute_mag_arr_y(j);
        
        if use_relative_or_absolute_mag_flag == 1
            mag0_arr(i) = mean(img_raw(:)) * relative_mag;
        elseif use_relative_or_absolute_mag_flag == 2
            mag0_arr(i) = absolute_mag;
        else
            error('useRelative must be 1 or 2');
        end
        
        disp(D(i).name)
        disp(['ENF added @ ' int2str(ENF) 'Hz']);
       
        
        param = struct(...
            'f_ENF'      , ENF, ...
            'T_row'      , T_row, ...
            'useRelative', use_relative_or_absolute_mag_flag, ...
            'relativeMag', relative_mag, ...
            'absoluteMag', absolute_mag);
        
        for k = 1 : img_gen_cnt
            [img_syn, true_param] = synEnfContainingImg_VAVB(img_raw, param);
            
            fn = [fl1 '\step' num2str(j) '_cnt' num2str(k) '.jpg'];
            if exist(fn)
                delete(fn);
                imwrite(img_syn, fn);
            else
                imwrite(img_syn, fn);
            end
            
            % save data
            results{cell_ind,1} = fn;
            results{cell_ind,2} = [D(i).folder '\' D(i).name];
            results{cell_ind,3} = true_param;
            
            cell_ind = cell_ind + 1;
        end
    end
end

if save_mat_flag
    myFolder = '.\mat_results';
    if ~exist(myFolder, 'dir')
        mkdir(myFolder);
    end
    
    mat_fn = ['.\mat_results\' mat_file_name];
    
    if exist(mat_fn)
        delete(mat_fn);
        save(mat_fn, 'results');
    else
        save(mat_fn, 'results');
    end
    disp('Matfile with intermediate results saved.')
else
    disp('Matfile with intermediate results NOT saved, but can be seen in workspace.')
end

