#!/bin/bash
#SBATCH --job-name=vectra
#SBATCH --cpus-per-task=4
#SBATCH --time=00:10:00 # HH:MM:SS
#SBATCH --mem=128g
#SBATCH --array=1-1000

module load singularity/3.9.6
module load rclone/1.53.2

#########################################################
#########################################################
#Variables that will need to be updated for each project:
PRJ="HCC-CBS-173-Hillman-BFerris-NRG-HN003-Vectra"
BASE="/ix/rbao/Projects/"$PRJ #Project path on HPC
SCRIPT_PATH=$BASE"/scripts/173-BFerris-NRG-HN003-Vectra" #Path of git clone of this codebase
SAMPLES=$BASE/"sampleinfo/file_list.tsv"
FILE_TYPE=".txt" #File type of WSI images
RESULTS_PATH=$BASE"/results/raw_clean" #Path where tiles / inference outputs will be stored

## Choose which parts of the pipeline to run:
RUN_PREPROC=1
RUN_POST=0 # not implemented

#Columns: task     slide         slide_path
#          1     example.svs   /full/path/to/example.svs  [WARNING: make sure there are no spaces in file path!]

#####################################################################
#####################################################################
### Do not change these variables unless you know what you're doing
## 
# 

FILE=$(awk -v task=$SLURM_ARRAY_TASK_ID '$1==task {print $2}' $SAMPLES)
FILE_NAME=${FILE%.*} 
FILE_PATH=$(awk -v task=$SLURM_ARRAY_TASK_ID '$1==task {print $3}' $SAMPLES)

#Copy the WSI file to scratch:
rclone copy $FILE_PATH $SLURM_SCRATCH --progress
FILE_PATH=$SLURM_SCRATCH/$FILE

#Size of the tiles to use for inference:
echo "Task ${SLURM_ARRAY_TASK_ID} using ${FILE}."
VER=1

#############################################################
#### 1) First run pre-processing R script
JOB_SCRIPT=$SCRIPT_PATH/pre_proc.r
# JOB_SCRIPT=$SCRIPT_PATH/test.r
RSCRIPT=/ihome/rbao/bri8/envs/r_seurat/bin/Rscript
if [ $RUN_PREPROC = 1 ]
then
    echo "Running proprocessing with ${JOB_SCRIPT}"
    DATE_STR=$(date "+%Y-%m-%d_%H-%M-%S")
    echo $DATE_STR
    $RSCRIPT $JOB_SCRIPT \
            $FILE_PATH \
            $RESULTS_PATH
    echo "Preprocessing complete, now beginning inference."
fi
DATE_STR=$(date "+%Y-%m-%d_%H-%M-%S")
echo $DATE_STR