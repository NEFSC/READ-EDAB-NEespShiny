ui <- fluidPage(
  selectInput(inputId = "species",
              label = "Species",
              choices = NEesp::species_key$Species),
  
  selectInput(inputId = "epu",
              label = "EPU",
              choices = c("GB", "GOM", "MAB")),
  
  selectInput(inputId = "region",
              label = "Stock Region",
              choices = sort(unique(NEesp::regression_species_regions$Region))),
  
  selectInput(inputId = "lag",
              label = "Lag correlation? \n(for predictive potential)",
              choices = 0:10),
  
  selectInput(inputId = "remove",
              label = "Remove past 10 years of data? \n(for predictive potential)",
              choices = c("FALSE", "TRUE")),
  
  downloadButton("report", "Generate report")
)