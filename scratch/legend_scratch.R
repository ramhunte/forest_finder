cnt_test <- county_rasters[[1]]


levels(cnt_test)[[1]]$value <- factor(levels(cnt_test)[[1]]$value, levels = color_table$value)  # Specify your order here


color_table <- coltab(cnt_test) |> 
  as.data.frame() |> 
  mutate(hex = rgb(red, green, blue, 
                   alpha, maxColorValue = 255)) |> 
  left_join(tree_levs, by = c("value" = "Value")) |>
  # mutate(value = as.factor(value)) |> 
  arrange(Label) |> 
  janitor::clean_names() |> 
  arrange(value)

write_rds(color_table, "myapp/data/legend.RDS")



factor_values <- as.factor(color_table$value)
levels(factor_values) <- color_table$Label

pal <- colorFactor(palette = color_table$hex,
                         domain = factor_values)

# Custom labFormat function to use factor levels
lab_format_custom_factor <- function(levels) {
  return(levels)  # Simply return the factor levels as labels
}


factorPalRev <- colorFactor(color_table$hex,
                            domain = color_table$Label,
                            ordered = TRUE)

leaflet() |> 
  addTiles() |> 
  # addRasterImage(cnt_test, colors = pal) |> 
  addLegend(pal = factorPalRev, 
                  values = factor(color_table$Label, 
                                   levels = color_table$Label), 
                  position = 'topright')


levels(cnt_test)


