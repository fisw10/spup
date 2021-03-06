% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/defineMUM.r
\name{defineMUM}
\alias{defineMUM}
\title{Define Mulivariate Uncertainty Model}
\usage{
defineMUM(UMlist, cormatrix, ...)
}
\arguments{
\item{UMlist}{a list of uncertain objects creaded in defineUM()}

\item{cormatrix}{matrix of cross-correlations}

\item{...}{}
}
\value{
Object of a class "JointNumericSpatial" or "JointScalar".
}
\description{
In case of scalar a square matrix of correlations,
dimentionally equal to the number of objects, square, symetric 
(transposed must be the same as original, diagonal must all be 1
all values must be <-1, +1>) and all eigenvalues must be > 0.
}
\details{
For the spatial object the
}
\examples{

data(Madagascar)
OC_crm <- makecrm(acf0 = 0.6, range = 1000, model = "Sph")
OC_UM <- defineUM(TRUE, distribution = "norm", distr_param = c(OC, OC_sd), crm = OC_crm, id = "OC")
class(OC_UM)
TN_crm <- makecrm(acf0 = 0.4, range = 1000, model = "Sph")
TN_UM <- defineUM(TRUE, distribution = "norm", distr_param = c(TN, TN_sd), crm = TN_crm, id = "TN")
class(TN_UM)

soil_prop <- list(OC_UM,TN_UM)
str(soil_prop)
mySpatialMUM <- defineMUM(soil_prop, matrix(c(1,0.7,0.7,1), nrow=2, ncol=2))
class(mySpatialMUM)
str(mySpatialMUM)

# scalar
scalarUM <- defineUM(uncertain = TRUE, distribution = "norm", distr_param = c(1, 2), id="Var1")                
scalarUM2 <- defineUM(uncertain = TRUE, distribution = "norm", distr_param = c(3, 2), id="Var2")
scalarUM3 <- defineUM(uncertain = TRUE, distribution = "norm", distr_param = c(10, 2.5), id="Var3")                
myMUM <- defineMUM(UMlist = list(scalarUM, scalarUM2, scalarUM3), 
               matrix(c(1,0.7,0.2,0.7,1,0.5,0.2,0.5,1), nrow = 3, ncol = 3))
class(myMUM)

}

