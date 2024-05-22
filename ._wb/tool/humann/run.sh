#!/bin/bash

set -euo pipefail

WORKFLOW_REPO="CirroBio/nf-humann"

date
echo
echo "Constructing the input samplesheet"
echo "Input Directory: ${INPUT_DIR}"
echo "File Pattern: SAMPLE${INPUT_SPACER}{1,2}${INPUT_SUFFIX}"
echo

echo sample,fastq_1,fastq_2 > samplesheet.csv
for R1 in $(find "${INPUT_DIR}/" -name "*${INPUT_SPACER}1${INPUT_SUFFIX}" | sort); do
    SAMPLE=$(basename "${R1}" | sed "s/${INPUT_SPACER}1${INPUT_SUFFIX}//")
    R2=$(echo "${R1}" | sed "s/1${INPUT_SUFFIX}/2${INPUT_SUFFIX}/")
    echo "${SAMPLE},${R1},${R2}"
done >> samplesheet.csv

# If there is only one row in samplesheet.csv, raise an error
if [ $(wc -l < samplesheet.csv) -eq 1 ]; then
    echo "ERROR: No samples found in ${INPUT_DIR} with pattern SAMPLE${INPUT_SPACER}{1,2}${INPUT_SUFFIX}"
    exit 1
fi

date
echo
echo "Running workflow '${WORKFLOW_REPO}' from ${PWD}"
echo

# Pull the workflow
nextflow pull "${WORKFLOW_REPO}"

# Run the workflow
echo Starting workflow
nextflow \
    run \
    "${WORKFLOW_REPO}" \
    -r main \
    --output "${PWD}" \
    --samplesheet samplesheet.csv \
    -params-file ._wb/tool/params.json \
    -resume \
    -latest

# If temporary files were not placed in a separate location
if [ -d work ]; then
    # Delete the temporary files created during execution
    echo Removing temporary files
    rm -r work
fi

echo
date
echo Done
