## ---- echo = FALSE-------------------------------------------------------
knitr::opts_chunk$set(
    comment = NA,
    quiet = TRUE,
    progress = FALSE,
    tidy = FALSE,
    cache = FALSE,
    message = FALSE,
    error = FALSE, # FALSE: always stop execution.
    warning = TRUE,
    dpi = 100
)

## ---- echo = FALSE-------------------------------------------------------
knitr::opts_knit$set(global.par = TRUE)

## ---- echo = FALSE-------------------------------------------------------
par(mar = c(3, 4, 2, 2), mgp = c(1.7, 0.5, 0), las = 1, cex.main = 1, tcl = -0.2, cex.axis = 0.8,
    cex.lab = 0.8)

## ---- fig.width = 7, fig.height = 3--------------------------------------
# load packages
library(spup)
library(raster)

# load and view the data
data(Madagascar)
par(mfrow = c(1,2))
class(OC)
class(TN)
plot(OC, main = "Mean of Organic Carbon") # vignette has problem compiling here
plot(TN, main = "Mean of Total Nitrogen")
summary(OC)
summary(TN)

## ------------------------------------------------------------------------
# define spatial correlogram models
OC_crm <- makecrm(acf0 = 0.6, range = 1000, model = "Sph")
TN_crm <- makecrm(acf0 = 0.4, range = 1000, model = "Sph")

## ---- fig.width = 7, fig.height = 3--------------------------------------
plot(OC_crm, main = "OC correlogram")
plot(TN_crm, main = "TN correlogram")

## ------------------------------------------------------------------------
# define uncertainty model for the OC and TN
OC_UM <- defineUM(TRUE, distribution = "norm", distr_param = c(OC, OC_sd), crm = OC_crm, id = "OC")
TN_UM <- defineUM(TRUE, distribution = "norm", distr_param = c(TN, TN_sd), crm = TN_crm, id = "TN")
class(OC_UM)
class(TN_UM)

## ------------------------------------------------------------------------
# define multivariate uncertainty model
mySpatialMUM <- defineMUM(UMlist = list(OC_UM, TN_UM), 
                          cormatrix = matrix(c(1,0.7,0.7,1), nrow=2, ncol=2))
class(mySpatialMUM)

## ------------------------------------------------------------------------
# create possible realizations from the joint distribution of OC and TN
OCTN_sample <- genSample(UMobject = mySpatialMUM, n = 3, samplemethod = "ugs", nmax = 20, asList = FALSE)

## ---- fig.width = 7, fig.height = 5--------------------------------------
# view the sample structure
OCTN_sample

# plot realizations of OC and TN
plot(OCTN_sample)

## ------------------------------------------------------------------------
# create possible realizations from the joint distribution of OC and TN
MC <- 100
OCTN_sample <- genSample(UMobject = mySpatialMUM, n = MC, samplemethod = "ugs", nmax = 20, asList = FALSE)

## ---- fig.width = 7, fig.height = 3--------------------------------------
# compute and plot OC and TN sample statistics
# e.g. mean and standard deviation
OC_sample <- OCTN_sample[[1:MC]]
TN_sample <- OCTN_sample[[(MC+1):(2*MC)]]
OC_sample_mean <- mean(OC_sample)
TN_sample_mean <- mean(TN_sample)
OC_sample_sd <- calc(OC_sample, fun = sd)  
TN_sample_sd <- calc(TN_sample, fun = sd)

par(mfrow= c(1,2))
plot(OC_sample_mean, main = "Mean of OC realizations")
plot(TN_sample_mean, main = "Mean of TN realizations")

## ---- fig.width = 5, fig.height = 5--------------------------------------
# R package GGally provides a nice option for plotting correlations
library(GGally)
octn <- cbind(as.data.frame(OC_sample[[1]]), as.data.frame(TN_sample[[1]]))
ggscatmat(data = octn, alpha=0.15) 
 # + theme(axis.text.x = element_text(angle = 90, vjust = 0.5))


## ------------------------------------------------------------------------
# view the model
C_N_model_raster

