####################### HOW TO GET AND PROCESS DATA: MUST DO BEFORE RUNNING APP #####################

# - create another file called 'ca_trees' under 'forest_finder/data'
# - download the FLDTYPCD: Field Forest Code data from https://data.fs.usda.gov/geodata/rastergateway/treemap/index.php
# - move it in your 'forest_finder/data' folder and unzip the file

################ 1) making a CA raster from original data ###########################

og_rast <- rast(
  "forest_finder/data/TreeMap2016_FLDTYPCD/TreeMap2016_FLDTYPCD.tif"
)

# get California polygon
california <- tigiris::states() |>
  filter(NAME == "California") |>
  st_transform(crs(test)) |>
  vect()

# crop raster to CA
crop_ca <- crop(og_rast, california)

# mask it
crop_ca2 <- crop_ca |>
  mask(california)

# put in leaflet rs
rep_crop_ca <- crop_ca2 |>
  project("EPSG:3857", res = 30)

# write it to data
writeRaster(
  rep_crop_ca,
  paste0(output_dir, "forest_finder/data/CA_TreeMap2016_FLDTYPCD.tif"),
  overwrite = TRUE
)


################ 2) making individual CA county rasters from CA raster #######################

ca_rast <- rast(
  "/Users/rayhunter/Desktop/unused_data/TreeMap2016_FLDTYPCD/CA_TreeMap2016_FLDTYPCD.tif"
)

# "forest_finder/data/CA_TreeMap2016_FLDTYPCD.tif")

# get county polygons
counts <- counties(state = "California") |>
  # transforming crs
  st_transform(crs = 3857)

# Loop through each county and crop the raster
for (i in 1:nrow(counts)) {
  # Extract county polygon
  county <- counts[i, ]

  # Crop the raster to the county polygon
  cropped_raster <- crop(ca_rast, county)

  # mask it
  cropped_raster <- cropped_raster |>
    mask(county)

  # Get the county name from the 'NAME' column
  county_name <- county$NAME

  # Create a directory to save the output rasters
  output_dir <- "forest_finder/data/240x240"

  # Define the output file path with county name
  output_file <- file.path(output_dir, paste0(county_name, ".tif"))

  # Save the cropped raster as a .tif file
  writeRaster(cropped_raster, output_file, overwrite = TRUE)
}

################### 3) reasampling resolution of rasters #######################################

# List all .tif files in the folder
raster_files <- list.files(
  "forest_finder/data/240x240", # 90x90 resolution files
  pattern = "\\.tif$",
  full.names = TRUE
)

# Create a named list of rasters
county_rasters <- setNames(
  lapply(raster_files, rast), # Load each raster as a terra object
  tools::file_path_sans_ext(basename(raster_files)) # Extract names without extensions
)

################ 3a. Resample resolution to 60x60m resolution for all counties except Siskiyou

for (i in seq_along(county_rasters)) {
  # if (names(county_rasters[i] != "Siskiyou")) {
  # change their resolutions to 240x240
  # Aggregate the raster from 30m to 90m resolution
  aggregated_rast <- aggregate(county_rasters[[i]], fact = 8, fun = "modal") # fact = 2 for doubling the cell size (30m to 60m)

  # Write the aggregated raster back to the same filename
  writeRaster(
    aggregated_rast,
    filename = sources(county_rasters[[i]]),
    overwrite = TRUE
  )
  # }
}

# ################ 3b. Resample resolution to 80x80m resolution for Siskiyou
#
# # read in Siskiyou
# rast_sisk <- rast("data/ca_trees/Siskiyou.tif")
#
# # make a resample to 80x80m template
# resampled_raster_temp <- rast(
#   extent = ext(rast_sisk), # Same spatial extent
#   resolution = c(80, 80), # New resolution (65x65 meters)
#   crs = crs(rast_sisk) # Same coordinate reference system
# )
#
# # resampling (using instead of aggregate b/c aggregate only lets you resample
# # by a factor of a whole number e.g 1 (30m), 2 (60m), 3(90m) but we want 80m )
# resampled_raster <- resample(rast_sisk, resampled_raster_temp, method = "near")
#
# # remove excess rows/cols with no value
# resampled_raster_trim <- trim(resampled_raster)
#
# # writing raster to data
# writeRaster(
#   resampled_raster_trim,
#   filename = "forest_finder/data/ca_trees/Siskiyou.tif",
#   overwrite = TRUE
# )
