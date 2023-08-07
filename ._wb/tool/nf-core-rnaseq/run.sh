#!/bin/bash

set -euo pipefail

date
echo
echo "Running workflow nf-core/rnaseq v${VERSION} from ${PWD}"
echo

echo "Using Nextflow version ${NXF_VER}"
echo

# Run the workflow
echo Starting workflow
NXF_VER=${NXF_VER} \
nextflow \
    run \
    nf-core/rnaseq \
    -r "${VERSION}" \
    --outdir "${PWD}" \
    --schema_ignore_params rnaseq_version,genomes \
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
