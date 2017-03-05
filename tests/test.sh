#!/bin/bash
set -e

export PATH=$PATH:$HOME/miniconda3/bin

source activate dnabc
command -v snakemake

ROOT=`pwd`
#snakemake --configfile config.yml
#TODO
