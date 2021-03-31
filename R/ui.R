#' User interface function
#'
#' User interface script code
#' 
#' @import shiny
#'
#' @export

ui <- fluidPage(
  
  h1("Generate Northeast ESP Preliminary Reports"),
  
  navlistPanel(
    
    widths = c(2, 10),
    
    tabPanel(
      "Explore Indicator Data (package bookdowns)",
      
      h2("Explore Indicator Data (package bookdowns)"),
      
      h3("Choose species"),
      
      selectInput(
        inputId = "i_species",
        label = "Species",
        choices = NEesp::species_key$Species
      ),
      
      h3("Choose indicator"),
      
      selectInput(
        inputId = "indicator",
        label = "Indicator",
        choices = list.files(system.file("indicator_bookdown_template", package = "NEesp"),
                                                pattern = ".Rmd")
      ),
      
      actionButton("go", "click"),
      
      htmlOutput("markdown")
      
    ),
    
    tabPanel(
      "Explore Indicator Data (test your bookdowns)",
      
      h2("Explore Indicator Data (test your bookdowns)"),
      
      h3("Choose species"),
      
      selectInput(
        inputId = "i_species2",
        label = "Species",
        choices = NEesp::species_key$Species
      ),
      
      h3("Do you have R scripts that need to be sourced?"),
      
      fileInput(
        inputId = "test_script",
        label = "Choose scripts(s) to load",
        multiple = TRUE,
        accept = ".R",
        placeholder = "No, I'm good"
      ),
      
      h3("Choose indicator file(s)"),
      p("Remember to include `index.Rmd` if needed!"),
      
      fileInput(
        inputId = "test_file",
        label = "Choose file(s) to test",
        multiple = TRUE,
        accept = ".Rmd"
        ),
        
        actionButton("go2", "click"),
        
        htmlOutput("markdown2")
        
      ),
      

    # indicator reports
    tabPanel(
      
      "Download an Indicator Report",
      
      h2("Download an Indicator Report"),
      
      h3("Report parameters"),
      
      selectInput(
        inputId = "ind_species",
        label = "Species",
        choices = NEesp::species_key$Species
      ),
      
      downloadButton("ind_report", "Generate indicator report")
    ),
    
    # regression reports
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