## ------------------------------------------------------------------------
# coerce  a raster stack to a list 
# in our example we consider two variables, so we need a list of two lists with realizations
l <- list()
l[[1]] <- map(1:100, function(x){OCTN_sample[[x]]})
l[[2]] <- map(101:200, function(x){OCTN_sample[[x]]})
OCTN_sample <- l
     
# or sample from uncertain input and return it automatically in a list by setting asList argument to TRUE (default)
OCTN_sample <- genSample(UMobject = mySpatialMUM, n = MC, samplemethod = "ugs", nmax = 20, asList = TRUE)

## ------------------------------------------------------------------------
# run uncertainty propagation
CN_sample <- propagate(realizations = OCTN_sample,
                       model = C_N_model_raster, n = MC)

## ---- fig.width = 7, fig.height = 5--------------------------------------
# coerce C/Ns list to a RasterStack
CN_sample <- stack(CN_sample)
names(CN_sample) <- paste("CN.", c(1:nlayers(CN_sample)), sep = "")

# view the sample of the model output
par(mfrow = c(1,1))
plot(CN_sample[[1:6]])

## ---- fig.width = 7, fig.height = 5--------------------------------------
# compute and plot the slope sample statistics
# e.g. mean and standard deviation
CN_mean <- mean(CN_sample)
CN_sd <- calc(CN_sample, fun = sd) 
par(mfrow = c(1,2))
plot(CN_mean, main = "C/N mean")
plot(CN_sd, main = "C/N sd")

## ---- fig.width = 7, fig.height = 3--------------------------------------
l_mean <- mean(CN_sample[which.min(OC)])
l_sd <- sd(CN_sample[which.min(OC)])
h_mean <- mean(CN_sample[which.max(OC)])
h_sd <- sd(CN_sample[which.max(OC)])

par(mfrow = c(1,2))
hist(CN_sample[which.min(OC)], main = paste("C/N at lowest OC,", "\n",
     "mean = ", round(l_mean, 2), ", sd = ", round(l_sd, 2), sep = ""), xlab = "C/N")
hist(CN_sample[which.max(OC)], main = paste("C/N at highiest OC,", "\n",
     "mean = ", round(h_mean, 2), ", sd = ", round(h_sd, 2), sep = ""), xlab = "C/N")

## ---- fig.width = 7, fig.height = 7--------------------------------------
# calculate quantiles
CN_sample_df <- as(CN_sample, "SpatialGridDataFrame")
CN_q <- quantile(CN_sample_df, probs = c(0.1, 0.25, 0.75, 0.9), na.rm = TRUE)
spplot(CN_q[c(3,4,1,2)], main = list(label = "Quantiles of C/N realizations", cex = 1))

## ---- fig.width = 7, fig.height = 7--------------------------------------
CN_q$good4crops <- factor(ifelse(CN_q$prob90perc < 24, 1, 0), labels = c("Good quality","Improvements needed"))
spplot(CN_q, "good4crops", col.regions = c("darkolivegreen2","firebrick1"), main = "Areas with sufficient C/N")

## ---- fig.width = 7, fig.height = 7--------------------------------------
# calculate total variance as a measure of total uncertainty
CN_tot_var <- calc(CN_sample, fun = var)

# OC contribution
OC_sample <- OCTN_sample[[1]]
CN_sample_oc <- propagate(realizations = OC_sample, model = C_N_model_raster, TN = TN, n = MC)
CN_sample_oc <- stack(CN_sample_oc)
CN_oc_var <- calc(CN_sample_oc, fun = var)
OC_contribution <- (CN_oc_var/CN_tot_var)*100

# TN contribution
TN_sample <- OCTN_sample[[2]]
CN_sample_tn <- propagate(realizations = TN_sample, model = C_N_model_raster, OC = OC, n = MC)
CN_sample_tn <- stack(CN_sample_tn)
CN_tn_var <- calc(CN_sample_tn, fun = var)
TN_contribution <- (CN_tn_var/CN_tot_var)*100

# plot results
par(mfrow = c(2,2))
plot(CN_mean, main = "C/N mean")
plot(CN_sd, main = "C/N sd")
plot(OC_contribution, main = "OC contribution to total C/N var [%]")
plot(TN_contribution, main = "TN contribution to total C/N var [%]")

