#!/bin/bash

set -em

echo "Setting up nextflow.config"

# Set up the folders being used for the Singularity cache and working files
WORK_DIR=${SCRATCH_DIR%/}/work/
CACHE_DIR=${SCRATCH_DIR%/}/cache/

echo """

workDir = '${WORK_DIR}'

singularity {
    enabled = $(echo $SINGULARITY | tr '[:upper:]' '[:lower:]')
    autoMounts = true
    cacheDir = '${CACHE_DIR}'
    runOptions = '--containall --no-home'
}

process{
    executor = 'slurm'
    queue = '${QUEUE}'
    errorStrategy = 'retry'
    maxRetries = ${MAX_RETRIES}
}

docker.enabled = false
report.enabled = true
trace.enabled = true
""" > nextflow.config

# If the Tower token was provided
if [ -z ${TOWER_ACCESS_TOKEN} ]; then
    echo Tower token is not set
else
    echo """
tower {
  accessToken = '${TOWER_ACCESS_TOKEN}'
  enabled = true
}
""" >> nextflow.config
fi

cat nextflow.config
echo

# Disable ANSI logging
export NXF_ANSI_LOG=false

# Print the Nextflow version being used
echo "Nextflow Version: ${NXF_VER}"
echo

# Execute the tool in the local environment
echo "Starting tool"
echo

# Load the Nextflow module (if running on rhino/gizmo)
ml Nextflow

# Load the Singularity module (if running on rhino/gizmo with Singularity)
ml Singularity
# Make sure that the singularity executables are in the PATH
export PATH=$SINGULARITYROOT/bin/:$PATH

# Start the tool
/bin/bash ._wb/helpers/run_tool
