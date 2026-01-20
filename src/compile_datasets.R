required_libraries <- c("data.table",
                        "optparse",
                        "stringr")

suppressPackageStartupMessages({
    lapply(required_libraries, library, character.only = TRUE)
})

## Options
options(stringsAsFactors = FALSE)

## --------------- ##
## Parse arguments ##
## --------------- ##
option_list <- list(
    make_option(c("-d", "--datasets"), type = "character", action = "store", help = "Comma-separated list of file paths to the expression datasets to compile."),
    make_option(c("-o", "--output_file"), type = "character", help = "Path to save the compiled expression matrix.")
)
opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

# process datasets argument
datasets <- strsplit(opt$datasets, split = ",")[[1]]

## Source functions
source("src/compile_datasets_fn.R")

# compile datasets
compiled_data <- compile_datasets(datasets, opt$output_file)