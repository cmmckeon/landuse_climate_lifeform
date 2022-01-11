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


# plotRGB(temp_var_stack, r = 1, g = 3, b = 2, scale = 1)
#   points(full_clim[, 'Longitude'], full_clim[,'Latitude'], pch = 20)
#   text(x = temp_var_stack$bio_1.1@extent@xmin+10, y = temp_var_stack$bio_1.1@extent@ymax - 3, labels = 'a)', cex = 2)
  
        

#par(bg= "white")
#plot(temp_scaled, col= viridis_pal(option="F")(255), alpha = 1)
# par(bty = "n")
# plot(var_scaled, col=viridis_pal(option="G", direction = 1)(255))
# points(full_clim[, 'Longitude'], full_clim[,'Latitude'], pch = 21, col = "orange",  cex = 2)
# text(x = temp_var_stack$bio_1.1@extent@xmin+90, y = temp_var_stack$bio_1.1@extent@ymax - 1, 
#      labels = 'Temperature variablity (scaled)', cex = 3)
#  
#   #plot(temp_scaled, col= viridis_pal(option="F")(255), alpha = 1)
#   #par(bg="transparent")
#   plot(var_scaled, col = "grey")
#   points(full_clim[, 'Longitude'], full_clim[,'Latitude'], pch = 21, col = "black", cex = 2)
#   text(x = temp_var_stack$bio_1.1@extent@xmin+70, y = temp_var_stack$bio_1.1@extent@ymax - 1, 
#        labels = 'Data origins', cex = 3)
  
  par(bg= "black", bty = "l", col="white", col.main = "white", col.lab = "white", col.axis = "white")
  #par(bg= "transparent")
  colfunc <- colorRampPalette(c("white", "#A715AD"))
  #colfunc <- colorRampPalette(c("#F4E4F5", "#A715AD"))
  plot(var_scaled, col = colfunc(255))
  points(full_clim[, 'Longitude'], full_clim[,'Latitude'], pch = 21, col = "orange", cex = 1)


  # par(bg= "white")
  # #plot(temp_scaled, col= viridis_pal(option="F")(255), alpha = 1)
  # #par(bg="transparent")
  # plot(layer_of_0, col=viridis_pal(option="G", direction = 1)(255), alpha = 1)
  # points(full_clim[, 'Longitude'], full_clim[,'Latitude'], pch = 21, col = "orange",  cex = 2, alpha = 0.5)
  # points(full_clim[, 'Longitude'], full_clim[,'Latitude'], pch = 21, col = "orange",  cex = 1, alpha = 0.5)
  # 
  
  # ggplot(data = world, aes(fill="grey", colour="grey")) +
  #   geom_sf(fill="grey", colour="grey") +
  #  # coord_sf(crs = "+proj=laea +lat_0=53 +lon_0=9 +x_0=4321000 +y_0=3210000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs ")+
  #   theme_void()

  # screen(3)# plot the environmetnal space
  # #make 2D legend for colours
  # dummy_temp <- raster(matrix(rep(seq(0, 1, length = 500), 500), ncol = 500, byrow = TRUE))
  # dummy_var <- raster(matrix(rep(seq(1, 0, length = 500), 500), ncol = 500, byrow = FALSE))
  # dummy_0 <- raster(matrix(rep(rep(0, 500), 500), ncol = 500)) 
  # legend_stack <- stack(dummy_temp, dummy_var, dummy_0)
  # par(mar = c(5, 6, 3, 1))
  # plot(seq(0, 1, 0.2), seq(0, 1, 0.2), type = 'n', bty = 'n', axes = FALSE, xlab = 'Mean annual temperature (C)', 
  #      ylab = 'Temperature seasonality', cex.lab = 1.5, cex.axis = 1.2,
  #      main = 'Temperature environmental space ', cex.main = 1.5)
  # mtext('b)', side = 3, adj = -0.2, cex = 2)
  # 
  # plotRGB(legend_stack, r = 1, g = 3, b = 2, scale = 1, add = TRUE)#, axes = TRUE, xlab = 'mean annual tempature', ylab = 'tempature seasonality')
  # axis(side = 1, at = seq(0, 1, length = 5), labels = round(seq(temp_min, env_pred$bio_1@data@max, length = 5)/10, 1), line = 0.7, tck = 0.02) 
  # axis(side = 2, at = seq(0, 1, length = 5), labels = round(seq(var_min, env_pred$bio_4@data@max, length = 5)/100, 1), line = 0.7, tck = 0.02) 
  # #plot the points of where my study points lie in that environmental space
  # #color code gray by PCA1 score 
  # points(obs_temp_scaled, obs_var_scaled, pch = 20)
  
  