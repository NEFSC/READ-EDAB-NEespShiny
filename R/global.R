
#' Render shiny regression report
#'
#' Render shiny regression report. Bookdown files are copied into the working directory and the report is generated in the working directory. Suggest to change to a temp directory before running.
#'
#' @param stock_var Species common name
#' @param epus_var EPU to use
#' @param region_var Stock region
#' @param remove_var Whether or not to remove the past 10 years of data
#' @param lag_var How many years to lag the correlation by
#' @param save_var Whether or not to save the data files as .csv
#' @param file_var The name of the zip file produced
#'
#' @importFrom magrittr %>%

render_reg_report_shiny <- function(stock_var,
                                    epus_var = "MAB",
                                    region_var = "Mid",
                                    remove_var = FALSE,
                                    lag_var = 0,
                                    save_var = TRUE,
                                    file_var) {

  # make sure directory is clean

  this_dir <- getwd()

  existing_files <- list.files(
    this_dir,
    full.names = TRUE,
    recursive = TRUE,
    all.files = TRUE
  )

  if (length(existing_files) > 0) {
    file.remove(existing_files)
  }

  file.copy(
    from = list.files(system.file("correlation_bookdown_template", package = "NEesp"),
      pattern = ".Rmd",
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

  # bookdown needs the files in the working directory... can't find a way around it
  # changing `input = ` doesn't work
  # putting full file path to temp files in yml doesn't work
  # setwd(this_dir)
  # working directory is set to this_dir before running this function

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
    #envir = new.env(parent = globalenv()),
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

  utils::zip("testZip",
    files = files2zip
  )
}

#' Render shiny indicator report
#'
#' Render shiny indicator report. Bookdown files are copied into the working directory and the report is generated in the working directory. Suggest to change to a temp directory before running.
#'
#' @param x Species common name
#' @param save_data Whether or not to save the data files as .csv
#' @param input The folder to copy the report template files from. Defaults to "package", which copies the template files from the NEesp package.
#' @param file_var The name of the zip file produced
#'
#' @importFrom magrittr %>%
#' @importFrom ggplot2 .pt

render_ind_report_shiny <- function(x,
                                    save_data = TRUE,
                                    input = "package",
                                    file_var) {
  this_dir <- getwd()

  # make sure directory is clean
  existing_files <- list.files(
    this_dir,
    full.names = TRUE,
    recursive = TRUE,
    all.files = TRUE
  )

  if (length(existing_files) > 0) {
    file.remove(existing_files)
  }

  if (input == "package") {
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
    #envir = new.env(parent = globalenv()),
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

#' Render shiny indicator page
#'
#' Render shiny indicator page. Bookdown files are copied into the working directory and the report is generated in the working directory. Suggest to change to a temp directory before running.
#'
#' @param x Species common name
#' @param input The folder to copy the report template files from. Defaults to "package", which copies the template files from the NEesp package.
#' @param file The name of the .Rmd file to render (if taking from the package template), or the uploaded .Rmd files
#'
#' @importFrom magrittr %>%
#' @importFrom ggplot2 .pt

render_ind_page_shiny <- function(x,
                                  input,
                                  file) {
  
 # DT::JS("destroy();")

  this_dir <- getwd()
  
  # create image directory (www)
  img_dir <- paste(system.file(package = "NEespShiny"),
                   "www//",
                   sep = "/"
  )
  dir.create(img_dir)

  # make sure directory is clean
  existing_files <- list.files(
    full.names = TRUE,
    recursive = TRUE,
    all.files = TRUE
  )

  if (length(existing_files) > 0) {
    file.remove(existing_files)
  }

  if (input == "package") {
    prefix <- system.file("indicator_bookdown_template", package = "NEesp")
    file.copy(
      from = paste(prefix, c("index.Rmd", file), sep = "/"),
      to = this_dir,
      overwrite = TRUE
    ) %>%
      invisible()

    params_list <- list(
      species_ID = x,
      path = img_dir,
      ricky_survey_data = NEesp::bio_survey,
      save = FALSE
    )

    name <- "package_output.html"
  } else {

    # copy index file, will be overwritten if user uploads one
    file.copy(
      from = system.file("indicator_bookdown_template/index.Rmd", package = "NEesp"),
      to = this_dir,
      overwrite = TRUE
    ) %>%
      invisible()

    file.copy(
      from = file$datapath,
      to = paste(this_dir, file$name, sep = "/"),
      overwrite = TRUE
    ) %>%
      invisible()

    params_list <- list(
      species_ID = x,
      path = img_dir,
      ricky_survey_data = NEesp::bio_survey,
      save = FALSE,
      file = "html"
    )

    name <- "custom_output.html"
  }

  bookdown::render_book(
    input = ".",
    params = params_list,
    output_format = bookdown::html_document2(),
    #envir = new.env(parent = globalenv()),
    output_file = name,
    output_dir = this_dir,
    intermediates_dir = this_dir,
    knit_root_dir = this_dir,
    clean = TRUE,
    quiet = FALSE
  )

}

#' Clean `www` folder
#'
#' Erases the `www` folder in the NEespShiny library folder at the end of the session

clean_www <- function() {
  if ("NEespShiny" %in% installed.packages()) {
    unlink(system.file("www", package = "NEespShiny",
                       recursive = TRUE))
  }
}
