# stock-indicator analysis ----
tabPanel(
  "Stock-Indicator Analysis",

  h2("Stock-Indicator Analysis"),

  h3("Select your input file"),
  p("This should be a .csv outputted from the 'Download a Regression Report' tab."),
  fileInput(
    inputId = "si_file",
    label = "Choose file to use",
    multiple = FALSE,
    accept = ".csv"
  ),

  h3("Select your parameters"),

  selectInput(
    inputId = "si_species",
    label = "Species",
    choices = NEesp::species_key$Species,
    selected = "Black sea bass"
  ),

  selectInput(
    inputId = "si_metric",
    label = "Stock metric",
    choices = c("Recruitment", "Abundance", "Catch", "Fmort")
  ),

  selectInput(
    inputId = "si_lag",
    label = "Number of years by which stock data was lagged",
    choices = 0:10
  ),

  uiOutput("var"),
  p(""),

  actionButton("go3", "click"),
  p(""),
  uiOutput("add_to_rpt"),
  p(""),
  uiOutput("text"),
  p(""),
  uiOutput("download_rpt"),

  h4(""),
  plotOutput("stock_indicator")
)
