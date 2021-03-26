server <- function(input, output) {
  
  # indicator report
  output$ind_report <- downloadHandler(
    
    filename = function() {
      paste(input$ind_species, "_indicator_report.zip", sep = "")
    },
    content = function(file) {
      
      id <- showNotification(
        "Rendering report...",
        duration = NULL,
        closeButton = FALSE,
        type = "message"
      )
      
      on.exit(removeNotification(id), add = TRUE)
      
      withProgress(message = "This may take a few minutes",
                   value = 0,
        {setProgress(0.05)
          
          render_ind_report_shiny(
        x = input$ind_species,
        input = here::here("indicator_bookdown_template-dev"),
        file_var = paste(input$ind_species, "_indicator_report.docx", sep = "")
      )
          
          setProgress(0.9)
      
      file.copy("testZip.zip", file)
      
      setProgress(1)
      })
    },
    
    contentType = "application/zip"
  )
  
  # regression report
  output$report <- downloadHandler(

    filename = function() {
      paste(input$species, "_regression_report.zip", sep = "")
    },
    content = function(file) {

      id <- showNotification(
        "Rendering report...",
        duration = NULL,
        closeButton = FALSE,
        type = "message"
      )
      on.exit(removeNotification(id), add = TRUE)

      render_reg_report_shiny(
        stock_var = input$species,
        epus_var = input$epu,
        region_var = input$region,
        remove_var = input$remove,
        lag_var = as.numeric(input$lag),
        file_var = paste(input$species, "_regression_report.docx", sep = ""),
        save_var = TRUE
      )

      file.copy("testZip.zip", file)
    },
    contentType = "application/zip"
  )

  # regression options table
  output$table <- DT::renderDataTable(NEesp::make_html_table_thin(
    NEesp::regression_species_regions,
    col_names = colnames(NEesp::regression_species_regions)),
                                      server = FALSE)
  
}
