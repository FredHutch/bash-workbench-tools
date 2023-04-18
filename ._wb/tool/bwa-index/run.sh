#!/bin/bash

set -euo pipefail

date >> log.txt
echo "Loading BWA" >> log.txt
ml BWA
echo "Loading tabix" >> log.txt
ml tabix

date >> log.txt
echo "Indexing all FASTA files in ${INPUT_FOLDER}" >> log.txt

for suffix in .fa .fna .fasta; do

    for ending in .gz ""; do

        for fp in ${INPUT_FOLDER}/*${suffix}${ending}; do

            if [ ! -s ${fp} ]; then continue; fi

            fn=${fp#${INPUT_FOLDER}/}
            fn=${fn%${suffix}${ending}}

            date >> log.txt
            echo "Reading sequences from $fp" >> log.txt
            if [[ "${ending}" == ".gz" ]]; then
                gunzip -c $fp | sed "s/>/>${fn}-/"
            else
                cat $fp | sed "s/>/>${fn}-/"
            fi

        done

    done

done | \
    sed 's/ .*//' | \
    sed '/^$/d' | \
    bgzip -c > genomes.fasta.gz

date >> log.txt
echo "Building BWA index" >> log.txt
bwa index genomes.fasta.gz 2>&1 >> log.txt

date >> log.txt
echo "Done" >> log.txt
