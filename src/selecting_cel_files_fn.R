#' @name select_cel_files
#' @title Select CEL files based on metadata
#' @description This function selects CEL files from a specified directory based on metadata criteria.
#' @param raw_data_dir Directory containing raw CEL files.
#' @param metadata_file Path to the metadata CSV file.
#' @param file_selection_method Method for selecting files: "all", "multi_region", or "single_region".
#' @param normal Logical indicating whether to also include normal samples.
#' @param output_file Path to the output file where selected CEL

select_cel_files <- function(raw_data_dir, metadata_file, file_selection_method = "all", normal = TRUE, output_file) {
    # Load metadata
    metadata <- read.csv(metadata_file, stringsAsFactors = FALSE)
    
    # init cel_files
    cel_files <- data.frame(file_name = character(0), 
                            tumour_id = character(0),
                            stringsAsFactors = FALSE)

    if (file_selection_method == "all") {
        cel_files <- data.frame(file_name = metadata$HTA_sample_file_name, 
                                tumour_id = metadata$Tumor_ID,
                                stringsAsFactors = FALSE)
    } else if (file_selection_method == "multi_region") {
        cel_files <- data.frame(file_name = metadata$HTA_sample_file_name[which(metadata$Multiregion == TRUE)], 
                                tumour_id = metadata$Tumor_ID[which(metadata$Multiregion == TRUE)],
                                stringsAsFactors = FALSE)
    } else if (file_selection_method == "single_region") {
        cel_files <- data.frame(file_name = metadata$HTA_sample_file_name[which(metadata$Multiregion == FALSE)], 
                                tumour_id = metadata$Tumor_ID[which(metadata$Multiregion == FALSE)],
                                stringsAsFactors = FALSE)
    } else {
        stop("Invalid file selection method.")
    }

    if (normal) {
        normal_cel_files <- data.frame(file_name = metadata$HTA_sample_file_name[which(metadata$Tissue_type == "Normal_mucosa")], 
                                       tumour_id = metadata$Tumor_ID[which(metadata$Tissue_type == "Normal_mucosa")],
                                       stringsAsFactors = FALSE)
        cel_files <- unique(rbind(cel_files, normal_cel_files))
    }

    cel_files$file_name <- paste0(cel_files$file_name, ".CEL")
    
    # Write to output file
    write.table(cel_files, file = output_file, sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)
    }