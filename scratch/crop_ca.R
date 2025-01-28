tigris::states(California
               )
states <- states(cb = TRUE) 
 
ca <- states |>  
  filter(NAME == "California") |> 
  st_transform(3857)

ca_broken <- st_cast(ca, "POLYGON") |> 
  mutate(ID = 1:13)

leaflet(ca_broken[13,]) %>%
  addTiles() %>%
  addPolygons(fillColor = "white",
              color = "black",
              weight = 0.5) 


test <- county_rasters[["Santa Barbara"]]

test2 <- mask(test, ca)


leaflet() |> addTiles() |> addRasterImage(test2)



