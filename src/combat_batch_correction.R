required_libraries <- c("optparse",
                        "sva",
                        "data.table"
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
    make_option(c("-e", "--exp_file"), type = "character", help = "Path to the unnormalised expression data file (genes x samples)."),
    make_option(c("-a", "--anno_file"), type = "character", help = "Path to the annotation/metadata file."),
    make_option(c("-b", "--batch_col"), type = "character", help = "Column name in the annotation file that contains batch information."),
    make_option(c("-o", "--out_file"), type = "character", help = "Path to save the batch-corrected expression data file.")
)
opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

## Source functions
source("src/combat_batch_correction_fn.R")

# Read expression data
exp_data <- fread(opt$exp_file, data.table = FALSE)
rownames(exp_data) <- exp_data[, 1]
exp_data <- exp_data[, -1]

# Read annotation/metadata
metadata <- fread(opt$anno_file, data.table = FALSE)
rownames(metadata) <- metadata[, 1]
metadata <- metadata[, -1]

# Perform batch correction
corrected_exp_data <- batch_correction(exp_data, metadata, opt$batch_col)

# Save batch-corrected expression data
corrected_exp_data <- cbind(Gene = rownames(corrected_exp_data), corrected_exp_data)
fwrite(corrected_exp_data, file = opt$out_file, sep = "\t", row.names = FALSE, quote = FALSE)