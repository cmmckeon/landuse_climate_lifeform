#' ---
#' title: "LF_04a_NO_RICH_frequentist_percent_cover.R"
# author: "Caroline McKeon"
# date: "01/07/2020"


## DATA NEEDED:

# Data_ModelDF.rds  - Model dataframe with 624696 obs of 24 variables, created in LF_01_data_handling.R
# Data_03a_PR_f_pc.rds - Taxonomy for the percent cover species, created in lines 425 - 437 of LF_01_data_handling.R 

print("This is the NO SPECIES RICHNESS frequentist percent cover model script")
setwd("~/landuse_climate_lifeform")


## Create model dataframe
#source("LF_01_data_handling.R")


## Setup---------------------------------------------------------------------------------------------------------------
library(tidyverse)
library(lme4)
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
} ## 02/09/2020 624696 obs of 24 vars, unique, continuous vars are scaled

## handle model dataframe to get just percent cover data, with species levels in the right format
levels(ModelDF$Best_guess_binomial) <- gsub(" ", "_", levels(ModelDF$Best_guess_binomial))

mydata <- ModelDF[ModelDF$Diversity_metric == "percent cover", ]
mydata <- mydata[mydata$Measurement !=0,]
mydata <- unique(mydata)
mydata$Measurement <- mydata$Measurement/100
mydata$response <- scale(logitTransform(mydata$Measurement))
mydata$animal <- mydata$Best_guess_binomial


## get taxomonic data for all species
PR_pc <- readRDS("Data_03a_PR_f_pc.rds")

mydata <- droplevels(merge(mydata, PR_pc, by = "Best_guess_binomial",all.x = TRUE)) 

## set up for weighted effects coding

print("configure contrasts for model a")

## main effects
mydata$Predominant_habitat.wec <- factor(mydata$Predominant_habitat)
contrasts(mydata$Predominant_habitat.wec) <- contr.wec(mydata$Predominant_habitat, "Urban")
mydata$raunk_lf.wec <- factor(mydata$raunk_lf)
contrasts(mydata$raunk_lf.wec) <- contr.wec(mydata$raunk_lf, "therophyte")
## interations
mydata$hab_raunk_interaction <- mydata$Predominant_habitat
mydata$hab_raunk_interaction <- wec.interact(mydata$Predominant_habitat.wec, mydata$raunk_lf.wec)
mydata$map_raunk_interaction <- wec.interact(mydata$raunk_lf.wec, mydata$map)
mydata$map_var_raunk_interaction <- wec.interact(mydata$raunk_lf.wec, mydata$map_var)
mydata$mat_raunk_interaction <- wec.interact(mydata$raunk_lf.wec, mydata$mat)
mydata$mat_var_raunk_interaction <- wec.interact(mydata$raunk_lf.wec, mydata$mat_var)


## ----pc_null----------------------------------------------------------------------------------------------------------------------------
# pc_null_beta <- glmmTMB(Measurement ~ 1 +
#                    (1|Best_guess_binomial) +
#                    (1|SS) +
#                    (1|SSS) +
#                    (1|SSBS),
#                  family = beta_family,
#                  data = mydata)
# saveRDS(pc_null_beta, "pc_null_beta.rds")

# pc_null_gauss_logit <- lmer(response ~ 1 +
#                           (1|Best_guess_binomial) +
#                           (1|SS),
#                           # (1|SSS) +
#                           # (1|SSBS),
#                         data = mydata)
#
# if(exists("pc_null_gauss_logit")) {
#   try(saveRDS(pc_null_gauss_logit, "f_pc_null_gauss_logit.rds"))
# } else warning("pc_null_gauss_logit failed to run")
#

## ----a_pc_maximal_gaussian_logit--------------------------------------------------------------------------------------------
print("start running model a")

pc_wec_NO_RICH_int_maximal_gauss_logit_nesting_no_U_T <- lmer(response ~ Predominant_habitat.wec + raunk_lf.wec + hab_raunk_interaction +
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
                                                      data = mydata)

if(exists("pc_wec_NO_RICH_int_maximal_gauss_logit_nesting_no_U_T")) {
  try(saveRDS(pc_wec_NO_RICH_int_maximal_gauss_logit_nesting_no_U_T, "f_pc_wec_NO_RICH_int_maximal_gauss_logit_nesting_no_U_T.rds"))
} else warning("pc_wec_NO_RICH_int_maximal_gauss_logit_nesting_no_U_T failed to run")

print("ran model omitting Urban or therophyte, now running model omitting Primary forest and phanerophte")

## ----b_pc_maximal_gaussian_logit--------------------------------------------------------------------------------------------
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

pc_wec_NO_RICH_int_maximal_gauss_logit_nesting_no_PF_P <- lmer(response ~ Predominant_habitat.wec + raunk_lf.wec + hab_raunk_interaction +
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
                                                       data = mydata)

if(exists("pc_wec_NO_RICH_int_maximal_gauss_logit_nesting_no_PF_P")) {
  try(saveRDS(pc_wec_NO_RICH_int_maximal_gauss_logit_nesting_no_PF_P, "f_pc_wec_NO_RICH_int_maximal_gauss_logit_nesting_no_PF_P.rds"))
} else warning("pc_wec_NO_RICH_int_maximal_gauss_logit_nesting_no_PF_P failed to run")

print("ran model omitting Primary forest and phanerophte, now running model ommitting Pasture and cryptophyte")

## ----c_pc_maximal_gaussian_logit--------------------------------------------------------------------------------------------
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

pc_wec_NO_RICH_int_maximal_gauss_logit_nesting_no_P_C <- lmer(response ~ Predominant_habitat.wec + raunk_lf.wec + hab_raunk_interaction +
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
                                                      data = mydata)

if(exists("pc_wec_NO_RICH_int_maximal_gauss_logit_nesting_no_P_C")) {
  try(saveRDS(pc_wec_NO_RICH_int_maximal_gauss_logit_nesting_no_P_C, "f_pc_wec_NO_RICH_int_maximal_gauss_logit_nesting_no_P_C.rds"))
} else warning("pc_wec_NO_RICH_int_maximal_gauss_logit_nesting_no_P_C failed to run")

print("end")

## Finished -------------
#' 
#' 
#' 
#' 
#' 
#' 
#' 
