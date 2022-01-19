# title: "LF_01_data_handling.R"
# author: "Caroline Mckeon"
# date started: "18/6/2019"
# last updated: "03/04/2020"

## to do:


## This script is the cluster runnable version of 01_data_handling.Rmd, for obtaining, manipulating, cleaning and 
## aggregating the data to be used in the modelling dataset for investigating the effects of Raunkiaerian Life Form on 
## plant population responses to human land use. Also creates some overview plots

## DATA NEEDED:

# Data_01_PR_plantDiversityCorr.rds  - plant data from PREDICTS project: a global dataset of local biodiversity responses to land-use (Hudson et al., 2016)
## obtained from PREDICTS team in 2017
# Data_01_sitediversityData.rds - site level species diversity data, calculated by PREDICTS team in 2017
# Data_01_try_species_info.csv - TRY plant trait database species info (version 5)
# Data_01_trait_info_try.csv - TRY plant trait database trait info (version 5)
# Data_01_lifeform_try.txt - TRY plant trait database lifeform data (version 5)

# Data_01_sp.list_BIEN.rds -BIEN plant database species list, obtained in 2019 using lines 75-101
# Data_01_lifeform_bien.rds - BIEN plant database lifeform data, obtained in 2019 using lines 75-101

## bioclim variables from WorldClim version 1.4 - statistical summaries of climatic variables as static spatial bioclimatic variables at 30 second resolution, 
## calculated using monthly records for temperature and rainfall from 1970-2000 (Fick & Hijmans, 2017). 
# bio1.bil ## mean annual temperature (C*10)
# bio12.bil ## mean annual precipatation (mm)
# bio15.bil ## mean annual precip coeff variation
# bio4.bil ## mean annual temp SD*100


## shell commands for running on the cluster
## ssh -l mckeonc2 lonsdale.tchpc.tcd.ie
## password: 

## Set up
#install.packages(c("tidyverse", "raster", "rgdal", "RColorBrewer"))
library(tidyverse)
library(raster)
library(rgdal)
library(RColorBrewer)

## create "not in" operator
'%nin%' = Negate('%in%')


##### Part 1: Get Species lists#######################

## get progress messages
print("***Starting reading in species lists***")

## PREDICTS Data
## Read in PREDICTS plant data (2016 release) (Effort Corrected)
PR <- readRDS("Data_01_PR_plantDiversityCorr.rds") 

## create species list vector for PREDICTS species
sp.list_PR <- as.vector(unique(PR$Best_guess_binomial)) ## 30255
#saveRDS(sp.list_PR, "Data_sp.list_PR.rds")


## TRY Data
##(Mannually download and) read in TRY species info data (version 5)
sp.info_try <- read.csv("Data_01_try_species_info.csv") ## 279875 obs of 7 vars

## Get the list of TRY species for which there are PREDICTS data
sp.list_TRY <- Reduce(intersect, list(unique(sp.info_try$AccSpeciesName),unique(PR$Best_guess_binomial))) ## 9709 species
#saveRDS(sp.list_TRY, "Data_sp.list_TRY.rds")


## BIEN Data
## Get the list of BIEN species for which there are PREDICTS data*
## * if you get errors connecting to server it is because the trinity network blocks SQL connections. 
## Hotspot or try another network and should work fine. 

# bien_sp <- BIEN_list_all() ## 331065 obs of 1 var
# sp.list_BIEN <- Reduce(intersect, list(unique(bien_sp$species),unique(PR$Best_guess_binomial))) ## 10080 speices
#saveRDS(sp.list_BIEN, "Data_sp.list_BIEN.rds")

## or read back in 
sp.list_BIEN <-readRDS("Data_01_sp.list_BIEN.rds") ## 10080 speices


#Get overlap between TRY and BIEN
sp.list_TRY_BIEN <- Reduce(intersect, list(sp.list_BIEN,sp.list_TRY)) ## 9064 speices
#saveRDS(sp.list_TRY_BIEN, "Data_overlap_TRY_BIEN.rds")

## get progress messages
print("***Finshed reading in species lists***")
print("***Starting reading in trait lists***")

#### Part 2: Get Traits###################

## Bien

#Get list of traits available from BIEN

# trait_info_bien <- BIEN_trait_list() ## 53 traits
# #saveRDS(trait_info_bien, "Data_trait_info_bien.rds")
# 
# ## quick check
# y <- BIEN_trait_species("Poa annua") # 160 values for a total of 18 traits
# 
# ## Get life form data from BIEN
# ## get specific traits for specific species
# lifeform_bien <- BIEN_trait_traitbyspecies("whole plant growth form",species=sp.list_BIEN) ## 84206 obs of 13 vars
# #saveRDS(lifeform_bien, "Data_lifeform_bien.rds")

