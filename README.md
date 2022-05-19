# BASH Workbench Tools

Collection of tools and launchers for the BASH Workbench which may be
useful to researchers at the Fred Hutch Cancer Research Center and others.

## Contents

### Tools

- `make_tar_gz`: Collect a group of files into a gzip-compressed tarball
- `alphafold2-single`: Run the AlphaFold2 structural prediction utility on the Fred Hutch SLURM cluster
- `alphafold2-multimer`: Run the AlphaFold2 structural prediction utility _for multimers_ on the Fred Hutch SLURM cluster
- `download_sra`: Download a collection of FASTQ files from the NCBI SRA repository

### Launchers

- `base`: Simply run a tool in the local system environment
- `nextflow_docker`: Run a Nextflow workflow using Docker on a local system
- `nextflow_slurm`: Run a Nextflow workflow using Singularity on a SLURM-based computing cluster

## BASH Workbench

The BASH Workbench is a utility for sharing analysis tools via configurable
BASH scripts. For more information on this utility, visit
[its homepage](https://github.com/FredHutch/bash-workbench).

## Using the Tools

To install this set of tools on your own system, simply install the
BASH Workbench and import this repository following its instructions.

```#!/bin/bash
wb add_repo --remote-name FredHutch/bash-workbench-tools
```

## Developers Guide

The tools and launchers defined by this repository are contained in the
folder `._wb/`. Tools and launchers are defined in their own subfolder,
and additional resources may be added by creating additional subfolders
which follow the same syntax.
