% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/list_depth.R
\name{list_depth}
\alias{list_depth}
\title{Title depth}
\usage{
list_depth(List)
}
\arguments{
\item{List}{an object of class 'list'}
}
\value{
an integer; level of list nesting
}
\description{
Title depth
}
\examples{

a <- list(1,2)
list_depth(a)

a <- list(list(1, 2), 3)
list_depth(a)

}

