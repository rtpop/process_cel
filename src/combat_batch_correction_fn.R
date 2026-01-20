#' @name batch_correction
#' @title Batch correction using ComBat
#' @description This function performs batch correction on expression data using the ComBat method from the sva package.
#' @param exp_data A data frame or matrix of expression data with genes as rows and samples as columns.
#' @param metadata A data frame containing sample metadata, including batch information.
#' @param batch_col A string specifying the column name in metadata that contains batch information.
#' @return A data frame or matrix of batch-corrected expression data.

batch_correction <- function(exp_data, metadata, batch_col) {

    # remove deduplication suffixes from sample names in exp_data
    colnames(exp_data) <- gsub("\\.\\d+$", "", colnames(exp_data))

    # Get the indices to reorder metadata to match exp_data column order
    sample_order <- match(colnames(exp_data), metadata[, "Tumor_ID"])

    # Extract batch information in the correct order
    batch_info <- metadata[sample_order, batch_col]
    
    # Perform ComBat batch correction
    print("Performing batch correction using ComBat...")
    corrected_data <- sva::ComBat(dat = as.matrix(exp_data), batch = batch_info, par.prior = TRUE, prior.plots = FALSE)
    
    return(as.data.frame(corrected_data))
}