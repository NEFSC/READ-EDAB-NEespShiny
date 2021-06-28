# stock-indicator analysis ----

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
  
  if (input$si_pattern == "ex: north, south, fall...") {
    new_pattern <- NULL
    new_remove <- NULL
  } else {
    new_pattern <- input$si_pattern %>%
      stringr::str_split(pattern = ", ")
    
    new_remove <- input$si_remove %>%
      stringr::str_split(pattern = ", ")
  }
  
  NEesp::wrap_analysis(
    file_path = input$si_file$datapath,
    metric = input$si_metric,
    pattern = new_pattern,
    remove = new_remove,
    lag = as.numeric(input$si_lag),
    species = input$si_species,
    mode = "shiny"
  )
  
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
# output$stock_indicator <- renderPlot({react_plot()},
#                                     height = 3200)

# height based on Var
react_h <- eventReactive(input$go3, {
  dat <- read.csv(input$si_file$datapath)
  h <- length(unique(dat$Var))
  h
})

# render reactive output
observeEvent(react_h(), {
  h <- as.numeric(react_h()) * 800
  
  output$stock_indicator <- renderPlot(
    {
      react_plot()
    },
    height = h
  )
})


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
  
  # must set file path, pattern (or null), remove (or null), metric, and lag
  # set species when rendering rmd
  path <- paste(tempdir(), "/SI-BOOK/",
                input$si_file$name %>% stringr::str_remove(".csv"),
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
  
  if (input$si_pattern == "ex: north, south, fall...") {
    new_pattern <- toString("NULL")
    new_remove <- toString("NULL")
  } else {
    new_pattern <- input$si_pattern %>%
      stringr::str_split(pattern = ", ")
    
    new_remove <- input$si_remove %>%
      stringr::str_split(pattern = ", ")
  }
  
  # print(input$si_file$datapath %>% stringr::str_replace_all("\\\\", "/"))
  
  writeLines(
    text = paste(first, "\n\n",
                 "```{r}\n",
                 "file_name <- '", input$si_file$name, "'\n",
                 "file <- '", input$si_file$datapath %>% stringr::str_replace_all("\\\\", "/"), "'\n",
                 "met <- '", input$si_metric, "'\n",
                 "pat <- ", new_pattern, "\n",
                 "rem <- ", new_remove, "\n",
                 "lag <- ", as.numeric(input$si_lag), "\n",
                 "res <- knitr::knit_child(
                            text = knitr::knit_expand(
                            system.file('summary_esp_template/child.Rmd', package = 'NEesp')
                            ),
                            quiet = TRUE
                            )
                            cat(res, sep = '\\n\\n')", "\n",
                 "```",
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
    print(stringr::str_detect(toString(data_added), "report.Rmd"))
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
      params = list(species = input$si_species),
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