#!/usr/bin/env nextflow

// Using DSL-2
nextflow.enable.dsl=2

process fastq_dump {
    // Write output files to the output directory
    publishDir "${params.output}", mode: "copy", overwrite: true
    cpus 4
    memory "8.GB"

    input:
    // Input is the SRA accession to download
    val accession

    output:
    // Capture all output files named for the accession
    path "${accession}*"

"""#!/bin/bash

set -e

# Load the SRA Toolkit
ml SRA-Toolkit

# Run the command to download the FASTQ files
fastq-dump ${params.options} ${accession}

# Compress the output
pigz -p ${task.cpus} *fastq
"""
}

workflow {
    fastq_dump(
        Channel
            .fromPath(
                "${params.input}"
            )
            .ifEmpty{
                error "No files found in ${params.input}"
            }
            .splitText(){ it.replaceAll(/\n/, '') }
            .flatten()
            .filter( ~/.*RR.*/ )
            .ifEmpty{
                error "No lines found in ${params.input} matching *RR*"
            }
    )
}