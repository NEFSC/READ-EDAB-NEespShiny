# stock-indicator analysis ----

# add Var options

react_var <- observeEvent(input$si_file$datapath, {
  data <- NEesp::read_file(input$si_file$datapath)
  
  output$var <- renderUI({
    selectInput("var_options", label = "Indicator", choices = unique(data$Var))
  })
  })

## display graph ----

# reactive expression so it doesn't change when the parameters are changed
# only changes when button is clicked
react_plot <- eventReactive(input$go3, {
  
  # rendering message
  id <- showNotification(
    "Rendering report...",
    duration = NULL,
    closeButton = FALSE,
    type = "message"
  )
  
  on.exit(removeNotification(id), add = TRUE)
  
  # show report
  dat <- NEesp::prep_si_data(file_path = input$si_file$datapath,
                         metric = input$si_metric,
                         var = input$var_options)
  plt <- NEesp::plot_corr_only(data = dat,
                        lag = as.numeric(input$si_lag),
                        species = input$si_species,
                        mode = "shiny"
  )
  print(plt)
  
  output$add_to_rpt <- renderUI({
    actionButton("go4", "Add to report")
  })
  output$text <- renderUI({
    htmlOutput("txt")
  })
  output$download_rpt <- renderUI({
    downloadButton("go5", "Download report")
  })
})

# render reactive output
 output$stock_indicator <- renderPlot({react_plot()},
                                     height = 800)

## add to report ----
observeEvent(input$go4, {
  
  # rendering message
  id <- showNotification(
    "Adding to report...",
    duration = NULL,
    closeButton = FALSE,
    type = "message"
  )
  
  on.exit(removeNotification(id), add = TRUE)
  
  path <- paste(tempdir(), "/SI-BOOK/",
                input$si_file$name %>% 
                  stringr::str_remove(".csv") %>% 
                  stringr::str_remove(".RDS"),
                "_",
                input$var_options %>%
                  stringr::str_replace_all(" ", "_") %>%
                  stringr::str_replace_all("\n", "_"),
                ".Rmd",
                sep = ""
  )
  # clear file and re-write if it already exists
  if (file.exists(path)) {
    file.remove(path)
  }
  
  if (!file.exists(path)) {
    dir.create(paste(tempdir(), "SI-BOOK", sep = "/"))
    file.create(path)
    first <- c()
  } else {
    first <- readLines(con = path) %>%
      paste(collapse = "\n")
  }

  writeLines(
    text = paste(first, 
                 "\n\n",
                 knitr::knit_expand(system.file('summary_esp_template/child.Rmd', package = 'NEesp')),
#                 "```{r}\n",
#                 "res <- knitr::knit_child(
#                            text = knitr::knit_expand(
#                            system.file('summary_esp_template/child.Rmd', package = 'NEesp')
#                            ),
#                            quiet = TRUE
#                            )
#                            cat(res, sep = '\\n\\n')", "\n",
#                 "```",
                 sep = ""
    ),
    con = path
  )
  
  data_added <- list.files(
    path = paste(tempdir(), "SI-BOOK", sep = "/"),
    pattern = ".Rmd"
  )
  print(data_added)
  if ("intro.Rmd" %in% data_added) {
    data_added <- data_added[-which(data_added == "intro.Rmd")]
  }
  if ("end.Rmd" %in% data_added) {
    data_added <- data_added[-which(data_added == "end.Rmd")]
  }
  if ("report.Rmd" %in% data_added) {
    data_added <- data_added[-which(data_added == "report.Rmd")]
  }
  output$txt <- renderUI({
    HTML(paste("Data added to report:",
               paste(data_added, collapse = "<br/>") %>%
                 stringr::str_remove_all(".Rmd"),
               sep = "<br/>"
    ))
  })
})

## download report ----
output$go5 <- downloadHandler(
  
  # create file name
  filename = function() {
    paste(input$si_species, "_esp_skeleton.zip", sep = "")
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
    
    # create rmd file
    # beginning and end
    intro <- readLines(system.file("summary_esp_template/intro.Rmd", package = "NEesp")) %>%
      paste(collapse = "\n")
    end <- readLines(system.file("summary_esp_template/end.Rmd", package = "NEesp")) %>%
      paste(collapse = "\n")
    
    # body
    data_added <- list.files(
      path = paste(tempdir(), "SI-BOOK", sep = "/"),
      full.names = TRUE,
      pattern = ".Rmd"
    )
    
    if (stringr::str_detect(toString(data_added), "intro.Rmd")) {
      data_added <- data_added[-stringr::str_which(data_added, "intro.Rmd")]
    }
    if (stringr::str_detect(toString(data_added), "end.Rmd")) {
      data_added <- data_added[-stringr::str_which(data_added, "end.Rmd")]
    }
    if (stringr::str_detect(toString(data_added), "report.Rmd")) {
      data_added <- data_added[-stringr::str_which(data_added, "report.Rmd")]
    }
    body <- ""
    for (i in data_added) {
      print(i)
      body <- paste(body,
                    readLines(i) %>%
                      paste(collapse = "\n"),
                    sep = "\n\n"
      )
    }
    
    path2 <- paste(tempdir(), "SI-BOOK", "report.Rmd", sep = "/")
    # clear file and re-write if it already exists
    if (file.exists(path2)) {
      file.remove(path2)
    }
    file.create(path2)
    writeLines(
      text = paste(intro, body, end, sep = "\n\n"),
      con = path2
    )
    
    # knit rmd file
    rmarkdown::render(
      input = path2,
      envir = new.env() # render in clean env or else `file` variable will mess up download later
    )
    
    # zip files
    files2zip <- c(
      list.files(
        path = paste(tempdir(), "SI-BOOK", sep = "/"),
        full.names = TRUE,
        recursive = TRUE,
        pattern = "report.doc"
      ),
      list.files(
        path = paste(tempdir(), "SI-BOOK", sep = "/"),
        full.names = TRUE,
        recursive = TRUE,
        pattern = ".png"
      )
    )
    
    # can't have figures folder without changing working directory or listing all parent directories up to ~
    utils::zip(paste(tempdir(), "SI-BOOK", "testZip", sep = "/"),
               files = files2zip,
               flags = "-j"
    )
    
    file.copy(
      from = paste(tempdir(), "SI-BOOK", "testZip.zip", sep = "/"),
      to = file
    )
  },
  contentType = "application/zip"
)