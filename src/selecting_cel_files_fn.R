select_cel_files <- function(raw_data_dir, metadata_file, file_selection_method = "all", output_file) {
    # Load metadata
    metadata <- read.csv(metadata_file, stringsAsFactors = FALSE)
    
    if (file_selection_method == "all") {
        cel_files <- paste0(metadata$HTA_sample_file_name, ".CEL")
    } else if (file_selection_method == "multi_region") {
        cel_files <- paste0(metadata$HTA_sample_file_name[which(metadata$Multiregion == TRUE)], ".CEL")
    } else if (file_selection_method == "single_region") {
        cel_files <- paste0(metadata$HTA_sample_file_name[which(metadata$Multiregion == FALSE)], ".CEL")
    } else {
        stop("Invalid file selection method.")
    }
    print(paste("Number of selected CEL files:", length(cel_files)))

    cel_file_paths <- file.path(raw_data_dir, cel_files)
    
    # Write to output file
    writeLines(cel_file_paths, con = output_file)
    }