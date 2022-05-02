#!/usr/bin/env nextflow

// Using DSL-2
nextflow.enable.dsl=2

process alphafold {
    // Write output files to the output directory
    publishDir "${params.output_folder}", mode: "move"
    cpus 16
    memory "120.GB"
    clusterOptions '--gres=gpu:1'

    input:
    path fasta

    output:
    // Capture all output files
    path "*"

"""#!/bin/bash
# Load the AlphaFold2 module
ml AlphaFold/2.1.1-fosscuda-2020b

# Run the command
alphafold --fasta_paths $fasta --output_dir ./ --max_template_date \$(date +"%Y-%m-%d")
"""
}

workflow {
    alphafold(
        Channel
            .fromPath(
                "${params.input}/*a"
            )
            .ifEmpty{
                error "No files found in ${params.input}"
            }
    )
}