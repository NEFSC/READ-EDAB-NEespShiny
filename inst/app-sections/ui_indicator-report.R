# indicator reports ----
tabPanel(
  "Download an Indicator Report",
  
  h2("Download an Indicator Report"),
  
  h3("Report parameters"),
  
  selectInput(
    inputId = "ind_species",
    label = "Species",
    choices = NEesp::species_key$Species
  ),
  
  h3("Do you want to use a local template?"),
  h4("Warning: Only upload one .yml!"),
  fileInput(
    inputId = "test_template",
    label = "Upload all .Rmds and your .yml",
    multiple = TRUE,
    accept = c(".Rmd", ".yml"),
    placeholder = "Just use the package template!"
  ),
  
  h3("Does your local template depend on sourced R scripts?"),
  h4("Warning: Scripts will be sourced before rendering the report; using `source` within the report is not supported."),
  fileInput(
    inputId = "test_tem_script",
    label = "Choose scripts(s) to load",
    multiple = TRUE,
    accept = ".R",
    placeholder = "No, I'm good"
  ),
  
  downloadButton("ind_report", "Generate indicator report")
)