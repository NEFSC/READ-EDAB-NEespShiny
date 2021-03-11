if (!"devtools" %in% installed.packages()) {
  install.packages("devtools")
}

#devtools::install_deps(dependencies = TRUE, upgrade = FALSE)

server <- function(input, output){
  re_message <- eventReactive(
    input$button, 
    {
      print(paste("This is a test!", input$species))
      }
  )
  
  re_report <- eventReactive(
    input$button, 
    {
      #NEesp::render_ind_report(input$species)
      
      lapply(list.files(here::here("action_reports", input$species),
                        full.names = TRUE,
                        pattern = ".html"),
        includeHTML
        )
    }
  )

  output$message <- renderText({ 
    re_message()
  })
  output$report <- renderUI({
    re_report()
  })
}
