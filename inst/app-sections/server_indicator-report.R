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
