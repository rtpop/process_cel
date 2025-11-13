required_libraries <- c("optparse")

for (library in required_libraries) {
    suppressPackageStartupMessages(library(library, character.only = TRUE, quietly = TRUE))
}

## Options
options(stringsAsFactors = FALSE)

## --------------- ##
## Parse arguments ##
## --------------- ##

option_list <- list(
    make_option(c("--raw_data_dir"), type = "character", default = "data/raw",
                help = "Directory containing raw data files"),
    make_option(c("--metadata_file"), type = "character", default = "metadata.csv",
                help = "Metadata file"),
    make_option(c("--file_selection_method"), type = "character", default = "all",
                help = "File selection method: all, multi_region, single_region"),
    make_option(c("--output_file"), type = "character", default = "selected_files.txt",
                help = "Output file for selected CEL files")
)

opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

## Source functions
source("src/selecting_cel_files_fn.R")

select_cel_files(
    raw_data_dir = opt$raw_data_dir,
    metadata_file = opt$metadata_file,
    file_selection_method = opt$file_selection_method,
    output_file = opt$output_file
)