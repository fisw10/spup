% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/propagate.R
\name{propagate}
\alias{propagate}
\title{Title Propagation function}
\usage{
propagate(realizations, model, n, ...)
}
\arguments{
\item{realizations}{a list or a list of lists; max one nesting is allowed.}

\item{model}{a model that is written as a function in R.}

\item{n}{number of Monte Carlo Runs.}

\item{...}{any arguments that the model takes on top of realizations.}
}
\value{
model output realizations
}
\description{
Title Propagation function
}
\examples{

# continuous spatial data example with a single variable
data(DEM)
dem_crm <- makecrm(acf0 = 0.78, range = 321, model = "Exp")
demUM <- defineUM(uncertain = TRUE, distribution = "norm", 
                   distr_param = c(dem30m, dem30m_sd), crm = dem_crm)
dem_sample <- genSample(UMobject = demUM, n = 5, samplemethod = "ugs", nmax = 20)
slope_sample <- propagate(dem_sample, model = Slope, n = 5, projection = CRS("+init=epsg:3857"))

# categorical spatial data example
data(Rotterdam)
woonUM <- defineUM(TRUE, categories = c(1,2,3), cat_prob = woon[, c(4:6)])
woon_sample <- genSample(woonUM, 10)
class(woon_sample)
tax # the model takes SpatialGridDataFrame with a column called "Function"
for (i in 1:10) names(woon_sample[[i]]) <- "Function"
tax_uncert <- propagate(realizations = woon_sample, n = 10, model = tax)
tax_uncert <- unlist(tax_uncert)
summary(tax_uncert)

# cross-correlated example
# load data
data(Madagascar)

# define marginal UMs
OC_crm <- makecrm(acf0 = 0.6, range = 1000, model = "Sph")
OC_UM <- defineUM(TRUE, distribution = "norm", distr_param = c(OC, OC_sd), crm = OC_crm, id = "OC")
TN_crm <- makecrm(acf0 = 0.4, range = 1000, model = "Sph")
TN_UM <- defineUM(TRUE, distribution = "norm", distr_param = c(TN, TN_sd), crm = TN_crm, id = "TN")

# define joint UM
mySpatialMUM <- defineMUM(list(OC_UM, TN_UM), matrix(c(1,0.7,0.7,1), nrow=2, ncol=2))

# sample - "ugs" method
my_cross_sample <- genSample(mySpatialMUM, 5, "ugs", nmax = 24)
class(my_cross_sample)

# run propagation
CN_sample <- propagate(realizations = my_cross_sample, model = C_N_model_raster, n = 5)
CN_sample


}

