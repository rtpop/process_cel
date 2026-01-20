#' @name compile_datasets
#' @description Compile multiple expression datasets into a single expression matrix.
#' @param datasets A character vector of file paths to the expression datasets to compile.
#' @param output_file A character string specifying the file path to save the compiled expression matrix

compile_datasets <- function(datasets, output_file) {
    # Initialize an empty list to store data tables
    data_list <- list()

    # Loop through each dataset and read it into a data table
    for (dataset in datasets) {
        dt <- fread(dataset, data.table = FALSE)
        data_list[[dataset]] <- dt
    }

    # filter all datasets to the same genes (intersection)
    common_genes <- Reduce(intersect, lapply(data_list, function(x) x[, 1]))
    data_list <- lapply(data_list, function(x) x[x[, 1] %in% common_genes, ])
    
    # Combine all datasets by column-binding them
    compiled_data <- cbind(data_list[[1]][, 1, drop = FALSE], do.call(cbind, lapply(data_list, function(x) x[, -1])))
    colnames(compiled_data) <- str_sub(colnames(compiled_data), -8)

    # Write the compiled data to the output file
    fwrite(compiled_data, file = output_file, sep = "\t", na = "NA")

}