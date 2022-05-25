#!/bin/bash

set -euo pipefail

# Nextflow Version
NXF_VER=21.10.6

# Nextflow script to run
NXF_RUN=._wb/tool/run.nf

# Nextflow Configuration File
NXF_CONFIG=._wb/tool/nextflow.config

# If the max_template_date was not provided
if [ -z ${MAX_TEMPLATE_DATE} ]; then
    MAX_TEMPLATE_DATE=$(date +"%Y-%m-%d")
    echo "max_template_date was not set, defaulting to today (${MAX_TEMPLATE_DATE})"
fi

# Disable ANSI logging
export NXF_ANSI_LOG=false

# Load the Nextflow module (if running on rhino/gizmo)
ml Nextflow

# Run the workflow
NXF_VER=$NXF_VER \
nextflow \
    run \
    -c ${NXF_CONFIG} \
    ${NXF_RUN} \
    --output_folder ./ \
    --max_template_date "${MAX_TEMPLATE_DATE}" \
    -params-file ._wb/tool/params.json \
    -with-report nextflow.report.html \
    -resume
