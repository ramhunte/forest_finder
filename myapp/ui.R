
ui <- navbarPage(
  title = div("Forest Finder",
  id = "main_navbar",
  
  # navbar icons ----
  # mail icon 
  tags$ul(
    class = "nav navbar-nav navbar-right",  # Aligns items to the right
    tags$a(
      href = "mailto:rmhunter999@gmail.com",  # Replace with your email
      tags$i(class = "fas fa-envelope",
             style = "font-size: 30px;
                        color: #ffffff;
               position: absolute;
               top: 10px;
             right: 10px;")  # Font Awesome mail icon
    )
  ), # end mail Icon 
  
  # github icon 
  tags$ul(
    class = "nav navbar-nav navbar-right",  # Aligns items to the right
    tags$a(
      href = "https://github.com/ramhunte",  # Replace with your email
      tags$i(class = "fa-brands fa-github",
             style = "font-size: 30px;
                        color: #ffffff;
               position: absolute;
               top: 10px;
             right: 50px;")  # Font Awesome mail icon
    )
  ), # end Github Icon 
  
  # linkedin icon
  tags$ul(
    class = "nav navbar-nav navbar-right",  # Aligns items to the right
    tags$a(
      href = "https://www.linkedin.com/in/raymond-hunter-90a8081a7/",  # Replace with your email
      tags$i(class = "fa-brands fa-linkedin",
             style = "font-size: 30px;
                        color: #ffffff;
               position: absolute;
               top: 10px;
             right: 90px;")  # Font Awesome mail icon
    )
  ), # end linkedin Icon 
  
  # website icon 
  tags$ul(
    class = "nav navbar-nav navbar-right",  # Aligns items to the right
    tags$a(
      href = "https://ramhunte.github.io/",  # Replace with your email
      tags$i(class = "fa-solid fa-user",
             style = "font-size: 25px;
                        color: #ffffff;
               position: absolute;
               top: 12px;
             right: 130px;")  # Font Awesome mail icon
    )
  ) # end website Icon 
  ), # End titile div()
  
  # linking CSS
  header = includeCSS('www/styles.css'),

  # # About Page ----
  tabPanel(title = "About",
           # intro text fluidRow
           fluidRow(
             # use columns to create white space on sides
             column(1),
             column(10, includeMarkdown("text/about.md")),
             column(1)),# END intro text fluidRow
           
           # Footer 
           tags$footer(
             style = "
      position: relative;
      bottom: 0;
      width: 100%;
      text-align: center;
      padding: 10px;
      border-top: 1px solid #004d00;",
             HTML(paste0(
               "<script>",
                "var today = new Date();",
                "var yyyy = today.getFullYear();",
               "</script>",
               
               "<p style = '
               text-align: center;
               font-size: 14px;
               color: #004d00;
               '
               > &copy; Raymond Hunter. All rights reserved. - <a href='https://ramhunte.github.io/' target='_blank'>https://ramhunte.github.io/</a> - <script>document.write(yyyy);</script></p>"))
           ) # END FOOTER
           
  ), # END About tabPanel
  

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
        choices = sort(legend$label),
        multiple = TRUE,
        options = list(`actions-box` = TRUE)
      ),
      
      pickerInput(
        inputId = "selectBasemap",
        label = "Basemap:",
        choices = c("Open Street Map (OSM)" = providers$OpenStreetMap,
                    "Satellite" = providers$Esri.WorldImagery,
                    "Plain" = providers$CartoDB.Positron),
        multiple = FALSE
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
  ) # End Map page

) # End Navbar 
