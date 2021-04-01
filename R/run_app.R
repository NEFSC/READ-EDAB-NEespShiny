
#' Run App
#'
#' Runs the app. No input required, leave blank.
#'
#' @export

run_NEesp <- function() {
  shiny::shinyApp(ui,
    server,
    onStart = function() {
      start_dir <- getwd()

      onStop(function(start = start_dir) {
        setwd(start)
        clean_www()
      })
    }
  )
}
