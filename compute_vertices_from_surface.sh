#!/bin/bash

# Load connectome workbench
module load connectome-workbench/1.4.1

# Assign base and output directories
base_dir="/archive/data-2.0/SPINS/pipelines/bids_apps/ciftify"
outdir="/projects/sbagheri/SPINS_and_SPASD/PALM_bothsoccog_lowfd_Dec13_2023/va_files_SPINS"

# Assign SPINS and SPASD subject IDs - run code saparately for SPINS and SPASD
sublist="/projects/sbagheri/SPINS_and_SPASD/PALM_bothsoccog_lowfd_Dec13_2023/sublist_SPINS_only_V1.txt" 
mkdir -p ${outdir}

# Compute the adjacency(neighbourhood) information between vertices from the surfaces
while read subid;
do
for id in L R;
do
wb_command -surface-vertex-areas ${base_dir}/${subid}/MNINonLinear/fsaverage_LR32k/${subid}.${id}.midthickness.32k_fs_LR.surf.gii ${outdir}/${subid}.${id}.midthick_va.shape.gii
echo ${subid} done
done
done < ${sublist}
