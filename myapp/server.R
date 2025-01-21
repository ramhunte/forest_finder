
# New UI that woprks better :) ----


server <- function(input, output, session) {
  
  # Reactive: Filter counties and transform
  cnty <- reactive({
    filter(counties_ca, NAME %in% input$selectCounty) |> 
      st_transform(4326)
  })
  
  # Reactive: County-specific bounding box
  bbox <- reactive({
    st_bbox(cnty()) |> as.data.frame()
  })
  
  # Reactive: County-specific raster
  cnty_rast <- reactive({
    if (is.null(input$selectSpecies) || length(input$selectSpecies) == 0) {
      return(NULL)
    }
    crop_rast <- county_rasters[[input$selectCounty]]
    rc_rast <- ifel(!is.null(crop_rast) & (crop_rast %in% input$selectSpecies), crop_rast, NA)
    levels(rc_rast) <- tree_levs |> filter(Value %in% unique(values(crop_rast)))
    coltab(rc_rast) <- tree_coltab
    return(rc_rast)
  })
  
  # Initial Map Render
  output$mapOutput <- renderLeaflet({
    leaflet() |> 
      addProviderTiles(providers$CartoDB.Positron) |> 
      setView(lng = -119.4179, lat = 36.7783, zoom = 6) |> 
      addMouseCoordinates() |>  
      addScaleBar(position = "bottomleft", options = scaleBarOptions(imperial = FALSE)) %>% 
      htmlwidgets::onRender("
        function(el, x) {
          var style = document.createElement('style');
          style.innerHTML = `
            .leaflet .info {
              max-height: 200px;
              max-width: 200px;
              overflow-y: auto;
              overflow-x: auto;
            }
          `;
          document.head.appendChild(style);
        }
      ")
  })
  
  # Update Species Picker When County Changes
  observeEvent(input$selectCounty, {
    new_choices <- tree_levs |>
      filter(Value %in% unique(values(county_rasters[[input$selectCounty]]))) |>
      pull(Label)
    
    # Retain previously selected species that are still valid
    valid_species <- input$selectSpecies[input$selectSpecies %in% new_choices]
    
    updatePickerInput(session, 
                      inputId = "selectSpecies", 
                      choices = new_choices, 
                      selected = valid_species)
  })
  
  # Apply Filters and Update Map
  
  # Reactive value to store the previous bounding box
  previous_bbox <- reactiveVal(NULL)
  
  observeEvent(input$applyFilters, {
    
    shinyjs::showElement(id = 'loading') # Show the spinner
    
    proxy <- leafletProxy("mapOutput")
    proxy <- proxy %>%
      clearShapes() %>%
      clearImages() %>%
      clearControls()
    
    # Add county polygon
    proxy <- proxy %>%
      addPolygons(
        data = cnty(),
        color = "darkgreen",
        weight = 1.5,
        fillColor = "transparent"
      ) 
    
    # Check if bbox has changed
    current_bbox <- bbox()
    if (!identical(previous_bbox(), current_bbox)) {
      proxy <- proxy %>%
        fitBounds(
          lng1 = current_bbox[1, ], lat1 = current_bbox[2, ],
          lng2 = current_bbox[3, ], lat2 = current_bbox[4, ]
        )
      # Update the previous bbox
      previous_bbox(current_bbox)
    }
    
    # Add tree raster if available
    if (!is.null(cnty_rast())) {

      proxy <- proxy %>%
        addRasterImage(cnty_rast(), opacity = 1, project = FALSE) |> 
        addRasterLegend(
          cnty_rast(),
          opacity = 1,
          group = "Trees",
          position = "bottomleft"
        )

    }
    
    shinyjs::hideElement(id = 'loading') # Hide the spinner
    
  })
  
  # Observe legend toggle ----
  observeEvent(input$toggleLegend, {
    proxy <- leafletProxy("mapOutput")
    
    if (input$toggleLegend) {
      # Add the legend if it is toggled on
      if (!is.null(cnty_rast())) {
        proxy <- proxy %>%
          addRasterLegend(
            cnty_rast(),
            opacity = 1,
            group = "Trees",
            position = "bottomleft"
          )
      }
    } else {
      # Remove the legend if it is toggled off
      proxy <- proxy %>%
        clearControls()
    }
  })
  
  # toogle control ----
  observeEvent(input$toggleControls2, {
    if (input$toggleControls2) {
      runjs("$('#controls').removeClass('hidden');")  # Show controls
    } else {
      runjs("$('#controls').addClass('hidden');")  # Hide controls
    }
  })
  
  

}

