###################### making a CA raster from OG data ######################
og_rast <-  rast("/myapp/data/TreeMap2016_FLDTYPCD/TreeMap2016_FLDTYPCD.tif")

# get california polygon
california <- states() |> 
  filter(NAME == "California") |> 
  st_transform(crs(test)) |> 
  vect()

# crop raster to CA
crop_ca <- crop(test, california)

# mask it
crop_ca2 <- crop_ca |> 
  mask(california)

# put in leaflet rs
rep_crop_ca <- crop_ca2 |> 
  project("EPSG:3857", res = 30)


# Create a directory to save the output rasters
output_dir <- "myapp/data/ca_trees"

# write it to data
writeRaster(rep_crop_ca, paste0(output_dir, "/CA_TreeMap2016_FLDTYPCD.tif"), overwrite = TRUE)


###################### making a county rasters from CA raster ######################

ca_rast <- rast("myapp/data/unused_data/TreeMap2016_FLDTYPCD/CA_TreeMap2016_FLDTYPCD.tif")

counts <- counties_ca |> 
  filter(NAME %in% c("Siskiyou")) # select county to resample

# Loop through each county and crop the raster
for (i in 1:nrow(counts)) {
  # Extract county polygon
  county <- counts[i, ]
  
  # Crop the raster to the county polygon
  cropped_raster <- crop(test, county)
  
  cropped_raster <- cropped_raster |> 
    mask(county)
  
  # Get the county name from the 'NAME' column
  county_name <- county$NAME
  
  # Define the output file path with county name
  output_file <- file.path(output_dir, paste0(county_name, ".tif"))
  
  # Save the cropped raster as a .tif file
  writeRaster(cropped_raster, output_file, overwrite = TRUE)
}















