#' @name extract_expression_matrix
#' @title Extract expression matrix from CEL files
#' @description This function reads CEL files and extracts the expression matrix using the affy package.
#' @param cel_files A character vector of file paths to the CEL files.
#' @param output_file A character string specifying the path to save the output expression matrix.
#' @param metadata A character string specifying the path to the metadata CSV file.
#' @param normalise A logical indicating whether to normalise the data (default is FALSE).
#' @param background A logical indicating whether to perform background correction (default is TRUE).
#' @param array_type A character string specifying the type of array (default is "HTA-2_0").
#' @return None. The function saves the expression matrix to the specified output file.

extract_expression_matrix <- function(cel_files, output_file, raw_data_dir, normalise=FALSE, background=TRUE, array_type, anno_file = "annotation.txt") {
    files_metadata <- fread(cel_files, stringsAsFactors = FALSE)
    files <- as.vector(files_metadata[[1]])
    files <- file.path(raw_data_dir, files)
    data <- justRMA(filenames = files, cdfname = "hta20_Hs_ENTREZG", background=background, normalize=normalise)
    exp <- exprs(data)
    
    # annotate expression matrix
    anno <- annotate_expression_matrix(exp, files_metadata, anno_file)

    # save expression matrix
    fwrite(as.data.frame(anno), file = output_file, sep = "\t", row.names = TRUE)
}


#' @name annotate_expression_matrix
#' @title Annotate expression matrix with gene names and Ensembl IDs
#' @description This function annotates the expression matrix with gene names and Ensembl IDs using biomaRt.
#' @param expression_matrix A numeric matrix of expression values with probe IDs as row names and sample IDs as column names.
#' @param files_metadata A data frame containing metadata for the samples, including tumour IDs and CEL file names.
#' @param array_type A character string specifying the type of array (e.g., "HTA20" or "HUEX10").
#' @return A data frame with the annotated expression matrix, including gene names and Ensembl IDs.


annotate_expression_matrix <- function(expression_matrix, files_metadata, anno_file = "annotation.txt") {
    bm_filter <- "entrezgene_id"
    
    # rename columns to tumour ids
    colnames(expression_matrix) <- files_metadata$tumour_id[match(colnames(expression_matrix), files_metadata$file_name)]

    # remove tag from probe ids
    rownames(expression_matrix) <- gsub("_at$", "", rownames(expression_matrix))

    # annotate genes
    mart <- useMart("ensembl", dataset = "hsapiens_gene_ensembl")
    annotations <- getBM(attributes = c("entrezgene_id", "ensembl_gene_id", "hgnc_symbol"),
                         filters = bm_filter,
                         values = rownames(expression_matrix),
                         mart = mart)
    
    fwrite(annotations, file = anno_file, sep = "\t", row.names = FALSE)

    rownames(expression_matrix) <- as.character(annotations$hgnc_symbol[match(rownames(expression_matrix), annotations$entrezgene_id)])

    return(expression_matrix)
}

