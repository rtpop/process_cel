#' @name extract_expression_matrix
#' @title Extract expression matrix from CEL files
#' @description This function reads CEL files and extracts the expression matrix using the affy package.
#' @param cel_files A character vector of file paths to the CEL files.
#' @param output_file A character string specifying the path to save the output expression matrix.
#' @param metadata A character string specifying the path to the metadata CSV file.
#' @param normalise A logical indicating whether to normalise the data (default is FALSE).
#' @param background A logical indicating whether to perform background correction (default is TRUE).
#' @return None. The function saves the expression matrix to the specified output file.

extract_expression_matrix <- function(cel_files, output_file, raw_data_dir, normalise=FALSE, background=TRUE) {
    files_metadata <- fread(cel_files, stringsAsFactors = FALSE)
    files <- as.vector(files_metadata[[1]])
    files <- file.path(raw_data_dir, files)
    data <- justRMA(filenames = files, cdfname = "hta20_Hs_ENTREZG", background=background, normalize=normalise)
    exp <- exprs(data)
    
    # annotate expression matrix
    anno <- annotate_expression_matrix(exp, files_metadata)

    # save expression matrix
    fwrite(as.data.frame(anno), file = output_file, sep = "\t", row.names = TRUE)
}

annotate_expression_matrix <- function(expression_matrix, files_metadata) {

    # rename columns to tumour ids
    colnames(expression_matrix) <- files_metadata$tumour_id[match(colnames(expression_matrix), files_metadata$cel_file_name)]

    # remove tag from probe ids
    rownames(expression_matrix) <- gsub("_at$", "", rownames(expression_matrix))

    # annotate genes
    mart <- useMart("ensembl", dataset = "hsapiens_gene_ensembl")
    annotations <- getBM(attributes = c("affy_hta_2_0", "ensembl_gene_id", "hgnc_symbol"),
                         filters = "affy_hta_2_0",
                         values = rownames(expression_matrix),
                         mart = mart)

    annotated_exp <- as.data.frame(expression_matrix)
    annotated_exp$gene_name <- annotations$hgnc_symbol[match(rownames(expression_matrix), annotations$affy_hta_2_0)]
    annotated_exp$ensembl_id <- annotations$ensembl_gene_id[match(rownames(expression_matrix), annotations$affy_hta_2_0)]
}

