## cleaning BIEN life form levels
## initally 139 levels which is a joke
## I want to clean themn to less than 10 classifications and then the combinations thereof

##to do 

## name the life form dataset "mydata"
mydata <- lifeform_bien

levels(factor(mydata$trait_value))
mydata$trait_value %>% factor(.) %>% table(.) %>% .[order(.)]


## making naming consistant
mydata$trait_value <- tolower(mydata$trait_value)


tree <- c("tree", "tree*", "tree ", "tree\\_", "medium sized tree", "medium size tree", "phanerophyte*", "small_phanerophyte")
mydata$trait_value <- gsub(paste(tree, collapse="|"),"phanerophyte", mydata$trait_value)

shrub <- c("shrub", "shru", "shrub*")
mydata$trait_value <- gsub(paste(shrub, collapse="|"), "shrub",mydata$trait_value) 

epiphyte <- c("epiphyte")
mydata$trait_value <- gsub(paste(epiphyte, collapse="|"),"epiphyte", mydata$trait_value, ignore.case = TRUE)

geophyte <- c("geophyte\\*")
mydata$trait_value <- gsub(paste(geophyte, collapse="|"), "geophyte",mydata$trait_value, ignore.case = TRUE) 

hemicryptophyte <- c("hemicryptophyte", "hemicr")
mydata$trait_value <- gsub(paste(hemicryptophyte, collapse="|"), "hemicryptophyte",mydata$trait_value, ignore.case = TRUE)

herb <- c("herb")
mydata$trait_value <- gsub(paste(herb, collapse="|"), "herb", mydata$trait_value, ignore.case = TRUE)

forb <- c("forb")
mydata$trait_value <- gsub(paste(forb, collapse="|"), "forb", mydata$trait_value, ignore.case = TRUE)

liana <- c("liana", "vine")
mydata$trait_value <- gsub(paste(liana, collapse="|"), "liana", mydata$trait_value, ignore.case = TRUE)

parasite <- c("parasite")
mydata$trait_valuez <- gsub(paste(parasite, collapse="|"), "parasite",mydata$trait_value, ignore.case = TRUE)

## remove unwanted characters
descriptions <-c("\\*")
mydata$trait_value <-gsub(paste(descriptions, collapse = "|"), "", ignore.case = TRUE, mydata$trait_value)




mydata <- mydata[mydata$trait_value %in% c("therophyte", "geophyte", "phanerophyte","hemicryptophyte"),] # hydrophyte? 

## look again at levels
#levels(factor(mydata$OrigValueStr)) 

#mydata$OrigValueStr %>% factor(.) %>% table(.) %>% .[order(.)]
bien_lfs <-droplevels(mydata)
rm(mydata)

## finished




