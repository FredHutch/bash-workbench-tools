#!/usr/bin/env nextflow

// Using DSL-2
nextflow.enable.dsl=2

process emapper {
    // Write output files to the output directory
    publishDir "${params.output}", mode: "copy", overwrite: true
    container "quay.io/biocontainers/eggnog-mapper:2.0.1--py_1"
    cpus params.cpus
    memory "${params.memory_gb}.GB"

    input:
    path query
    path "data/eggnog.db"
    path "data/eggnog_proteins.dmnd"

    output:
    path "genes.emapper.annotations.gz"

"""#!/bin/bash
set -e

echo "Loading the eggNOG-mapper module"
ml eggnog-mapper

echo "Setting up temporary directories"
mkdir TEMP
mkdir SCRATCH

echo "Running eggNOG-mapper"
emapper.py \
    -i ${query} \
    --output genes \
    -m "diamond" \
    --cpu ${task.cpus} \
    --data_dir data/ \
    --scratch_dir SCRATCH/ \
    --temp_dir TEMP/ \
    ${params.options}

echo "Compressing results"
gzip genes.emapper.annotations
"""
}

workflow {

    // Get the input files
    fasta = file(params.fasta, checkIfExists: true)
    eggnog_db = file(params.eggnog_db, checkIfExists: true)
    eggnog_dmnd = file(params.eggnog_dmnd, checkIfExists: true)

    emapper(
        fasta,
        eggnog_db,
        eggnog_dmnd
    )

}