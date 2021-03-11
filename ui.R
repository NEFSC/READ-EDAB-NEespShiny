ui <- fluidPage(
  selectInput(inputId = "species",
              label = "Species",
              choices = NEesp::species_key$Species),
  actionButton(inputId = "button",
               label = "Generate report!"),
  
  textOutput(outputId = "message"),
  htmlOutput(outputId = "report")
)