lifeform_bien <-readRDS("Data_01_lifeform_bien.rds") ## 84205 obs of 13 vars
## there are about 300 species in this bien life form list absent from the PREDICTS list. 

## TRY

# Get life form data from TRY
# Read in TRY trait list
trait_info_try <- read.csv("Data_01_trait_info_try.csv")

## fix the column names for this dataframe
trait_info_try <- trait_info_try[-c(1:2),] 
colnames(trait_info_try) <- levels(unlist(droplevels(trait_info_try[1,])))
trait_info_try <- trait_info_try[-1,]


#Get list of TRY trait codes for lifeform type traits
# lifeform_try_list <- trait_info_try[trait_info_try$Trait %in% c("Plant growth form", 
#                                                                 "Plant clonal growth form",
#                                                                 "Plant growth form detailed consolidated",
#                                                                 "Plant growth form simple consolidated", 
#                                                                 "Plant life form (Raunkiaer life form)",
#                                                                 "Moss: plant growth form (morphological)"),]
# 
# lifeform_try_traitIDs <- cat(paste(lifeform_try_list$TraitID, collapse = ", "))

## Get TRY species IDs to extract from database (OR use all TRY species with lifeform data available?)
#cat(paste(sp.info_try$AccSpeciesID[sp.info_try$AccSpeciesName %in% sp.list_TRY], collapse = ", ")) 
# Now request data corresponding to these lists from the TRY Dataportal on the website.
# Then download and read in this data.

## get progress messages
print("***Starting reading TRY life form data (large file)***")

## Note VERY large file, takes for ever and sometimes hangs. Read in subsiquent premade datasets whenever possible.
lifeform_try <- read.delim("Data_01_lifeform_try.txt", quote = "")

#names(lifeform_try)


# So I think I got more data than I asked for...
# There are 800+ levels in "DataNames" when there should be 6.


## get progress messages
print("***Finished reading TRY life form data (large file)***")
print("***Finished reading species list and traits***")
print("***Starting cleaning data***")

### Part 3: Clean data #########################


## TRY life form 

## Subset by the "TraitNames" I want
lifeform_try <- lifeform_try[lifeform_try$TraitName %in% c("Plant growth form", "Plant life form (Raunkiaer life form)"),]  


## Ok: 1585 levels in "OrgValueStr" (trait value) when we are only looking at relevant traits. 
## First, subdivide dataset by lifeform trait

pgf <- lifeform_try[lifeform_try$TraitName == "Plant growth form",]
pgl_raunk <- lifeform_try[lifeform_try$TraitName == "Plant life form (Raunkiaer life form)",]
# saveRDS(pgl, "Data_try_Plant.growth.form.rds")
# saveRDS(pgl_raunk, "Data_try_Plant.growth.form.raunkiear.rds")

## Now see how the levels divide up between them
pgl_raunk <-readRDS("Data_try_Plant.growth.form.raunkiear.rds") ##28634 obs of 28 vars
pgf <- readRDS("Data_try_Plant.growth.form.Rds")
# levels(factor(pgl$OrigValueStr)) ##1442
# levels(factor(pgl_clonal$OrigValueStr)) ## 22
# levels(factor(pgl_raunk$OrigValueStr)) ##144
# levels(factor(pgl_moss$OrigValueStr)) ## 2

## only "Plant growth form" and "Plant life form ((Raunkiaer life form)" have relevent levels.
## lets see how many species' life forms we can get out of these with some cleaning

## Looking at the Raunkier life form trait
#pgl_raunk$OrigValueStr %>% factor(.) %>% table(.) %>% .[order(.)]

## Source cleaning script for TRY raunkiaer lifeform levels
## initially 144 levels
source("cleaning_try.lifeform_raunk.R") ## currently should clean to 65
# Remaining extra levels are things like category1/category2, unitelligable short letter codes and non-standard levels to be dropped
# using a subset of try raunkiaer life form data with straight forward categories to model with
length(unique(raunk5$AccSpeciesName)) ## 11337 species


## looking at growth form (not classed as raunkiear) try data
#pgf$OrigValueStr %>% levels(.)

## initially 1442 levels yikes
source("cleaning_try.lifeform.R") ## not cleaning that well, but should be able to use some of the 
## more obvious (and luckily data heavy) levels

