#!/bin/bash

set -e

ml CellRanger/6.1.1

for sample in ${INPUT_FOLDER}/*; do
    cellranger count \
        --id=${sample} \
        --transcriptome=${REF_DB} \
        --fastqs=${INPUT_FOLDER}/${sample} \
        --sample=${sample} \
        --chemistry=${CHEMISTRY}
done