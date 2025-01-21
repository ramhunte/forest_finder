make_map <- function(ca_cnties, cnty, ca_rast, species, ca_pub_land) {
  
  # 1) finding trees raster in each county 
  cnty_rast <- find_trees(ca_cnties, cnty, ca_rast, species)
  
  # 2) finding public land 
  cnty_pub_land <- find_pub_land(ca_pub_land, ca_cnties, cnty)
  
  # 4) make final map 
  map <- make_leaflet(cnty_pub_land, cnty_rast)
  
  return(map)
}