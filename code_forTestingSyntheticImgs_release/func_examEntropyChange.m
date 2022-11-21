function func_examEntropyChange(T_row, imgPath)

%% Daily images with synthesized ENF traces
%  
%  ENF variation along pixel location in y can be modeled as
% 
%    e(y) = cos(2*pi*f_ENF*T_row*y + \phi_offset), y = 0, ..., img_height-1.
%  
%  Chau-Wai Wong, 8/23/2016

myEntropy =@(pmf) -pmf(:)'/sum(pmf) * log2(pmf(:)/sum(pmf));


%% synthesize ENF containing images
D = dir([imgPath '*.jpg']);

ENF_arr = [100 120];
enfCnt = length(ENF_arr);
phaseCnt = 10;
imgCnt = length(D);

img_cell = cell(imgCnt, 1);
for i = 1 : imgCnt
    
    disp(D(i).name)
    img_rgb = imread([imgPath D(i).name]);
    img_rgb = func_putImgToLandscape(img_rgb);
    
    %bestChannel = rgb2ycbcr(img_rgb);
    bestChannel = uint8(0.5*func_extractBestChannel_PCA(img_rgb));
    img_cell{i} = bestChannel;
end

img_syn_cell_iter3 = {};
for k = 1 : phaseCnt
    
    img_syn_cell_iter2 = {};
    
    for j = 1 : length(ENF_arr)
        
        ENF = ENF_arr(j);
        
        disp(['ENF = ' int2str(ENF)]);
        
        img_syn_cell = {};
        
        for i = 1 : imgCnt
            disp(D(i).name)
            
            param = struct(...
                'f_ENF', ENF, ...
                'T_row', T_row, ...
                'phi'  , 2*pi*rand(), ...
                'relativeMag', 0.2, ...
                'absoluteMag', 16, ...
                'useRelative', 1);
            
            [img_syn, ~] = func_addSynEnfToImg(img_cell{i}, param);

            img_syn_cell{i} = img_syn;
            
            %imshow(img_syn);
            %drawnow
            %pause(0.1)
        end

        img_syn_cell_iter2{j} = img_syn_cell;
    end

    img_syn_cell_iter3{k} = img_syn_cell_iter2;
end


%% examine how entropy changes due to the addition of ENF signal and also,
%  the added amount difference due to 120 Hz and 100 Hz ENF
ctr_raw = [0 : 255];
drawFigure_flag = 0;
% % for i = 2 %: length(img_cell)

i = 1; %2
img = img_cell{i};
dim = size(img);
entropyChange = zeros(phaseCnt, enfCnt, dim(2));
enfCnt = length(ENF_arr);

for k = 1 : phaseCnt
    
    disp(['phase#' int2str(k)])
    for j = 1 : enfCnt
        
        disp(['enfCnt ' int2str(j)]);
        img = img_cell{i};
        img_syn = img_syn_cell_iter3{k}{j}{i};
        dim = size(img);
        dim_syn = size(img_syn);
        if ~isequal(dim, dim_syn), error('dimension of img and img_syn are not equal'); end
        
        img_disp = imrotate(imresize(img_syn, 0.125, 'bicubic'), 0);
        figure(4); imshow(img_disp, [])
        
        for colIdx = 1 : 1 : dim(2)
            
            cnt_raw = hist(img(:, colIdx), ctr_raw);
            pmf_raw = cnt_raw/sum(cnt_raw);
            entropy_raw = myEntropy(pmf_raw(pmf_raw > 0));
            
            if drawFigure_flag
                plot(ctr_raw, pmf_raw); hold on
                xlim([0 500]);
            end
            
            [cnt_syn, ctr_syn] = hist(img_syn(:, colIdx), ctr_raw);
            pmf_syn = cnt_syn/sum(cnt_syn);
            entropy_syn = myEntropy(pmf_syn(pmf_syn>0));
            
            entropyChange(k, j, colIdx) = entropy_syn - entropy_raw;
            
            if drawFigure_flag
                plot(ctr_syn, pmf_syn); hold off
                xlim([0 500]);
                
                leg{1} = sprintf('entropy (raw) = %.2f', entropy_raw);
                leg{2} = sprintf('entropy (ENF added) = %.2f', entropy_syn);
                legend(leg)
                drawnow
                pause%(0.1)
            end
        end
    end
end

hFig = figure(1);
increasedPerc = sum(entropyChange(:) > 0) / length(entropyChange(:));
%hist(entropyChange(:), 20);
h = histogram(entropyChange(:)); hold on
h.FaceColor = [1 1 1];
h.NumBins = 30;
yUpper = max(h.Values) * 1.1;
ylim([0 yUpper]); xlim([-0.4 2.2])
plot([0 0], [0 yUpper], '--', 'LineWidth', 1.5); hold off
xlabel('Entropy increase'); ylabel('Frequency')
%title(sprintf('%.1f%% columns have increase in entropy', increasedPerc*100))
print('yourTransparentImage','-depsc');
set(hFig, 'position', [100 500 300 200]);
func_tightfig;

% entroChan = squeeze(mean(entropyChange, 1));
% entroChan_120to100= entroChan(2,:) - entroChan(1,:);
% figure(2); plot(entroChan_120to100); hold on
% xlim([1 dim(2)]); xlabel('row index'); ylabel('entro120 - entro100')
% plot([1 size(entroChan_120to100, 2)], [0 0]); hold off
% largerPerc = sum(entroChan_120to100(:) > 0) / length(entroChan_120to100(:));
% title(sprintf('%.1f%% columns have larger entropy for 120Hz than 100Hz', largerPerc*100));
% 
% increasedLog = entroChan_120to100 > 0;
% maskD = 0.3*ones(dim(1),1)*increasedLog;
% mask0 = zeros(dim(1), dim(2));
% mask = cat(3, mask0, maskD, mask0);
% figure(3); 
% img_blended = imfuse(img_syn, mask, 'blend', 'Scaling', 'joint');
% imshow(imresize(img_blended, 0.125, 'bicubic'));
% %title('Histogram of column's entropy increase')

