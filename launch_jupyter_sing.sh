#!/bin/bash
module load singularity/3.9.6

PORT=$1
PORT="${PORT:-8888}" #Switches port to default value if left empty
PRJ="HCC-CBS-173-Hillman-BFerris-NRG-HN003-Vectra"
singularity exec -B /ix/rbao/Projects/$PRJ:/mnt \
    /ix/rbao/images/pathml_jupyter6_nv.sif \
    /opt/conda/envs/py38/bin/jupyter lab \
    --no-browser --port=$PORT --ip=0.0.0.0 
