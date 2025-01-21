### 2) FUNCTION: find public land

# making a function to find public land by county

find_pub_land <- function(ca_pub_land, ca_cnties, cnty){
  
  cnty_pub_land <- # start with public land 
    st_intersection(ca_pub_land, filter(ca_cnties, NAME == cnty)) |> 
    st_transform(crs = 4326)
  
  return(cnty_pub_land)
}