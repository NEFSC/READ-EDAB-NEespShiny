library(shiny)

ui <- shiny::fluidPage(
  h1("hello world"),
  actionButton("go", "click"),
  
  DT::DTOutput("table")
)

server <- function(input, output) {
  observeEvent(input$go,
  {
    output$table <- DT::renderDT({
                                 tibble::tibble("letters" = c("a", "b", "c"),
                                            "numbers" = 1:3)
                               })
    })
}

shinyApp(ui = ui, server = server)

#runApp(here::here("test"))
