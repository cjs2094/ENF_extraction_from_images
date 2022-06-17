function img_paths_cell = getAllImagePaths(img_db)
%% Get the file path for every image inside the two directory level image database
%  Chau-Wai Wong, 11/3/2016

if exist(img_db, 'dir') ~= 7, error([img_db ' does not exist']); end

D = dir(img_db);

img_paths_cell = cell(0,2);
for i = 1 : length(D)
    
    if ~D(i).isdir, continue; end
    if strcmp(D(i).name, '.'), continue; end
    if strcmp(D(i).name, '..'), continue; end
    
    folder_name = D(i).name;
    
    %% read camera model
    fn_cm = [img_db folder_name '\camera_model.txt'];
    if exist(fn_cm, 'file') ~= 2
        disp(['folder ' folder_name ': camera model file does not exist.']);
        continue;
    end
    
    fp = fopen(fn_cm);
    camera_model = fread(fp, '*char')';
    fclose(fp);

    %% read smooth region
    fn_sr = [img_db folder_name '\smooth_region.txt'];
    if exist(fn_sr, 'file') ~= 2
        disp(['folder ' folder_name ': smooth region file does not exist.']);
        continue;
    end
    
    fp = fopen(fn_sr);
    smooth_region = fread(fp, '*char')';
    fclose(fp);
    smooth_region = str2num(smooth_region);
    
    %% read smooth region
    fn_sr = [img_db folder_name '\nonsmooth_region.txt'];
    if exist(fn_sr, 'file') ~= 2
        disp(['folder ' folder_name ': nonsmooth region file does not exist.']);
        continue;
    end
    
    fp = fopen(fn_sr);
    nonsmooth_region = fread(fp, '*char')';
    fclose(fp);
    nonsmooth_region = str2num(nonsmooth_region);
    
    %% prepare output
    sub_D = dir([img_db folder_name '\*.JPG']);
    %sub_D = dir([img_db folder_name '\*.PNG']);
    
    for j = 1 : length(sub_D)
        img_paths_cell{end+1, 1} = sub_D(j).name;
        img_paths_cell{end  , 2} = camera_model;
        img_paths_cell{end  , 3} = [img_db folder_name '\' sub_D(j).name];
        img_paths_cell{end  , 4} = [folder_name '\' sub_D(j).name];
        img_paths_cell{end  , 5} = smooth_region;
        img_paths_cell{end  , 6} = nonsmooth_region;
    end
    
end