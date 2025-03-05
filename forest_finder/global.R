library(tidyverse)
library(markdown)
library(rmarkdown)
library(aws.s3)
# Shiny tools
library(shiny)
library(shinyWidgets)
library(shinycssloaders)
library(shinyjs)
library(htmltools)
#spatial tools
library(terra)
library(stars)
library(sf)
library(tigris)
library(leaflet)
library(leaflet.extras)
library(leafem)

### READ IN DATA

# raster legend ----
legend <- read_rds("data/legend.RDS")

#################

# List all files in the bucket
s3_files <- data.table::rbindlist(get_bucket(
  bucket = "s3://forest-finder-data/"
)) |>
  filter(str_detect(Key, "\\.tif$")) |>
  mutate(Key = str_remove(Key, "\\.tif$"))

# Initialize an empty list to store raster objects
county_rasters <- list()

# Loop through each .tif file, read it, and store it in the list with the same name as the file key
for (file in s3_files$Key) {
  # Create a temporary file to download the .tif file
  tempfile <- tempfile(fileext = ".tif")

  # Download the file from S3
  save_object(
    object = paste0("s3://forest-finder-data/", file, ".tif"),
    file = tempfile
  )

  # Read the .tif file as a raster object
  raster_data <- terra::rast(tempfile)

  # assigning levels
  levels(raster_data) <- legend[, c(1, 7)]

  # Store the raster data in the list with the file name as the key
  county_rasters[[file]] <- raster_data
}

rm(raster_data)
################

# rasters ----
# List all .tif files in the folder
# raster_files <- list.files(
#   "forest_finder/data/ca_trees",
#   pattern = "\\.tif$",
#   full.names = TRUE
# )
#
# # Create a named list of rasters
# county_rasters <- setNames(
#   lapply(raster_files, rast), # Load each raster as a terra object
#   tools::file_path_sans_ext(basename(raster_files)) # Extract names without extensions
# )

# california counties ----
counties_ca <- counties(state = "California") |>
  # transforming crs
  st_transform(crs = 4326)

# counties_ca <- tigris::counties(state = "California") |>
#   pull(NAME) |>
#   sort()
