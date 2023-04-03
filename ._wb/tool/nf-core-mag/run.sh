#!/bin/bash

set -euo pipefail

date
echo
echo "Running workflow nf-core/mag v${VERSION} from ${PWD}"
echo

# Run the workflow
echo Starting workflow
nextflow \
    run \
    nf-core/mag \
    -r "${VERSION}" \
    --outdir "${PWD}" \
    --schema_ignore_params mag_version \
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
