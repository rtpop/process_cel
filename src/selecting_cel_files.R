required_libraries <- c()

for (library in required_libraries) {
    suppressPackageStartupMessages(library(library, character.only = TRUE, quietly = TRUE))
}

## Options
options(stringsAsFactors = FALSE)

## --------------- ##
## Parse arguments ##
## --------------- ##

opt <- list(
    snakemake@input[["raw_data_dir"]],
    snakemake@input[["metadata_file"]],
    snakemake@params[["file_selection_method"]],
    snakemake@params[["array_type"]],
    snakemake@params[["tumour_metadata_column"]],
    snakemake@params[["normal_samples"]],
    snakemake@output[["output_file"]],
)

## Source functions
source("src/selecting_cel_files_fn.R")

select_cel_files(
    raw_data_dir = opt$raw_data_dir,
    metadata_file = opt$metadata_file,
    file_selection_method = opt$file_selection_method,
    output_file = opt$output_file,
    array_type = opt$array_type,
    tumour_metadata_column = opt$tumour_metadata_column,
    normal = opt$normal
)