## get and explore phylogeny
## cm 04/2020


################ set up
#install.packages(c("ape", "phytools", "ggtree", "caper"))
library(caper)
library(ape)
library(phytools)
library(phangorn)

if(!exists("ModelDF")) {
  if(file.exists("Data_ModelDF.rds")) {
    try(ModelDF <- readRDS("Data_ModelDF.rds"))
  } else warning("ModelDF does not exist in this directory")
}


## look at phylogenetic tree options and species listoverlap with my usable PREDICTS data

## SMITH 2018 "open tree" tree
treefile <- read.tree("big_seed_trees_SMITH2018/ALLMB.tre")
  if(exists("treefile")) {
    print("phylogeny read in")
  } else warning("phylogeny does not exist in this directory")


tip_labels <- as.character(treefile$tip.label) ## 356305 species (well, tips..)

# ## get ModelDF species names in the right format to match with those in phylogenetic trees
levels(ModelDF$Best_guess_binomial) <- gsub(" ", "_", levels(ModelDF$Best_guess_binomial))

#### drop unused species from phylogeny 
omit_spe <- as.character(setdiff(treefile$tip.label, unique(ModelDF$Best_guess_binomial)))
clean_tree <- drop.tip(treefile, omit_spe)

## label nodes
clean_tree$node.label <- c(1:length(clean_tree$node.label))  

## make tree ultrametric
clean_tree <- nnls.tree(cophenetic(clean_tree),clean_tree,rooted=TRUE)
## "RSS: 0.574181455739743"

#### check trees similarity this should equal 1
tips<-clean_tree$tip.label
cor(as.vector(cophenetic(clean_tree)[tips,tips]),
    as.vector(cophenetic(clean_tree)[tips,tips]))
### 1

clean_tips <- as.character(clean_tree$tip.label)
## save
#write.tree(clean_tree, file = "clean_tree.tre")

plotTree(clean_tree,type="fan",fsize=0.1,lwd=0.5, ftype="i", part = 0.93)

if(exists("clean_tree")) {
  print("clean_tree created")
} else warning("failed to create clean_tree")
#str(clean_tree)



## checking other published phylogeny options

# sp_smithOT <- Reduce(intersect, list(noquote(tip_labels), unique(ModelDF$Best_guess_binomial))) ## 4453 species
# plot(ModelDF$raunk_lf[ModelDF$Best_guess_binomial %in% sp_smithOT]) ## reasonably even spread across life forms

## find out which species are missing
# sp_missing <- setdiff(unique(ModelDF$Best_guess_binomial), noquote(tip_labels)) ## missing 564 species from usable PREDICTS data

# ## SMITH genebank tree
# treefile <- read.tree("big_seed_trees_SMITH2018/GBOTB.tre")
# ## look for additional species in genebank data
# tip_lables <- as.character(treefile$tip.label) ## 79881 species (well, tipes..)
# 
# sp_smithGB <- Reduce(intersect, list(noquote(tip_lables), unique(ModelDF$Best_guess_binomial))) ## 2933 species
# plot(ModelDF$raunk_lf[ModelDF$Best_guess_binomial %in% sp_smithGB]) ## reasonably even spread across life forms
# 
# ## see if there are some missing species missing from SMITH open tree are in genebank
# found <- Reduce(intersect, list(noquote(sp_missing), noquote(sp_smithGB))) ## 0 species
# found <- setdiff(noquote(sp_missing), noquote(sp_smithGB)) ## 564 species. smithGB gives no extra species
# rm(sp_smithGB)

# ## ZANNA 2013
# ## read in file
# treefile <- read.tree(file ="Vascular_Plants_rooted.dated.tre")
# 
# #plot(treefile, cex = 0.3)
# ## look at which species are represented in the tree
# tip_labels <- as.character(treefile$tip.label) ## 31749 species
# 
# sp_zanne <- Reduce(intersect, list(noquote(tip_labels), unique(ModelDF$Best_guess_binomial))) ## only 2823 species.... brutal

###########################
## merging ZANNE's 189 extra species with SMITH's 4453
## if that's possible...

## then we would have the full 4642 species...
###########################




