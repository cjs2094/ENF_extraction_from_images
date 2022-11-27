# Code for testing images with real ENF traces and generating results

## Preparation
* If you want to play with the datasets used in the paper, please download the mat datasets named `'matResults.zip'` and `'matResults_preModel.zip'` and image dataset named `'datasets.zip'` from the following URL: [https://ieee-dataport.org/documents/images-real-enf-traces-and-related-dataset-enf-presence-classification-test](https://ieee-dataport.org/documents/images-real-enf-traces-and-related-dataset-enf-presence-classification-test), upzip, and put them under the directory `./code_forTestingRealImgs_release/`
* If you want to examine your own image(s), get your own image templates(s) ready and follow the procedures below
  * Create a folder named `'datasets'` under the directory `./code_forTestingRealImgs_release/` and create two subfolders named `'images_test_50Hz_xxx'` and `'images_test_60Hz_xxx'`, where xxx may represent a person capturing the correponding dataset and a number used for distinguising it from other datasets
  * Each subfolder has photo(s) organized by folder(s), where each subsubfolder may contain same-scene images taken under different shutter speed levels.
  * Each subsubfolder should include image(s) whose filename has the form "stepx_y", where x represents the order of embedded ENF strength (x should be 1, 2, ... / Larger x contains a stronger ENF trace) and y is a reciprocal of the shutter speed used for the corresponding image.
  * Each subsubfolder should have the following three .txt files:
	  1) `camera_model.txt`: includes a camera model used for taking image(s)
	  2) `nonsmooth_region.txt`: includes the location for nonsmooth region(s) of the form [x1 x2 y1 y2]. The x1 and x2 elements row-wise start and end points, respectively. The y1 and y2 elements column-wise start and end points, respectively.
	  3) `smooth_region.txt`: includes the location for smooth region(s) of the form [x1 x2 y1 y2]. The x1 and x2 elements row-wise start and end points, respectively. The y1 and y2 elements column-wise start and end points, respectively.
  * Run the scripts named `'main1_fig18_testImgs.m'` and `'main4_testImgs_preModel.m'`, which will make folders named `'matResults'` and `'matResults_preModel'` under `./code_forTestingRealImgs_release/` and generate .mat files under those folders. The scripts will also create folders named `'fig_results'` and `'fig_results_preModel'` and generate figures like fig.18 in the paper 


## Usage
* Open each following script and run sequentially each section divided by %%
  * `'main2_fig12_drawRocCurves.m'` draws roc curves for the first and second-level decisions
  * `'main3_fig14_compareEERs_smoothVsNonsmoothVsOverall.m'` performs bootstrapping and compares EERs of the entropy minimization applied to smooth, nonsmooth, and overall regions of images 
  * `'main5_fig13_compareEERs_preliminaryVsProposed.m'` performs bootstrapping and compares EERs of the preliminary and proposed parametric models