#!/bin/bash
module load singularity/3.9.6

PORT=$1
PORT="${PORT:-8888}" #Switches port to default value if left empty
PRJ="HCC-CBS-162-Hillman-BFerris-18139-HN-Vectra"
singularity exec -B /ix/rbao/Projects/$PRJ:/mnt \
    /ix/rbao/images/pathml_jupyter2.sif \
    /opt/conda/envs/py38/bin/jupyter lab \
    --no-browser --port=$PORT --ip=0.0.0.0 