## add life forms from "non-raunkiear" life form try data
lifeform <- rbind(raunk5, lfs) ## 400886 obs 28 vars
lifeform <- lifeform[, which(names(lifeform) %in% c("AccSpeciesName", "OrigValueStr")),]
names(lifeform)[names(lifeform) == 'OrigValueStr'] <- 'raunk_lf'
length(unique(lifeform$AccSpeciesName)) ## 40369 (bajillions)

## BIEN life form 

## Want lifeform levels as Raunkiear plant life forms
## initially 139 levels 
source("cleaning_bien.lifeform.R")

bien_lfs <- bien_lfs[, which(names(bien_lfs) %in% c("scrubbed_species_binomial", "trait_value"))]
names(bien_lfs)[names(bien_lfs) == c("scrubbed_species_binomial", "trait_value")] <-  c("AccSpeciesName", "raunk_lf")
lifeform <- rbind(lifeform, bien_lfs) ## 40499 unique species
lifeform$raunk_lf[lifeform$raunk_lf == "geophyte" |lifeform$raunk_lf == "hydrophyte"] <- "cryptophyte"

## Create new column detailing how many life form catergories have been entered in try for each species
# for (i in unique(lifeform$AccSpeciesName)){
#   lifeform$numberlifeforms[lifeform$AccSpeciesName ==i] <- length(unique(levels(factor(lifeform$raunk_lf[lifeform$AccSpeciesName ==i]))))
# }
# ## pretty much all species are entered as only having 1 life form so not that usable as a variable
# length(unique(lifeform$AccSpeciesName[lifeform$numberlifeforms !=1]))
# length(unique(lifeform$AccSpeciesName[lifeform$numberlifeforms ==1]))
#write_csv(lifeform, "Data_lifeform.csv")


## get progress messages
print("***Finished cleaning species list and traits data***")
print("***Starting preparing additional variables***")


### Part 4: Prepare additional variables ################


## Bioclim

#Reading in bioclim

#lifeform <- read.csv("Data_try_lifeform.csv")
# sp.list_TRY <-readRDS("Data_sp.list_TRY.rds")
# try_height <- readRDS("Data_try_PR_height.csv")
mat <-raster('bio1.bil') ## mean annual temperature (C*10)
map <-raster('bio12.bil') ## mean annual precipatation (mm)
map_var <-raster('bio15.bil') ## mean annual precip coeff variation
mat_var <-raster('bio4.bil') ## mean annual temp SD*100


#Subset PREDICTS data keeping only variables relevant to anlaysis

PR <- PR %>% .[.$Best_guess_binomial %in% lifeform$AccSpeciesName,]
length(unique(PR$Best_guess_binomial)) #5313
#dput(names(PR))
PR <- PR %>% .[.$Diversity_metric == "abundance" | .$Diversity_metric == "percent cover"| .$Diversity_metric == "occurrence",]
PR <- PR %>% .[, which(names(.) %in% c("Study_name", "Region", "Diversity_metric","Predominant_habitat",
                                       "Use_intensity", "Fragmentation_layout", "Longitude", "Latitude", 
                                       "Country", "Biome", "Measurement", "SS", "SSS", "SSB", "SSBS",
                                       "Best_guess_binomial"))] ##, "Sample_midpoint", "Sample_start_earliest", "Sample_end_latest"))] ## can be included for checking data date range
PR <- droplevels(PR)
PR <-unique(PR) ## 5551081 obs of 16 vars

## Explore raster data

par(bty ="n")
plot(map)
plot(mat)
plot(map_var)
plot(mat_var)


## Handle raster climate data

#PR <- readRDS("Data_PR_plantDiversityCorr.rds") 
## make dataframe with just the lat and long co-ordinates of PREDICTS data that is relevant to my analysis
PR_co <- PR %>% .[, which(names(.) %in% c("Longitude", "Latitude"))]

## make climate variables into one object (raster brick)
clim_map <- brick(map, mat, map_var, mat_var) 

## #extract climate values for coordinates in (full) PREDICTS dataset
full_clim <- drop_na(data.frame(raster::extract(clim_map,PR_co))) 

## create dataset with both climate values and co-ordinates of the values
full_clim <- cbind(full_clim,PR_co)
full_clim <- unique(full_clim)
names(full_clim) <- c("map", "mat", "map_var", "mat_var","Longitude", "Latitude") 

## should now have df with 4285 obs of 6 variables, corresponding to the 
## latitude and longtitude of the 4 climate variables to be used in modelling for PREDICTS data

