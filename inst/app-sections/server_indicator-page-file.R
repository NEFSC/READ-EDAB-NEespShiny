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
