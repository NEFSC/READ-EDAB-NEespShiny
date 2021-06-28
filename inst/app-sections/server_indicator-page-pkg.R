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
