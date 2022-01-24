#' ---
#' title: "LF_04b_NO_RICH_frequentist_occurrence.R"
#' output: word_document
#' ---
#' 
#' 
#' # Set up
print("This is the NO RICH frequentist occurrence model script")

setwd("~/landuse_climate_lifeform")

## create "not in" operator
'%nin%' = Negate('%in%')
#' 
## ----setup, include=FALSE---------------------------------------------------------------------------------------------------------------
#install.packages(c("tidyverse", "lme4","optimx", "DHARMa", "glmmTMB", "MuMIn", "effects"))
library(tidyverse)
library(lme4)
#library(DHARMa)
library(optimx) 
library(glmmTMB)
library(wec)

## create "not in" operator
'%nin%' = Negate('%in%')
## create logit transformation function
logitTransform <- function(x) { log(x/(1-x)) }

## read in and handle data------------------------------------
if(!exists("ModelDF")) {
  if(file.exists("Data_ModelDF.rds")) {
    try(ModelDF <- readRDS("Data_ModelDF.rds")) }
  else source("LF_01_data_handling.R")
} ## 02/09/2020 624696 obs of 25 vars, unique, continous vars are scaled


## ---------------------------------------------------------------------------------------------------------------------------------------
## handle model dataframe to get just percent cover data, with species levels in the right format
levels(ModelDF$Best_guess_binomial) <- gsub(" ", "_", levels(ModelDF$Best_guess_binomial))
mydata <- ModelDF
mydata$animal <- mydata$Best_guess_binomial

## get taxomonic data for all species
PR_oc <- readRDS("Data_03b_PR_f_oc.rds")

# ## get taxomonic data for all species
# if(!exists("PR_oc")) {
#   if(file.exists("Data_03b_PR_f_oc.rds")) {
#     try(PR_oc <- readRDS("Data_03b_PR_f_oc.rds"))
#   } else try(
#     {PR <- readRDS("Data_PR_plantDiversityCorr.rds")
#     levels(PR$Best_guess_binomial) <- gsub(" ", "_", levels(PR$Best_guess_binomial))
#     PR <- PR[PR$Best_guess_binomial %in% mydata$Best_guess_binomial,]
#     PR_oc <- unique(PR[, which(names(PR) %in% c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus",
#                                                 "Best_guess_binomial"))])})
# }

mydata <- droplevels(merge(mydata, PR_oc, by = "Best_guess_binomial",all.x = TRUE)) 

## set up for weighted effects coding

print("configure contrasts for model a")
## main effects
mydata$Predominant_habitat.wec <- factor(mydata$Predominant_habitat)
contrasts(mydata$Predominant_habitat.wec) <- contr.wec(mydata$Predominant_habitat, "Urban")
mydata$raunk_lf.wec <- factor(mydata$raunk_lf)
contrasts(mydata$raunk_lf.wec) <- contr.wec(mydata$raunk_lf, "therophyte")
## interactions
mydata$hab_raunk_interaction <- mydata$Predominant_habitat
mydata$hab_raunk_interaction <- wec.interact(mydata$Predominant_habitat.wec, mydata$raunk_lf.wec)
mydata$map_raunk_interaction <- wec.interact(mydata$raunk_lf.wec, mydata$map)
mydata$map_var_raunk_interaction <- wec.interact(mydata$raunk_lf.wec, mydata$map_var)
mydata$mat_raunk_interaction <- wec.interact(mydata$raunk_lf.wec, mydata$mat)
mydata$mat_var_raunk_interaction <- wec.interact(mydata$raunk_lf.wec, mydata$mat_var)

## ----oc_null----------------------------------------------------------------------------------------------------------------------------

