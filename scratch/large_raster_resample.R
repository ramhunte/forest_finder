raster_files <- list.files("myapp/data/ca_trees", pattern = "\\.tif$", full.names = TRUE)

output_dir <- "myapp/data/ca_trees"

# Get file information
file_info <- file.info(raster_files)

# Filter files that are larger than 4 MB (4 MB = 4 * 1024 * 1024 bytes)
large_rasters <- raster_files[file_info$size > (6.3 * 1024 * 1024)]

###################################
rasters30 <- list() 

for(i in seq_along(county_rasters)) {
  
  raster <- county_rasters[[i]]
  
  if(res(raster)[1] == 30)
   {
    rasters30[[i]] <- raster
  }
}

rasters30 <- Filter(Negate(is.null), rasters30)


##################################

for (i in seq_along(rasters30)) {
  
  # Step 1: Read the raster
  # rast <- rasters30[[i]]  # Use [[i]] to correctly access the element
  
  # Step 2: Aggregate the raster from 30m to 60m resolution
  aggregated_rast <- aggregate(rasters30[[i]], fact = 2, fun = "modal")  # fact = 2 for doubling the cell size (30m to 60m)
  
  # Step 3: Write the aggregated raster back to the same filename
  writeRaster(aggregated_rast, filename = sources(rasters30[[i]]), overwrite = TRUE)
}


for (i in seq_along(county_rasters)) {
  
  # Step 1: Read the raster
  # rast <- rasters30[[i]]  # Use [[i]] to correctly access the element
  source <- sources(county_rasters[[i]])
  
  # Step 2: Aggregate the raster from 30m to 60m resolution
  trimmed_rast <- trim(county_rasters[[i]])  # fact = 2 for doubling the cell size (30m to 60m)
  
  # Step 3: Write the aggregated raster back to the same filename
  writeRaster(trimmed_rast, filename = source, overwrite = TRUE)
}



########### resampling Siskiyou to 80mx80m resolution (all others are 60)

rast_sisk <- rast("/Users/rayhunter/Documents/coding/forest_finder/myapp/data/ca_trees/Siskiyou.tif")

resampled_raster_temp <- rast(
  extent = ext(rast_sisk),   # Same spatial extent
  resolution = c(80, 80),          # New resolution (65x65 meters)
  crs = crs(rast_sisk)       # Same coordinate reference system
)

resampled_raster <- resample(rast_sisk, resampled_raster_temp, method = "near")

resampled_raster_trim <- trim(resampled_raster)

writeRaster(resampled_raster_trim, filename = "/Users/rayhunter/Documents/coding/forest_finder/myapp/data/ca_trees/Siskiyou.tif", overwrite = TRUE)

