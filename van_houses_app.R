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
            "Stat 1: Number of Houses",
            textOutput(outputId = "num_houses")
          )
        ),
        # average house price
        column(
          width = 5,
          offset = 2,
          div(
            style = "height:100px;",
            "Stat 2: Average House Price",
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
            "Stat 3: Average Year of House Built",
            textOutput(outputId = "avg_year_built")
          )
        ),
        # average year house improved
        column(
          width = 5,
          offset = 2,
          div(
            style = "height:100px;",
            "Stat 4: Average Year of House Improvement",
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
        max = 5000000,
        value = range(300000, 5000000),
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
      checkboxGroupInput(
        inputId = "zoning",
        label = "Select a Zoning Classification (multiple selection allowed):",
        choices = sort(unique(house_data$zoning_classification))
      ),
      checkboxInput("select_all_zoning", "Select All", value = FALSE),

      # creating picker for community
      checkboxGroupInput(
        inputId = "community",
        label = "Select Community (multiple selection allowed):",
        choices = sort(unique(house_data$`Geo Local Area`))
      ),
      checkboxInput("select_all", "Select All", value = FALSE),
    ),
    # four plot outputs
    mainPanel(
      fluidRow(
        column(width = 4, leaflet::leafletOutput(outputId = "vancouver_map")),
        column(width = 4, plotOutput(outputId = "histogram_land_value")),
        column(width = 4, plotlyOutput(outputId = "box_plot")),
      ),
      fluidRow(
        column(
          width = 12, # adding a download button for downloading csv file
          downloadButton(
            outputId = "download_van_houses",
            label = "Download Full Data"
          ),
          DT::dataTableOutput(outputId = "table1"),
        )
      ),
    )
  )
)

# Creating server
server <- function(input, output, session) {
  thematic::thematic_shiny()

  observeEvent(input$select_all_zoning, {
    if (input$select_all_zoning) {
      updateCheckboxGroupInput(session, "zoning", selected = sort(unique(house_data$zoning_classification)))
    } else {
      updateCheckboxGroupInput(session, "zoning", selected = c(
        "Comprehensive Development",
        "One-Family Dwelling",
        "Single Detached House",
        "Two-Family Dwelling"
      ))
    }
  })

  observeEvent(input$select_all, {
    if (input$select_all) {
      updateCheckboxGroupInput(session, "community", selected = sort(unique(house_data$`Geo Local Area`)))
    } else {
      updateCheckboxGroupInput(session, "community", selected = c("Shaughnessy", "Kerrisdale", "Downtown"), )
    }
  })

  # filtered data set
  filtered_data <- reactive({
    house_data |>
      dplyr::filter(
        current_land_value >= input$priceslider[1],
        current_land_value <= input$priceslider[2],
        year_built >= input$yearslider[1],
        year_built <= input$yearslider[2],
        report_year == input$reportyear,
        zoning_classification %in% input$zoning,
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

  # plot1: map of Vancouver showing selected communities
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

  # plot2: histogram of housing price
  output$histogram_land_value <- renderPlot({
    plot1 <- filtered_data()

    hist(plot1$current_land_value,
      col = "darkgray", border = "white",
      xlab = "House Price ($)",
      ylab = "Number of Houses",
      main = "House Price Distribution",
    )
  })

  # plot3: boxplot of land legal type
  output$box_plot <- renderPlotly({
    plot_ly(filtered_data(),
            x= ~current_land_value,
            y= ~legal_type,
            type = "box", 
            orientation = "h"
    ) |>
      layout(
        xaxis = list(title = "House Price ($)"),
        yaxis = list(title = "Legal Type"),
        title = "Price per Legal Type")
  })

  # table 1: Selected housing data preview
  output$table1 <- DT::renderDataTable(
    filtered_data() |>
      select(
        "Geo Local Area",
        full_address,
        current_land_value,
        current_improvement_value,
        tax_assessment_year,
        year_built
      ) |>
      rename(
        "Area Name" = "Geo Local Area",
        "Full address" = full_address,
        "Current land value" = current_land_value,
        "Current improvement value" = current_improvement_value,
        "Annual tax assessment" = tax_assessment_year,
        "Year built" = year_built
      ),
  )

  # download button: downloading table 1
  output$download_van_houses <- downloadHandler(
    filename = function() {
      "van_houses.csv"
    },
    content = function(file) {
      # Load selected housing dataset as a data frame
      van_houses_df <- as.data.frame(filtered_data())
      # Write the data frame to a CSV file
      write.csv(van_houses_df, file, row.names = FALSE)
    }
  )
}

shinyApp(ui, server)
