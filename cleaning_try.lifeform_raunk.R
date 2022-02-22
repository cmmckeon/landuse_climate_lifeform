## cleaning TRY life form raunkiear levels
## initally 144 levels
## I want to clean themn to less than 10 classifications and then the combinations thereof


## name the raunkiear life form dataset "mydata"
mydata <- pgl_raunk
 
## look at levels
levels(factor(mydata$OrigValueStr))

## remove descriptive lables 
descriptions <-c("always ","sometimes ", "questionable ", " \\(annual land plant)", 
                 " \\(perennial water plant)", "bulbous ", "non-bulbous ", "perennial ", " \\(rhizome/corm or tuber)")
mydata$OrigValueStr <-gsub(paste(descriptions, collapse = "|"), "", ignore.case = TRUE, mydata$OrigValueStr)

## making naming consistant

mydata$OrigValueStr <- tolower(mydata$OrigValueStr)

## chamaephyte typos 
chamaephyte <- c("chamaephyte", "chamaephytes", "chamephyte", "cha")
mydata$OrigValueStr <-gsub(paste(chamaephyte, collapse = "|"), "chamaephyte", mydata$OrigValueStr, ignore.case = TRUE)

## therophyte typos
therophyte <- c("therophyte", "therophytes", "Terophytes")
mydata$OrigValueStr <-gsub(paste(therophyte, collapse = "|"), "therophyte", mydata$OrigValueStr, ignore.case = TRUE)

## phanerophyte typos
phanerophyte <- c("phanerophyte", "phanerophytes", "tree", "mega- meso- and micro- phanerophyte", 
                  "mega-/meso- and microphanerophyte","mega//meso- and microphanerophyte", "phanerophyt", "nanophanerophyte", "macrophanerophyte", 
                  "megaphanerophyte", "\\mega//meso/ and microphanerophyte")
mydata$OrigValueStr <-gsub(paste(phanerophyte, collapse = "|"), "phanerophyte", mydata$OrigValueStr, ignore.case = TRUE)

mydata$OrigValueStr <-gsub("\\phanerophyte/phanerophyte", "phanerophyte", mydata$OrigValueStr, ignore.case = TRUE)

## geophyte typos
geophyte <- c("geophyte", "geophytes")
mydata$OrigValueStr <-gsub(paste(geophyte, collapse = "|"), "geophyte", mydata$OrigValueStr, ignore.case = TRUE)

## hemicryptophyte typos
hemicryptophyte <- c("hemicryptophyte", "hemicryptophytes")
mydata$OrigValueStr <-gsub(paste(hemicryptophyte, collapse = "|"), "hemicryptophyte", mydata$OrigValueStr, ignore.case = TRUE)


## change letter codes for full words

## find all levels containing a string of interest
#dput(paste(mydata$OrigValueStr[grep(("hh"), mydata$OrigValueStr, ignore.case =TRUE)]))
## excluding T-H(Hh), all are suitable for transformation into Hh only.

## changing commas to forward slashes
mydata$OrigValueStr <-gsub(", |-", "/", mydata$OrigValueStr)


## ordering combination categories alphabetically
mydata$OrigValueStr <-gsub("therophyte/hydrophyte|hydrophyte/therophyte", "therophyte/hydrophyte", mydata$OrigValueStr)

mydata$OrigValueStr <-gsub("therophyte/geophyte|geophyte/therophyte", "therophyte/geophyte", mydata$OrigValueStr)

mydata$OrigValueStr <-gsub("therophyte/chamaephyte|chamaephyte/therophyte", "therophyte/chamaephyte", mydata$OrigValueStr)

mydata$OrigValueStr <-gsub("therophyte/hemicryptophyte|hemicryptophyte/therophyte", "therophyte/hemicryptophyte", mydata$OrigValueStr)


mydata$OrigValueStr <-gsub("hemicryptophyte/geophyte|geophyte/hemicryptophyte", "hemicryptophyte/geophyte", mydata$OrigValueStr)

mydata$OrigValueStr <-gsub("hemicryptophyte/chamaephyte|chamaephyte/hemicryptophyte", "hemicryptophyte/chamaephyte", mydata$OrigValueStr)

mydata$OrigValueStr <-gsub("hemicryptophyte/hydrophyte|hydrophyte/hemicryptophyte", "hemicryptophyte/hydrophyte", mydata$OrigValueStr)

mydata$OrigValueStr <-gsub("hemicryptophyte/phanerophyte|phanerophyte/hemicryptophyte", "hemicryptophyte/phanerophyte", mydata$OrigValueStr)


mydata$OrigValueStr <-gsub("chamaephyte/geophyte|geophyte/chamaephyte", "chamaephyte/geophyte", mydata$OrigValueStr)

mydata$OrigValueStr <-gsub("chamaephyte/phanerophyte|phanerophyte/chamaephyte", "chamaephyte/phanerophyte", mydata$OrigValueStr)


mydata$OrigValueStr <-gsub("hydrophyte/geophyte|geophyte/hydrophyte", "hydrophyte/geophyte", mydata$OrigValueStr)


## more fine scale editing on the reduced levels ## at the moment down to 85 levels 
mydata$OrigValueStr[mydata$OrigValueStr == "ch"] <- "chamaephyte"
mydata$OrigValueStr[mydata$OrigValueStr == "ep"] <- "epiphyte"
mydata$OrigValueStr[mydata$OrigValueStr == "g"] <- "geophyte"
mydata$OrigValueStr[mydata$OrigValueStr == "ph"] <- "phanerophyte"
mydata$OrigValueStr[mydata$OrigValueStr == "h"] <- "hemicryptophyte"  ## have not decided if this is wise

