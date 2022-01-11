#' ---
#' title: "LF_04a_frequentist_percent_cover.R"
# author: "Caroline McKeon"
# date: "01/07/2020"

print("This is the frequentist percent cover model script")
setwd("~/PREDICTS")


## Create model dataframe
#source("LF_01_data_handling.R")

## Create phylogeny 
#source("LF_01b_phylogeny.R")


## Setup---------------------------------------------------------------------------------------------------------------
library(tidyverse)
library(lme4)
#library(DHARMa)
library(optimx) 
library(glmmTMB)
library(wec)
# library("MuMIn")
#install.packages("sjPlot")
# library(sjPlot)
# library(effects)
#install.packages("see")
# library("see") 
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

mydata <- ModelDF[ModelDF$Diversity_metric == "percent cover", ]
mydata <- mydata[mydata$Measurement !=0,]
mydata <- unique(mydata)
mydata$Measurement <- mydata$Measurement/100
mydata$response <- c(scale(logitTransform(mydata$Measurement)))
mydata$animal <- mydata$Best_guess_binomial

## get taxomonic data for all species
if(!exists("PR_pc")) {
  if(file.exists("Data_PR_f_pc.rds")) {
    try(PR_pc <- readRDS("Data_PR_f_pc.rds"))
  } else try(
    {PR <- readRDS("Data_PR_plantDiversityCorr.rds")
    levels(PR$Best_guess_binomial) <- gsub(" ", "_", levels(PR$Best_guess_binomial))
    PR <- PR[PR$Best_guess_binomial %in% mydata$Best_guess_binomial,]
    PR_pc <- unique(PR[, which(names(PR) %in% c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus",
                                                         "Best_guess_binomial"))])})
}

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
mydata$spp_raunk_interaction <- wec.interact(mydata$raunk_lf.wec, mydata$Species_richness)


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

#' ## ----pc_maximal_beta,--------------------------------------------------------------------------------------------
# pc_maximal_beta <- glmmTMB(Measurement ~ Predominant_habitat*raunk_lf +
#                           humanfootprint_value +
#                           Species_richness +
#                           map +
#                           map_var +
#                           mat +
#                           mat_var +
#                           Species_richness:raunk_lf +
#                           map_var:raunk_lf +
#                           map:raunk_lf +
#                           mat_var:raunk_lf +
#                           mat:raunk_lf +
#                           humanfootprint_value:raunk_lf +
#
#                    (1|Best_guess_binomial) +
#                    (1|SS), family = beta_family,
#                    data = mydata)
#'
# if(exists("pc_maximal_beta")) {
#   try(saveRDS(pc_maximal_beta, "f_pc_maximal_beta.rds"))
# } else warning("pc_maximal_beta failed to run")
#'
#'
#' ## ----pc_maximal_gaussian_logit--------------------------------------------------------------------------------------------
print("start running model a")

pc_wec_int_maximal_gauss_logit_nesting_no_U_T <- lmer(response ~ Predominant_habitat.wec + raunk_lf.wec + hab_raunk_interaction +
                            # humanfootprint_value +
                             Species_richness +
                             map +
                             map_var +
                             mat +
                             mat_var +
                             spp_raunk_interaction +
                             map_raunk_interaction +
                             map_var_raunk_interaction +
                             mat_raunk_interaction +
                             mat_var_raunk_interaction +
                            # humanfootprint_value:raunk_lf +
                             (1|Best_guess_binomial) +
                             (1|SS) +
                             (1|Class/Order/Family/Genus),
                           data = mydata)

if(exists("pc_wec_int_maximal_gauss_logit_nesting_no_U_T")) {
  try(saveRDS(pc_wec_int_maximal_gauss_logit_nesting_no_U_T, "f_pc_wec_int_maximal_gauss_logit_nesting_no_U_T.rds"))
} else warning("pc_wec_int_maximal_gauss_logit_nesting_no_U_T failed to run")

print("ran model omitting Urban or therophyte, now running model omitting Primary forest and phanerophte")

#' ## ----pc_maximal_gaussian_logit--------------------------------------------------------------------------------------------
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
mydata$spp_raunk_interaction <- wec.interact(mydata$raunk_lf.wec, mydata$Species_richness)

print("start running model b")

