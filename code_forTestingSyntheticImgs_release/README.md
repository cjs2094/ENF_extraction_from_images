## Preparation
* If you want to play with the dataset used in the paper, please download the mat dataset named `'mat_results_syn.zip'` and image dataset named `'imgs_with_syn_enf.zip'` from the following URL:

[...](...), upzip, and put them under the directory `./code_forTestingSyntheticImgs_release/`
* If you want to examine your own image template(s), get your own image templates(s) ready and follow the procedures below
  * Create a folder named `'raw_imgs'`under the directory `./code_forTestingSyntheticImgs_release/` and put your image templates into the folder `'raw_imgs'`
  * Run the first two sections of the script named `'main1_testImgs.m'`, which will make folders named  `'mat_results_syn'` and `'imgs_with_syn_enf'` under `./code_forTestingSyntheticImgs_release/`
  * Generate three .txt files for each image template and put them into each subfolder named the filename of each image template under folders `res_synthetic_6imgs_50Hz` and `res_synthetic_6imgs_60Hz`. Each .txt file should contain the following:
	1) `camera_model.txt`: should include a camera model assumed to be used for taking images
	2) `nonsmooth_region.txt`: should include the location for nonsmooth region(s) of the form [x1 x2 y1 y2]. The x1 and x2 elements row-wise start and end points, respectively. The y1 and y2 elements column-wise start and end points, respectively
	3) `smooth_region.txt`: should include the location for smooth region(s) of the form [x1 x2 y1 y2]. The x1 and x2 elements row-wise start and end points, respectively. The y1 and y2 elements column-wise start and end points, respectively.
   * Open the script named `'main1_testImgs.m'` and run the third and fourth sections


## Usage
* Open each following script and run sequentially each section divided by %%
   * `'main2_fig11_drawRocCurves.m'` draws roc curves for the first and second-level decisions
   * `'main3_fig6a_examEntropyChange.m'` generates a histogram of column's entropy increase due to ENF trace embedding
   * `'main4_fig15a_drawErrSurf_avgcols_slopeIntercept.m'` generates error surfaces of a pair of search variables when $B(i)$ is parameterized in the slope-intercept form
   * `'main4_fig15b_drawErrSurf_avgcols_twoPoint.m'` generates error surfaces of a pair of search variables when $B(i)$ is parameterized in the two-point form
   * `'main5_fig8_genHistsForEstimates.m'` generates histograms for estimates obtained from the entropy minimization