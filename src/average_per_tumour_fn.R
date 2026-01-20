#' @name average_per_tumour
#' @title Average Expression Data Per Tumour/Sample Type
#' @description this function averages expression data for each tumour/sample type based on metadata.
#' @param exp_file Path to the expression data file (genes x samples).
#' @param meta_file Path to the metadata/annotation file.
#' @param tumour_col Column name in the metadata file that contains tumour/sample type information.
#' @param out_file Path to save the averaged expression data file.

average_per_tumour <- function(exp_file, meta_file, tumour_col, out_file) {
    # Read expression data
    exp_data <- fread(exp_file, data.table = FALSE, check.names = FALSE)
    rownames(exp_data) <- exp_data[, 1]
    exp_data <- exp_data[, -1]
    colnames(exp_data) <- gsub("\\.\\d+$", "", colnames(exp_data))

    # Read metadata/annotation
    metadata <- fread(meta_file, data.table = FALSE)
    
    # Average expression data per tumour/sample type
    
    # transpose data frame for splitting
    exp_matrix <- t(as.matrix(exp_data))
    exp_split  <- split.data.frame(exp_matrix, rownames(exp_matrix))

    averaged_exp_list <- lapply(exp_split, function(x) colMeans(x, na.rm = TRUE))
    averaged_exp_data <- do.call(cbind, averaged_exp_list)
    rownames(averaged_exp_data) <- rownames(exp_data)

    # Save averaged expression data
    fwrite(averaged_exp_data, file = out_file, sep = "\t", row.names = TRUE, quote = FALSE)
}