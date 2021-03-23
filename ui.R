ui <- fluidPage(
  selectInput(inputId = "species",
              label = "Species",
              choices = NEesp::species_key$Species),
  
  downloadButton("report", "Generate report")
)