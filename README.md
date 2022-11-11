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


## Preparation
* If you want to play with the dataset used in the paper, please download the video dataset named `'mat_results.zip'` from the following URL:
[...](...), upzip, and put it under the directory `./test_syn_release/`
* If you want to examine your own image template(s), get your own image templates(s) ready and follow the procedures below
  * Create a folder named `'raw_imgs'`under the directory `./test_syn_release/` and put your image templates into the folder `'raw_imgs'`
  * Run the first two sections of the script named `'main1_testImgs.m'`, which will generate folder named `'imgs_with_syn_enf'` under `./test_syn_release/`
  * Generate three .txt files for each image template and put them into each subfolder named the filename of each image template under folders `res_synthetic_6imgs_50Hz` and `res_synthetic_6imgs_60Hz`. Each .txt file should contain the following:
	1) `camera_model.txt`: should include a camera model assumed to be used for taking images
	2) `nonsmooth_region.txt`: should include the location for nonsmooth region(s) of the form [x1 x2 y1 y2]. The x1 and x2 elements row-wise start and end points, respectively. The y1 and y2 elements column-wise start and end points, respectively
	3) `smooth_region.txt`: should include the location for smooth region(s) of the form [x1 x2 y1 y2]. The x1 and x2 elements row-wise start and end points, respectively. The y1 and y2 elements column-wise start and end points, respectively.
   * Open the script named `'main1_testImgs.m'` and run the third and fourth sections

## Usage
* For the dataset used in the paper, open each script file named `'main2_fig11_drawRocCurves.m'`, `'main3_fig6a_examEntropyChange.m'`, `'main4_fig15a_drawErrSurf_avgcols_slopeIntercept.m'`, `'main4_fig15b_drawErrSurf_avgcols_twoPoint.m'`, and `'main5_fig8_genHistsForEstimates.m'` and run sequentially each section divided by %%
   * `'main2_fig11_drawRocCurves.m'` draws roc curves for the first and second-level decisions
   * `'main3_fig6a_examEntropyChange.m'` generates a histogram of column's entropy increase due to ENF trace embedding
   * `'main4_fig15a_drawErrSurf_avgcols_slopeIntercept.m'` generates error surfaces of a pair of search variables when B(i) is parameterized in the slope-intercept form
   * `'main4_fig15b_drawErrSurf_avgcols_twoPoint.m'` generates error surfaces of a pair of search variables when B(i) is parameterized in the two-point form
   * `'main5_fig8_genHistsForEstimates.m'` generates histograms for estimates obtained from the entropy minimization

## README for folder `test_syn`:
- Folder `raw_imgs` contains six template images.
- The section `step 1) generate imgs with syn enf` in the script `main1_syn_test_imgs` generates folder `imgs_with_syn_enf` which contains `res_synthetic_6imgs_50Hz` and `res_synthetic_6imgs_60Hz` folders. Each folder named `res_synthetic_6imgs_xxHz` has six set folders, which of each has nine images. The file name of each image is of the form "stepx_cnty" in which both x and y are positive integers. x represents the ENF strength (Larger x contains a stronger ENF trace). y represents the image count number at a specific ENF strength.
- Before running the section `step 2) baseline method - curve fitting` in the script `main1_syn_test_imgs`, please generate and manually put three .txt files (`camera_model.txt`, `nonsmooth_region.txt`, and `smooth_region.txt`) into each set folder under folders `res_synthetic_6imgs_50Hz` and `res_synthetic_6imgs_60Hz`. Each .txt file should contain the following:
	1) `camera_model.txt`: includes a camera model used for taking images
	2) `nonsmooth_region.txt`: includes the location for nonsmooth region(s) of the form [x1 x2 y1 y2]. The x1 and x2 elements row-wise start and end points, respectively. The y1 and y2 elements column-wise start and end points, respectively.
	3) `smooth_region.txt`: includes the location for smooth region(s) of the form [x1 x2 y1 y2]. The x1 and x2 elements row-wise start and end points, respectively. The y1 and y2 elements column-wise start and end points, respectively.


## README for folder `test_real`:
- Download `images_test_50Hz` and `images_test_60Hz`, upzip them, and put them under datasets folder.
  - Each dataset has ten sets of photos organized by folders where each set folder containing images taken under seven different shutter speed levels.
  - Each set folder has seven images whose file name has the form "stepx_y" where x represents the ENF strength having a positive integer (Larger x contains a stronger ENF trace) and y is a reciprocal of the shutter speed used for the corresponding image.
  - Each set folder has three .txt files:
	  1) `camera_model.txt`: includes a camera model used for taking images
	  2) `nonsmooth_region.txt`: includes the location for nonsmooth region(s) of the form [x1 x2 y1 y2]. The x1 and x2 elements row-wise start and end points, respectively. The y1 and y2 elements column-wise start and end points, respectively.
	  3) `smooth_region.txt`: includes the location for smooth region(s) of the form [x1 x2 y1 y2]. The x1 and x2 elements row-wise start and end points, respectively. The y1 and y2 elements column-wise start and end points, respectively.

#### Short note for Scripts:
- The script `main1_real_testImgs` performs the curve fitting method and the entropy minimization method.
- Based on .mat files generated from the script `main1_real_testImgs`, the script `main2_1_real_draw_figs_roc_curve_1stLevel` and `main2_2_real_draw_figs_roc_curve_2ndLevel` analayze experimental results of the 1st level and the 2nd level by drawing ROC curves. 




#### Short note for Scripts:
- The script `main1_syn_test_imgs` performs the curve fitting method and the entropy minimization method.
- Based on .mat files generated from the script `main1_real_testImgs`, the script `main2_2_syn_draw_figs_roc_curve_1stLevel` and `main2_3_syn_draw_figs_roc_curve_2ndLevel` analayze experimental results of the 1st level and the 2nd level by drawing ROC curves. 

## Contact
Jisoo Choi, email: [cjs2094@gmail.com](cjs2094@gmail.com)
