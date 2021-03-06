#' Generating Monte Carlo sample from an uncertain object of a class 
#' 'MarginalCategoricalSpatial'
#'
#' @usage genSample(UMobject, n, ...)
#'
#' @param UMobject uncertain object defined using defineUM().
#' @param n Integer. Number of Monte Carlo realizations.
#' @param ... additional parameters
#' 
#' @return A Monte Carlo sample of a categorical spatial variable.
#' 
#' @author Kasia Sawicka
#' 
#' @examples
#'
#' # load data
#' data(house)
#' houseUM <- defineUM(uncertain = TRUE, categories = c(100,200), cat_prob = houses_DF)
#' h_sample <- genSample(houseUM, n = 10)
#' str(h_sample)
#'
#' # load data
#' data(Rotterdam)
#' woonUM <- defineUM(TRUE, categories = c(1,2,3), cat_prob = woon[, c(4:6)])
#' # woon_sample <- genSample(woonUM, 10, asList=FALSE)
#' # class(woon_sample)
#' # str(woon_sample@data)
#' # spplot(woon_sample)
#' woon_sample <- genSample(woonUM, 10)
#' class(woon_sample)
#' 
#' # analyse probability of having snow
#' # load data
#' data(DEM)
#' 
#' # generate dummy probabilities for categories "snow" and "no snow"
#' dem30m$snow_prob <- NA
#' dem30m$snow_prob[dem30m$Elevation > 1000] <- 0.75
#' dem30m$snow_prob[dem30m$Elevation <= 1000] <- 0.25
#' dem30m$no_snow_prob <- 1 - dem30m$snow_prob
#' summary(dem30m@data)
#' snowUM <- defineUM(uncertain = TRUE, categories = c("snow", "no snow"), cat_prob = dem30m[2:3])
#' class(snowUM)
#' snow_sample <- genSample(snowUM, 10, asList=F)
#' head(snow_sample@data)
#' 
#' # case with raster
#' # load data
#' data(DEM)
#' dem30m$snow_prob <- NA
#' dem30m$snow_prob[dem30m$Elevation > 1000] <- 0.75
#' dem30m$snow_prob[dem30m$Elevation <= 1000] <- 0.25
#' dem30m$no_snow_prob <- 1 - dem30m$snow_prob
#' summary(dem30m@data)
#' dem_stack <- raster::stack(dem30m)
#' snowUM <- defineUM(uncertain = TRUE, categories = c("snow", "no snow"), cat_prob = dem_stack[[2:3]])
#' snow_sample <- genSample(snowUM, 10, asList=F)
#' plot(snow_sample)
#'
#' @export
genSample.MarginalCategoricalSpatial <- function(UMobject, n, asList = TRUE, ...) {

  # extract information from UMobject
  categories <- UMobject[[2]]
  cat_prob <- UMobject[[3]]
  
  # recognise if dealing with rester or spatial data frame objects,
  # if raster then converst it to spatial grid
  if (is(cat_prob, "RasterStack")) {
    original_class <- "RasterLayer"
    cat_prob <- as(cat_prob, "SpatialGridDataFrame")
  } else {
    original_class <- "SpatialDF"
  }
  
  # 
  X_sample <- cat_prob[1] # assign geometry
  cat_prob <- cat_prob@data  
  in1mtx <- as.matrix(cat_prob)
  
  # sample
  temp_samples <- t(apply(in1mtx, MARGIN = 1, 
                          function(x) sample(categories, 
                                             size = n, 
                                             replace = TRUE, 
                                             prob = x)))
  
  X_sample@data <- as.data.frame(temp_samples)
  
  # sort out the names
  if (!is.null(UMobject$id)) {
    names(X_sample@data) <- paste(UMobject$id, ".sim", c(1:n), sep = "")
  } else {
    names(X_sample@data) <- paste("sim", c(1:n), sep = "")}

  # sort out final product depending on if Raster or spatial data frame
  # and if object to be returned as list
  if (original_class == "RasterLayer") {
    X_sample <- raster::stack(X_sample)
    if (asList == TRUE) {
      X_sample <- map(1:n, function(x){X_sample[[x]]})
    }
  } else if (asList == TRUE) {
    X_sample <- map(1:n, function(x){X_sample[x]}) # convert SpGridDF to list
  }
  
  X_sample
}



