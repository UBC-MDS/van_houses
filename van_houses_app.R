library(shiny)
library(bslib)
library(thematic)

ui <- fluidPage(
  theme = bslib::bs_theme(bootswatch = "journal"),
  titlePanel("Vancouver Housing Dashboard"),
  sidebarLayout(
    sidebarPanel(
      fluidRow(
        column(width = 5, "Stat 1: # of Houses"),
        column(width = 5, "Stat 2: Avg Price")),
      fluidRow(
        column(width = 5, "Stat 3: Avg House Area"),
        column(width = 5, "Stat 4: Avg Year Built")),
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
        label = "Price range($1,000)",
        min = 0,
        max = 10,
        value = 5
      ),
      sliderInput(
        inputId = "yearslider",
        label = "Year built",
        min = 0,
        max = 10,
        value = 5
      ),
    ),
    mainPanel(plotOutput(outputId = "distplot"))
  )
)

server <- function(input, output, session) {
  thematic::thematic_shiny()
  output$distplot <- renderPlot({
    # generate bins
    x <- faithful[, 2]
    bins <- seq(min(x), max(x), length.out = input$priceslider + 1)

    # draw the histogram with the specified number of bins
    hist(x,
      breaks = bins, col = "darkgray", border = "white",
      xlab = "Waiting time to next eruption (in mins)",
      main = "Histogram of waiting times"
    )
  })
}

shinyApp(ui, server)
