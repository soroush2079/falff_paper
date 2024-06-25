# fALFF Manuscript Pipeline
Overview: 
This repository contains the scripts that were utilized in the fALFF manuscript using the SPINS and SPIN-ASD data by Bagheri et al.
General order of codes that were run after preprocessing and cleaning was as such: 
ciftify_falff.py > 
fALFF_normalization.sh > 
SPINS_SPASD_Final_ComBat_Code.m > 
compute vertices from surface.sh > 
PALM_scripts for main effect and interaction & 
Individual Vairiability Code for Slow 4 and Slow 5


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


4 - 
