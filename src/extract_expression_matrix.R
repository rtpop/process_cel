required_libraries <- c("optparse",
                        "biomaRt",
                        "data.table", 
                        "hta20hsentrezgcdf",
                        "huex10sthsentrezgcdf", 
                        "affy"
                        )

for (library in required_libraries) {
    suppressPackageStartupMessages(library(library, character.only = TRUE, quietly = TRUE))
}

## Options
options(stringsAsFactors = FALSE)

## --------------- ##
## Parse arguments ##
## --------------- ##

option_list <- list(
    make_option(c("-c", "--cel_files"), type="character", help="Path to text file with list of CEL files to process"),
    make_option(c("-r", "--raw_data_dir"), type="character", help="Path to raw data directory"),
    make_option(c("-o", "--output_file"), type="character", help="Path to save output expression matrix"),
    make_option(c("-n", "--normalise"), type="logical", default=FALSE, help="Whether to normalise the data [default %default]"),
    make_option(c("-a", "--array_type"), type="character", help="Type of array (e.g., hta20, huex10)"),
    make_option(c("-f", "--anno_file"), type="character", default="annotation.txt", help="Path to save annotation file [default %default]"),
    make_option(c("-b", "--background"), type="logical", default=TRUE, help="Whether to perform background correction [default %default]")
)

opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)

## Source functions
source("src/extract_expression_matrix_fn.R")

extract_expression_matrix(cel_files = opt$cel_files,
                           output_file = opt$output_file,
                           raw_data_dir = opt$raw_data_dir,
                           normalise = opt$normalise,
                           background = opt$background,
                           array_type = opt$array_type,
                           anno_file = opt$anno_file)