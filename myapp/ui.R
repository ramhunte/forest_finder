
ui <- navbarPage(
  title = "Forest Finder",
  id = "main_navbar",
  header = includeCSS('www/styles.css'),
  

  # Map Page ----
  tabPanel(
    useShinyjs(),
    title = "Interactive Map",
    div(
      style = "position: absolute; top: 0; bottom: 0; left: 0; right: 0; ", # Full viewport height and width
      leafletOutput(outputId = "mapOutput", width = "100%", height = "100%"),

      # Loading Spinner
      shinyjs::hidden(div(
        id = 'loading',
        style = "position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); z-index: 1000;",
        addSpinner(div(), spin = "circle", color = "#01796F")
      )),
      
    absolutePanel(id = "controls",
                  class = "panel panel-default",
                  fixed = TRUE, top = 68, left = "auto", right = 5,
                  bottom = "auto", width = 350, height = "auto",

      pickerInput(
        inputId = "selectCounty",
        label = "County:",
        choices = sort(unique(counties_ca$NAME)),
        multiple = FALSE,
        pickerOptions(maxOptionsText = 1)),

      pickerInput(
        inputId = "selectSpecies",
        label = "Species:",
        choices = tree_levs$Label,
        multiple = TRUE,
        options = list(`actions-box` = TRUE)
      ),
      materialSwitch(inputId = "toggleLegend", "Legend",
                     status = "success", value = TRUE),
      div(style = "padding-right: 23px;",
        materialSwitch(inputId = "toggleRaster", "Trees  ",
                     status = "success", value = TRUE)),
      actionButton(inputId = "applyFilters", label = "Apply")

    )
    ),
  div(style = "position: absolute; top: 60px; right: -270px; z-index: 1000;",
     prettyToggle(inputId = "toggleControls2",
                  value = TRUE,
                  label_on = NULL,
                  icon_on = icon("xmark"),
                  status_on = "primary",
                  label_off = NULL,
                  shape = "curve",
                  outline = TRUE))
  ), # End Map page

  # # About Page ----
  tabPanel(title = "About",
           # intro text fluidRow ----
           fluidRow(
             # use columns to create white space on sides
             column(1),
             column(10, includeMarkdown("text/about.md")),
             column(1)) # END intro text fluidRow
  ) # END About tabPanel
) # End Navbar 
