#' Server function
#'
#' Server script code
#'
#' @param input Input for app
#' @param output Output for app
#' @param session App session
#'
#' @import shiny
#' @importFrom magrittr %>%

server <- function(input, output, session) {

  eval(parse(system.file("app-sections/server_indicator-page-pkg.R", package = "NEespShiny")))
  
  eval(parse(system.file("app-sections/server_indicator-page-file.R", package = "NEespShiny")))
  
  eval(parse(system.file("app-sections/server_indicator-report.R", package = "NEespShiny")))
  
  eval(parse(system.file("app-sections/server_reg-report.R", package = "NEespShiny")))
  
  eval(parse(system.file("app-sections/server_stock-indicator.R", package = "NEespShiny")))

}
