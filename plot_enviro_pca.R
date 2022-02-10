## sites by cliamte space map
## adapted from shaun coutts github
library(raster)
library(rasterVis)
library(httr)
library(scales)


if(!exists("ModelDF")) {
  if(file.exists("Data_ModelDF.rds")) {
    try(ModelDF <- readRDS("Data_ModelDF.rds"))
  } else warning("ModelDF does not exist in this directory")
}

bio_1 <-raster('bio1.bil') ## mean annual temperature (C*10)
bio_12 <-raster('bio12.bil') ## mean annual precipatation (mm)
bio_15 <-raster('bio15.bil') ## mean annual precip coeff variation
bio_4 <-raster('bio4.bil') ## mean annual temp SD*100


PR_co <- ModelDF %>% .[, which(names(.) %in% c("Longitude", "Latitude"))]

## make climate variables into one object (raster brick)
env_pred <- stack(bio_1, bio_4, bio_12, bio_15) 
names(env_pred) <- c("bio_1", "bio_4", "bio_12", "bio_15") 

## #extract climate values for coordinates in (full) PREDICTS dataset
full_clim <- data.frame(raster::extract(env_pred,PR_co)) 
## create dataset with both climate values and co-ordinates of the values
full_clim <- cbind(full_clim,PR_co)
full_clim <- unique(full_clim)
names(full_clim) <- c("bio_1", "bio_4", "bio_12", "bio_15","Longitude", "Latitude") 


temp_range <- env_pred$bio_1@data@max - env_pred$bio_1@data@min
  temp_min <- env_pred$bio_1@data@min
  temp_scaled <- (env_pred$bio_1 - temp_min) / temp_range
  var_range <- env_pred$bio_4@data@max - env_pred$bio_4@data@min
  var_min <- env_pred$bio_4@data@min
  var_scaled <- (env_pred$bio_4 - var_min) / var_range
  obs_temp_scaled <- (full_clim$bio_1 - temp_min) / temp_range
  obs_var_scaled <- (full_clim$bio_4 - var_min) / var_range
  layer_of_0 <- env_pred$bio_1*0
  temp_var_stack <- stack(temp_scaled, var_scaled, layer_of_0)
  
  par(bg= "black", bty = "l", col="white", col.main = "white", col.lab = "white", col.axis = "white")
  #par(bg= "transparent")
  colfunc <- colorRampPalette(c("white", "#A715AD"))
  #colfunc <- colorRampPalette(c("#F4E4F5", "#A715AD"))
  plot(var_scaled, col = colfunc(255))
  points(full_clim[, 'Longitude'], full_clim[,'Latitude'], pch = 21, col = "orange", cex = 1)



  
  