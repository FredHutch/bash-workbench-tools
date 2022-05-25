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

set -e

# Load the AlphaFold2 module
ml AlphaFold/2.1.1-fosscuda-2020b

# Get the folder with all of the databases
DB_DIR="\${ALPHAFOLD_DATA_DIR}"

unset ALPHAFOLD_DATA_DIR

# Make a string indicating that all sequences in the FASTA are prokaryotes
IS_PROKARYOTE_LIST=${params.prokaryote}

echo "Running with --is_prokaryote_list \$IS_PROKARYOTE_LIST"

# Run the command
alphafold \
    --fasta_paths $fasta \
    --output_dir ./ \
    --is_prokaryote_list \$IS_PROKARYOTE_LIST \
    --model_preset multimer \
    --max_template_date ${params.max_template_date} \
    --bfd_database_path \${DB_DIR}/bfd/bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt \
    --mgnify_database_path \${DB_DIR}/mgnify/mgy_clusters_2018_12.fa \
    --template_mmcif_dir \${DB_DIR}/pdb_mmcif/mmcif_files \
    --uniclust30_database_path \${DB_DIR}/uniclust30/uniclust30_2018_08/uniclust30_2018_08 \
    --uniref90_database_path \${DB_DIR}/uniref90/uniref90.fasta \
    --pdb_seqres_database_path \${DB_DIR}/pdb_seqres/pdb_seqres.txt \
    --uniprot_database_path \${DB_DIR}/uniprot/uniprot.fasta \
    --obsolete_pdbs_path \${DB_DIR}/pdb_mmcif/obsolete.dat \
    --data_dir \${DB_DIR}
"""
}

workflow {
    alphafold(
        Channel
            .fromPath(
                ["${params.input}/*a", "${params.input}/*.txt"]
            )
            .ifEmpty{
                error "No files found in ${params.input}"
            }
    )
}