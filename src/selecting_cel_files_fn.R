#' @name select_cel_files
#' @title Select CEL files based on metadata
#' @description This function selects CEL files from a specified directory based on metadata criteria.
#' @param raw_data_dir Directory containing raw CEL files.
#' @param metadata_file Path to the metadata CSV file.
#' @param file_selection_method Method for selecting files: "all", "multi_region", or "single_region".
#' @param array_type Type of array.
#' @param normal Logical indicating whether to also include normal samples.
#' @param output_file Path to the output file where selected CEL

select_cel_files <- function(raw_data_dir, metadata_file, tumour_metadata_column, file_selection_method = "all", array_type = "hta20", normal = TRUE, output_file) {
    # Load metadata
    metadata <- read.csv(metadata_file, stringsAsFactors = FALSE)
    
    array_type <- tolower(array_type)
    print(paste("Array type:", array_type))
    
    # select only files of the correct array type
    if (array_type == "hta20") {
        print("Getting HTA files")
        # Filter metadata first, then create cel_files
        filtered_metadata <- metadata[which(metadata$Array == "HTA"), ]
        # Then recreate cel_files based on file_selection_method using filtered_metadata
    } else if (array_type == "huex10") {
        print("Getting HUEX files")
        filtered_metadata <- metadata[which(metadata$Array == "HuEx"), ]
    } else {
        stop("Invalid array type.")
    }

    # init cel_files
    cel_files <- data.frame(file_name = character(0), 
                            tumour_id = character(0),
                            stringsAsFactors = FALSE)

    if (file_selection_method == "all") {
        cel_files <- data.frame(file_name = filtered_metadata$HTA_sample_file_name, 
                                tumour_id = filtered_metadata[[tumour_metadata_column]],
                                stringsAsFactors = FALSE)
    } else if (file_selection_method == "multi_region") {
        cel_files <- data.frame(file_name = filtered_metadata$HTA_sample_file_name[which(filtered_metadata$Multiregion == TRUE)], 
                                tumour_id = filtered_metadata[[tumour_metadata_column]][which(filtered_metadata$Multiregion == TRUE)],
                                stringsAsFactors = FALSE)
    } else if (file_selection_method == "single_region") {
        cel_files <- data.frame(file_name = filtered_metadata$HTA_sample_file_name[which(filtered_metadata$Multiregion == FALSE)], 
                                tumour_id = filtered_metadata[[tumour_metadata_column]][which(filtered_metadata$Multiregion == FALSE)],
                                stringsAsFactors = FALSE)
    } else {
        stop("Invalid file selection method.")
    }

    if (!normal) {
    keep_idx <- !grepl(
        "norm",
        filtered_metadata$Tissue[match(cel_files$file_name, filtered_metadata$HTA_sample_file_name)],
        ignore.case = TRUE
    )
    cel_files <- cel_files[keep_idx, ]
    }

    # Append .CEL extension
    cel_files$file_name <- paste0(cel_files$file_name, ".CEL")
    
    # Write to output file
    write.table(cel_files, file = output_file, sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)
    }