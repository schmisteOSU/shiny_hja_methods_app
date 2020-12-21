#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
# library(readr)
# methods <- read_csv("shiny_methods.csv", col_types = cols(start = col_date(format = "%m/%d/%Y")), na = "NA")



library(shiny)
library(shinyWidgets)
library(ggplot2)
library(tidyverse)
library(readr)
library(DT)
library(htmltools)
library(timevis)

source("read_in_data.R")

#####UI
ui = fluidPage(
  theme = "bootstrap.css",
  
  titlePanel(NULL, windowTitle = "H.J. Andrews Climate Station Methods History"),
  
  headerPanel(p("H.J. Andrews Climate Station Methods History\n", align = "center", style = "background: #265363;color: white;")
  ),
  
  wellPanel(
    h4("The table below includes the full methods history for select climate stations at H.J. Andrews.", align = "center"), 
    h5("To narrow results, filter by parameter, benchmark station, and/or date range.", align = "center"),
    h5("The Search field can be used to limit results to those containing the search term(s).", align = "center"),
    style = "background: #265363;color: white;"
  ),
  
  # Create a new Row in the UI for selectInputs
  #fluidrow 1 = selections
  fluidRow(
    column(12, h5("Deselect ", strong("All"), "in the dropdown to filter results."), style = "color: #d55e00;"
           
    ),
    column(4,
           pickerInput(
             inputId = "parameter",
             label = "Measurement parameter:",
             choices = c("All", unique(as.character(methods$parameter))),
             selected = "All", multiple = TRUE, choicesOpt = list(style = rep(("color: white; background: #265363; font-weight: bold;"),15))
           )
    ),
    column(4,
           pickerInput(
             inputId = "sitecode",
             label = "Climate station:", 
             choices = c("All", unique(as.character(methods$sitecode))),
             selected = "All", multiple = TRUE
           )
    ),
    column(4,
           dateRangeInput("dateRange",
                          label = 'Date range input:',
                          start = min(methods$start)			
           )
    )
  ),
  
  #fluidrow 2 = Tabs
  fluidRow(column(12, tabsetPanel(type = "tabs",
                                  tabPanel(strong("Table")),
                                  tabPanel(strong("Timeline"), timevisOutput("timeline")))
            )
  ),
  
  #fluidrow 3 = download button
  fluidRow(column(4, downloadButton("download_filtered", label = "Download CSV", class="btn btn-primary btn-lg"), style='padding:5px;'),
    
    # Create a new row for the table.
    column(12, DT::DTOutput("table", width = "100%"), style='padding:5px; font-size:75%'
    )
  )
)

##########SERVER
server = function(input, output) {
  
  #Explanatory text
  output$text2 <- renderText({
    paste0("The complete methods history database is displayed below.\n", "Results can be narrowed by parameter, benchmark station, and/or date range by selecting an option from the drop-down menu.\n", "You can also narrow results by entering terms in the search bar.\n", 
           p("To download results to a CSV, click the button below.\n"))
  })
  
  # Filter data based on selections
  output$table <- DT::renderDT(DT::datatable({
    dat <- methods
    dat <- dplyr::filter(dat, start >= input$dateRange[1] & end <= input$dateRange[2])
    if (input$parameter != "All") {
      dat <- dplyr::filter(dat, parameter == input$parameter)
    }
    if (input$sitecode != "All") {
      dat <- dplyr::filter(dat, sitecode == input$sitecode)
    }
    dat
  }, rownames = FALSE, filter = "top", width = "100%", options = list(pageLength = 50, autoWidth = TRUE))
  )
  
  output$filtered_row <- 
    renderPrint({
      input[["table_rows_all"]]
    })
  
  output$download_filtered <- 
    downloadHandler(
      filename = "downloadData.csv",
      content = function(file){
        write.csv(dat[input[["table_rows_all"]], ],
                  file, row.names = FALSE)
      }
    )
  
  #create timeline
  output$timeline <- renderTimevis({
    dat <- methods
    dat = rowid_to_column(dat, var = "id")
    dat = filter(dat, start >= input$dateRange[1] & end <= input$dateRange[2])
    dat = filter(dat, parameter == input$parameter, sitecode == input$sitecode)
    dat = dat %>%
      mutate(content = paste0("<b>",method_code,"</b>"), group = res, subgroup = height, title = paste0(method_code,": ", method_desc)) %>%
      mutate(style = ifelse(height == 150, "background:purple;color:white",
                            ifelse(height == 250, "background:green;color:white",
                                   ifelse(height == 350, "background:cyan", "background:yellow"))))
      
    groups <- data.frame(id = levels(dat$res), content = levels(dat$res))
    config <- list(zoomKey = "ctrlKey", stack = FALSE)
    timevis(data = dat, groups = groups, options = config)
  })  
  
  
  #Closing bracket
}

# Create app object
shinyApp(ui = ui, server = server)