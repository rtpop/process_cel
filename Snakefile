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
CONFIG_PATH = "config_multi_region.yaml"
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
RAW_DATA_FILES = os.path.join(RAW_DATA_DIR, config["raw_data_files"])

EXP_FILE_UNNORMALISED = os.path.join(PROCESSED_DATA_DIR, config["exp_file_unnormalised"])
ANNO_FILE = os.path.join(PROCESSED_DATA_DIR, config["annotation_file"])
EXP_FILE_BATCH_CORRECTED = os.path.join(PROCESSED_DATA_DIR, config["exp_file_batch_corrected"])
EXP_FILE_FINAL = os.path.join(PROCESSED_DATA_DIR, config["exp_file_final"])
PCA_PLOT = EXP_FILE_UNNORMALISED.replace(".txt", "_PCA_plot_msi.pdf")
PCA_PLOT_BATCH_CORRECTED = EXP_FILE_BATCH_CORRECTED.replace(".txt", "_PCA_plot_msi.pdf")

## Params
FILE_SELECTION_METHOD = config["file_selection_method"]
NORMALISE = config["normalise"]
BACKGROUND_CORRECTION = config["background_correction"]
NORMALISATION_METHOD = config["normalization_method"]
BATCH_CORRECTION = config["batch_correction"]
BATCH_METADATA_COLUMN = config["batch_metadata_column"]
ARRAY_TYPE = config["array_type"]
AVERAGE_BY_TUMOUR = config["average_by_tumour"]

## helper functions ##
# I don't know if this is the best way to do it
def get_all_inputs():
    """Get all required input files based on configuration"""
    inputs = [
        RAW_DATA_FILES,
        EXP_FILE_UNNORMALISED,
        PCA_PLOT
    ]
    
    if BATCH_CORRECTION:
        inputs.extend([
            EXP_FILE_BATCH_CORRECTED,
            PCA_PLOT_BATCH_CORRECTED
        ])
    
    return inputs

## ----- ##
## Rules ##
## ----- ##

rule all:
    input:
        get_all_inputs()

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
        array_type = ARRAY_TYPE
    shell:
        """
        Rscript {params.script} \
            --raw_data_dir {input.raw_data_dir} \
            --metadata_file {input.metadata_file} \
            --file_selection_method {params.file_selection_method} \
            --output_file {output.raw_data_files} \
            --array_type {params.array_type}
        """

rule extract_expression_matrix:
    input:
        raw_data_dir = RAW_DATA_DIR, \
        raw_data_files = RAW_DATA_FILES, \
        metadata_file = METADATA_FILE
    output:
        exp_file = EXP_FILE_UNNORMALISED
    container: R_CONTAINER
    params:
        script = os.path.join(SRC_DIR, "extract_expression_matrix.R"), \
        normalise = NORMALISE, \
        background_correction = BACKGROUND_CORRECTION, \
        array_type = ARRAY_TYPE, \
        anno_file = ANNO_FILE
    shell:
        """
        Rscript {params.script} \
            --raw_data_dir {input.raw_data_dir} \
            --cel_files {input.raw_data_files} \
            --normalise {params.normalise} \
            --background {params.background_correction} \
            --array_type {params.array_type} \
            --anno_file {params.anno_file} \
            --output_file {output.exp_file}
        """

rule pca_plot:
    input:
        exp_file = EXP_FILE_UNNORMALISED, \
        metadata_file = METADATA_FILE
    output:
        pca_plot = PCA_PLOT
    container: R_CONTAINER
    params:
        script = os.path.join(SRC_DIR, "plot_pca.R"), \
        color_by = config["pca_color_by"] if config["pca_color_by"] else "NULL", \
        shape_by = config["pca_shape_by"] if config["pca_shape_by"] else "NULL", \
        title = config["pca_title"]
    shell:
        """
        Rscript {params.script} \
            --exp_mat {input.exp_file} \
            --metadata {input.metadata_file} \
            --color_by {params.color_by} \
            --shape_by {params.shape_by} \
            --title "{params.title}" \
            --output_file {output.pca_plot}
        """

if BATCH_CORRECTION:
    rule combat_batch_correction:
        input:
            exp_file = EXP_FILE_UNNORMALISED, \
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
            color_by = config["pca_color_by"] if config["pca_color_by"] else "NULL", \
            shape_by = config["pca_shape_by"] if config["pca_shape_by"] else "NULL", \
            title = config["pca_title"] + " (Batch Corrected)"
        shell:
            """
            Rscript {params.script} \
                --exp_mat {input.exp_file} \
                --metadata {input.metadata_file} \
                --color_by {params.color_by} \
                --shape_by {params.shape_by} \
                --title "{params.title}" \
                --output_file {output.pca_plot}
            """

# if AVERAGE_BY_TUMOUR:
#     # rule rename_batch_corrected_file:
#     #     """Changing the name of the batch corrected file to a temporary name before averaging so the normalisation rule works correctly
#     #     regardless of whether averaging is performed or not."""
#     #     input:
#     #         exp_file = get_averaging_input()
#     #     output:
#     #         exp_file_rename = EXP_FILE_BATCH_CORRECTED.replace(".txt", "_preavg.txt")
#     #     shell:
#     #         """
#     #         cp {input.exp_file} {output.exp_file_rename}
#     #         """

#     rule average_per_tumour:
#         input:
#             exp_file = get_averaging_input(), \
#             metadata_file = METADATA_FILE
#         output:
#             exp_file_final = EXP_FILE_FINAL
#         container: R_CONTAINER
#         params:
#             script = os.path.join(SRC_DIR, "average_per_tumour.R")
#         shell:
#             """
#             Rscript {params.script} \
#                 --exp_file {input.exp_file} \
#                 --metadata_file {input.metadata_file} \
#                 --output_file {output.exp_file_final}
#             """



# if NORMALISE:
#     rule normalise_final_expression:
#         input:
#             exp_file = EXP_FILE_BATCH_CORRECTED
#         output:
#             exp_file_final = EXP_FILE_FINAL
#         container: R_CONTAINER
#         params:
#             script = os.path.join(SRC_DIR, "normalise_final_expression.R"), \
#             normalization_method = NORMALISATION_METHOD
#         shell:
#             """
#             Rscript {params.script} \
#                 --exp_file {input.exp_file} \
#                 --normalization_method {params.normalization_method} \
#                 --output_file {output.exp_file_final}
#             """