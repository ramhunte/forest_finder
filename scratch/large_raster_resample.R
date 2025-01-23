raster_files <- list.files("myapp/data/ca_trees", pattern = "\\.tif$", full.names = TRUE)

# Get file information
file_info <- file.info(raster_files)

# Filter files that are larger than 4 MB (4 MB = 4 * 1024 * 1024 bytes)
large_rasters <- raster_files[file_info$size > (6.3 * 1024 * 1024)]

output_dir <- "myapp/data/ca_trees"

for (i in seq_along(large_rasters)) {
  
  # Step 1: Read the raster
  rast <- rast(large_rasters[[i]])  # Use [[i]] to correctly access the element
  
  # Step 2: Aggregate the raster from 30m to 60m resolution
  aggregated_rast <- aggregate(rast, fact = 2, fun = "modal")  # fact = 2 for doubling the cell size (30m to 60m)
  
  # Step 3: Write the aggregated raster back to the same filename
  writeRaster(aggregated_rast, filename = large_rasters[[i]], overwrite = TRUE)
}