plot(full_clim)
#plot(clim_map)


# Mapping locations I have data for
# Try throw in a bit of transparency ect for emphasising spots with loads of records.
# WorldData <- map_data('world')
# ggplot(WorldData, aes(x=long, y=lat)) +
#   geom_map(data=WorldData, map=WorldData,
#            aes(x=long, y=lat, map_id=region),
#            fill="white", colour="#7f7f7f")+ #, size=0.5)+
#   geom_point(data=PR, aes(x=Longitude, y=Latitude), size=0.9, colour="red")


## Site diversity

## Read in site level diversity
Site_Div <- readRDS("Data_01_sitediversityData.rds")

#x <- Reduce(intersect, list(unique(PR$SSBS),unique(Site_Div$SSBS))) ## 

#Subset site level diversity
Site_Div <- Site_Div %>% .[.$SSBS %in% unique(PR$SSBS),]
Site_Div <- droplevels(Site_Div)
Site_Div <-unique(Site_Div) ## 4002 obs. of 11 vars

## for now, keep only species richness, total abundance and simpson's diverity from site level diveristy variables
## leaving out total abundance for now as what does this mean? and when it's included I can't investigate occurrence data as there is none for occurrence 
Site_Div <- Site_Div %>% .[, which(names(.) %in% c("SSBS",# "Total_abundance", 
                                                   "Species_richness"#, "Simpson_diversity"
))]


## Human footprint
# no longer used as a variable, but retained as it affects the creation of the final model dataframe
# (same final number of species, but changes the number of sites slightly, and so it is being kept in for reproducibility)

## read in human footprint data

hf <- raster("Data_01_wildareas-v3-2009-human-footprint-geotiff/wildareas-v3-2009-human-footprint.tif")

# now I want to visualise this nicely... good link for tips:
#   http://www.nickeubank.com/wp-content/uploads/2015/10/RGIS3_MakingMaps_part2_mappingRasterData.html 
# https://rspatial.org/raster/spatial/8-rastermanip.html

## Map human footprint dataa
pal <- colorRampPalette(c('#0C276C', '#3B9088', '#EEFF00', '#ffffff'))
hf_map <- calc(hf, fun=function(x){ x[x > 100] <- NA; return(x)} )
par(bty = "n", mar=c(0.02,0.02,2,0.2))
plot(hf_map, col = pal(50), main = "Human footprint 2009", yaxt="n", xaxt="n")


## Co-ordinate system and spatial extent of human footprint diffirent from PR and bioclim. Must reproject.
## https://datacarpentry.org/r-raster-vector-geospatial/03-raster-reproject-in-r/
## Reproject human footprint value on to the specs of the bioclim data so it's compatible with PR co-ordinates
hf_repro <- projectRaster(hf, clim_map)

## I reprojected this raster to bioclim specs, but bioclim is at a much lower resolution, so I am getting a
## averaged values instead of the detail I had before. Because human footprint value was averaged over adjacent 
## grid cells to reduce resolution when reprojection, we get a few values that are higher than they should be, 
## i.e. cells that were beside water bodies (given 120 value to distinguish from terrestrial values which were all sub 80 or so). 
## So removing those high values, as that might be stopping models with human footprint from converging. 

## Quick visualisation inspection to be sure it worked
map
hf_repro


#hf_repro_map <- calc(hf_repro, fun=function(x){ x[x > 100] <- NA; return(x)} )
plot(hf_repro, col = pal(50))
plot(map,col = pal(50))

## Successful, but gives a huge drop in resolution

## Show sites in relation to human footprint
par(bty = "n", mar=c(0.02,0.02,2,0.2))
hf_repro_map <- calc(hf_repro, fun=function(x){ x[x > 100] <- NA; return(x)} )
plot(hf_repro_map, col = pal(50), main = "Sites and Human footprint", yaxt="n", xaxt="n")
points(PR_co$Longitude, PR_co$Latitude, type = "p", col = "orange")


## Handle raster human footprint data so it can be added to modeling dataframe

## #extract climate values for coordinates in (full) PREDICTS dataset
full_humanfoot <- data.frame(raster::extract(hf_repro,PR_co)) 
## create dataset with both climate values and co-ordinates of the values
full_humanfoot <- cbind(full_humanfoot,PR_co)
full_humanfoot <- unique(full_humanfoot)
names(full_humanfoot) <- c("humanfootprint_value","Longitude", "Latitude") 


