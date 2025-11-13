#' @name extract_expression_matrix
#' @title Extract expression matrix from CEL files
#' @description This function reads CEL files and extracts the expression matrix using the affy package.
#' @param cel_files A character vector of file paths to the CEL files.
#' @param output_file A character string specifying the path to save the output expression matrix.
#' @param metadata A character string specifying the path to the metadata CSV file.
#' @param normalise A logical indicating whether to normalise the data (default is FALSE).
#' @param background A logical indicating whether to perform background correction (default is TRUE).
#' @return None. The function saves the expression matrix to the specified output file.

extract_expression_matrix <- function(cel_files, output_file, metadata, normalise=FALSE, background=TRUE) {
    files <- fread(cel_files, stringsAsFactors = FALSE)
    files <- as.vector(files[[1]])
    data <- justRMA(filenames = files, cdfname = "hta20_Hs_ENTREZG", background=background, normalize=normalise)
    exp <- exprs(data)
    
    # annotate expression matrix
    metadata <- fread(metadata, stringsAsFactors = FALSE)
    anno <- annotate_expression_matrix(exp, metadata)

    # save expression matrix
    fwrite(as.data.frame(anno), file = output_file, sep = "\t", row.names = TRUE)
}

annotate_expression_matrix <- function(expression_matrix, metadata) {

    # extract patient ID from column names
    file_patient_IDs <- colnames(expression_matrix)
    file_patient_IDs <- substr(file_patient_IDs, 1, 8)

    colnames(expression_matrix) <- file_patient_IDs

    # annotate genes
    mart <- useMart("ensembl", dataset = "hsapiens_gene_ensembl")
    annotations <- getBM(attributes = c("affy_hta_2_0", "ensembl_gene_id", "hgnc_symbol", "description"),
                         filters = "affy_hta_2_0",
                         values = rownames(expression_matrix),
                         mart = mart)
}

