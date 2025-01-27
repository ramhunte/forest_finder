# cropping/masking raster to CA ----
test <-  rast("/Users/rayhunter/Documents/coding/forest_finder/myapp/data/TreeMap2016_FLDTYPCD/TreeMap2016_FLDTYPCD.tif")

crs(test) 

california <- states() |> 
  filter(NAME == "California") |> 
  st_transform(crs(test)) |> 
  vect()

crop_ca <- crop(test, california)

crop_ca2 <- crop_ca |> 
  mask(california)

summary(crop_ca)

rep_crop_ca <- crop_ca2 |> 
  project("EPSG:3857", res = 30)


writeRaster(rep_crop_ca, "myapp/data/ca_trees/CA_TreeMap2016_FLDTYPCD.tif", overwrite = TRUE)




# writing county rasters ----

# Create a directory to save the output rasters
output_dir <- "myapp/data/ca_trees"

test <- rast("/Users/rayhunter/Documents/coding/forest_finder/myapp/data/TreeMap2016_FLDTYPCD/CA_TreeMap2016_FLDTYPCD.tif")

counts <- counties_ca |> 
  filter(NAME %in% c("Santa Cruz"))
# filter(NAME %in% c("Sierra", "San Diego", "Napa", "Monterey", "Mono", "Merced", "Los Angeles", "Kings", "Kern", "Imperial", "Glenn", "Calaveras", "Riverside", "Tuolumne", "Tulare", "Fresno", "Humboldt", "Inyo", "Lassen", "Medocino", "Modoc", "Plumas", "San Bernardino", "Shasta", "Siskiyou", "Solano", "Trinity"))

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














