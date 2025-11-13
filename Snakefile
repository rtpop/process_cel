## ------------------------------------------------------------------------------------------- ##
## HOW TO RUN                                                                                  ##
## Run from directory containing Snakefile                                                     ##
## ------------------------------------------------------------------------------------------- ##
## For dry run                                                                                 ##
## snakemake --cores 1 -np                                                                     ##
## ------------------------------------------------------------------------------------------- ##
## For local run                                                                               ##
## snakemake --cores 1                                                                         ##
## ------------------------------------------------------------------------------------------- ##
## For running with singularity container                                                      ##
## snakemake --cores 1 --use-singularity --singularity-args '\-e' --cores 1                    ##
## ------------------------------------------------------------------------------------------- ## ------------------------------ ##
## For running in the background                                                                                                 ##
## nohup snakemake --cores 1 --use-singularity --singularity-args '\-e' 2>&1 > logs/snakemake_$(date +'%Y-%m-%d_%H-%M-%S').log & ##
## ----------------------------------------------------------------------------------------------------------------------------- ##
## How to manually run a container on biotin4 cluster with binding of the Snakemake folder but no software env                   ##
## apptainer shell --cleanenv --containall --no-home --bind path/to/snakemake/folder:/home/ .snakemake/singularity/your_image    ##
## ----------------------------------------------------------------------------------------------------------------------------- ##

##-----------##
## Libraries ##
##-----------##

import os 
import sys
import glob
from pathlib import Path
import time

## ----------------- ##
## Global parameters ##
## ----------------- ##

# Config file
global CONFIG_PATH
CONFIG_PATH = "config.yaml"
configfile: CONFIG_PATH

# Containers
R_CONTAINER = config["r_container"]

# Number of cores
NCORES = config["ncores"]


# Directories
DATA_DIR = config["data_dir"]
RAW_DATA_DIR = config["raw_data_dir"]
PROCESSED_DATA_DIR = config["processed_data_dir"]
SRC_DIR = config["src_dir"]

## ----------------------------------------- ##
## Processing CEL files to expression matrix ##
## ----------------------------------------- ##

## Input files
METADATA_FILE = os.path.join(DATA_DIR, config["metadata_file"])

## Intermediate files
RAW_DATA_FILES = os.path.join(RAW_DATA_DIR, "files_to_process.txt")

EXP_FILE = os.path.join(PROCESSED_DATA_DIR, "expression_matrix.tsv")


## Params
FILE_SELECTION_METHOD = config["file_selection_method"]

## ----- ##
## Rules ##
## ----- ##

rule all:
    input:
        RAW_DATA_FILES

rule select_cel_files:
    input:
        raw_data_dir = RAW_DATA_DIR, \
        metadata_file = METADATA_FILE
    output:
        raw_data_files = RAW_DATA_FILES
    container: R_CONTAINER
    params:
        script = os.path.join(SRC_DIR, "selecting_cel_files.R"), \
        file_selection_method = FILE_SELECTION_METHOD
    shell:
        """
        Rscript {params.script} \
            --raw_data_dir {input.raw_data_dir} \
            --metadata_file {input.metadata_file} \
            --file_selection_method {params.file_selection_method} \
            --output_file {output.raw_data_files}
        """

rule extract_expression_matrix:
    input:
        raw_data_files = RAW_DATA_FILES, \
        metadata_file = METADATA_FILE
    output:
        exp_file = EXP_FILE
    container: R_CONTAINER
    params:
        script = os.path.join(SRC_DIR, "process_cel.R")
    shell:
        """
        Rscript {params.script} \
            --input_dir {input.raw_data_files} \
            --metadata_file {input.metadata_file} \
            --output_file {output.exp_file}
        """