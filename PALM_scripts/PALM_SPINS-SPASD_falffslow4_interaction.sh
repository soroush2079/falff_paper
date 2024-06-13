#!/bin/bash

#SBATCH --partition=high-moby               # Specify the partition for the job
#SBATCH --nodes=1                           # Number of nodes
#SBATCH --cpus-per-task=4                   # Number of CPUs per task
#SBATCH --mem-per-cpu=2G                    # Memory per CPU
#SBATCH --time=48:00:00                     # Maximum runtime (48 hours)
#SBATCH --export=ALL                        # Export all environment variables
#SBATCH --job-name=PALM                     # Job name
#SBATCH --output=/projects/sbagheri/PALM_conmat_bothsoccog_falff_interaction_slow4_%j.txt  # Standard output and error log
#SBATCH --array=1                           # Job array index

# Load modules
module load matlab/R2017b
module load palm/alpha111
module load connectome-workbench/1.4.1

# Assign root directory to "DIR"
DIR="/projects/sbagheri/SPINS_and_SPASD/PALM_bothsoccog_lowfd_Dec13_2023"

# Assign the file that contains the list of participant IDs
sublistids="${DIR}/final_sublist.txt"

# Assign the file that contains paths to GLM outputs
filename="$(find $DIR/filelists/*slow4*txt -type f | head -n $SLURM_ARRAY_TASK_ID | tail -n 1)"

# Modify the output file name for consistency
truncname="$(echo $(basename `echo "$filename"`) | sed 's/filepaths/PALM_conmat_combined_falff_with_covariates_interaction_slow4/;s/.txt//')" 

# Set the path for the design and contrast matrices for PALM
desmat="$DIR/con_design_bothsoccog_interaction/desmat1.csv" 
conmat="$DIR/con_design_bothsoccog_interaction/conmat1.csv"

# Define the output directory for PALM
outdir="${DIR}/PALM_result_bothsoccog_interaction/$truncname"

# Go to output directory where results of PALM will be saved
echo output directory is $outdir
echo $filename
head -20 $filename
head -20 $desmat
mkdir -p $outdir
cd $outdir

# Assign HCP data directory
HCP_DATA=/archive/data/SPASD/pipelines/bids_apps

# Extracting the first subject ID
exampleSubid=$(head -n 1 ${sublistids})

# Define paths to the left and right hemisphere midthickness surface files for the first subject, which will be used as reference templates for surface-based analysis
surfL=${HCP_DATA}/ciftify/${exampleSubid}/MNINonLinear/fsaverage_LR32k/${exampleSubid}.L.midthickness.32k_fs_LR.surf.gii
surfR=${HCP_DATA}/ciftify/${exampleSubid}/MNINonLinear/fsaverage_LR32k/${exampleSubid}.R.midthickness.32k_fs_LR.surf.gii

# Define the input file and filename prefix for merging
infile=allsubs_merged.dscalar.nii
fname=merge_split



# Merge CIFTI files into one
mergefiles() {
    args=""
    while read ff
    do
	  args="${args} -cifti $ff"
    done < ${filename}
    echo $args
    wb_command -cifti-merge ${infile} ${args}
}



# Separate CIFTI file into GIFTI files
cifti2gifti() {
    wb_command -cifti-separate $infile COLUMN -volume-all ${fname}_sub.nii -metric CORTEX_LEFT ${fname}_L.func.gii -metric CORTEX_RIGHT ${fname}_R.func.gii
    wb_command -gifti-convert BASE64_BINARY ${fname}_L.func.gii ${fname}_L.func.gii
    wb_command -gifti-convert BASE64_BINARY ${fname}_R.func.gii ${fname}_R.func.gii
}



# Calculate mean surface
meansurface() {
    MERGELIST=""
    while read subids; do
	  MERGELIST="${MERGELIST} -metric $DIR/va_files/${subids}.L.midthick_va.shape.gii";#dont forgetbto run the compute_vertices_form_surface.sh file
    done < ${sublistids}


    wb_command -metric-merge L_midthick_va.func.gii ${MERGELIST}
    wb_command -metric-reduce L_midthick_va.func.gii MEAN L_area.func.gii

    MERGELIST=""
    while read subids; do
	  MERGELIST="${MERGELIST} -metric $DIR/va_files/${subids}.R.midthick_va.shape.gii";
    done < ${sublistids}

    wb_command -metric-merge R_midthick_va.func.gii ${MERGELIST}
    wb_command -metric-reduce R_midthick_va.func.gii MEAN R_area.func.gii
}



