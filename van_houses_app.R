library(shiny)
library(bslib)
library(thematic)
library(plotly)
library(tidyverse)
library(leaflet)

# Optimizing workflow
options(shiny.autoreload = TRUE)

# Uncomment the following to download the data from Vancouver Open Data Portal
# url <- "https://opendata.vancouver.ca/api/explore/v2.1/catalog/datasets/property-tax-report/exports/csv?lang=en&timezone=America%2FLos_Angeles&use_labels=true&delimiter=%3B"
# house_data <- read_delim(url, delim = ";", show_col_types = FALSE)
# dir.create("data-raw")
# write_csv(house_data, "data-raw/van_house_data.csv")

# Load previously annotated data from Vancouver Open Portal
load(file = "data-raw/house_data.rda")

# Creating ui
ui <- fluidPage(
  theme = bslib::bs_theme(bootswatch = "journal"),
  titlePanel(paste("Vancouver Housing Dashboard", house_data$report_year[[1]])), # Here can we add so it updates the year and community we select.
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
        selected = "2023",
        choices = unique(house_data$report_year)
      ),

      # creating picker for community
      selectInput(
        inputId = "community",
        label = "Select Community (multiple selection allowed):",
        selected = c("Shaughnessy", "Kerrisdale", "Downtown"),
        multiple = TRUE,
        choices = unique(house_data$`Geo Local Area`)
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
  map_filtered_data <- reactive({
    filtered_data() |>
      dplyr::group_by(`Geo Local Area`) |>
      dplyr::summarize(
        n = n(),
        total = sum(n),
        mean_price = round(mean(current_land_value), 2),
        lat = mean(latitude),
        long = mean(longitude)
      )
  })

  output$vancouver_map <- leaflet::renderLeaflet({
    map_filtered_data() |>
      leaflet::leaflet() |>
      leaflet::setView(lng = -123.12402, lat = 49.2474, zoom = 11.5) |>
      leaflet::addTiles() |>
      leaflet::addCircleMarkers(
        lat = ~lat,
        lng = ~long,
        radius = ~ n * 20 / total,
        popup = paste0(
          map_filtered_data()$n,
          " houses in ",
          map_filtered_data()$`Geo Local Area`,
          " averaging $",
          map_filtered_data()$mean_price
        ),
        options = popupOptions(closeButton = FALSE)
      )
  })
}

shinyApp(ui, server)