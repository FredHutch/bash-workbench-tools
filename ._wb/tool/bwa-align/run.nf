#!/usr/bin/env nextflow

// Using DSL-2
nextflow.enable.dsl=2

process bwa_mem {
    // Write output files to the output directory
    publishDir "${params.output}", mode: "copy", overwrite: true

    input:
    tuple val(sample), path(R1), path(R2)
    path "reference/"

    output:
    // Capture all output files named for the accession
    path "${sample}.bam"
    path "${sample}.bam.bai"

"""#!/bin/bash

set -e

echo Loading modules
ml BWA
ml SAMtools

REF_FULL="${params.genome}"
REF_BASE="\${REF_FULL##*/}"

echo Checking for the reference
ls reference
ls reference/\${REF_BASE}

echo Running alignments
bwa mem \
    -t ${task.cpus} \
    ${params.extra_args} \
    reference/\${REF_BASE} \
    ${R1} \
    ${R2} \
    | samtools view -b \
    | samtools sort - > ${sample}.bam

echo Indexing alignments
samtools index ${sample}.bam

echo Done

"""
}

workflow {

    // Set up the reference genome
    Channel
        .fromPath(
            "${params.genome}*",
            checkIfExists: true
        )
        .toSortedList()
        .set { reference }

    bwa_mem(
        Channel
            .fromFilePairs(
                "${params.reads}",
                checkIfExists: true
            )
            .ifEmpty{
                error "No files found in ${params.reads}"
            }
            .map {
                it -> [it[0], it[1][0], it[1][1]]
            },
        reference
    )
}