# oc_null <- glmmTMB(pres_abs ~ 1 +
#                      (1|Best_guess_binomial) +
#                      (1|SS) +
#                      (1|SSS) +
#                      (1|SSBS),
#                    ziformula= ~ Predominant_habitat + raunk_lf,
#                    family = binomial,
#                    control = glmmTMBControl(optCtrl = list(iter.max = 1000, eval.max = 1000),
#                                             profile = FALSE, collect = FALSE),
#                    data = mydata)
#
# if(exists("oc_null")) {
#   try(saveRDS(oc_null, "f_oc_null.rds"))
# } else warning("oc_null failed to run")


#' ## ----oc_maximal--------------------------------------------------------------------------------------------
# oc_maximal_zi <- glmmTMB(pres_abs ~ Predominant_habitat*raunk_lf +
#                                  humanfootprint_value +
#                                  Species_richness +
#                                  map +
#                                  map_var +
#                                  mat +
#                                  mat_var +
#                                  Species_richness:raunk_lf +
#                                  map_var:raunk_lf +
#                                  map:raunk_lf +
#                                  mat_var:raunk_lf +
#                                  mat:raunk_lf +
#                                  humanfootprint_value:raunk_lf +
#                            (1|Best_guess_binomial) +
#                            (1|SS), # +
#                            # (1|SSS) +
#                            # (1|SSBS),
#                          ziformula= ~ Predominant_habitat + raunk_lf,
#                          family = binomial,
#                          control = glmmTMBControl(optCtrl = list(iter.max = 10000, eval.max = 10000),
#                                                   profile = FALSE, collect = FALSE),
#                                data = mydata)
#
# if(exists("oc_maximal_zi")) {
#   try(saveRDS(oc_maximal_zi, "f_oc_maximal_zi.rds"))
# } else warning("oc_maximal_zi failed to run")

print("start running model a")

oc_wec_NO_RICH_int_maximal_zi_1_nested_no_U_T <- glmmTMB(pres_abs ~ Predominant_habitat.wec + raunk_lf.wec + hab_raunk_interaction +
                                    map +
                                    map_var +
                                    mat +
                                    mat_var +
                                    map_raunk_interaction +
                                    map_var_raunk_interaction +
                                    mat_raunk_interaction +
                                    mat_var_raunk_interaction +
                           (1|Best_guess_binomial) +
                           (1|SS) +
                           (1|Class/Order/Family/Genus),
                           ziformula= ~ 1,
                         family = binomial,
                         control = glmmTMBControl(optCtrl = list(iter.max = 10000, eval.max = 10000),
                                                  profile = FALSE, collect = FALSE),
                         data = mydata)

if(exists("oc_wec_NO_RICH_int_maximal_zi_1_nested_no_U_T")) {
  try(saveRDS(oc_wec_NO_RICH_int_maximal_zi_1_nested_no_U_T, "oc_wec_NO_RICH_int_maximal_zi_1_nested_no_U_T.rds"))
} else warning("oc_wec_NO_RICH_int_maximal_zi_1_nested_no_U_T failed to run")

print("ran model omitting Urban or therophyte, now running model omitting Primary forest and phanerophte")

print("configure contrasts for model b")
## main effects
mydata$Predominant_habitat.wec <- factor(mydata$Predominant_habitat)
contrasts(mydata$Predominant_habitat.wec) <- contr.wec(mydata$Predominant_habitat, "Primary forest")
mydata$raunk_lf.wec <- factor(mydata$raunk_lf)
contrasts(mydata$raunk_lf.wec) <- contr.wec(mydata$raunk_lf, "phanerophyte")
## interactions
mydata$hab_raunk_interaction <- mydata$Predominant_habitat
mydata$hab_raunk_interaction <- wec.interact(mydata$Predominant_habitat.wec, mydata$raunk_lf.wec)
mydata$map_raunk_interaction <- wec.interact(mydata$raunk_lf.wec, mydata$map)
mydata$map_var_raunk_interaction <- wec.interact(mydata$raunk_lf.wec, mydata$map_var)
mydata$mat_raunk_interaction <- wec.interact(mydata$raunk_lf.wec, mydata$mat)
mydata$mat_var_raunk_interaction <- wec.interact(mydata$raunk_lf.wec, mydata$mat_var)

