# indicators rendered from local files ----
tabPanel(
  "Explore Indicator Data (test your bookdowns)",
  
  h2("Explore Indicator Data (test your bookdowns)"),
  
  h3("Choose species"),
  
  selectInput(
    inputId = "i_species2",
    label = "Species",
    choices = c(NEesp::species_key$Species, "NO SPECIES - TEST")
  ),
  
  h3("Do you have R scripts that need to be sourced?"),
  h4("Warning: Scripts will be sourced before rendering the report; using `source` within the report is not supported."),
  
  fileInput(
    inputId = "test_script",
    label = "Choose scripts(s) to load",
    multiple = TRUE,
    accept = ".R",
    placeholder = "No, I'm good"
  ),
  
  h3("Choose indicator file(s)"),
  h4("Remember to include `index.Rmd`!"),
  h4("Check yourself: Are you editing a child doc? Are you sure you're sourcing the local version in the rest of your code?"),
  
  fileInput(
    inputId = "test_file",
    label = "Choose file(s) to test",
    multiple = TRUE,
    accept = ".Rmd"
  ),
  
  actionButton("go2", "click"),
  
  htmlOutput("markdown2")
)