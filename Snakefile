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

# config file
global CONFIG_PATH
CONFIG_PATH = "config_merged.yaml"
configfile: CONFIG_PATH

# Containers
R_CONTAINER = config.get("r_container", "")

# Number of cores
NCORES = config.get("ncores", "")


# Directories
DATA_DIR = config.get("data_dir", "")
RAW_DATA_DIR = config.get("raw_data_dir", "")
PROCESSED_DATA_DIR = config.get("processed_data_dir", "")
SRC_DIR = config.get("src_dir", "")

## ----------------------------------------- ##
## Processing CEL files to expression matrix ##
## ----------------------------------------- ##

## Input files
METADATA_FILE = os.path.join(DATA_DIR, config.get("metadata_file", ""))

## Intermediate files
RAW_DATA_FILES = os.path.join(RAW_DATA_DIR, config.get("cel_files", ""))

EXP_FILE = os.path.join(PROCESSED_DATA_DIR, config.get("exp_file", ""))
EXP_FILE_BATCH_CORRECTED = os.path.join(PROCESSED_DATA_DIR, config.get("exp_file_batch_corrected", ""))
EXP_FILE_FINAL = os.path.join(PROCESSED_DATA_DIR, config.get("exp_file_final", ""))

# pca params
PCA_PLOT = EXP_FILE.replace(".txt", "_PCA_plot.pdf")
PCA_PLOT_BATCH_CORRECTED = EXP_FILE_BATCH_CORRECTED.replace(".txt", "_PCA_plot.pdf")
TOP_N = config.get("top_n", "")
N_PROBES = config.get("n_probes", "")

## Params
PROCESS_CEL = config.get("processing_cel", "")
FILE_SELECTION_METHOD = config.get("file_selection_method", "")
NORMALISE = config.get("normalise", True)
BATCH_CORRECTION = config.get("batch_correction", False)
BATCH_METADATA_COLUMN = config.get("batch_metadata_column", "")
ARRAY_TYPE = config.get("array_type", "")
AVERAGE_BY_TUMOUR = config.get("average_by_tumour", "")
TUMOUR_METADATA_COLUMN = config.get("tumour_metadata_column", "")
EXP_FILE_AVG = os.path.join(PROCESSED_DATA_DIR, config.get("exp_file_avg", "exp_avg_by_tumour.txt"))
NORMAL_SAMPLES = config.get("normal_samples", False)

MERGE_DATASETS = config.get("compile_datasets", False)
if MERGE_DATASETS:
    print("Datasets to compile:", config.get("datasets_to_compile", []))
    DATASETS_TO_COMPILE = [os.path.join(PROCESSED_DATA_DIR, f) for f in config.get("datasets_to_compile", [])]
    EXP_FILE_MERGED = os.path.join(PROCESSED_DATA_DIR, config.get("exp_file_merged", ""))

## helper functions ##
# I don't know if this is the best way to do it
def get_all_inputs():
    """Get all required input files based on configuration"""
    inputs = []

    if PROCESS_CEL:
        inputs.extend([
            RAW_DATA_FILES,
            EXP_FILE,
            PCA_PLOT
        ])
    
    if BATCH_CORRECTION:
        inputs.extend([
            EXP_FILE_BATCH_CORRECTED,
            PCA_PLOT_BATCH_CORRECTED
        ])
    
    if AVERAGE_BY_TUMOUR:
        inputs.append(EXP_FILE_AVG)
    
    if MERGE_DATASETS:
        inputs.append(EXP_FILE_MERGED)
    
    return inputs

def get_averaging_input():
    """Get the correct input file for averaging based on whether batch correction is performed"""
    if BATCH_CORRECTION:
        return EXP_FILE_BATCH_CORRECTED
    else:
        return EXP_FILE

## ----- ##
## Rules ##
## ----- ##

rule all:
    input:
        get_all_inputs()


