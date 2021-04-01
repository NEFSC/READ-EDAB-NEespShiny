#' Server function
#'
#' Server script code
#'
#' @param input input for app
#' @param output output for app
#'
#' @import shiny
#' @importFrom magrittr %>%
#'
#' @export

server <- function(input, output) {

  # indicator page from package ----

  re <- eventReactive(
    input$go,
    {

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
      includeHTML(paste(this_dir, "package_output.html", sep = "/"))
    }
  )

  output$markdown <- renderUI({
    re()
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
        lapply(input$test_script$datapath,
               source)
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
            lapply(input$test_tem_script$datapath,
                   source)
          }
          
          # use uploaded template, if it exists
          if (class(input$test_template) == "data.frame") {
            
            # don't copy to this_dir, will be erased in file cleaning during render_ind_report_shiny()
            temp <- paste(tempdir(), "local_template", sep = "/")
            dir.create(temp)
            
            file.copy(
              from = input$test_template$datapath,
              
              to = paste(temp, input$test_template$name, sep = "/"),
              overwrite = TRUE
            ) %>%
              invisible()
            
            # rename .yml as `_bookdown.yml`
            yml <- list.files(pattern = ".yml")
            file.rename(yml, "_bookdown.yml")
            
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
}
