## cleaning TRY life form (NOT named as raunkiear) levels
## initally 1442 levels which coudl be better
## I want to clean themn to less than 10 classifications and then the combinations thereof

## name the life form dataset "mydata"
mydata <- pgf

## look at levels
levels(factor(mydata$OrigValueStr))

## making naming consistant
mydata$OrigValueStr <- tolower(mydata$OrigValueStr)

## remove numeric levels for now, deal with later
mydata$OrigValueStr[grep("[[:digit:]]", mydata$OrigValueStr)] <- "numeric"

## remove symbols lables 
symbols <-c("\\_", "\\/", "\\,", "\\|", "\\(?)", "\\?") #, "\\ |")
mydata$OrigValueStr <-gsub(paste(symbols, collapse = "|"), " ", ignore.case = TRUE, mydata$OrigValueStr)

## remove sdouble spaces
mydata$OrigValueStr <-gsub("  ", " ", mydata$OrigValueStr)

## remove descriptive lables 
descriptions <-c("large","free", "tall", "terrestrial" ,"woody", "short", "small")
mydata$OrigValueStr <-gsub(paste(descriptions, collapse = "|"), "", ignore.case = TRUE, mydata$OrigValueStr)

## tree typos
tree <- c("treees", "t tree tree", "tre", "t tree", "tree treee", "tree tree", "tree\\(deciduous ", 
          "tree\\(evergreen ","treee", "treees ", "treeetreee", "treeetree", "treeet", "treeelet",
          "conifer", "conifers", "tree treetree", "treetree")
mydata$OrigValueStr <-gsub(paste(tree, collapse = "|"), "phanerophyte", mydata$OrigValueStr)
mydata$OrigValueStr <-gsub("treee", "phanerophyte", mydata$OrigValueStr)
mydata$OrigValueStr <-gsub("phanerophytee", "phanerophyte", mydata$OrigValueStr)

tree <- c("phanerophytelet", "phanerophyte ", "phanerophyte phanerophyte", "phanerophytet", "phanerophyten", "mesophyte",
          "phanerophyte\\(deciduous ", "phanerophyte\\(evergreen ")
mydata$OrigValueStr <-gsub(paste(tree, collapse = "|"), "phanerophyte", mydata$OrigValueStr)

## harmonise grammar
mydata$OrigValueStr <-gsub("lianas", "liana", mydata$OrigValueStr)
mydata$OrigValueStr <-gsub("phytes", "phyte", mydata$OrigValueStr)


## chamaephyte
chamaephyte <- c("chamaephyte", "nano-chamaephyte", "chamaephyte nano-chamaephyte")
mydata$OrigValueStr <-gsub(paste(chamaephyte, collapse = "|"), "chamaephyte", mydata$OrigValueStr)

## shrub typos. even though i can't do anything with them..
shrub <- c("srub", "shrubs")
mydata$OrigValueStr <-gsub(paste(shrub, collapse = "|"), "shrub", mydata$OrigValueStr)

mydata$OrigValueStr[] %>% factor(.) %>% table(.) %>% .[order(.)]


mydata <- mydata[mydata$OrigValueStr %in% c("chamaephyte", "geophyte", "phanerophyte", "hydrophyte"),]

## look again at levels
#levels(factor(mydata$OrigValueStr)) ## 65 levels

#mydata$OrigValueStr %>% factor(.) %>% table(.) %>% .[order(.)]
lfs <-droplevels(mydata)
rm(symbols, descriptions, tree, mydata)

## finished
