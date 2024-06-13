#!/bin/bash

# Normalize the fALFF raw data by dividing the fALFF value of each voxel by average fALFF of entire brain 
for file in *.nii
do dscalar_mean=`wb_command -cifti-stats /projects/sbagheri/SPINS_and_SPASD/SPINS_SPASD_falff_raw/slow_5/$file -reduce MEAN`
   MATH_EX=`echo "(x/${dscalar_mean})"`
   wb_command -cifti-math ${MATH_EX} /projects/sbagheri/SPINS_and_SPASD/SPINS_SPASD_falff_standardized/slow5/$file -var x /projects/sbagheri/SPINS_and_SPASD/SPINS_SPASD_falff_raw/slow_5/$file # another normalization for fALFF slow 4
done
