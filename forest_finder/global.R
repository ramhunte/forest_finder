library(tidyverse)
# Shiny tools 
library(shiny)
library(shinyWidgets)
library(shinycssloaders)
library(shinyjs)
library(htmltools)
#spatial tools
library(terra)
library(sf)
library(tigris)
library(leaflet)
library(leaflet.extras)
library(leafem)

### READ IN DATA

# rasters ----
# List all .tif files in the folder
raster_files <- list.files("data/ca_trees", pattern = "\\.tif$", full.names = TRUE)

# Create a named list of rasters
county_rasters <- setNames(
  lapply(raster_files, rast),  # Load each raster as a terra object
  tools::file_path_sans_ext(basename(raster_files))  # Extract names without extensions
)

# california counties ----
counties_ca <- counties(state = "California") |> 
  # transforming crs
  st_transform(crs = 3857)

# # california public land ----
# ca_land <- read_sf("data/unused_data/California_Land_Ownership/California_Land_Ownership.shp")

# raster legend ----
legend <- read_rds("data/legend.RDS")

