required_libraries <- c("optparse",
                        "data.table"
                        )

for (library in required_libraries) {
    suppressPackageStartupMessages(library(library, character.only = TRUE, quietly = TRUE)))
}

## Options
options(stringsAsFactors = FALSE)

## --------------- ##
## Parse arguments ##
## --------------- ##
option_list <- list(
    make_option(c("-e", "--exp_file"), type = "character", help = "Path to the expression data file (genes x samples)."),
    make_option(c("-m", "--meta_file"), type = "character", help = "Path to the metadata/annotation file."),
    make_option(c("-t", "--tumour_col"), type = "character", help = "Column name in the metadata file that contains tumour/sample type information."),
    make_option(c("-o", "--out_file"), type = "character", help = "Path to save the averaged expression data file.")
)
opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

## Source functions
source("src/average_per_tumour_fn.R")

# Perform averaging per tumour/sample type
average_per_tumour(opt$exp_file, opt$meta_file, opt$tumour_col, opt$out_file)