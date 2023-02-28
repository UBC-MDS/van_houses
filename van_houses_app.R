library(shiny)
library(bslib)
library(thematic)
library(plotly)
library(tidyverse)
library(leaflet)

# Optimizing workflow
options(shiny.autoreload = TRUE)

# Uncomment the following if need to download data from Vancouver Open Data Portal
# Warning! This can take a while to download and tidy (~300Mb)
# source("data-raw/download.R")
# download()

# Load previously annotated data from Vancouver Open Portal
load(file = "data-raw/house_data.rda")

# Creating ui
ui <- fluidPage(
  theme = bslib::bs_theme(bootswatch = "journal"),
  titlePanel(div(textOutput(outputId = "title"))),
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
            textOutput(outputId = "num_houses")
          )
        ),
        # average house price
        column(
          width = 5,
          offset = 2,
          div(
            style = "height:100px;",
            "Stat 2: Avg Price",
            textOutput(outputId = "avg_price")
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
            textOutput(outputId = "avg_year_built")
          )
        ),
        # average year house improved
        column(
          width = 5,
          offset = 2,
          div(
            style = "height:100px;",
            "Stat 4: Avg Year House Improved",
            textOutput(outputId = "avg_year_improve")
          )
        )
      ),

      # creating radio buttons for report year
      radioButtons(
        inputId = "reportyear",
        label = "Select Report Year",
        selected = "2023",
        choices = sort(unique(house_data$report_year))
      ),

      # Create slider for house price
      sliderInput(
        inputId = "priceslider",
        label = "Price range",
        min = 300000,
        max = 1000000,
        value = range(300000, 1000000),
        step = 1000,
        sep = ""
      ),

      # create slider for year built
      sliderInput(
        inputId = "yearslider",
        label = "Year built",
        min = 1975,
        max = 2016,
        value = range(1975, 2016),
        step = 1,
        sep = ""
      ),

      # creating picker for community
      checkboxGroupInput(
        inputId = "community",
        label = "Select Community (multiple selection allowed):",
        selected = c("Shaughnessy", "Kerrisdale", "Downtown"),
        choices = sort(unique(house_data$`Geo Local Area`))
      )
    ),
    # four plot outputs
    mainPanel(
      fluidRow(
        column(width = 5, plotOutput(outputId = "histogram_land_value")),
        column(width = 6, leaflet::leafletOutput(outputId = "vancouver_map"))
      ),
      fluidRow(
        column(width = 5, "Third plot"),
        column(width = 6, "Fourth plot")
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
        report_year == input$reportyear,
        `Geo Local Area` %in% input$community
      )
  })

  # Page title
  output$title <- renderText(
    paste("Vancouver Housing Dashboard", input$reportyear)
  )

  # Stats boxes
  output$num_houses <- renderText(
    length(na.omit(filtered_data()$current_land_value))
  )

  output$avg_price <- renderText(
    paste0("$", round(mean(na.omit(filtered_data()$current_land_value)), 2))
  )

  output$avg_year_built <- renderText(
    round(mean(na.omit(filtered_data()$year_built)), 0)
  )

  output$avg_year_improve <- renderText(
    round(mean(na.omit(filtered_data()$big_improvement_year)), 0)
  )

  # plot1: histogram_land_value
  output$histogram_land_value <- renderPlot({
    plot1 <- filtered_data()

    hist(plot1$current_land_value,
      col = "darkgray", border = "white",
      xlab = "House Price ($)",
      ylab = "Number of Houses",
      main = "House Price Distribtuion",
    )
  })

  # plot2: map of Vancouver showing selected communities
  output$vancouver_map <- leaflet::renderLeaflet({
    filtered_data() |>
      leaflet::leaflet() |>
      leaflet::setView(lng = -123.12402, lat = 49.2474, zoom = 11.5) |>
      leaflet::addTiles() |>
      leaflet::addMarkers(
        lat = ~latitude,
        lng = ~longitude,
        popup = paste0(
          filtered_data()$full_address,
          " $",
          filtered_data()$current_land_value
        ),
        options = popupOptions(closeButton = FALSE),
        clusterOptions = markerClusterOptions()
      )
  })
}

shinyApp(ui, server)
