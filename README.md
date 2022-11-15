# Code for Invisible Geolocation Signature Extraction From a Single Image

This respository includes an implementation of the following paper (**DOI**: [10.1109/TIFS.2022.3185775](https://doi.org/10.1109/TIFS.2022.3185775)):

J. Choi, C.-W. Wong, A. Hajj-Ahmad, M. Wu, and Y. Ren, "[Invisible geolocation signature extraction from a single image](https://ieeexplore.ieee.org/document/9804874)," *IEEE Transactions on Information Forensics and Security*, pp. 2598–2613, Jun. 2022.

```bibtex
@article{choi2022invisible,
  title={Invisible Geolocation Signature Extraction From a Single Image},
  author={Choi, Jisoo and Wong, Chau-Wai and Hajj-Ahmad, Adi and Wu, Min and Ren, Yanpin},
  journal={IEEE Transactions on Information Forensics and Security},
  volume={17},
  pages={2598--2613},
  year={2022},
  month={Jun}
}
```


If you used any of the code or the dataset, please cite our paper as listed above

## Requirement
Matlab





## README for folder `test_syn`:
- Folder `raw_imgs` contains six template images.
- The section `step 1) generate imgs with syn enf` in the script `main1_syn_test_imgs` generates folder `imgs_with_syn_enf` which contains `res_synthetic_6imgs_50Hz` and `res_synthetic_6imgs_60Hz` folders. Each folder named `res_synthetic_6imgs_xxHz` has six set folders, which of each has nine images. The file name of each image is of the form "stepx_cnty" in which both x and y are positive integers. x represents the ENF strength (Larger x contains a stronger ENF trace). y represents the image count number at a specific ENF strength.
- Before running the section `step 2) baseline method - curve fitting` in the script `main1_syn_test_imgs`, please generate and manually put three .txt files (`camera_model.txt`, `nonsmooth_region.txt`, and `smooth_region.txt`) into each set folder under folders `res_synthetic_6imgs_50Hz` and `res_synthetic_6imgs_60Hz`. Each .txt file should contain the following:
	1) `camera_model.txt`: includes a camera model used for taking images
	2) `nonsmooth_region.txt`: includes the location for nonsmooth region(s) of the form [x1 x2 y1 y2]. The x1 and x2 elements row-wise start and end points, respectively. The y1 and y2 elements column-wise start and end points, respectively.
	3) `smooth_region.txt`: includes the location for smooth region(s) of the form [x1 x2 y1 y2]. The x1 and x2 elements row-wise start and end points, respectively. The y1 and y2 elements column-wise start and end points, respectively


## Preparation
* If you want to play with the datasets used in the paper, please download the mat datasets named `'mat_results.zip'` and `'mat_results_preModel.zip'` and image dataset named `'datasets.zip'` from the following URL:

[...](...), upzip, and put them under the directory `./code_forTestingRealImgs_release/`
* If you want to examine your own image(s), get your own image templates(s) ready and follow the procedures below
  * Create a folder named `'datasets'` under the directory `./code_forTestingRealImgs_release/` and create two subfolders named `'images_test_50Hz_xxx'` and `'images_test_60Hz_xxx'`, where xxx may represent a person capturing the correponding dataset and a number used for distinguising it from other datasets
  * Each subfolder has photo(s) organized by folder(s), where each subsubfolder may contain same-scene images taken under different shutter speed levels.
  * Each subsubfolder should include image(s) whose filename has the form "stepx_y", where x represents the order of embedded ENF strength (x should be 1, 2, ... / Larger x contains a stronger ENF trace) and y is a reciprocal of the shutter speed used for the corresponding image.
  * Each subsubfolder should have the following three .txt files:
	  1) `camera_model.txt`: includes a camera model used for taking images
	  2) `nonsmooth_region.txt`: includes the location for nonsmooth region(s) of the form [x1 x2 y1 y2]. The x1 and x2 elements row-wise start and end points, respectively. The y1 and y2 elements column-wise start and end points, respectively.
	  3) `smooth_region.txt`: includes the location for smooth region(s) of the form [x1 x2 y1 y2]. The x1 and x2 elements row-wise start and end points, respectively. The y1 and y2 elements column-wise start and end points, respectively.
  * Run the scripts named `'main1_fig18_testImgs.m'` and `'main4_testImgs_preModel.m'`, which will make folders named `'mat_results'` and `'mat_results_preModel'` under `./code_forTestingRealImgs_release/` and generate .mat files under those folders. The scripts will also make folders named `'fig_results'` and `'fig_results_preModel'` and generate figures like fig.18 in the paper 


## Usage
* Open each following script and run sequentially each section divided by %%
   * `'main2_fig11_drawRocCurves.m'` draws roc curves for the first and second-level decisions
   * `'main3_fig6a_examEntropyChange.m'` generates a histogram of column's entropy increase due to ENF trace embedding
   * `'main4_fig15a_drawErrSurf_avgcols_slopeIntercept.m'` generates error surfaces of a pair of search variables when $B(i)$ is parameterized in the slope-intercept form
   * `'main4_fig15b_drawErrSurf_avgcols_twoPoint.m'` generates error surfaces of a pair of search variables when $B(i)$ is parameterized in the two-point form
   * `'main5_fig8_genHistsForEstimates.m'` generates histograms for estimates obtained from the entropy minimization
   * `'main6_fig16_genCorrCoeffBoxplot.m'` generates a boxplot for entropy margins against ENF strengths
   * `'main6_fig16_genCorrCoeffBoxplot.m'` generates a boxplot for correlation coefficients against ENF amplitude



#### Short note for Scripts:
- The script `main1_real_testImgs` performs the curve fitting method and the entropy minimization method.
- Based on .mat files generated from the script `main1_real_testImgs`, the script `main2_1_real_draw_figs_roc_curve_1stLevel` and `main2_2_real_draw_figs_roc_curve_2ndLevel` analayze experimental results of the 1st level and the 2nd level by drawing ROC curves. 




#### Short note for Scripts:
- The script `main1_syn_test_imgs` performs the curve fitting method and the entropy minimization method.
- Based on .mat files generated from the script `main1_real_testImgs`, the script `main2_2_syn_draw_figs_roc_curve_1stLevel` and `main2_3_syn_draw_figs_roc_curve_2ndLevel` analayze experimental results of the 1st level and the 2nd level by drawing ROC curves. 

## Contact
Jisoo Choi, email: [cjs2094@gmail.com](cjs2094@gmail.com)
