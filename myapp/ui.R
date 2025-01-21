
ui <- navbarPage(
  title = "Forest Finder",
  id = "main_navbar",
  header = includeCSS('www/styles.css'),
  useShinyjs(),
  

  # Map Page ----
  tabPanel(
    title = "Interactive Map",
    div(
      style = "position: absolute; top: 0; bottom: 0; left: 0; right: 0; ", # Full viewport height and width
      leafletOutput(outputId = "mapOutput", width = "100%", height = "100%"),
      
      # Controls Panel
      # actionButton("toggleControls", "Controls",
      #              class = "btn btn-primary",
      #              style = "position: absolute; top: 57px; right: 5px; z-index: 9999;"),

      # Loading Spinner
      shinyjs::hidden(div(
        id = 'loading',
        style = "position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); z-index: 1000;",
        addSpinner(div(), spin = "circle", color = "#01796F")
      )),
      
      absolutePanel(id = "controls", 
                    class = "panel panel-default",
                    fixed = TRUE, top = 110, left = "auto", right = 5, 
                    bottom = "auto", width = 350, height = "auto",
        
        selectInput(
          inputId = "selectCounty",
          label = "County:",
          choices = sort(unique(counties_ca$NAME)),
          selected = NULL
        ),
        
        pickerInput(
          inputId = "selectSpecies",
          label = "Species:",
          choices = tree_levs$Label,
          multiple = TRUE,
          options = list(`actions-box` = TRUE)
        ),
        materialSwitch(inputId = "toggleLegend", "Legend",
                       status = "success", value = TRUE),
        # prettyCheckbox(inputId = "toggleLegend", label = "Hide Legend",  
        #               icon = icon("check"), shape = "round", value = TRUE), # New buttonc
        actionButton(inputId = "applyFilters", label = "Apply")
        
      )
    ),
    div(style = "position: absolute; top: 53px; right: -100px; z-index: 1000;",
        materialSwitch(inputId = "toggleControls2", "Controls",
                       status = "success", value = TRUE))
  ), # End Map page
  
  # About Page ----
  tabPanel(title = "About",
           # intro text fluidRow ----
           fluidRow(
             # use columns to create white space on sides
             column(1),
             column(10, includeMarkdown("text/about.md")),
             column(1)) # END intro text fluidRow
  ), # END About tabPanel 
) # End Navbar 
