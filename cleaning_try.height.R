## cleaning TRY height data

## having looked at Dr Ruth Kelly's detailed cleaning notes, I will take a rule based exclusion approach to data from plants that are:
## juvenile, manipulated or unhealthy.
## also seeking to address the units discrepencies

## name the try height dataset "mydata"
mydata <- try_height
mydata <- droplevels(mydata)

## look at levels
#levels(factor(mydata$OrigValueStr))
## 86 data sets

## look at what these values for "plant vegatative height" came in as originally
#mydata$OriglName %>% factor(.) %>% table(.) %>% .[order(.)]

#dput(levels(mydata$OriglName))

## create "not in" operator
'%nin%' = Negate('%in%')

## dropping obviously silly data sources containing miniumum plant height
mydata <- mydata[mydata$OriglName %nin% c("Height (seedling)", "HEIGHT min",  "Plant height [min]", "Stem length (Height)"),]  

## there are still some pretty questionable measurements in there (99m silver birches), so lets see if cleaning out datasets with other problems helps

#mydata$Comment %>% levels()
## comments all seem fine, don't reveal much

#dput(levels(factor(mydata$Dataset)))
 
## dropping datasets that seem a bit jippy
mydata <- mydata[mydata$Dataset %nin% c("Growth and Herbivory of Juvenil Trees"),]  


## now I just have to got through Ruth's databases to see who she dropped, 
## then check how many species I'm left with, and then I'm away.

#mydata$ValueKindName %>% factor(.) %>% levels(.) %>% dput(.)

## select the higher measurements of height, dropping "low" and "Minimum", 
mydata <- mydata %>% subset(., .$ValueKindName %in% c("Best estimate", "High", "Maximum", "Mean", #"Median", 
                                                      "Single", "Site specific mean", "Upper 95 percentile"))

## drop databases which Ruth excluded on the basis of juvenile trees or experimental treament
mydata <- mydata %>% subset(., .$Dataset %nin% c("The Functional Ecology of Trees (FET) Database  - Jena", 
                                                 "Leaf Economic Traits Across Varying Environmental Conditions", 
                                                 "Plant Traits from Romania","Leaf Structure and Chemistry",
                                                 "ECOCRAFT","Leaf Physiology Database","The DIRECT Plant Trait Database", 
                                                 "French Weeds Trait Database"))

mydata$SpeciesName %>% unique(.) %>% length(.)

####################################################################
## Start of useful but unecessicary script where I clean "plant height" 
## (previously named "OrigValueStr"), even though TRY have already done it in StdValue...

# #levels(mydata$UnitName)
# ## try hase pre-convert cm measurements to m
# 
# #mydata$OrigValueStr %>% factor(.) %>% table(.) %>% .[order(.)]
# 
# ## remove rows where the measurement value is nonsense
# mydata <- mydata[mydata$OrigValueStr %nin% c("", ".", "]", "unknown"),]  
# 
# ## remove text from the measurements
# words <- c("to ", " m", "\\*", "<")
# mydata$OrigValueStr <-gsub(paste(words, collapse = "|"), "", mydata$OrigValueStr)
# 
# 
# length(which(is.na(mydata$OrigValueStr)))
# ## this changes when data is plant_height (character) is converted to numeric, so there must still be some non-numeric characters in there
# 
# ## removed "lower value dash" where a range of values was entered, leaving just the upper value
# dash <- c("[[:digit:]]-", "[[:digit:]] - ", "[[:digit:]] -")
# mydata$OrigValueStr <-gsub(paste(dash, collapse = "|"), "", mydata$OrigValueStr)
# 
# ## removed brackets and keep higher values within
# brackets <- c("[[:digit:]] \\(", "\\(", "\\)")
# mydata$OrigValueStr <-gsub(paste(brackets, collapse = "|"), "", mydata$OrigValueStr)
# 
# ## remove characters and convert out of ft to m (in theory, it's so messy I amn't sure I trust these values)
# check <- mydata[grep("ft", mydata$OrigValueStr),]
# check$OrigValueStr <-gsub(" ft", "", check$OrigValueStr)
# check$OrigValueStr <- as.numeric(check$OrigValueStr)*0.3048
# mydata$OrigValueStr[grep("ft", mydata$OrigValueStr)] <- check$OrigValueStr
# 
# ## do the same for "cm" data NOTE : also dropping lower set of digits befor a space
# check <- mydata[grep("cm", mydata$OrigValueStr),]
# cm <- c(" cm", "cm")
# check$OrigValueStr <-gsub(paste(cm, collapse = "|"), "", check$OrigValueStr)
# ## deal with entries that have a range of values and no dash
# sub_check <- check[grep("[[:digit:]] [[:digit:]]", check$OrigValueStr),]
# sub_check$OrigValueStr <-gsub("[[:digit:]] ", "", sub_check$OrigValueStr)
# check$OrigValueStr[grep("[[:digit:]] [[:digit:]]", check$OrigValueStr)] <- sub_check$OrigValueStr
# 
# ## proceed with cm data again
# check$OrigValueStr <- as.numeric(check$OrigValueStr)/100
# mydata$OrigValueStr[grep("cm", mydata$OrigValueStr)] <- check$OrigValueStr
# 
# rm(words, dash, brackets, cm)
# 
# ## look at the values we're left with
# summary(as.numeric(mydata$OrigValueStr))
# 
# # Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
# #    0.00    0.80   10.00   52.12   30.00 6500.00     592 


####################################################################
## End of useful but unecessicary script where I clean "plant height" 
## (previously named "OrigValueStr"), even though TRY have already done it in StdValue...

mydata <- droplevels(unique(mydata))


hist((mydata$plant_height), main = "Histogram of plant heights", breaks = 1000)

summary(as.numeric(mydata$plant_height))

try_height <- mydata

## the end 
