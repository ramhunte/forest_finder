# writing rasters ----
# Create a directory to save the output rasters
output_dir <- "myapp/data/ca_trees"

# Loop through each county and crop the raster
for (i in 1:nrow(counties_ca)) {
  # Extract county polygon
  county <- counties_ca[i, ]
  
  # Crop the raster to the county polygon
  cropped_raster <- crop(tree_dat, county, mask = TRUE)
  
  # Get the county name from the 'NAME' column
  county_name <- county$NAME
  
  # Define the output file path with county name
  output_file <- file.path(output_dir, paste0(county_name, ".tif"))
  
  # Save the cropped raster as a .tif file
  writeRaster(cropped_raster, output_file, overwrite = TRUE)
}


