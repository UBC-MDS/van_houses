library(shiny)
library(bslib)
library(thematic)
library(plotly)
library(tidyverse)

# Download the data from Vancouver Open Portal
load(file='data-raw/house_data.rda')

house_data <- read_csv("data-raw/van_house_data.csv", show_col_types = FALSE)

ui <- fluidPage(
  theme = bslib::bs_theme(bootswatch = "journal"),
  titlePanel("Vancouver Housing Dashboard"),
  sidebarLayout(
    sidebarPanel(
      fluidRow(
        column(
          width = 5,
          div(
            style = "height:100px;",
            "Stat 1: # of Houses",
            length(na.omit(house_data$CURRENT_LAND_VALUE))
          )
        ),
        column(
          width = 5,
          offset = 2,
          div(
            style = "height:100px;",
            "Stat 2: Avg Price",
            paste0("$", round(mean(na.omit(house_data$CURRENT_LAND_VALUE)), 2))
          )
        )
      ),
      fluidRow(
        column(
          width = 5,
          div(
            style = "height:100px;",
            "Stat 3: Avg Year House Built",
            round(mean(na.omit(house_data$YEAR_BUILT)), 0)
          )
        ),
        column(
          width = 5,
          offset = 2,
          div(
            style = "height:100px;",
            "Stat 4: Avg Year House Improved",
            round(mean(na.omit(house_data$BIG_IMPROVEMENT_YEAR)), 0)
          )
        )
      ),
      # checkboxInput(
      #   inputId = "communityCheckbox",
      #   label = "Community", FALSE
      # ),
      # verbatimTextOutput("value"),
      # selectInput(
      #   inputId = "housetypeDropdown",
      #   label = "House type",
      #   choices == c(
      #     "Type 1" = "type1",
      #     "Type 2" = "type2",
      #     "Type 3" = "type3",
      #     "Type 4" = "type4",
      #   ),
      #   selected = "type1"
      # ),
      sliderInput(
        inputId = "priceslider",
        label = "Price range",
        min = 300000,
        max = 1000000,
        value = range(300000, 1000000),
        step = 1000,
        sep = ''
      ),
      sliderInput(
        inputId = "yearslider",
        label = "Year built",
        min = 1975,
        max = 2016,
        value = range(1975, 2016),
        step = 1,
        sep = ''
      ),
    ),
    mainPanel(
      fluidRow(
        column(width = 5, plotOutput(outputId = "histogram_land_value")),
        column(width = 5, "Second plot")
      ),
      fluidRow(
        column(width = 5, "Third plot"),
        column(width = 5, "Fourth plot")
      ),
    )
  )
)

server <- function(input, output, session) {
  thematic::thematic_shiny()
  # plot1: histogram_land_value
  output$histogram_land_value <- renderPlot({
    plot1 <- house_data |>
      filter(CURRENT_LAND_VALUE >= input$priceslider[1],
             CURRENT_LAND_VALUE <= input$priceslider[2],
             YEAR_BUILT >= input$yearslider[1],
             YEAR_BUILT <= input$yearslider[2])
    
    hist(plot1$CURRENT_LAND_VALUE,
         col = "darkgray", border = "white",
         xlab = "House Price",
         main = "House Price Distribtuion"
    )
  })
}

shinyApp(ui, server)