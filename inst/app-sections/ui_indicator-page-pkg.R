# indicator rendered from package ----
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
                         pattern = ".Rmd"
    ) %>%
      stringr::str_subset("child-doc.Rmd", negate = TRUE) %>%
      stringr::str_subset("index.Rmd", negate = TRUE)
  ),
  
  actionButton("go", "click"),
  
  htmlOutput("markdown")
  
  # htmlwidgets::shinyWidgetOutput("markdown",
  #                               name = "datatable",
  #                               package = "DT",
  #                               width = "100%",
  #                               height = "100%")
)