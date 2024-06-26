# fALFF Manuscript Pipeline
Overview: 
This repository contains the scripts that were utilized in the fALFF manuscript using the SPINS and SPIN-ASD data by Bagheri et al.
General order of codes that were run after preprocessing and cleaning was as such: 

1 - ciftify_falff.py > 

2 - fALFF_normalization.sh > 

3 - SPINS_SPASD_Final_ComBat_Code.m > 

4 - compute_vertices_from_surface.sh > 

5 - PALM_scripts for main effect and interaction & 

6 - Individual Vairiability Code for Slow 4 and Slow 5


1 - The ciftify_falff.py code was used to calculate fALFF in a virtual environement. In the command line, the following lines were run for slow 4 and slow 5 fALFF for SPINS and SPIN-ASD participants to run the ciftify_falff.py script on the cleaned data. For details of how the ciftify_falff.py script works, please refer to the explanations commented within the script.

To activate virtual environment:
```bash
source /path/to/virtual/environment/bin/activate
```

For slow-5 run this:
```bash
basename -a /path/to/cleaned/SPIN-ASD_or_SPINS/Data/sub-* | \
while read ID;
do python /path/to/ciftify_falff.py /path/to/cleaned/SPIN-ASD_or_SPINS/Data/${ID}/${ID}_ses-01_task-rest_desc-cleansm6_bold.dtseries.nii --min-low-freq 0.01  --max-low-freq 0.027   /path/to/falff/output/slow5/${ID}_ses-01_task-rest_desc-falffslow5.dscalar.nii;
done
```
For slow-4 run this:
```bash
basename -a /path/to/cleaned/SPIN-ASD_or_SPINS/Data/sub-* | \
while read ID;
do python /path/to/ciftify_falff.py /path/to/cleaned/SPIN-ASD_or_SPINS/Data/${ID}/${ID}_ses-01_task-rest_desc-cleansm6_bold.dtseries.nii --min-low-freq 0.027  --max-low-freq 0.073  /path/to/falff/output/slow4/${ID}_ses-01_task-rest_desc-falffslow4.dscalar.nii;
done
```

2 - fALFF_normalization code was run once slow 4 and slow 5 fALFF were calculated. This script normalizes fALFF by dividing the fALFF value of each voxel by the average fALFF of the entire brain for that participant.


3 - The SPINS_SPASD_Final_ComBat_Code.m should be run once for slow-4 and once for slow-5 after assigning the correct value to the variable "slow" (lines 44 and 45). This code takes a .csv file with participant IDs, age, sex, scanner, diagnostic group, TASIT-3-Sar and ER40 scores. Then, each variable is assigned a numerical value and path to standardized (i.e. normalized) fALFF was defined, functional data was loaded, data was harmonized and was eventually saved with the appropriate filename.


4 - The compute_vertices_from_surface.sh is simply a code that computes adjancency for vertices, run prior to PALM, once for SPINS and another time for SPIN-ASD data.


5 - The PALM Script folder is comprised of 4 .sh scripts, slow 4 main effect of fALFF (group differences in slow 4), slow 5 main effect (group differences in slow 5), slow 4 interaction (social cognitive scores by fALFF interaction for slow 4) and slow 5 interaction (social cognitive scores by fALFF interaction for slow 5). Each script can be run once. 
desmat.csv and conmat.csv, defined just after line 30 are design and contrast matrices for main effect and interaction that include the diagnostic group, age, sex, scanner, social cognitive scores, etc information.
At about line 87, we are using the output of the script we ran on part 4 (i.e. compute_vertices_from_surface.sh) that computes the vertecies adjacency.
After line 110, we are actually runnin PALM and finding differences using the design and contrast matrices.


6 - There are 3 individual variability scripts in R. The calc_ind_var_slow4.R and calc_ind_var_slow5.R calculate individual varibility separatly for slow 4 and slow 5. In this code, after dividing individuals based on diagnostic group, average pairwise correlattion distance for each individual is calculated. In the MCD_model_plot.R script, the slow 4 and slow 5 MCD models are tested statistically and significant findings are then plotted using the R ggplot package.
