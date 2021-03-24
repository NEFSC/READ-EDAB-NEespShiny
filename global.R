if (!"devtools" %in% installed.packages()) {
  install.packages("devtools")
}

if (!"NEesp" %in% installed.packages()) {
  devtools::install_github("NOAA-EDAB/esp_data_aggretation@package")
}

`%>%` <- magrittr::`%>%`
library(NEesp)
library(shiny)
library(ggplot2)

render_reg_report_shiny <- function(stock_var,
                                    epus_var = "MAB",
                                    region_var = "Mid",
                                    remove_var = FALSE,
                                    lag_var = 0,
                                    save_var = TRUE,
                                    file_var) {

  new_dir <- tempdir()
  
  setwd(new_dir)
  dir.create("BOOK")
  setwd("BOOK")
  this_dir <- getwd()
  
  # make sure directory is clean
  existing_files <- list.files(
    full.names = TRUE,
    recursive = TRUE,
    all.files = TRUE
  )
  
  if (length(existing_files) > 0) {
    file.remove(existing_files)
  }
  
  file.copy(
    from = list.files(system.file("correlation_bookdown_template", package = "NEesp"),
                      full.names = TRUE
    ),
    to = this_dir,
    overwrite = TRUE
  ) %>%
    invisible()
  
  if (save_var) {
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
      out = "word"
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
  files2zip <- c(
    list.files(
      full.names = TRUE,
      recursive = TRUE,
      pattern = "report.doc"
    ),
    list.files(
      full.names = TRUE,
      recursive = TRUE,
      pattern = ".png"
    ),
    list.files(
      full.names = TRUE,
      recursive = TRUE,
      pattern = ".csv"
    )
  )

  utils::zip(zipfile = "testZip", files = files2zip)
}

render_ind_report_shiny <- function(x, 
                                    save_data = TRUE, 
                                    input,
                                    file_var) {

  new_dir <- tempdir()
  
  setwd(new_dir)
  dir.create("BOOK")
  setwd("BOOK")
  this_dir <- getwd()
  
  # make sure directory is clean
  existing_files <- list.files(
    full.names = TRUE,
    recursive = TRUE,
    all.files = TRUE
  )
  
  if (length(existing_files) > 0) {
    file.remove(existing_files)
  }
  
  if(input == "package"){
    file.copy(
      from = list.files(system.file("indicator_bookdown_template", package = "NEesp"),
                        full.names = TRUE
      ),
      to = this_dir,
      overwrite = TRUE
    ) %>%
      invisible()
    
    params_list <- list(
      species_ID = x,
      path = paste(this_dir, "/figures//", sep = ""),
      ricky_survey_data = NEesp::bio_survey,
      save = save_data
    )
    
  } else {

    file.copy(
      from = list.files(input,
                        full.names = TRUE
      ),
      to = this_dir,
      overwrite = TRUE
    ) %>%
      invisible()
    
    params_list <- list(
      species_ID = x,
      path = paste(this_dir, "/figures//", sep = ""),
      ricky_survey_data = NEesp::bio_survey,
      save = save_data,
      file = "word"
    )
  }
  
    bookdown::render_book(
      input = ".",
      params = params_list, 
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
    files2zip <- c(
      list.files(
        full.names = TRUE,
        recursive = TRUE,
        pattern = "report.doc"
      ),
      list.files(
        full.names = TRUE,
        recursive = TRUE,
        pattern = ".png"
      ),
      list.files(
        full.names = TRUE,
        recursive = TRUE,
        pattern = ".csv"
      )
    )
    
    utils::zip(zipfile = "testZip", files = files2zip)
}
