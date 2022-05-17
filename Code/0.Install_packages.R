
## Install packages required to the NextGen ENM/SDM 

packages <- c("raster", "sp", "rgeos", "rworldmap", 
              "corrplot", "dismo", "rgdal", "maptools", 
              "rgbif", "spThin", "corrplot", "sdmvspecies", "mmap") 

# Install packages not yet installed
installed_packages <- packages %in% rownames(installed.packages())

if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages], dependencies = TRUE)
}

# Install the package from source
remotes::install_github("ropensci/scrubr")
remotes::install_git("https://gitup.uni-potsdam.de/macroecology/mecofun.git")

install.packages("sdm", dependencies = TRUE)

## Install additional packages that allow {sdm} to work with no issues.
sdm::installAll()