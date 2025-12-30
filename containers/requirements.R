##-----------------------------##
## List of R packages required ##
##-----------------------------##

## CRAN packages:
required_packages_cran <- c(
    "BiocManager",    # To install Bioconductor packages
    "dplyr",          # For data manipulation
    "data.table",     # For data manipulation with data.table
    "optparse",       # For reading command-line arguments
    "tidyr",          # For tidying data
    "ggplot2",        # For creating plots
    "ggrepel",        # For adding labels to ggplot2 plots
    "ggpubr",         # For ggplot2 publication-ready plots
    "magrittr",       # For pipe operator %<>%
    "pheatmap",       # For drawing heatmaps
    "RColorBrewer",   # For color palettes for heatmaps
    "remotes",        # For installing local or GitHub packages
    "sessioninfo",    # For session information
    "stringr"         # For string manipulation
    )

install.packages(
    required_packages_cran,
    dependencies = TRUE, verbose = TRUE)

## Bioconductor packages:
required_packages_bioconductor <- c(
    "affy",             # For processing Affymetrix microarray data
    "biomaRt",          # For accessing BioMart databases
    "ComBat",           # For batch effect correction
    "org.Hs.eg.db",     # For gene annotations
    "pd.hta.2.0",       # For processing Affymetrix microarray data
    "hta20cdf",         # For processing Affymetrix microarray data
    "pcaMethods",       # For PCA analysis
    #"pd.huex.1.0.st.v1", # For processing Affymetrix microarray data
    #"hta20probeset.db", # For processing Affymetrix microarray data
    #"hta20transcriptcluster.db", # For processing Affymetrix microarray data
    #"huex10stprobeset.db", # For processing Affymetrix microarray data
    #"huex10sttranscriptcluster.db", # For processing Affymetrix microarray data
    "rtracklayer",
    "liftOver",
    "makecdfenv"
)

BiocManager::install(
    required_packages_bioconductor)

## Install any local tarballs placed into /opt
local_tarballs <- list.files("/opt", pattern="\\.tar\\.gz$", full.names=TRUE)
if (length(local_tarballs) > 0) {
  if (!requireNamespace("remotes", quietly=TRUE)) {
    install.packages("remotes", repos="https://cloud.r-project.org")
  }
  remotes::install_local(local_tarballs, dependencies = TRUE)
}