## checked the species for np and I think they're nanophanerophytes
mydata$OrigValueStr[mydata$OrigValueStr == "np"] <- "phanerophyte"

## checked the species for p and I think they're nanophanerophytes
mydata$OrigValueStr[mydata$OrigValueStr == "p"] <- "phanerophyte"

## cleaning the numeric levels using information from the comments column

## there are 8 commment levels, 3 of which correspond to numeric life form levels. 
## Each contributing dataset has a different numbering system so needs to be dealt with individually

mydata$OrigValueStr[mydata$Comment == "1=therophyte, 2=geophyte, 3=hemicryptophyte, 4=chamaephyte, 5=phanerophyte" &
                      mydata$OrigValueStr == 1] <- "therophyte"
mydata$OrigValueStr[mydata$Comment == "1=therophyte, 2=geophyte, 3=hemicryptophyte, 4=chamaephyte, 5=phanerophyte" &
                      mydata$OrigValueStr == 2] <- "geophyte"
mydata$OrigValueStr[mydata$Comment == "1=therophyte, 2=geophyte, 3=hemicryptophyte, 4=chamaephyte, 5=phanerophyte" &
                      mydata$OrigValueStr == 3] <- "hemicryptophyte"
mydata$OrigValueStr[mydata$Comment == "1=therophyte, 2=geophyte, 3=hemicryptophyte, 4=chamaephyte, 5=phanerophyte" &
                      mydata$OrigValueStr == 4] <- "chamaephyte"
mydata$OrigValueStr[mydata$Comment == "1=therophyte, 2=geophyte, 3=hemicryptophyte, 4=chamaephyte, 5=phanerophyte" &
                      mydata$OrigValueStr == 5] <- "phanerophyte"



mydata$OrigValueStr[mydata$Comment == "1= mega- (max height>20 m), 2 = meso- (<20 m), 3 = micro- (<10 m), 4 = nanophanerophyte (<3 m)" &
                      mydata$OrigValueStr == 1 | mydata$OrigValueStr == 2 | mydata$OrigValueStr == 3 | mydata$OrigValueStr == 4 ] <- "phanerophyte"


mydata$OrigValueStr[mydata$Comment == "1, phanerophyte and nano-phanerophyte; 2, ph-ch; 3, chamaephyte; 4, ch-h; 5, hemicryptophyte; 6, h-g; 7, geophyte; 8, therophytes" &
                      mydata$OrigValueStr == 1] <- "phanerophyte"
mydata$OrigValueStr[mydata$Comment == "1, phanerophyte and nano-phanerophyte; 2, ph-ch; 3, chamaephyte; 4, ch-h; 5, hemicryptophyte; 6, h-g; 7, geophyte; 8, therophytes" &
                      mydata$OrigValueStr == 2] <- "phanerophyte/chamaephyte"
mydata$OrigValueStr[mydata$Comment == "1, phanerophyte and nano-phanerophyte; 2, ph-ch; 3, chamaephyte; 4, ch-h; 5, hemicryptophyte; 6, h-g; 7, geophyte; 8, therophytes" &
                      mydata$OrigValueStr == 3] <- "chamaephyte"
mydata$OrigValueStr[mydata$Comment == "1, phanerophyte and nano-phanerophyte; 2, ph-ch; 3, chamaephyte; 4, ch-h; 5, hemicryptophyte; 6, h-g; 7, geophyte; 8, therophytes" &
                      mydata$OrigValueStr == 4] <- "hemicryptophyte/chamaephyte"
mydata$OrigValueStr[mydata$Comment == "1, phanerophyte and nano-phanerophyte; 2, ph-ch; 3, chamaephyte; 4, ch-h; 5, hemicryptophyte; 6, h-g; 7, geophyte; 8, therophytes" &
                      mydata$OrigValueStr == 5] <- "hemicryptophyte"
mydata$OrigValueStr[mydata$Comment == "1, phanerophyte and nano-phanerophyte; 2, ph-ch; 3, chamaephyte; 4, ch-h; 5, hemicryptophyte; 6, h-g; 7, geophyte; 8, therophytes" &
                      mydata$OrigValueStr == 6] <- "hemicryptophyte/geophyte"
mydata$OrigValueStr[mydata$Comment == "1, phanerophyte and nano-phanerophyte; 2, ph-ch; 3, chamaephyte; 4, ch-h; 5, hemicryptophyte; 6, h-g; 7, geophyte; 8, therophytes" &
                      mydata$OrigValueStr == 7] <- "geophyte"
mydata$OrigValueStr[mydata$Comment == "1, phanerophyte and nano-phanerophyte; 2, ph-ch; 3, chamaephyte; 4, ch-h; 5, hemicryptophyte; 6, h-g; 7, geophyte; 8, therophytes" &
                      mydata$OrigValueStr == 8] <- "therophyte"

## look again at levels
levels(factor(mydata$OrigValueStr)) ## 65 levels

mydata$OrigValueStr %>% factor(.) %>% table(.) %>% .[order(.)]
raunk5 <- droplevels(mydata %>% .[.$OrigValueStr %in% c("chamaephyte", "geophyte", "therophyte", 
                                                        "phanerophyte", "hemicryptophyte"),]) ## 28634 obs of 28 vars

rm("mydata", "chamaephyte", "descriptions", "geophyte", "hemicryptophyte", "phanerophyte", "therophyte", pgl_raunk)

## finished
