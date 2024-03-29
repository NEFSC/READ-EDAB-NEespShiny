% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/global.R
\name{render_ind_page_shiny}
\alias{render_ind_page_shiny}
\title{Render shiny indicator page}
\usage{
render_ind_page_shiny(x, input, file)
}
\arguments{
\item{x}{Species common name}

\item{input}{The folder to copy the report template files from. Defaults to "package", which copies the template files from the NEesp package.}

\item{file}{The name of the .Rmd file to render (if taking from the package template), or the uploaded .Rmd files}
}
\description{
Render shiny indicator page. Bookdown files are copied into the working directory and the report is generated in the working directory. Suggest to change to a temp directory before running.
}
