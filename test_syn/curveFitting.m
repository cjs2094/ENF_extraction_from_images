function [fitting_results_all, ind_for_fitting_results_all] = curveFitting...
    (img_file_location, camera_model, Fe_true, mRange, I, fitting_results_all, ind_for_fitting_results_all)

ENF_arr        = [100, 120];
bound_flag_arr = ['L', 'U'];

T_ro_db   = getReadoutTimeDB();
T_readout = T_ro_db.time(camera_model);
T_row     = T_readout / T_ro_db.num_of_rows(camera_model);
mRange = mRange(:);

for ind_for_Fe = 1 : length(ENF_arr)
    Fe_set = ENF_arr(ind_for_Fe);
    
    for ind_for_bound_flag = 1 : length(bound_flag_arr)
        bound_flag = bound_flag_arr(ind_for_bound_flag);
        [fitresult, gof1] = myFit(mRange, I, Fe_set, T_row, bound_flag);
                        
        % assign frequency estimation, root mean squared error
        Fe_hat_para = Fe_set;
        rmse = gof1.rmse;
        
        % store intermediate results
        fitting_results_all(ind_for_fitting_results_all, :) = {img_file_location, Fe_set, ...
            bound_flag, fitresult, rmse, Fe_true, Fe_hat_para};
        
        ind_for_fitting_results_all = ind_for_fitting_results_all + 1;
    end
    
end
