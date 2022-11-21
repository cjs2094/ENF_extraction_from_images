function [enfContainingImages, enfSignals, trueParameters] = func_synEnfContainingImgs_twoPoint(imgPath, T_row, relativeStr, absoluteStr, phase0Cnt, ENF_arr)
%% synthesize ENF containing images
%  Chau-Wai Wong, Oct-Nov 2016

D = dir([imgPath '*.jpg']);

rng('default');
phase0_arr = 2*pi*rand(phase0Cnt,1);
enfCnt = length(ENF_arr);
imgCnt = length(D);

mag0_arr = zeros(imgCnt, 1);
img_cell = cell(imgCnt, 1);
for i = 1 : imgCnt
    
    disp(D(i).name)
    img_rgb = imread([imgPath D(i).name]);
    img_rgb = func_putImgToLandscape(img_rgb);
    
    %bestChannel = rgb2ycbcr(img_rgb);
    bestChannel = uint8(0.5*func_extractBestChannel_PCA(img_rgb));
    img_cell{i} = bestChannel;
    mag0_arr(i) = mean(img_cell{i}(:)) * relativeStr;
end

tic
img_syn_cell_iter3 = {};
enfSigal_cell_iter3 = {};
trueParam_cell_iter3 = {};
for iii = 1 : phase0Cnt
    img_syn_cell_iter2 = {};
    enfSigal_cell_iter2 = {};
    trueParam_cell_iter2 = {};
    
    for ii = 1 : length(ENF_arr)
        f_ENF = ENF_arr(ii);
        
        disp(['ENF = ' int2str(f_ENF)]);
        
        img_syn_cell = {};
        enfSignal_cell = {};
        trueParam_cell = {};
        
        for i = 1 : imgCnt
            disp(D(i).name)
            param = struct(...
                'f_ENF'      , f_ENF, ...
                'T_row'      , T_row, ...
                'phi'        , phase0_arr(iii), ...
                'relativeMag', relativeStr, ...
                'absoluteMag', absoluteStr, ...
                'useRelative', 2);
            
            [img_syn, trueParam] = func_addSynEnfToImg_specialCase_twoPoint(img_cell{i}, param);
            
            dim = size(img_syn);
            M = dim(1);
            mRange = 1 : M;
            
            a_1 = trueParam(1);
            a_M = trueParam(2);
            b_1 = trueParam(3);
            b_M = trueParam(4);
            phi = trueParam(5);
            mag = ((a_M - a_1)/(M - 1)*(mRange - 1) + a_1);
            trend = ((b_M - b_1)/(M - 1)*(mRange - 1) + b_1);
            enfSignal = mag .* cos(2*pi*f_ENF*T_row*mRange + phi) + trend;

            img_syn_cell{i} = img_syn;
            enfSignal_cell{i} = enfSignal;
            trueParam_cell{i} = trueParam;
            
            %imshow(img_syn);
            %drawnow
            %pause(0.1)
        end

        img_syn_cell_iter2{ii} = img_syn_cell;
        enfSignal_cell_iter2{ii} = enfSignal_cell;
        trueParam_cell_iter2{ii} = trueParam_cell;
    end

    img_syn_cell_iter3{iii} = img_syn_cell_iter2;
    enfSignal_cell_iter3{iii} = enfSignal_cell_iter2;
    trueParam_cell_iter3{iii} = trueParam_cell_iter2;
end
toc

enfContainingImages = img_syn_cell_iter3;
enfSignals = enfSignal_cell_iter3;
trueParameters = trueParam_cell_iter3;


