#' User interface function
#'
#' User interface script code
#'
#' @import shiny
#' @importFrom magrittr %>%

ui <- fluidPage(
  h1("Generate Northeast ESP Preliminary Reports"),

  navlistPanel(
    widths = c(2, 10),

    eval(parse(system.file("app-sections/ui_indicator-page-pkg.R", package = "NEespShiny"))),

    eval(parse(system.file("app-sections/ui_indicator-page-file.R", package = "NEespShiny"))),
                  
    eval(parse(system.file("app-sections/ui_indicator-report.R", package = "NEespShiny"))),
                  
    eval(parse(system.file("app-sections/ui_reg-report.R", package = "NEespShiny"))),
                  
    eval(parse(system.file("app-sections/ui_stock-indicator.R", package = "NEespShiny")))
    
  )
)
