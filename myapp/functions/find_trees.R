### 1) FUNCTION: find trees

find_trees <- function(cnty, ca_rast, species){
  
  # cropping trees to counties of interest
  crop_rast = ca_rast |> 
    crop(
      filter(counties_ca, NAME %in% cnty), 
      mask = TRUE)  
  
 
  if(species != "All"){
  
    # reclassifying to select species
  rc_rast <- ifel(crop_rast %in% species, crop_rast, NA)
  
  # reassigning levels to raster
  levels(rc_rast) <- data.frame(levels(ca_rast)) |> 
    filter(Label %in% species)
  
  # reassigning color table to raster
  coltab(rc_rast) <- data.frame(coltab(ca_rast)) 
  
  }
  
  else {
    rc_rast <- crop_rast
  }
  
  return(rc_rast)
}
