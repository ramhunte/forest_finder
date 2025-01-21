library(shiny)
library(shinyWidgets)
library(shinycssloaders)
library(shinyjs)
library(tidyverse)
library(terra)
library(sf)
library(leaflet)
library(leaflet.extras)
library(leafem)
library(htmltools)
library(tigris)


### READ IN DATA

# rasters ----
# List all .tif files in the folder
raster_files <- list.files("data/ca_trees", pattern = "\\.tif$", full.names = TRUE)

# Create a named list of rasters
county_rasters <- setNames(
  lapply(raster_files, rast),  # Load each raster as a terra object
  tools::file_path_sans_ext(basename(raster_files))  # Extract names without extensions
)


# 
# #tree raster data for california
# tree_dat <- rast(file.path(
#   "data/TreeMap2016_FLDTYPCD/CA_TreeMap2016_FLDTYPCD.tif"))

# california counties ----
counties_ca <- counties(state = "California") |> 
  # transforming crs
  st_transform(crs = 3857)

# california public land ----
# ca_land <- read_sf("data/California_Land_Ownership/California_Land_Ownership.shp")

# levels and colors ----
tree_levs <- read_rds("data/tree_levels.RDS")
tree_coltab <- read_rds("data/tree_colors_tab.RDS")




### SOURCE FUNCTIONS ----

# sourcing a list of all the files in the functions folder containing ".R"

invisible( # dont show results 
  lapply(list.files(path = "functions", 
                    pattern = "\\.R$", 
                    full.names = TRUE), 
         source)
)


