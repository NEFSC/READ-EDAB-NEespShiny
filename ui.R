ui <- fluidPage(
  
  h1("Generate Northeast ESP Preliminary Reports"),
  
  navlistPanel(
    
    widths = c(2, 10),
    
    tabPanel(
      "Explore Indicator Data",
      
      h2("Choose species"),
      
      selectInput(
        inputId = "i_species",
        label = "Species",
        choices = NEesp::species_key$Species
      ),
      
      h2("Choose indicator"),
      
      selectInput(
        inputId = "indicator",
        label = "Indicator",
        choices = list.files(here::here("indicator_bookdown_template-dev"),
                             pattern = ".Rmd")
      ),
      
      actionButton("go", "click"),
      
      htmlOutput('markdown')
      
    ),

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
          h2(HTML("Possible <br/> species - region - EPU <br/> combinations"),
             align = "center"),
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
