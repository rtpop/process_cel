required_libraries <- c("optparse",
                        "data.table",
                        "ggplot2",
                        "pcaMethods")

for (library in required_libraries) {
    suppressPackageStartupMessages(library(library, character.only = TRUE, quietly = TRUE))
}

## Options
options(stringsAsFactors = FALSE)   

## --------------- ##
## Parse arguments ##
## --------------- ##

option_list <- list(
    make_option(c("-e", "--exp_mat"), type="character", help="Path to expression matrix file"),
    make_option(c("-m", "--metadata"), type="character", help="Path to sample metadata file"),
    make_option(c("-c", "--color_by"), type="character", default=NULL, help="Column name in metadata to color points by [default %default]"),
    make_option(c("-s", "--shape_by"), type="character", default=NULL, help="Column name in metadata to shape points by [default %default]"),
    make_option(c("-t", "--title"), type="character", default="PCA Plot", help="Title of the plot [default %default]"),
    make_option(c("-o", "--output_file"), type="character", help="Path to save the PCA plot")
)

opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)

## Source functions
source("src/plot_pca_fn.R")

# Read expression matrix and metadata
exp_mat <- fread(opt$exp_mat, data.table = FALSE, header = TRUE)
rownames(exp_mat) <- exp_mat[,1]
exp_mat <- as.matrix(exp_mat[,-1])
metadata <- fread(opt$metadata, data.table = FALSE, header = TRUE)

# Plot PCA
pca_plot <- plot_pca(exp_mat = exp_mat,
                     metadata = metadata,
                     color_by = opt$color_by,
                     shape_by = opt$shape_by,
                     title = opt$title)

# Save the plot
ggsave(opt$output_file, plot = pca_plot)