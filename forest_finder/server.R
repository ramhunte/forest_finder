server <- function(input, output, session) {
  # Reactive: Filter counties and transform ----
  cnty <- reactive({
    # filter(counties_ca, NAME %in% input$selectCounty) # filter to selected counties
    counties_ca[counties_ca$NAME %in% input$selectCounty, ] # filter to selected counties
  })

  # Reactive: County-specific bounding box ----
  bbox <- reactive({
    st_bbox(cnty()) |> # creating a new bounding box from county
      as.data.frame()
  })

  # Reactive: County-specific raster ----
  cnty_rast <- reactive({
    # makign sure the raster has values, NULL if not
    if (is.null(input$selectSpecies) || length(input$selectSpecies) == 0) {
      return(NULL)
    }

    # selecting county raster
    crop_rast <- county_rasters[[input$selectCounty]]

    # reclassifying it to include just the species of interest
    rc_rast <- ifel(
      !is.null(crop_rast) & (crop_rast %in% input$selectSpecies),
      crop_rast,
      NA
    )

    # reassigning color tab (it gets lost when reclassifying)
    coltab(rc_rast) <- legend[, 1:5]

    return(rc_rast)
  })

  # Reactive: Legend and colors ----

  # creating a legend from the raster values
  cnty_legend <- reactive({
    # legend[legend$value %in% unique(values(cnty_rast())), ] |>
    legend[legend$label %in% input$selectSpecies, ] |>
      arrange(label)
  })

  # reactive update color pal for legend
  factorPalRev <- reactive({
    # creating an ordered factor color pallet from the legend
    colorFactor(cnty_legend()$hex, domain = cnty_legend()$label, ordered = TRUE)
  })

  # Initial Map Render ----

  # initial map legend render of Siskiyou county
  sisk_legend <- legend[legend$label %in% spcs_list[["Siskiyou"]], ] |>
    arrange(label)

  # initial map legend color pal of Siskiyou
  sisk_factorPal <- colorFactor(
    sisk_legend$hex,
    domain = sisk_legend$label,
    ordered = TRUE
  )

  # creating initial load of map
  output$mapOutput <- renderLeaflet({
    leaflet() |>
      addTiles() |> # base map is OSM
      addPolygons(
        # add new county lines
        data = counties_ca[counties_ca$NAME %in% "Siskiyou", ],
        color = "red",
        weight = 2,
        fillColor = "transparent"
      ) |>
      addRasterImage(
        county_rasters[["Siskiyou"]],
        opacity = 1,
        project = FALSE,
        group = "Raster Layer"
      ) |>
      addLegend(
        pal = sisk_factorPal,
        values = factor(sisk_legend$label, levels = sisk_legend$label),
        opacity = 1,
        group = "Trees",
        position = "bottomleft"
      ) |>

      # setting the size dimensions of the legend
      htmlwidgets::onRender(
        "
  function(el, x) {
    var style = document.createElement('style');
    style.innerHTML = `
      .leaflet .info {
        max-height: 200px;
        max-width: 200px;
        overflow-y: auto;
        overflow-x: auto;
        white-space: nowrap; /* Prevents wrapping */
      }
    `;
    document.head.appendChild(style);

    // Prevent scrolling inside legend from zooming the map
    
    var legend = document.querySelector('.leaflet .info');
    if (legend) {
      legend.addEventListener('wheel', function(event) {
        event.stopPropagation();
      });
    }
  }
  "
      )
  })

  # Update Species Picker ----
  observeEvent(input$selectCounty, {
    new_choices <- spcs_list[[input$selectCounty]] # update list with county species

    # keep previously selected tree species selected in new county raster
    valid_species <- input$selectSpecies[input$selectSpecies %in% new_choices]

    # updating species picker with new choices and new values
    updatePickerInput(
      session,
      inputId = "selectSpecies",
      choices = new_choices,
      selected = valid_species
    )
  })

  # Apply Filters/Update Map ----

  # make original bbox NULL when rendering map at first
  previous_bbox <- reactiveVal(NULL)

  observeEvent(input$applyFilters, {
    # Disable the button when the action starts
    shinyjs::disable("applyFilters")

    shinyjs::showElement(id = 'loading') # Show a loading spinner when rendering

    proxy <- leafletProxy("mapOutput")

    # clear all polygons, rasters, and legends when re-rendered
    proxy <- proxy %>% #
      clearShapes() %>%
      clearImages() %>%
      clearControls()

    # Add county polygon
    proxy <- proxy %>%
      clearTiles() |> # remove basemap
      addProviderTiles(input$selectBasemap) |> # add new basemap from selected picker
      addPolygons(
        # add new county lines
        data = cnty(),
        color = "red",
        weight = 2,
        fillColor = "transparent"
      )

    current_bbox <- bbox() # set new boundaries to current bbox

    if (!identical(previous_bbox(), current_bbox)) {
      # Check if bbox has changed

      proxy <- proxy %>% # make new boundaries if bounding box has updated
        fitBounds(
          lng1 = current_bbox[1, ],
          lat1 = current_bbox[2, ],
          lng2 = current_bbox[3, ],
          lat2 = current_bbox[4, ]
        )

      # Update the previous bbox with new boundaries
      previous_bbox(current_bbox)
    }

    # Add tree raster if available
    if (!is.null(cnty_rast())) {
      proxy <- proxy %>%
        addRasterImage(
          cnty_rast(),
          opacity = 1,
          project = FALSE,
          group = "Raster Layer"
        )

      # add legend of new raster image if toggled on
      if (input$toggleLegend) {
        proxy <- proxy %>%
          addLegend(
            pal = factorPalRev(),
            values = factor(cnty_legend()$label, levels = cnty_legend()$label),
            opacity = 1,
            group = "Trees",
            position = "bottomleft"
          )
      }
    }

    shinyjs::hideElement(id = 'loading') # Hide the spinner

    # Re-enable the button after the event is done
    shinyjs::enable("applyFilters")
  })

  # Observe raster toggle ----
  # Observe the toggle button for raster visibility
  observeEvent(input$toggleRaster, {
    proxy <- leafletProxy("mapOutput")

    if (input$toggleRaster) {
      proxy %>% showGroup("Raster Layer") # Show the raster layer by adding it to the map
    } else {
      proxy %>% hideGroup("Raster Layer") # Hide the raster layer by removing it from the map
    }
  })

  # toggle legend  ----
  observeEvent(input$toggleLegend, {
    req(cnty_rast(), cnty_legend()) # Ensure the reactive values and legend are available

    proxy <- leafletProxy("mapOutput")

    if (input$toggleLegend) {
      # Add the legend if it is toggled on
      proxy <- proxy %>%
        addLegend(
          pal = factorPalRev(),
          values = factor(cnty_legend()$label, levels = cnty_legend()$label),
          opacity = 1,
          position = "bottomleft"
        )
    } else {
      # Remove the legend if it is toggled off
      proxy <- proxy %>%
        clearControls()
    }
  })

  # toggle control ----
  observeEvent(input$toggleControls2, {
    if (input$toggleControls2) {
      runjs("$('#controls').removeClass('hidden');") # Show controls absolute panel
    } else {
      runjs("$('#controls').addClass('hidden');") # Hide controls asolute panel
    }
  })
}
