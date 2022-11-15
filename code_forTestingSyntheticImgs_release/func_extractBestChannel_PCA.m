function img_best = func_extractBestChannel_PCA(img_rgb)
%% Chau-Wai Wong, 8/4/2016

img_dim = size(img_rgb);
data = [];
for i = 1 : img_dim(3)
    tmp = img_rgb(:,:,i);
    data = [data tmp(:)];
end

pcaWeights = pca(double(data));
img_best = reshape(double(data)*pcaWeights(:,1), img_dim(1:2));

