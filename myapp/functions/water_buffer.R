### 3) FUNCTION: find rivers

# source https://data.cnra.ca.gov/dataset/california-streams/resource/ab639cda-e5de-4667-b70e-3c707b7c333d



find_rivers <- function(ca_streams, ca_cnties, cnty){
  
cnty_streams = st_intersection(ca_streams, filter(ca_cnties, NAME == cnty)) |> 
  # st_union() |> 
  st_transform(crs = 4326)
  
}


# test <- find_rivers(ca_streams = water_ca,
#             ca_cnties = counties_ca,
#             cnty = "Santa Barbara")
# 
# leaflet() |> 
#   addTiles() |> 
#   addPolylines(data = test2,
#                color = "blue",
#                weight = .4,)









