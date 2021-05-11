#' Server function
#'
#' Server script code
#'
#' @param input Input for app
#' @param output Output for app
#'
#' @import shiny
#' @importFrom magrittr %>%

server <- function(input, output, session) {

  # indicator page from package ----

  # datatables do not render except on fist instance
  # can get the tables to render if you refresh the page before running a new indicator
  # could fix the datatables issue if the page could be auto-refreshed before displaying new page
  # but don't know how to successfully auto-refresh shiny and render page on one click
  # shinyjs::refresh() and session$reload() only complete AFTER all server code runs
  # making a separate observeEvent() and doing o$destroy() does not work
  # changing priority numbers in observeEvent() does not affect refresh/reload order
  # removing UI and re-inserting does not work
  # session$onFlushed either gets stuck in a never-ending refresh loop or doesn't do anything
  # clearing temp files does not change anything
  # running javascript with htmlwidgets::JS() does not do anything (are there typos??)
  # removing r objects with rm() does not do anything
  # extract html between <body> </body> - suggested fix but doesn't work

  observeEvent(input$go, {

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
    render_ind_page_shiny(
      x = input$i_species,
      input = "package",
      file = input$indicator
    )

    # show report

    output$markdown <- renderUI({
      tags$iframe(
        srcdoc = htmltools::HTML(readLines(paste(this_dir, "package_output.html", sep = "/"))),
        width = "100%",
        height = "800px"
      )
    })
  })

  # indicator page from test bookdowns ----

  re2 <- eventReactive(
    input$go2,
    {

      # rendering message
      id <- showNotification(
        "Rendering report...",
        duration = NULL,
        closeButton = FALSE,
        type = "message"
      )

      on.exit(removeNotification(id), add = TRUE)

      # source R scripts if necessary
      if (class(input$test_script) == "data.frame") {
        lapply(
          input$test_script$datapath,
          source
        )
      }

      # create temp dir
      this_dir <- paste(tempdir(), "BOOK", sep = "/")
      dir.create(this_dir)
      # can't find a way around this
      # bookdown needs it
      # downloading zip file needs it (only sometimes???)
      setwd(this_dir)

      # render report
      render_ind_page_shiny(
        x = input$i_species2,
        input = "custom",
        file = input$test_file
      )

      # show report
      includeHTML(paste(this_dir, "custom_output.html", sep = "/"))
    }
  )

  output$markdown2 <- renderUI({
    re2()
  })

  # indicator report ----
  output$ind_report <- downloadHandler(

    # create file name
    filename = function() {
      paste(input$ind_species, "_indicator_report.zip", sep = "")
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

      withProgress(
        message = "This may take a few minutes",
        value = 0,
        {
          setProgress(0.05)

          # create temp dir
          this_dir <- paste(tempdir(), "BOOK", sep = "/")
          dir.create(this_dir)
          # can't find a way around this
          # bookdown needs it
          # downloading zip file needs it (only sometimes???)
          setwd(this_dir)

          # source R scripts if necessary
          if (class(input$test_tem_script) == "data.frame") {
            lapply(
              input$test_tem_script$datapath,
              source
            )
          }

          # use uploaded template, if it exists
          if (class(input$test_template) == "data.frame") {

            # don't copy to this_dir, will be erased in file cleaning during render_ind_report_shiny()
            temp <- paste(tempdir(), "local_template", sep = "/")
            dir.create(temp)

            # make sure directory is clean
            existing_files <- list.files(
              temp,
              full.names = TRUE,
              recursive = TRUE,
              all.files = TRUE
            )

            if (length(existing_files) > 0) {
              file.remove(existing_files)
            }

            # copy files
            file.copy(
              from = input$test_template$datapath,

              to = paste(temp, input$test_template$name, sep = "/"),
              overwrite = TRUE
            ) %>%
              invisible()

            # rename .yml as `_bookdown.yml`
            yml <- list.files(temp,
              pattern = ".yml",
              full.names = TRUE
            )
            file.rename(
              from = yml,
              to = paste(temp, "_bookdown.yml", sep = "/")
            )

            render_ind_report_shiny(
              x = input$ind_species,
              input = temp,
              file_var = paste(input$ind_species, "_indicator_report.docx", sep = "")
            )
          } else { # use package
            # render report
            render_ind_report_shiny(
              x = input$ind_species,
              file_var = paste(input$ind_species, "_indicator_report.docx", sep = "")
            )
          }

          setProgress(0.9)

          # copy zip file for download
          file.copy("testZip.zip", file)

          setProgress(1)
        }
      )
    },

    contentType = "application/zip"
  )

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
  
  # stock-indicator analysis ----
  
  ## display graph
  observeEvent(input$go3, {
    
    # rendering message 
    id <- showNotification(
      "Rendering report...",
      duration = NULL,
      closeButton = FALSE,
      type = "message"
    )
    
    on.exit(removeNotification(id), add = TRUE)

    # show report
    
    if(input$si_pattern == "ex: north, south, fall..."){
      new_pattern <- NULL
      new_remove <- NULL
    } else {
      new_pattern <- input$si_pattern %>%
        stringr::str_split(pattern = ", ")
      
      new_remove <- input$si_remove %>%
        stringr::str_split(pattern = ", ")
    }

    output$stock_indicator <- renderPlot({
      NEesp::wrap_analysis(
        file_path = input$si_file$datapath,
        metric = input$si_metric,
        pattern = new_pattern,
        remove = new_remove,
        lag = as.numeric(input$si_lag),
        species = input$si_species,
        mode = "shiny"
      )
      
    })
    
    output$add_to_rpt <- renderUI({actionButton("go4", "Add to report")})
    output$download_rpt <- renderUI({downloadButton("go5", "Download report")})
  })
  
  ## add to report
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
    path <- paste(tempdir(), "BOOK", "body.Rmd", sep = "/")
    if(!file.exists(path)){
      dir.create(paste(tempdir(), "BOOK", sep = "/"))
      file.create(path)
      first <- c()
    } else {first <- readLines(con = path) %>%
      paste(collapse = "\n") 
    }
    
    if(input$si_pattern == "ex: north, south, fall..."){
      new_pattern <- toString("NULL")
      new_remove <- toString("NULL")
    } else {
      new_pattern <- input$si_pattern %>%
        stringr::str_split(pattern = ", ")
      
      new_remove <- input$si_remove %>%
        stringr::str_split(pattern = ", ")
    }
    
    writeLines(text = paste(first, "\n\n",
                            "```{r}\n",
                            "file <- '", input$si_file$name, "'\n",
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
                            sep = ""),
               con = path
      )
    })
  
  ## download report
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
      print("creating file...")
      intro <- readLines(system.file('summary_esp_template/intro.Rmd', package = 'NEesp')) %>%
        paste(collapse = "\n")
      body <- readLines(paste(tempdir(), "BOOK", "body.Rmd", sep = "/")) %>%
        paste(collapse = "\n")
      end <- readLines(system.file('summary_esp_template/end.Rmd', package = 'NEesp')) %>%
        paste(collapse = "\n")
      
      path2 <- paste(tempdir(), "BOOK", "report.Rmd", sep = "/")
      file.create(path2)
      writeLines(text = paste(intro, body, end, sep = "\n\n"),
                 con = path2)
      
      # knit rmd file
      print("knitting file...")
      rmarkdown::render(input = path2,
                        params = list(species = input$si_species))
      
      # copy zip file for download
      #file.copy("testZip.zip", file)
      file.copy("report.doc", file)

    },
    
    #contentType = "application/zip"
  )
}
