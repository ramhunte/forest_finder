################# getting information of files ######################

# list rasters in folder ca_trees
raster_files <- list.files("myapp/data/ca_trees", pattern = "\\.tif$", full.names = TRUE)

# Get file information
file_info <- file.info(raster_files)

# Filter files that are larger than 4 MB (4 MB = 4 * 1024 * 1024 bytes)
large_rasters <- raster_files[file_info$size > (6.3 * 1024 * 1024)]

# create output directory
output_dir <- "myapp/data/ca_trees"

################   resampling    ###################

# make a list of rasters with resolutions of 30x30
rasters30 <- list() 

for(i in seq_along(county_rasters)) {
  
  raster <- county_rasters[[i]]
  
  if(res(raster)[1] == 30)
   {
    rasters30[[i]] <- raster
  }
}

rasters30 <- Filter(Negate(is.null), rasters30) # remove nulls


for (i in seq_along(rasters30)) {
  
  # change their resolutions to 60x60
  # Step 1: Aggregate the raster from 30m to 60m resolution
  aggregated_rast <- aggregate(rasters30[[i]], fact = 2, fun = "modal")  # fact = 2 for doubling the cell size (30m to 60m)
  
  # Step 2: Write the aggregated raster back to the same filename
  writeRaster(aggregated_rast, filename = sources(rasters30[[i]]), overwrite = TRUE)
}

########### resampling Siskiyou to 80mx80m  resolution (cant use aggregate for 80x80, all others are 60)

rast_sisk <- rast("/Users/rayhunter/Documents/coding/forest_finder/myapp/data/ca_trees/Siskiyou.tif")

resampled_raster_temp <- rast(
  extent = ext(rast_sisk),   # Same spatial extent
  resolution = c(80, 80),          # New resolution (65x65 meters)
  crs = crs(rast_sisk)       # Same coordinate reference system
)

# resampling (using instead of aggregate b/c aggregate only lets you resample 
# by a factor of a whole number e.g 1 (30m), 2 (60m), 3(90m) but we want 80m )
resampled_raster <- resample(rast_sisk, resampled_raster_temp, method = "near")

# remove excess rows/cols with no value 
resampled_raster_trim <- trim(resampled_raster)

# writing raster to data
writeRaster(resampled_raster_trim, filename = "/Users/rayhunter/Documents/coding/forest_finder/myapp/data/ca_trees/Siskiyou.tif", overwrite = TRUE)