print("start running model b")
oc_wec_NO_RICH_int_maximal_zi_1_nested_no_PF_P <- glmmTMB(pres_abs ~ Predominant_habitat.wec + raunk_lf.wec + hab_raunk_interaction +
                                                    map +
                                                    map_var +
                                                    mat +
                                                    mat_var +
                                                    map_raunk_interaction +
                                                    map_var_raunk_interaction +
                                                    mat_raunk_interaction +
                                                    mat_var_raunk_interaction +
                                                    (1|Best_guess_binomial) +
                                                    (1|SS) +
                                                    (1|Class/Order/Family/Genus),
                                                  ziformula= ~ 1,
                                                  family = binomial,
                                                  control = glmmTMBControl(optCtrl = list(iter.max = 10000, eval.max = 10000),
                                                                           profile = FALSE, collect = FALSE),
                                                  data = mydata)

if(exists("oc_wec_NO_RICH_int_maximal_zi_1_nested_no_PF_P")) {
  try(saveRDS(oc_wec_NO_RICH_int_maximal_zi_1_nested_no_PF_P, "oc_wec_NO_RICH_int_maximal_zi_1_nested_no_PF_P.rds"))
} else warning("oc_wec_NO_RICH_int_maximal_zi_1_nested_no_PF_P failed to run")

print("ran model omitting Primary forest and phanerophte, now running model omitting Pasture and cryptophyte")

print("configure contrasts for model c")
## main effects
mydata$Predominant_habitat.wec <- factor(mydata$Predominant_habitat)
contrasts(mydata$Predominant_habitat.wec) <- contr.wec(mydata$Predominant_habitat, "Pasture")
mydata$raunk_lf.wec <- factor(mydata$raunk_lf)
contrasts(mydata$raunk_lf.wec) <- contr.wec(mydata$raunk_lf, "cryptophyte")
## interactions
mydata$hab_raunk_interaction <- mydata$Predominant_habitat
mydata$hab_raunk_interaction <- wec.interact(mydata$Predominant_habitat.wec, mydata$raunk_lf.wec)
mydata$map_raunk_interaction <- wec.interact(mydata$raunk_lf.wec, mydata$map)
mydata$map_var_raunk_interaction <- wec.interact(mydata$raunk_lf.wec, mydata$map_var)
mydata$mat_raunk_interaction <- wec.interact(mydata$raunk_lf.wec, mydata$mat)
mydata$mat_var_raunk_interaction <- wec.interact(mydata$raunk_lf.wec, mydata$mat_var)

print("start running model c")
oc_wec_NO_RICH_int_maximal_zi_1_nested_no_P_C <- glmmTMB(pres_abs ~ Predominant_habitat.wec + raunk_lf.wec + hab_raunk_interaction +
                                                   map +
                                                   map_var +
                                                   mat +
                                                   mat_var +
                                                   map_raunk_interaction +
                                                   map_var_raunk_interaction +
                                                   mat_raunk_interaction +
                                                   mat_var_raunk_interaction +
                                                   (1|Best_guess_binomial) + 
                                                   (1|SS) +
                                                   (1|Class/Order/Family/Genus),
                                                 ziformula= ~ 1,
                                                 family = binomial, 
                                                 control = glmmTMBControl(optCtrl = list(iter.max = 10000, eval.max = 10000), 
                                                                          profile = FALSE, collect = FALSE),
                                                 data = mydata)

if(exists("oc_wec_NO_RICH_int_maximal_zi_1_nested_no_P_C")) {
  try(saveRDS(oc_wec_NO_RICH_int_maximal_zi_1_nested_no_P_C, "oc_wec_NO_RICH_int_maximal_zi_1_nested_no_P_C.rds"))
} else warning("oc_wec_NO_RICH_int_maximal_zi_1_nested_no_P_C failed to run")

print("end")

## Finished ------------------------------------------------------------------------------------------------------------------------
#' 
#' 
#' 
#' 
#' 
#' 
#' 
