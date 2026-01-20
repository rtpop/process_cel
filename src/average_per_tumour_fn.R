#' @name average_per_tumour
#' @title Average Expression Data Per Tumour/Sample Type
#' @description this function averages expression data for each tumour/sample type based on metadata.
#' @param exp_file Path to the expression data file (genes x samples).
#' @param meta_file Path to the metadata/annotation file.
#' @param tumour_col Column name in the metadata file that contains tumour/sample type information.
#' @param out_file Path to save the averaged expression data file.

average_per_tumour <- function(exp_file, meta_file, tumour_col, out_file) {
    # Read expression data
    exp_data <- fread(exp_file, data.table = FALSE)
    rownames(exp_data) <- exp_data[, 1]
    exp_data <- exp_data[, -1]
    
    # Read metadata/annotation
    metadata <- fread(meta_file, data.table = FALSE)
    
    # Average expression data per tumour/sample type
    exp_split  <- split(exp_data, metadata[[tumour_col]])
    averaged_exp_data <- sapply(exp_split, function(x) rowMeans(x, na.rm = TRUE))
    
    # Save averaged expression data
    averaged_exp_data <- cbind(Gene = rownames(averaged_exp_data), averaged_exp_data)
    fwrite(averaged_exp_data, file = out_file, sep = "\t", row.names = FALSE, quote = FALSE)
}