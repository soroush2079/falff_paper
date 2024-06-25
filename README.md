# falff_paper
Overview: 
This repository contains the scripts that were utilized in the fALFF manuscript using the SPINS and SPIN-ASD data by Bagheri et al.
General order of codes that were run after preprocessing and cleaning was as such: 
ciftify_falff.py > fALFF_normalization.sh > SPINS_SPASD_Final_ComBat_Code.m > compute vertices from surface.sh > PALM_scripts for main effect and interaction & Individual Vairiability Code for Slow 4 and Slow 5


1 - The ciftify_falff.py code was used to calculate fALFF in a virtual environement. In the command line, the following lines were run for slow 4 and slow 5 fALFF for SPINS and SPIN-ASD participants:
Slow 5
basename -a /path/to/cleaned/SPIN-ASD_or_SPINS/Data/sub-* | \
while read ID;
do python /path/to/ciftify_falff.py /path/to/cleaned/SPIN-ASD_or_SPINS/Data/${ID}/${ID}_ses-01_task-rest_desc-cleansm6_bold.dtseries.nii --min-low-freq 0.01  --max-low-freq 0.027   /path/to/falff/output/slow5/${ID}_ses-01_task-rest_desc-falffslow5.dscalar.nii;
done

Slow4
basename -a /path/to/cleaned/SPIN-ASD_or_SPINS/Data/sub-* | \
while read ID;
do python /path/to/ciftify_falff.py /path/to/cleaned/SPIN-ASD_or_SPINS/Data/${ID}/${ID}_ses-01_task-rest_desc-cleansm6_bold.dtseries.nii --min-low-freq 0.027  --max-low-freq 0.073  /path/to/falff/output/slow4/${ID}_ses-01_task-rest_desc-falffslow4.dscalar.nii;
done
