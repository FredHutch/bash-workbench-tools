#!/bin/bash

set -euo pipefail

date
echo
echo "Running workflow from ${PWD}"
echo

# Build the samplesheet
echo "Building the samplesheet"
echo fasta,name > sample_sheet.csv
for fp in ${FOLDER%/}/*${SUFFIX}; do
    n="${fp##*/}"
    n="${n%$SUFFIX}"
    echo "$fp,$n" >> sample_sheet.csv
done

# Nextflow Version
NXF_VER=21.10.6

# Nextflow script to run
NXF_RUN=._wb/tool/run.nf

# Nextflow Configuration File
NXF_CONFIG=._wb/tool/nextflow.config

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
    --output_folder "${PWD}" \
    --sample_sheet sample_sheet.csv \
    -params-file ._wb/tool/params.json \
    -with-report nextflow.report.html \
    -resume

echo
date
echo Done