##  drop humanfootprint data where values are greater than 80, which results from averging of 
## cell values when resolution was reduced during reprojection. (there actually are non because of dropping values greater 
## than 100 before reprojecting)
full_humanfoot <- full_humanfoot[full_humanfoot$humanfootprint_value <= 80,]

## should now have df with (less than) 18824 (actually 4309) obs of 3 variables, corresponding to the 
## latitude and longtitude of the human footprint values to be used in modelling for PREDICTS data

## WOOOOOOO!

## get progress messages
print("***Finshed preparing additional variables***")
print("***Starting creating model dataset***")

#### Part 5: Create model dataset  ###############


#Combine all datasets into one modelling dataframe

ModelDF <- merge(PR, lifeform, by.x = "Best_guess_binomial", by.y = "AccSpeciesName", all.x = TRUE) ## 2450447 obs. of 19 vars
ModelDF <- merge(ModelDF, Site_Div, by = "SSBS", all.x = TRUE) ## 2450447 obs. of 20 vars
ModelDF <- merge(ModelDF, full_clim, by = c("Longitude","Latitude"), all.x = TRUE) ## 2450447 obs. of 24 vars
ModelDF <- merge(ModelDF, full_humanfoot, by = c("Longitude","Latitude"), all.x = TRUE) ## 2450447 obs. of 25 vars
ModelDF <- unique(ModelDF)

## Find and remove all NA containing rows from dataframe
## Looking at which varibles still contain NAs
list <- c()
for (i in names(ModelDF)){
  list[i] <-length(which(is.na(ModelDF[,i])))
}

print(list) ## all variables should be zero 

ModelDF$Best_guess_binomial %>% unique(.) %>% length(.) ## 4804

## Drop NAs 
ModelDF <- ModelDF %>% drop_na() ## Model dataframe (ModelDF) currently 624696 obs of 23 variables
save <- ModelDF
ModelDF <- save

cont_vars <- c("map", "map_var", "Species_richness", "mat", "mat_var")
for(i in cont_vars){
  ModelDF[,paste(i, "_unscaled", sep = "")] <- ModelDF[,i]
}

## Scale continuous variables so that the effect sizes can be directly compared
cont_vars <- c("map", "map_var", "Species_richness", "mat", "mat_var", "humanfootprint_value")
for (i in cont_vars){
  ModelDF[, i] <- c(scale(ModelDF[,i]))
}

## Save
ModelDF$raunk_lf <- as.factor(ModelDF$raunk_lf)
ModelDF <- unique(ModelDF) ## 624696 obs. of 28 vars 

## create occurrence column 
ModelDF$pc_binary[ModelDF$Diversity_metric == "percent cover"] <- 1
ModelDF$pc_binary[ModelDF$Diversity_metric == "percent cover" &
                    ModelDF$Measurement == 0] <- 0
ModelDF$ab_binary[ModelDF$Diversity_metric == "abundance"] <- 1
ModelDF$ab_binary[ModelDF$Diversity_metric == "abundance" &
                    ModelDF$Measurement == 0] <- 0
ModelDF$oc_binary[ModelDF$Diversity_metric == "occurrence"] <- 1
ModelDF$oc_binary[ModelDF$Diversity_metric == "occurrence" &
                    ModelDF$Measurement == 0] <- 0
ModelDF$pres_abs <- rowSums(ModelDF[, which(names(ModelDF) %in% c("pc_binary", "ab_binary", "oc_binary"))], na.rm = TRUE) 
## drop unnecassary columns
ModelDF <- ModelDF[, which(names(ModelDF) %nin% c("pc_binary", "ab_binary", "oc_binary"))]
ModelDF$raunk_lf <- factor(ModelDF$raunk_lf , 
                      levels = c("phanerophyte","chamaephyte", "hemicryptophyte", "cryptophyte", 
                                 "therophyte"))
#saveRDS(ModelDF, "Data_ModelDF_unscaled.rds")
ModelDF <- ModelDF[, which(names(ModelDF) %nin% c("map_unscaled", "map_var_unscaled", 
                                                  "Species_richness_unscaled", "mat_unscaled", "mat_var_unscaled"))]
#saveRDS(ModelDF, "Data_ModelDF.rds")


## Quick look at model dataframe
## Factors
# for (i in names(Filter(is.factor, ModelDF))) {
#   plot(ModelDF[,i], 
#        main = paste(i))
# }
# 
## Numeric variables
# for (i in names(Filter(is.numeric, ModelDF))) {
#   hist(ModelDF[,i],
#        breaks = 3000,
#        main = paste(i),
#        xlab = paste(i))
# }

## get progress message 
print("***Model dataset created***")

