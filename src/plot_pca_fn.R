#' @name plot_pca
#' @title Plot PCA
#' @description This function plots a PCA of the expression data.
#' @param exp_mat Expression matrix (genes x samples).
#' @param metadata Sample metadata data frame.
#' @param color_by Column name in metadata to color points by.
#' @param shape_by Column name in metadata to shape points by.
#' @param title Title of the plot.
#' 

plot_pca <- function(exp_mat, metadata, color_by = NULL, shape_by = NULL, title = "PCA Plot") {
  # Perform PCA
  pca_res <- pcaMethods::pca(t(exp_mat), scale. = TRUE)
  pca_df <- as.data.frame(pca_res@scores[, 1:2])
  pca_df$Sample <- rownames(pca_df)
  colnames(pca_df)[1:2] <- c("PC1", "PC2")
  
  # Merge with metadata
  pca_df <- merge(pca_df, metadata, by.x = "Sample", by.y = "Tumor_ID")

    # Convert color variable to factor for discrete coloring
  if (!is.null(color_by) && color_by != "NULL" && color_by %in% colnames(pca_df)) {
    pca_df[[color_by]] <- as.factor(pca_df[[color_by]])
  }
  
  # Create ggplot
  # Create base aesthetics
  base_aes <- aes(x = PC1, y = PC2)

  # Add color if specified
  if (!is.null(color_by) && color_by != "NULL") {
  base_aes$colour <- as.name(color_by)
  }

# Add shape if specified  
if (!is.null(shape_by) && shape_by != "NULL") {
  base_aes$shape <- as.name(shape_by)
}

# Create ggplot
p <- ggplot(pca_df, base_aes) +
  geom_point(size = 3) +
  labs(title = title, x = "PC1", y = "PC2") +
  theme_minimal() +
  theme(panel.background = element_rect(fill = "white"))
  
  return(p)
}