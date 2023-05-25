#!/bin/bash

set -euo pipefail

date
echo
echo "Running workflow from ${PWD}"
echo

# Nextflow Version
NXF_VER=21.10.6

# Nextflow script to run
NXF_RUN=._wb/tool/run.nf

# Nextflow Configuration File
NXF_CONFIG=._wb/tool/nextflow.config

# Disable ANSI logging
export NXF_ANSI_LOG=false

# Load the Nextflow module (if running on rhino/gizmo)
echo "Loading the Nextflow module"
ml Nextflow

# Run the workflow
echo "Running the workflow"
NXF_VER=$NXF_VER \
nextflow \
    run \
    -c ${NXF_CONFIG} \
    ${NXF_RUN} \
    --output_folder "${PWD}" \
    -params-file ._wb/tool/params.json \
    -with-report nextflow.report.html \
    -resume

echo
date
echo Done
