library(shiny)

ui <- shiny::fluidPage(
  h1("hello world"),
  actionButton("go", "click"),

  htmlOutput("test"),
  
  textOutput("text")
)

server <- function(input, output) {
  observeEvent(input$go,
  {
    file <- "widget.html"
    output$test <- renderUI(htmltools::HTML(readLines(file)),
                            env = .GlobalEnv)
    output$text <- renderText(readLines(file)) # make sure file exists/isn't empty
    })
}

shinyApp(ui = ui, server = server)

#runApp(here::here("test"))
