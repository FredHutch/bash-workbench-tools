#!/bin/bash

set -e

echo "Setting up nextflow.config"

echo """
{
    docker {
        enabled = true
    }
    report {
        enabled = true
    }
    trace {
        enabled = true
    }
}
""" > nextflow.config

# Execute the tool in the local environment
/bin/bash ._wb/helpers/run_tool
