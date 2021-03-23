if (!"devtools" %in% installed.packages()) {
  install.packages("devtools")
}

if (!"NEesp" %in% installed.packages()) {
  devtools::install_github("NOAA-EDAB/esp_data_aggretation@package")
}

render_reg_report_shiny <- function(stock_var, epus_var  = "MAB", 
                                    region_var = "Mid", 
                                    remove_var = FALSE, file_var,
                                    lag_var = 0, save_var = TRUE, 
                                    out = "word") {
  starting_dir <- getwd()
  
  new_dir <- tempdir()
  
  file.copy(
      from = list.files(system.file("correlation_bookdown_template", package = "NEesp"),
                        full.names = TRUE
      ),
      to = here::here(new_dir),
      overwrite = TRUE
    ) %>%
      invisible()
 
  setwd(here::here(new_dir))
  
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
        path = here::here(new_dir, "figures//"),
        save = save_var,
        remove_recent = remove_var
      ),
      output_format = bookdown::word_document2(),
      envir = new.env(parent = globalenv()),
      output_file = file_var,
      clean = TRUE,
      quiet = FALSE
    )
  

  setwd(starting_dir)

}

`%>%` <- magrittr::`%>%`
library(NEesp)
library(shiny)

server <- function(input, output){
  
  output$report <- downloadHandler(
    # For PDF output, change this to "report.pdf"
    filename = "report.doc",
    content = function(file) {
      # Copy the report file to a temporary directory before processing it, in
      # case we don't have write permissions to the current working dir (which
      # can happen when deployed).

      # Set up parameters to pass to Rmd document
      #params <- list(n = input$slider)
      
      # Knit the document, passing in the `params` list, and eval it in a
      # child of the global environment (this isolates the code in the document
      # from the code in this app).
      render_reg_report_shiny(stock_var = input$species,
                              file_var = file,
                              save_var = FALSE)

    }
  )
}
