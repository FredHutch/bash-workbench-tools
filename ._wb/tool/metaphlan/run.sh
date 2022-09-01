#!/bin/bash

set -euo pipefail

WORKFLOW_REPO="FredHutch/metaphlan-nf"

date
echo
echo "Running workflow '${WORKFLOW_REPO}' from ${PWD}"
echo

# Run the workflow
echo Starting workflow
nextflow \
    run \
    "${WORKFLOW_REPO}" \
    --output "${PWD}" \
    -params-file ._wb/tool/params.json \
    -resume

# If temporary files were not placed in a separate location
if [ -d work ]; then
    # Delete the temporary files created during execution
    echo Removing temporary files
    rm -r work
fi

echo
date
echo Done
