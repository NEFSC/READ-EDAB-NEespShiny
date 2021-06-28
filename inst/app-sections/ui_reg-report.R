# regression reports ----
tabPanel(
  "Download a Regression Report",
  
  h2("Download a Regression Report"),
  
  splitLayout(
    
    verticalLayout(
      h3("Report parameters"),
      
      selectInput(
        inputId = "species",
        label = "Species",
        choices = NEesp::species_key$Species
      ),
      
      selectInput(
        inputId = "epu",
        label = "EPU",
        choices = c("GB", "GOM", "MAB")
      ),
      
      selectInput(
        inputId = "region",
        label = "Stock Region",
        choices = sort(unique(NEesp::regression_species_regions$Region))
      ),
      
      selectInput(
        inputId = "lag",
        label = HTML("Lag correlation by how many years? <br/> (for predictive potential)"),
        choices = 0:10
      ),
      
      selectInput(
        inputId = "remove",
        label = HTML("Remove past 10 years of data? <br/> (for predictive potential)"),
        choices = c("FALSE", "TRUE")
      ),
      
      downloadButton("report", "Generate regression report")
    ),
    
    verticalLayout(
      h3(HTML("Possible <br/> species - region - EPU <br/> combinations"),
         align = "center"
      ),
      DT::dataTableOutput("table",
                          height = "100%"
      )
    ),
    cellWidths = c("40%", "60%"),
    cellArgs = list(style = "overflow-x: hidden;")
  )
)