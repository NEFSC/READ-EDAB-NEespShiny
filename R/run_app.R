# source(here::here("inst/R-scripts/package-dev", "life_history_functions.R"))
# source(here::here("inst/R-scripts/package-dev", "plot_temp_anom.R"))
# source(here::here("R/global.R"))

#' Run App
#'
#' Runs the app
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

# on.exit(clean_www, add = TRUE)
# on.exit(setwd(start_dir), add = TRUE)
