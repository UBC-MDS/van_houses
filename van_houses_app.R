library(shiny)
library(bslib)
library(thematic)
library(plotly)
library(tidyverse)
library(shinyWidgets)
library(leaflet)

# Optimizing workflow
options(shiny.autoreload = TRUE)

# Uncomment the following to download the data from Vancouver Open Data Portal
# url <- "https://opendata.vancouver.ca/api/explore/v2.1/catalog/datasets/property-tax-report/exports/csv?lang=en&timezone=America%2FLos_Angeles&use_labels=true&delimiter=%3B"
# house_data <- read_delim(url, delim = ";", show_col_types = FALSE)
# dir.create("data-raw")
# write_csv(house_data, "data-raw/van_house_data.csv")

# Load previously annotated data from Vancouver Open Portal
load(file='data-raw/house_data.rda')

# Creating ui
ui <- fluidPage(
  theme = bslib::bs_theme(bootswatch = "journal"),
  titlePanel("Vancouver Housing Dashboard"),
  sidebarLayout(
    sidebarPanel(
      # Create four stats summary to give an overall view
      # number of Houses
      fluidRow(
        column(
          width = 5,
          div(
            style = "height:100px;",
            "Stat 1: # of Houses",
            length(na.omit(house_data$current_land_value))
          )
        ),
        # average house price
        column(
          width = 5,
          offset = 2,
          div(
            style = "height:100px;",
            "Stat 2: Avg Price",
            paste0("$", round(mean(na.omit(house_data$current_land_value)), 2))
          )
        )
      ),
      # average year built
      fluidRow(
        column(
          width = 5,
          div(
            style = "height:100px;",
            "Stat 3: Avg Year House Built",
            round(mean(na.omit(house_data$year_built)), 0)
          )
        ),
        # average year house improved
        column(
          width = 5,
          offset = 2,
          div(
            style = "height:100px;",
            "Stat 4: Avg Year House Improved",
            round(mean(na.omit(house_data$big_improvement_year)), 0)
          )
        )
      ),

      # creating radio buttons for report year
      radioButtons(
        inputId = "reportyear", 
        label = "Select Report Year", 
        choices = unique(house_data$report_year),
        selected = 2023
      ),
      
      # creating picker for community
      pickerInput(
        inputId = "community", 
        label = "Select Community", 
        choices = unique(house_data$report_year), 
        options = pickerOptions(
          actionsBox = TRUE, 
          selected = unique(house_data$report_year),
          size = 10,
          selectedTextFormat = "count > 1",
        )
      ),
      # Create slider for house price
      sliderInput(
        inputId = "priceslider",
        label = "Price range",
        min = 300000,
        max = 1000000,
        value = range(300000, 1000000),
        step = 1000,
        sep = ''
      ),
      # create slider for year built
      sliderInput(
        inputId = "yearslider",
        label = "Year built",
        min = 1975,
        max = 2016,
        value = range(1975, 2016),
        step = 1,
        sep = ''
      )
    ),
    # four plot outputs
    mainPanel(
      fluidRow(
        column(width = 5, plotOutput(outputId = "histogram_land_value")),
        column(width = 5, leaflet::leafletOutput(outputId = "vancouver_map"))
      ),
      fluidRow(
        column(width = 5, "Third plot"),
        column(width = 5, "Fourth plot")
      ),
    )
  )
)

# Creating server
server <- function(input, output, session) {
  thematic::thematic_shiny()
  
  # filtered data set
  filtered_data <- reactive({ 
    house_data |>
      dplyr::filter(
        current_land_value >= input$priceslider[1],
        current_land_value <= input$priceslider[2],
        year_built >= input$yearslider[1],
        year_built <= input$yearslider[2],
        report_year %in% input$reportyear
      )
  }) 
  
  # plot1: histogram_land_value
  output$histogram_land_value <- renderPlot({
    
    plot1 <- filtered_data()
    
    hist(plot1$current_land_value,
         col = "darkgray", border = "white",
         xlab = "House Price ($)",
         main = "House Price Distribtuion"
    )
  })
  
  # plot 2: map
  output$vancouver_map <- leaflet::renderLeaflet({
    filtered_data() |>
      dplyr::group_by(`Geo Local Area`) |>
      dplyr::summarize(n = n(), 
                       lat = mean(latitude),
                       long = mean(longitude)) |>
      leaflet::leaflet() |>
      leaflet::setView(lng = -123.12402, lat = 49.2474, zoom = 11.5) |>
      leaflet::addTiles() |>
      leaflet::addCircleMarkers(
        lat = ~lat,
        lng = ~long,
        radius = ~n/10000,
        # popup = paste(
        #   filtered_data()$n,
        #   "bird/s in",
        #   filtered_data()$`Geo Local Area`
        # ),
        options = popupOptions(closeButton = FALSE)
      )
  })
}

shinyApp(ui, server)