# Run PALM
runpalm() {
    palm -i ${fname}_L.func.gii -d $desmat -t $conmat -o results_L_cort -T -tfce2D -s $surfL L_area.func.gii -logp -n 1000
    palm -i ${fname}_R.func.gii -d $desmat -t $conmat -o results_R_cort -T -tfce2D -s $surfR R_area.func.gii -logp -n 1000
    palm -i ${fname}_sub.nii -d $desmat -t $conmat -o results_sub -T -logp -n 1000



    wb_command -cifti-create-dense-from-template ${infile} results_cort_tfce_tstat_fwep_c1.dscalar.nii -volume-all results_sub_tfce_tstat_fwep_c1.nii -metric CORTEX_LEFT results_L_cort_tfce_tstat_fwep_c1.gii -metric CORTEX_RIGHT results_R_cort_tfce_tstat_fwep_c1.gii
    wb_command -cifti-create-dense-from-template ${infile} results_cort_tfce_tstat_fwep_c2.dscalar.nii -volume-all results_sub_tfce_tstat_fwep_c2.nii -metric CORTEX_LEFT results_L_cort_tfce_tstat_fwep_c2.gii -metric CORTEX_RIGHT results_R_cort_tfce_tstat_fwep_c2.gii
    wb_command -cifti-create-dense-from-template ${infile} results_cort_tfce_tstat_fwep_c3.dscalar.nii -volume-all results_sub_tfce_tstat_fwep_c3.nii -metric CORTEX_LEFT results_L_cort_tfce_tstat_fwep_c3.gii -metric CORTEX_RIGHT results_R_cort_tfce_tstat_fwep_c3.gii
    wb_command -cifti-create-dense-from-template ${infile} results_cort_tfce_tstat_fwep_c4.dscalar.nii -volume-all results_sub_tfce_tstat_fwep_c4.nii -metric CORTEX_LEFT results_L_cort_tfce_tstat_fwep_c4.gii -metric CORTEX_RIGHT results_R_cort_tfce_tstat_fwep_c4.gii
    wb_command -cifti-create-dense-from-template ${infile} results_cort_tfce_tstat_fwep_c5.dscalar.nii -volume-all results_sub_tfce_tstat_fwep_c5.nii -metric CORTEX_LEFT results_L_cort_tfce_tstat_fwep_c5.gii -metric CORTEX_RIGHT results_R_cort_tfce_tstat_fwep_c5.gii
    wb_command -cifti-create-dense-from-template ${infile} results_cort_tfce_tstat_fwep_c6.dscalar.nii -volume-all results_sub_tfce_tstat_fwep_c6.nii -metric CORTEX_LEFT results_L_cort_tfce_tstat_fwep_c6.gii -metric CORTEX_RIGHT results_R_cort_tfce_tstat_fwep_c6.gii
    wb_command -cifti-create-dense-from-template ${infile} results_cort_tfce_tstat_fwep_c7.dscalar.nii -volume-all results_sub_tfce_tstat_fwep_c7.nii -metric CORTEX_LEFT results_L_cort_tfce_tstat_fwep_c7.gii -metric CORTEX_RIGHT results_R_cort_tfce_tstat_fwep_c7.gii
    wb_command -cifti-create-dense-from-template ${infile} results_cort_tfce_tstat_fwep_c8.dscalar.nii -volume-all results_sub_tfce_tstat_fwep_c8.nii -metric CORTEX_LEFT results_L_cort_tfce_tstat_fwep_c8.gii -metric CORTEX_RIGHT results_R_cort_tfce_tstat_fwep_c8.gii
    wb_command -cifti-create-dense-from-template ${infile} results_cort_tfce_tstat_fwep_c9.dscalar.nii -volume-all results_sub_tfce_tstat_fwep_c9.nii -metric CORTEX_LEFT results_L_cort_tfce_tstat_fwep_c9.gii -metric CORTEX_RIGHT results_R_cort_tfce_tstat_fwep_c9.gii
    wb_command -cifti-create-dense-from-template ${infile} results_cort_tfce_tstat_fwep_c10.dscalar.nii -volume-all results_sub_tfce_tstat_fwep_c10.nii -metric CORTEX_LEFT results_L_cort_tfce_tstat_fwep_c10.gii -metric CORTEX_RIGHT results_R_cort_tfce_tstat_fwep_c10.gii
    wb_command -cifti-create-dense-from-template ${infile} results_cort_tfce_tstat_fwep_c11.dscalar.nii -volume-all results_sub_tfce_tstat_fwep_c11.nii -metric CORTEX_LEFT results_L_cort_tfce_tstat_fwep_c11.gii -metric CORTEX_RIGHT results_R_cort_tfce_tstat_fwep_c11.gii
    wb_command -cifti-create-dense-from-template ${infile} results_cort_tfce_tstat_fwep_c12.dscalar.nii -volume-all results_sub_tfce_tstat_fwep_c12.nii -metric CORTEX_LEFT results_L_cort_tfce_tstat_fwep_c12.gii -metric CORTEX_RIGHT results_R_cort_tfce_tstat_fwep_c12.gii


# Find differences
    wb_command -cifti-math '(x-y)' ${fname}_tstat_fwep_c12.dscalar.nii -var x results_cort_tfce_tstat_fwep_c1.dscalar.nii -var y results_cort_tfce_tstat_fwep_c2.dscalar.nii
    wb_command -cifti-math '(x-y)' ${fname}_tstat_fwep_c34.dscalar.nii -var x results_cort_tfce_tstat_fwep_c3.dscalar.nii -var y results_cort_tfce_tstat_fwep_c4.dscalar.nii
    wb_command -cifti-math '(x-y)' ${fname}_tstat_fwep_c56.dscalar.nii -var x results_cort_tfce_tstat_fwep_c5.dscalar.nii -var y results_cort_tfce_tstat_fwep_c6.dscalar.nii
    wb_command -cifti-math '(x-y)' ${fname}_tstat_fwep_c78.dscalar.nii -var x results_cort_tfce_tstat_fwep_c7.dscalar.nii -var y results_cort_tfce_tstat_fwep_c8.dscalar.nii
    wb_command -cifti-math '(x-y)' ${fname}_tstat_fwep_c910.dscalar.nii -var x results_cort_tfce_tstat_fwep_c9.dscalar.nii -var y results_cort_tfce_tstat_fwep_c10.dscalar.nii
    wb_command -cifti-math '(x-y)' ${fname}_tstat_fwep_c1112.dscalar.nii -var x results_cort_tfce_tstat_fwep_c11.dscalar.nii -var y results_cort_tfce_tstat_fwep_c12.dscalar.nii
}


mergefiles &&
    cifti2gifti &&
    meansurface &&
    runpalm
