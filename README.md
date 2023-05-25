DOI: 10.1080/15481603.2023.2217573

# RSWFM
This is a novel regression-based surface water fraction mapping method (RSWFM).  
The aim of RSWFM is to map sub-pixel surface water fractions for small water bodies with areas that were mostly smaller than 1 ha by using a synthetic spectral library and random forest regression.

# File list
## Main function:  
Main_lib2kind_stdnoise_rf_autoparam_10band.m
## Other functions:  
lib_2kinds_nonlinear.m and nonlinear.m  
unmixing.m  
generic_random_forests_ompParam.m  
oobErrRF.m  
rfpredict.m
## Data (example data):  
Sentinel2_SR.tif - Sentinel-2 image with 10 bands  
water_sample.txt - All water samples spectra derived from ENVI Classic  
land_sample.txt - All land samples spectra derived from ENVI Classic  
E_W.txt - Mean water endmember spectra for each water sub-class  
E_V.txt - Mean vegetation endmember spectra for each vegetation sub-class  
E_I.txt - Mean impervious surface endmember spectra for each impervious surface sub-class  
E_S.txt - Mean soil endmember spectra for each soil sub-class

# Parameters in RSWFM
## Input
S2 - Sentinel-2 image with 10 bands  (matrix size -  (x,y,10))  
E_W_n - All water samples spectra derived from ENVI Classic  (matrix size -  (number of water samples,17))  
E_L_n - All land samples spectra derived from ENVI Classic, including vegetation, impervious surface, and soil  (matrix size -  (number of land samples,17))  
E_water - Mean water endmember spectra for each water sub-class  (matrix size -  (10,number of water sub-classes))  
E_vegetation - Mean vegetation endmember spectra for each vegetation sub-class  (matrix size -  (10,number of vegetation sub-classes))  
E_impervious - Mean impervious surface endmember spectra for each impervious surface sub-class  (matrix size -  (10,number of impervious surface sub-classes))  
E_soil - Mean soil endmember spectra for each soil sub-class  (matrix size -  (10,number of soil sub-classes))
## Output
predict_wr - surface water fraction map
## Hyperparameters
k - determines the number of synthetic pure spectra in the training data  
c - controls the magnitude of Gaussian noise  
step - mixing ratio interval (ranges from 0 to 1)

# Usage
Before running the main function code on MATLAB, the three steps below needed to be executed first to generate input files.  

1. Select pure endmember samples for four classes of water-vegetation-impervious surface-soil (WVIS) on the Sentinel-2 image with 10 bands on ENVI classic.
   Here, you can select several sub-classes according to the image for each class and about 20 samples for each sub-class.
2. Put the sample spectra out to create files "water_sample.txt" and "land_sample.txt".
3. Calculate the mean spectra for each sub-class of WVIS from the samples 
   and create four txt files ("E_W.txt, E_V.txt, E_I.txt, and E_S.txt") for WVIS classes.   
   
Then, put the seven files into the data folder or change the file path in the code to run the main function. It takes about 16 minitues to run the example data. 

# Note
If you use this software please cite the following paper in any resulting publication:  
Regression-based surface water fraction mapping using a synthetic spectral library for monitoring small water bodies.
