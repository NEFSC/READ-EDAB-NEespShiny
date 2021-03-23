if (!"devtools" %in% installed.packages()) {
  install.packages("devtools")
}

if (!"NEesp" %in% installed.packages()) {
  devtools::install_github("NOAA-EDAB/esp_data_aggretation@package")
}

`%>%` <- magrittr::`%>%`
library(NEesp)
library(shiny)

render_reg_report_shiny <- function(stock_var, 
                                    epus_var  = "MAB", 
                                    region_var = "Mid", 
                                    remove_var = FALSE,
                                    lag_var = 0, 
                                    save_var = TRUE, 
                                    out = "word", 
                                    file_var) {
  starting_dir <- getwd()
  
  new_dir <- tempdir()
  
  setwd(new_dir)
  dir.create("BOOK")
  setwd("BOOK")
  this_dir <- getwd()
  
  # make sure directory is clean
  existing_files <- list.files(full.names = TRUE, 
                               recursive = TRUE, 
                               all.files = TRUE)
  if(length(existing_files) > 0){
    file.remove(existing_files)
  }

  file.copy(
      from = list.files(system.file("correlation_bookdown_template", package = "NEesp"),
                        full.names = TRUE
      ),
      to = getwd(),
      overwrite = TRUE
    ) %>%
      invisible()

  if(save_var){
    dir.create("data",
               recursive = TRUE
    )
  }
  
  # render bookdown
    bookdown::render_book(
      input = ".",
      params = list(
        lag = lag_var,
        stock = stock_var,
        region = region_var,
        epu = c(epus_var, c("All", "all", "NE")),
        path = paste(this_dir, "/figures//", sep = ""),
        save = save_var,
        remove_recent = remove_var,
        out = out
      ),
      output_format = bookdown::word_document2(),
      envir = new.env(parent = globalenv()),
      output_file = file_var,
      output_dir = this_dir,
      intermediates_dir = this_dir,
      knit_root_dir = this_dir,
      clean = TRUE,
      quiet = FALSE
    )

    # zip files
    files2zip <- c(list.files(full.names = TRUE,
                              recursive = TRUE,
                              pattern = "report.doc"),
                   list.files(full.names = TRUE,
                              recursive = TRUE,
                              pattern = ".png"),
                   list.files(full.names = TRUE,
                              recursive = TRUE,
                              pattern = ".csv"))
    
    print(files2zip)
    
    utils::zip(zipfile = 'testZip', files = files2zip)
    
}

server <- function(input, output){
  
  output$report <- downloadHandler(
    # For PDF output, change this to "report.pdf"
    filename = function() {"report.zip"},
    content = function(file) {
      # Copy the report file to a temporary directory before processing it, in
      # case we don't have write permissions to the current working dir (which
      # can happen when deployed).

      # Set up parameters to pass to Rmd document
      #params <- list(n = input$slider)
      
      id <- showNotification(
        "Rendering report...", 
        duration = NULL, 
        closeButton = FALSE
      )
      on.exit(removeNotification(id), add = TRUE)
      
      # Knit the document, passing in the `params` list, and eval it in a
      # child of the global environment (this isolates the code in the document
      # from the code in this app).
      render_reg_report_shiny(stock_var = input$species,
                              epus_var  = input$epu, 
                              region_var = input$region, 
                              remove_var = input$remove,
                              lag_var = as.numeric(input$lag), 
                              file_var = "report.docx",
                              save_var = TRUE)

      file.copy("testZip.zip", file)

    },
    contentType = "application/zip"
  )
}