if PROCESS_CEL:
    rule select_cel_files:
        input:
            raw_data_dir = RAW_DATA_DIR, \
            metadata_file = METADATA_FILE
        output:
            raw_data_files = RAW_DATA_FILES
        container: R_CONTAINER
        params:
            script = os.path.join(SRC_DIR, "selecting_cel_files.R"), \
            file_selection_method = FILE_SELECTION_METHOD, \
            array_type = ARRAY_TYPE, \
            tumour_metadata_column = TUMOUR_METADATA_COLUMN, \
            normal_samples = NORMAL_SAMPLES
        script:
            "{params.script}"

    rule extract_expression_matrix:
        input:
            raw_data_dir = RAW_DATA_DIR, \
            raw_data_files = RAW_DATA_FILES, \
            metadata_file = METADATA_FILE
        output:
            exp_file = EXP_FILE
        container: R_CONTAINER
        params:
            script = os.path.join(SRC_DIR, "extract_expression_matrix.R"), \
            normalise = NORMALISE, \
            array_type = ARRAY_TYPE, \
            tumour_metadata_column = TUMOUR_METADATA_COLUMN, \
            normal_samples = NORMAL_SAMPLES
        script:
            "{params.script}"

    rule pca_plot:
        input:
            exp_file = EXP_FILE, \
            metadata_file = METADATA_FILE
        output:
            pca_plot = PCA_PLOT
        container: R_CONTAINER
        params:
            script = os.path.join(SRC_DIR, "plot_pca.R"), \
            color_by = config.get("pca_color_by", "") if config.get("pca_color_by") else "NULL", \
            shape_by = config.get("pca_shape_by", "") if config.get("pca_shape_by") else "NULL", \
            title = config.get("pca_title", ""), \
            top_n = TOP_N, \
            n_probes = N_PROBES
            
        shell:
            """
            Rscript {params.script} \
                --exp_mat {input.exp_file} \
                --metadata {input.metadata_file} \
                --color_by {params.color_by} \
                --shape_by {params.shape_by} \
                --title "{params.title}" \
                --output_file {output.pca_plot} \
                --top_n {params.top_n} \
                --n_probes {params.n_probes}
            """

if BATCH_CORRECTION:
    rule combat_batch_correction:
        input:
            exp_file = EXP_FILE, \
            metadata_file = METADATA_FILE
        output:
            exp_file_corrected = EXP_FILE_BATCH_CORRECTED
        container: R_CONTAINER
        params:
            script = os.path.join(SRC_DIR, "combat_batch_correction.R"), \
            batch_metadata_column = BATCH_METADATA_COLUMN
        shell:
            """
            Rscript {params.script} \
                --exp_file {input.exp_file} \
                --anno_file {input.metadata_file} \
                --batch_col {params.batch_metadata_column} \
                --out_file {output.exp_file_corrected}
            """

    rule pca_plot_batch_corrected:
        input:
            exp_file = EXP_FILE_BATCH_CORRECTED, \
            metadata_file = METADATA_FILE
        output:
            pca_plot = PCA_PLOT_BATCH_CORRECTED
        container: R_CONTAINER
        params:
            script = os.path.join(SRC_DIR, "plot_pca.R"), \
            color_by = config.get("pca_color_by") if config.get("pca_color_by") else "NULL", \
            shape_by = config.get("pca_shape_by") if config.get("pca_shape_by") else "NULL", \
            title = config.get("pca_title") + " (Batch Corrected)", \
            top_n = TOP_N, \
            n_probes = N_PROBES
        shell:
            """
            Rscript {params.script} \
                --exp_mat {input.exp_file} \
                --metadata {input.metadata_file} \
                --color_by {params.color_by} \
                --shape_by {params.shape_by} \
                --title "{params.title}" \
                --output_file {output.pca_plot} \
                --top_n {params.top_n} \
                --n_probes {params.n_probes}
            """

if AVERAGE_BY_TUMOUR:
    # rule rename_batch_corrected_file:
    #     """Changing the name of the batch corrected file to a temporary name before averaging so the normalisation rule works correctly
    #     regardless of whether averaging is performed or not."""
    #     input:
    #         exp_file = get_averaging_input()
    #     output:
    #         exp_file_rename = EXP_FILE_BATCH_CORRECTED.replace(".txt", "_preavg.txt")
    #     shell:
    #         """
    #         cp {input.exp_file} {output.exp_file_rename}
    #         """

    rule average_per_tumour:
        input:
            exp_file = get_averaging_input(), \
            meta_file = METADATA_FILE
        output:
            exp_file_final = EXP_FILE_AVG
        container: R_CONTAINER
        params:
            script = os.path.join(SRC_DIR, "average_per_tumour.R"), \
            tumour_col = TUMOUR_METADATA_COLUMN
        shell:
            """
            Rscript {params.script} \
                --exp_file {input.exp_file} \
                --meta_file {input.meta_file} \
                --tumour_col {params.tumour_col} \
                --out_file {output.exp_file_final}
            """

if MERGE_DATASETS:
    rule compile_datasets:
        input:
            datasets = expand(DATASETS_TO_COMPILE)
        output:
            exp_file_final = EXP_FILE
        container: R_CONTAINER
        params:
            script = os.path.join(SRC_DIR, "compile_datasets.R"), \
            datasets_str = ",".join(DATASETS_TO_COMPILE)
        shell:
            """
            Rscript {params.script} \
                --datasets {params.datasets_str} \
                --output_file {output.exp_file_final}
            """

    