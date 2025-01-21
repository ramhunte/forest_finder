### FUNCTION: make map function

make_leaflet <- function(cnty_pub_land, cnty_rast) {

  leaflet(options = leafletOptions(scrollWheelZoom = FALSE)) %>%
    
    addMouseCoordinates() |> 
    
    addMeasure(
      position = "topleft",
      primaryLengthUnit = "meters",
      secondaryLengthUnit = "kilometers",
      primaryAreaUnit = "sqmeters",
      activeColor = "#3D535D",
      completedColor = "#7D4479") |> 

    
    # Add scale bar
    addScaleBar(
      position = "bottomleft",
      options = scaleBarOptions(imperial = FALSE)
    ) %>% 
    
    
    # adding tiles
    addTiles(group = "OSM") %>%
    addProviderTiles('Esri.NatGeoWorldMap',
                     group="Esri.NatGeoWorldMap") |>
    addProviderTiles('Esri.WorldImagery',
                     group="Esri.WorldImagery") |>
    # addProviderTiles("Stadia.StamenTerrain",
    #                  group = "Stadia.StamenTerrain") |>
    addProviderTiles("Stadia.Outdoors",
                     group = "Stadia.Outdoors") |>
    addProviderTiles("Stadia.AlidadeSmoothDark",
                     group = "Stadia.AlidadeSmoothDark") |>
    # addProviderTiles("Stadia.AlidadeSatellite",
    #                  group = "Stadia.AlidadeSatellite") |>


    addPolygons(data = cnty_pub_land,
                weight = .7,
                color = "orange",
                popup = ~paste("<b>GROUP:</b> ", OWN_GROUP, "<br>",
                               "<b>AGENCY:</b> ", OWN_AGENCY),
                group = "Public Land") |>
    # adding raster
    addRasterImage(cnty_rast,
                   opacity = 1,
                   group = "Raster",
                   project = FALSE) |>

    addRasterLegend(cnty_rast,
                    opacity = 1,
                    group = "Raster",
                    position = "bottomright") |>

    # controls
    addLayersControl(
      baseGroups = c(
        "OSM",
        "Esri.NatGeoWorldMap",
        "Esri.WorldImagery",
        "Stadia.Outdoors",
        "Stadia.AlidadeSmoothDark"),

      overlayGroups = c(
        "Raster",
        "Public Land"),
      options = layersControlOptions(collapsed = TRUE)
    ) |> 
    # addFullscreenControl() |>
    

    # # Add styling to make the legend scrollable
    # addControl(
    #   tags$style(HTML('
    #   .leaflet .info {
    #     max-height: 400px; /* Set the maximum height of the legend */
    #     overflow-y: auto;  /* Enable vertical scrolling */
    #     }
    #   '))
    # )
  
  # Add CSS for scrollable legend with onRender
  htmlwidgets::onRender("
      function(el, x) {
        var style = document.createElement('style');
        style.innerHTML = `
          .leaflet .info {
            max-height: 200px; /* Set the maximum height of the legend */
            max-width: 200px;
            overflow-y: auto;  /* Enable vertical scrolling */
            overflow-x: auto;
          }
        `;
        document.head.appendChild(style);
      }
    ")

}
