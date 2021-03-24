ui <- fluidPage(
  
  h1("Generate Northeast ESP Preliminary Reports"),
  
  navlistPanel(
    
    widths = c(2, 10),

    # indicator reports
    tabPanel(
      
      "Indicator Reports",
      
      h2("Report parameters"),
      
      selectInput(
        inputId = "ind_species",
        label = "Species",
        choices = NEesp::species_key$Species
      ),
      
      downloadButton("ind_report", "Generate indicator report")
    ),
    
    # regression reports
    tabPanel(
      
      "Regression Reports",
      
      splitLayout(

        verticalLayout(
          h2("Report parameters"),

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
            label = "Lag correlation by how many years? \n(for predictive potential)",
            choices = 0:10
          ),

          selectInput(
            inputId = "remove",
            label = "Remove past 10 years of data? \n(for predictive potential)",
            choices = c("FALSE", "TRUE")
          ),

          downloadButton("report", "Generate regression report")
        ),

        verticalLayout(
          h2("Possible species - region - EPU combinations"),
          DT::dataTableOutput("table",
            height = "100%"
          )
        ),
        cellWidths = c("40%", "60%"),
        cellArgs = list(style = "overflow-x: hidden;")
      )
    )
  )
)
