function [col_idx_set] = colSelectFromSelectedRegion(img_region_coordinates, total_num_of_col_to_use)

cnt = size(img_region_coordinates, 1);

if cnt > 1
    for k = 1 : cnt
        x_s_smooth = img_region_coordinates (k, 3);
        x_t_smooth = img_region_coordinates (k, 4);
        len_arr(k) = x_t_smooth - x_s_smooth + 1;
    end
    
    num_of_col_to_use_arr = [];
    for k = 1 : cnt-1
        proportional_num_of_col = round(total_num_of_col_to_use*len_arr(1)/sum(len_arr));
        num_of_col_to_use_arr = [num_of_col_to_use_arr, proportional_num_of_col];
    end
    
    num_of_col_to_use_arr(cnt) = total_num_of_col_to_use - sum(num_of_col_to_use_arr);
    
    col_idx_set = [];
    for k = 1 : cnt
        n_s = img_region_coordinates (k, 3);
        n_t = img_region_coordinates (k, 4);
        
        num_of_col_to_use = num_of_col_to_use_arr(k);
        
        % select evenly spaced columns; The further they are apart, the lower the correlation we will have.
        num_of_n = n_t - n_s + 1;
        maxWidth = floor(num_of_n / num_of_col_to_use);
        n_s0 = randsample(n_s : n_s + maxWidth - 1, 1);
        col_idx_set_temp = n_s0:maxWidth:n_s0 + maxWidth*(num_of_col_to_use - 1);    
        col_idx_set = [col_idx_set, col_idx_set_temp];
    end
    
else
    n_s = img_region_coordinates (1, 3);
    n_t = img_region_coordinates (1, 4);
   
    % select evenly spaced columns; The further they are apart, the lower the correlation we will have.
    num_of_n = n_t - n_s + 1;
    maxWidth = floor(num_of_n / total_num_of_col_to_use);
    n_s0 = randsample(n_s : n_s + maxWidth - 1, 1);
    col_idx_set = n_s0:maxWidth:n_s0 + maxWidth*(total_num_of_col_to_use - 1);
end










% randomly select columns
% col_idx_set = randsample(x_s:x_t, num_of_col_to_use);

