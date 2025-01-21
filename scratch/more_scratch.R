
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

t2 <-  rast("/Users/rayhunter/Documents/coding/forest_finder/myapp/data/ca_trees/CA_TreeMap2016_FLDTYPCD.tif")




t1 <- rast('/Users/rayhunter/Documents/coding/forest_finder/myapp/data/ca_trees/Santa Barbara.tif')













