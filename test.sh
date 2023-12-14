#!/bin/bash
#########################################################
#########################################################
#Variables that will need to be updated for each project:
PRJ="HCC-CBS-173-Hillman-BFerris-NRG-HN003-Vectra"
BASE="/ix/rbao/Projects/"$PRJ #Project path on HPC
SCRIPT_PATH=$BASE"/scripts/173-BFerris-NRG-HN003-Vectra" #Path of git clone of this codebase
SAMPLES=$BASE/"sampleinfo/file_list.tsv"
FILE_TYPE=".txt" #File type of WSI images
RESULTS_PATH=$BASE"/results/" #Path where tiles / inference outputs will be stored

## Choose which parts of the pipeline to run:
RUN_PREPROC=0
RUN_INFER=0 #Requires preproc
RUN_POST=0 #Requres preproc -> infer (creates heatmaps, geojson)

#Columns: task     slide         slide_path
#          1     example.svs   /full/path/to/example.svs  [WARNING: make sure there are no spaces in file path!]

#####################################################################
#####################################################################
### Do not change these variables unless you know what you're doing
## 
# 
SLURM_ARRAY_TASK_ID=1 #For debugging
FILE=$(awk -v task=$SLURM_ARRAY_TASK_ID '$1==task {print $2}' $SAMPLES)
FILE_NAME=${FILE%.*} 
echo $FILE_NAME
FILE_PATH=$(awk -v task=$SLURM_ARRAY_TASK_ID '$1==task {print $3}' $SAMPLES)
echo $FILE_PATH