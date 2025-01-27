test <- county_rasters[["Santa Barbara"]]

system.time({
t1 <- ifel(test %in% "Coast live oak", test, NA)
})

system.time({
t2 <- mask(test, test, 931, inverse = TRUE)
})

# new trial 

system.time({
specs <- filter(legend, label %in% "Coast live oak") |> 
  pull(value)

t_rast1 <- mask(county_rasters[["Santa Barbara"]], county_rasters[["Santa Barbara"]], specs, inverse = TRUE)

leaflet() |> 
  addTiles() |> 
  addRasterImage(t_rast1)
})

# original trial 

system.time({
t_rast2 <- ifel(!is.null(county_rasters[["Santa Barbara"]]) & (county_rasters[["Santa Barbara"]] %in% "Coast live oak"), county_rasters[["Santa Barbara"]], NA)

coltab(t_rast2) <- legend[,1:5]

leaflet() |> 
  addTiles() |> 
  addRasterImage(t_rast2)


})


microbenchmark(
  
  method1 = {
    # specs <- filter(legend, label %in% "Coast live oak") |> 
    #   pull(value)
    
    # t_rast1 <- mask(county_rasters[["Santa Barbara"]], county_rasters[["Santa Barbara"]], 931, inverse = TRUE)
    
    leaflet() |> 
      addTiles() |> 
      addRasterImage(t_rast2)
  },
  
  method2 = {
  # 
  # t_rast2 <- ifel(!is.null(county_rasters[["Santa Barbara"]]) & (county_rasters[["Santa Barbara"]] %in% "Coast live oak"), county_rasters[["Santa Barbara"]], NA)
  # 
  # coltab(t_rast2) <- legend[,1:5]
  # 
  leaflet() |>
    addTiles() |>
    addRasterImage(t_rast1)
  # 
  },
  
  times = 10
)



image <- image_read("myapp/www/images/forest.png")

pixelated_image <- image_scale(image, "50x50!")

pixelated_image2 <- image_scale(pixelated_image,"360x360!")

image_write(pixelated_image2, "myapp/www/images/forest_pix.png")





