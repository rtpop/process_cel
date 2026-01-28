##-----------------------------##
## List of R packages required ##
##-----------------------------##

options(repos = c(CRAN = "https://cran.r-project.org"))

## CRAN packages:
required_packages_cran <- c()

install.packages(
    required_packages_cran,
    dependencies = TRUE, verbose = TRUE)

## Bioconductor packages:
required_packages_bioconductor <- c(
    "affy",             # For processing Affymetrix microarray data
    "pd.hta.2.0",       # For processing Affymetrix microarray data
    "hta20cdf"         # For processing Affymetrix microarray data
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