pc_wec_int_maximal_gauss_logit_nesting_no_PF_P <- lmer(response ~ Predominant_habitat.wec + raunk_lf.wec + hab_raunk_interaction +
                                                 # humanfootprint_value +
                                                 Species_richness +
                                                 map +
                                                 map_var +
                                                 mat +
                                                 mat_var +
                                                 spp_raunk_interaction +
                                                 map_raunk_interaction +
                                                 map_var_raunk_interaction +
                                                 mat_raunk_interaction +
                                                 mat_var_raunk_interaction +
                                                 # humanfootprint_value:raunk_lf +
                                                 (1|Best_guess_binomial) +
                                                 (1|SS) +
                                                 (1|Class/Order/Family/Genus),
                                               data = mydata)

if(exists("pc_wec_int_maximal_gauss_logit_nesting_no_PF_P")) {
  try(saveRDS(pc_wec_int_maximal_gauss_logit_nesting_no_PF_P, "f_pc_wec_int_maximal_gauss_logit_nesting_no_PF_P.rds"))
} else warning("pc_wec_int_maximal_gauss_logit_nesting_no_PF_P failed to run")

print("ran model omitting Primary forest and phanerophte, now running model ommitting Pasture and cryptophyte")

#' ## ----pc_maximal_gaussian_logit--------------------------------------------------------------------------------------------
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
mydata$spp_raunk_interaction <- wec.interact(mydata$raunk_lf.wec, mydata$Species_richness)

print("start running model c")

pc_wec_int_maximal_gauss_logit_nesting_no_P_C <- lmer(response ~ Predominant_habitat.wec + raunk_lf.wec + hab_raunk_interaction +
                                                         # humanfootprint_value +
                                                         Species_richness +
                                                         map +
                                                         map_var +
                                                         mat +
                                                         mat_var +
                                                         spp_raunk_interaction +
                                                         map_raunk_interaction +
                                                         map_var_raunk_interaction +
                                                         mat_raunk_interaction +
                                                         mat_var_raunk_interaction +
                                                         # humanfootprint_value:raunk_lf +
                                                         (1|Best_guess_binomial) +
                                                         (1|SS) +
                                                         (1|Class/Order/Family/Genus),
                                                       data = mydata)

if(exists("pc_wec_int_maximal_gauss_logit_nesting_no_P_C")) {
  try(saveRDS(pc_wec_int_maximal_gauss_logit_nesting_no_P_C, "f_pc_wec_int_maximal_gauss_logit_nesting_no_P_C.rds"))
} else warning("pc_wec_int_maximal_gauss_logit_nesting_no_P_C failed to run")

print("end")

#' #' 
#' ## ----pc_maximal_poisson,-----------------------------------------------------------------------------------------
#' pc_maximal_poisson <- glmmTMB(Measurement ~ Predominant_habitat*raunk_lf +
#'                                     humanfootprint_value +
#'                                     Species_richness +
#'                                     map +
#'                                     map_var +
#'                                     mat +
#'                                     mat_var +
#'                                     Species_richness:raunk_lf +
#'                                     map_var:raunk_lf +
#'                                     map:raunk_lf +
#'                                     mat_var:raunk_lf +
#'                                     mat:raunk_lf +
#'                                     humanfootprint_value:raunk_lf +
#'                                     
#'                                     (1|Best_guess_binomial) +
#'                                     (1|SS), family = poisson,
#'                                   data = mydata)
#' 
#' saveRDS(pc_maximal_poisson, "pc_maximal_poisson.rds")
#' #' 
#' #' # dredge 
#' #' Dredge to validate best combination of predictors
#' ## ----pc dredge interactions,----------------------------------------------------------------------------------
#' ## pc_full_dredge <- dredge(pc_best, beta = "sd", evaluate = TRUE, trace = TRUE,
#' ##         rank = "AIC")
## 
## summary(pc_full_dredge) ##
## plot(pc_full_dredge)


## ----save models------------------------------------------------------------------------------------------------------------------------
# saveRDS(pc_best_beta, "pc_best_beta.rds")
#saveRDS(pc_best_interaction, "pc_best_beta_interactions.rds")
# saveRDS(pc_best_poisson, "pc_best_poisson.rds")
# saveRDS(pc_best_nbinom1, "pc_best_nbinom1.rds")
# saveRDS(pc_best_gaussian, "pc_best_guassian.rds")







#' 
#' 
#' 
#' 
#' 
#' 
#' 
