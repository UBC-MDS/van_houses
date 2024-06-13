library(shiny)
library(bslib)
library(thematic)
library(plotly)
library(tidyverse)
library(leaflet)
library(shinyWidgets)
library(shinycssloaders)

# Optimizing workflow
options(shiny.autoreload = TRUE)

# Uncomment the following if need to download data from Vancouver Open Data Portal
# Warning! This can take a while to download and tidy (~300Mb)
# source("data-raw/download.R")
# download()

# Load previously annotated data from Vancouver Open Portal
load(file = "data-raw/house_data.rda")

light_theme <- bslib::bs_theme(bootswatch = "journal")

dark_theme <- bslib::bs_theme(bootswatch = "darkly")

# Creating ui
ui <- fluidPage(
  theme = light_theme,
  titlePanel(
    div(
      style = "display: flex; align-items: center; height: 30px;",
      tags$img(src = "logo.png", height = 50, width = 50),
      textOutput(outputId = "title"), style = "font-size: 30px"
    )
  ),
  title = "Vancouver Housing App",
  sidebarLayout(
    sidebarPanel(
      width = 3,
      # creating radio buttons for report year
      radioButtons(
        inputId = "reportyear",
        label = "Select Report Year",
        selected = "2024",
        choices = sort(unique(house_data$report_year), decreasing = TRUE)
      ),

      # Create slider for house price
      sliderInput(
        inputId = "priceslider",
        label = "Price range (5-95th percentile)",
        min = quantile(house_data$current_land_value, probs=0.05, na.rm=TRUE),
        max = quantile(house_data$current_land_value, probs=0.95, na.rm=TRUE),
        value = range(quantile(house_data$current_land_value, probs=0.05, na.rm=TRUE), 
                      quantile(house_data$current_land_value, probs=0.95, na.rm=TRUE)),
        step = 10000,
        sep = ""
      ),

      # create slider for year built
      sliderInput(
        inputId = "yearslider",
        label = "Year built",
        min = min(house_data$year_built, na.rm=TRUE),
        max = max(house_data$year_built, na.rm=TRUE),
        value = range(min(house_data$year_built, na.rm=TRUE),
                      max(house_data$year_built, na.rm=TRUE)),
        step = 1,
        sep = ""
      ),

      # select zoning
      selectInput(
        inputId = "zoning",
        label = "Select Zoning Classification:",
        choices = sort(unique(house_data$zoning_classification)),
        multiple = TRUE
      ),
      checkboxInput("select_all_zoning", "Select All", value = FALSE),
      selectInput(
        inputId = "community",
        label = "Select Community:",
        choices = sort(unique(house_data$`Geo Local Area`)),
        multiple = TRUE
      ),
      checkboxInput("select_all", "Select All", value = FALSE),
      shinyWidgets::materialSwitch(
        inputId = "toggle_theme",
        label = span(icon("lightbulb"), "Dark Mode"),
        value = FALSE,
        status = "info"
      ),
    ),
    # four plot outputs
    mainPanel(
      # column(width = 4, plotlyOutput(outputId = "box_plot")),
      # Create four stats summary to give an overall view
      # number of Houses
      fluidRow(
        layout_column_wrap(
          width = 1 / 4,
          card(
            div(
              span(
                style = "font-size: 28px;",
                textOutput(outputId = "num_houses")
              ),
              span(
                icon("house"),
                "Houses Reported",
                style = "font-size: 15px"
              )
            )
          ),
          # average house price
          card(
            div(
              span(
                style = "font-size: 28px;",
                textOutput(outputId = "avg_price")
              ),
              span(
                icon("sack-dollar"),
                "Average House Price",
                style = "font-size: 15px"
              )
            )
          ),
          # average year built
          card(
            div(
              span(
                style = "font-size: 28px;",
                textOutput(outputId = "avg_year_built")
              ),
              span(
                icon("hammer"),
                "Avg. Built Year",
                style = "font-size: 15px"
              )
            )
          ),
          # average year house improved
          card(
            div(
              span(
                style = "font-size: 28px;",
                textOutput(outputId = "avg_year_improve")
              ),
              span(
                icon("wrench"),
                "Avg. Improvement Year",
                style = "font-size: 15px"
              )
            )
          ),
        )
      ),
      fluidRow(
        layout_column_wrap(
          width = 1 / 2,
          height = 340,
          fill = TRUE,
          heights_equal = "all",
          card(
            full_screen = TRUE,
            card_header(
              # class = "bg-dark",
              span(icon("map-location-dot"), " Map of Vancouver", style = "font-size: 18px")
            ),
            card_body_fill(shinycssloaders::withSpinner(leaflet::leafletOutput(outputId = "vancouver_map", height = 280)), class = "my-card-image")
          ),
          card(
            full_screen = TRUE,
            card_header(
              # class = "bg-dark",
              span(icon("chart-simple"), " Distribution of House Values", style = "font-size: 18px")
            ),
            card_body_fill(shinycssloaders::withSpinner(plotOutput(outputId = "histogram_land_value", height = 280)), class = "my-card-image")
          ),
        ),
      ),
      fluidRow(
        layout_column_wrap(
          width = 1,
          height = 290,
          fill = TRUE,
          card(
            full_screen = TRUE,
            card_header(
              # class = "bg-dark",
              span(icon("table-list"), " Detailed data",
                downloadButton(
                  outputId = "download_van_houses",
                  label = "Download Selected Data"
                ),
                style = "font-size: 18px",
                class = "rightAlign"
              )
            ),
            tags$style(".card-header span { display: flex; justify-content: space-between; align-items: center; }"),
            card_body_fill( # adding a download button for downloading csv file
              shinycssloaders::withSpinner(
                DT::dataTableOutput(outputId = "table1")
              )
            )
          ),
        )
      ),
    ),
  ),
  footer = tags$div(
    class = "footer",
    p(
      hr(),
      column(4, p()),
      column(4, p()),
      column(4, p()),
    ),
    p("2023 © H. Wang, K. Wang, M. Zhao, Z. Chen")
  )
)

