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
  
 # on.exit(clean_www, add = TRUE)

  # indicator page from package ----
  
  re <- eventReactive(
    input$go, { 
      render_ind_page_shiny(x = input$i_species,
                                             input = "package",
                                             file = input$indicator)
    
    includeHTML(paste(tempdir(), "BOOK", "package_output.html", sep = "/"))
    
    })

  output$markdown <- renderUI({
    re()
  })
  
  # indicator page from test bookdowns ----
  
  re2 <- eventReactive(
    input$go2, { 
      
      if(class(input$test_script) == "data.frame"){
        source(input$test_script$datapath)
      }

      render_ind_page_shiny(x = input$i_species2,
                                    input = "custom",
                                    file = input$test_file)
      
      includeHTML(paste(tempdir(), "BOOK", "custom_output.html", sep = "/"))
      
    })
  
  output$markdown2 <- renderUI({
    re2()
  })
  
  # indicator report ----
  output$ind_report <- downloadHandler(
    
    filename = function() {
      paste(input$ind_species, "_indicator_report.zip", sep = "")
    },
    
    content = function(file) {
      
      id <- showNotification(
        "Rendering report...",
        duration = NULL,
        closeButton = FALSE,
        type = "message"
      )
      
      on.exit(removeNotification(id), add = TRUE)
      
      withProgress(message = "This may take a few minutes",
                   value = 0,
        {setProgress(0.05)
          
          render_ind_report_shiny(
        x = input$ind_species,
        #input = here::here("indicator_bookdown_template-dev"),
        file_var = paste(input$ind_species, "_indicator_report.docx", sep = "")
      )
          
          setProgress(0.9)
      
      file.copy("testZip.zip", file)
      
      setProgress(1)
      })
    },
    
    contentType = "application/zip"
  )
  
  # regression report ----
  output$report <- downloadHandler(

    filename = function() {
      paste(input$species, "_regression_report.zip", sep = "")
    },
    
    content = function(file) {

      id <- showNotification(
        "Rendering report...",
        duration = NULL,
        closeButton = FALSE,
        type = "message"
      )
      on.exit(removeNotification(id), add = TRUE)

      this_dir <- paste(tempdir(), "BOOK", sep = "/")
      dir.create(this_dir)
      # can't find a way around this
      # bookdown needs it
      # downloading zip file needs it (only sometimes???)
      setwd(this_dir)
      
      render_reg_report_shiny(
        stock_var = input$species,
        epus_var = input$epu,
        region_var = input$region,
        remove_var = input$remove,
        lag_var = as.numeric(input$lag),
        file_var = paste(input$species, "_regression_report.docx", sep = ""),
        save_var = TRUE,
        this_dir = this_dir
      )
      
      file.copy(from = "testZip.zip", 
                to = file)
    },
    contentType = "application/zip"
  )

  # regression options table 
  output$table <- DT::renderDataTable(NEesp::make_html_table_thin(
    NEesp::regression_species_regions,
    col_names = colnames(NEesp::regression_species_regions)),
                                      server = FALSE)
  
}
