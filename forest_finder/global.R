library(tidyverse)
library(markdown)
# library(rmarkdown)
# Shiny tools
library(shiny)
library(shinyWidgets)
library(shinycssloaders)
library(shinyjs)
library(htmltools)
#spatial tools
library(terra)
library(sf)
library(leaflet)
library(leaflet.extras)
library(leafem)

### READ IN DATA

# raster legend ----
legend <- read_rds("data/legend.RDS")

# county tree species list ----
spcs_list <- read_rds("data/spcs_list.RDS")

# raster files ----

# List all .tif files in the folder
raster_files <- list.files(
  "data/ca_trees",
  pattern = "\\.tif$",
  full.names = TRUE
)

# Create a named list of rasters
county_rasters <- setNames(
  lapply(raster_files, rast), # Load each raster as a terra object
  tools::file_path_sans_ext(basename(raster_files)) # Extract names without extensions
)

# california counties ----
counties_ca <- readRDS("data/counties_ca.RDS")