# Creating server
server <- function(input, output, session) {
  # shinythemes::themeSelector(),
  # Dark Mode
  observe({
    session$setCurrentTheme(
      if (isTRUE(input$toggle_theme)) {
        dark_theme
      } else {
        light_theme
      }
    )
  })

  observeEvent(input$select_all_zoning, {
    if (input$select_all_zoning) {
      updateCheckboxGroupInput(session, "zoning", selected = unique(house_data$zoning_classification))
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
      updateCheckboxGroupInput(session, "community", selected = unique(house_data$`Geo Local Area`))
    } else {
      updateCheckboxGroupInput(session, "community", selected = c("Shaughnessy", "Kerrisdale", "Downtown"), )
    }
  })

  # filtered data set
  filtered_data <- reactive({
    first_filter <- house_data |>
      dplyr::filter(
        current_land_value >= input$priceslider[1],
        current_land_value <= input$priceslider[2],
        year_built >= input$yearslider[1],
        year_built <= input$yearslider[2],
        report_year == input$reportyear,
        zoning_classification %in% input$zoning,
        `Geo Local Area` %in% input$community
      )
    # Show text to the user if the filtering returns a 0 row dataset
    validate(
      missing_values(first_filter)
    )

    first_filter
  })

  missing_values <- function(input_data) {
    if ( nrow(input_data) == 0 ) {
      "No matched houses!"
    } else {
      NULL
    }
  }

  # Page title
  output$title <- renderText(
    paste("Vancouver Housing Dashboard", input$reportyear)
  )

  # Stats boxes
  output$num_houses <- renderText(
    length(na.omit(filtered_data()$current_land_value))
  )

  output$avg_price <- renderText(
    paste0("$", format(round(mean(na.omit(filtered_data()$current_land_value)), 0), big.mark=","))
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
    hist(filtered_data()$current_land_value / 1000,
      col = "darkgray", border = "white",
      xlab = "House Price (per $1000)",
      ylab = "Number of Houses",
      main = NULL,
      breaks = seq(0, 5000, by = 250),
    )
    par(mar = c(5, 4, 4, 2) + 0.1)
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
