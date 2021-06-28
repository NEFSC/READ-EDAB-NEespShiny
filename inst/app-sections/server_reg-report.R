# regression report ----
output$report <- downloadHandler(
  
  # create file name
  filename = function() {
    paste(input$species, "_regression_report.zip", sep = "")
  },
  
  # create file content
  content = function(file) {
    
    # rendering message
    id <- showNotification(
      "Rendering report...",
      duration = NULL,
      closeButton = FALSE,
      type = "message"
    )
    on.exit(removeNotification(id), add = TRUE)
    
    # create temp dir
    this_dir <- paste(tempdir(), "BOOK", sep = "/")
    dir.create(this_dir)
    # can't find a way around this
    # bookdown needs it
    # downloading zip file needs it (only sometimes???)
    setwd(this_dir)
    
    # render report
    render_reg_report_shiny(
      stock_var = input$species,
      epus_var = input$epu,
      region_var = input$region,
      remove_var = input$remove,
      lag_var = as.numeric(input$lag),
      file_var = paste(input$species, "_regression_report.docx", sep = ""),
      save_var = TRUE
    )
    
    # copy to zip file for download
    file.copy(
      from = "testZip.zip",
      to = file
    )
  },
  contentType = "application/zip"
)

# regression options table
output$table <- DT::renderDataTable(NEesp::make_html_table_thin(
  NEesp::regression_species_regions,
  col_names = colnames(NEesp::regression_species_regions)
),
server = FALSE
)
