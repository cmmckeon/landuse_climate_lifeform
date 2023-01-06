## LF_05_frequentist_diagnostics

## this is an interactive script where you can work through the models yourself

## set up --------------------------------------------------------
#install.packages(c("DHARMa"))

library(DHARMa)
library(glmmTMB)
library(lme4)
library(data.table)
library(ggplot2)
library(sjPlot) ## for the set_theme function
library(viridis)
library(ggpubr)
library(ggeffects)
library(gtools)

## create logit transformation function
logitTransform <- function(x) { log(x/(1-x)) }


## read in a model----------------------------------------------------------------------------------------------------
if(!exists("f_mod")) {
  if(file.exists("f_pc_wec_int_maximal_gauss_logit_nesting_no_U_T.rds")) {
    try(f_mod <- readRDS("f_pc_wec_int_maximal_gauss_logit_nesting_no_U_T.rds"))
  } else warning("f_pc_wec_int_maximal_gauss_logit_nesting_no_U_T.rds does not exist in this directory")
} 


if(!exists("ModelDF")) {
  if(file.exists("Data_ModelDF.rds")) {
    try(ModelDF <- readRDS("Data_ModelDF.rds"))
    print("Model Dataframe read in")
  } else warning("ModelDF does not exist in this directory")
}

#f_mod <- readRDS("f_pc_wec_int_maximal_gauss_logit_nesting_no_P_C.rds")
#f_mod <- readRDS("f_pc_wec_int_maximal_gauss_logit_nesting_no_PF_P.rds")

# f_mod <- readRDS("oc_wec_int_maximal_zi_1_nested_no_P_C.rds")
# f_mod <- readRDS("oc_wec_int_maximal_zi_1_nested_no_PF_P.rds")
# f_mod <- readRDS("oc_wec_int_maximal_zi_1_nested_no_U_T.rds")

mydata <- ModelDF

## handle model dataframe to get just percent cover data, with species levels in the right format
levels(ModelDF$Best_guess_binomial) <- gsub(" ", "_", levels(ModelDF$Best_guess_binomial))
mydata <- ModelDF[ModelDF$Diversity_metric == "percent cover", ]
mydata <- mydata[mydata$Measurement !=0,]
mydata <- unique(mydata)
mydata$Measurement <- mydata$Measurement/100
mydata$response <- scale(logitTransform(mydata$Measurement))
mydata$animal <- mydata$Best_guess_binomial

## handle model dataframe to get just percent cover data, with species levels in the right format
levels(ModelDF$Best_guess_binomial) <- gsub(" ", "_", levels(ModelDF$Best_guess_binomial))
mydata <- ModelDF
mydata$animal <- mydata$Best_guess_binomial


## get taxomonic data for all species
PR_pc <- readRDS("Data_03a_PR_f_pc.rds")
#PR_oc <- readRDS("Data_03b_PR_f_oc.rds")

mydata <- droplevels(merge(mydata, PR_oc, by = "Best_guess_binomial",all.x = TRUE)) 



summary(f_mod)

plot(f_mod)

fittedModel <- f_mod

## Diagnostics ----------------------------------------------------------

## DHARMa residuals for whole model
set.seed(17)

 save <- simulationOutput
# simulationOutput <- save
simulationOutput <- simulateResiduals(fittedModel = f_mod, n = 250, use.u = T)
simulationOutput <- simulateResiduals(fittedModel = f_mod, n = 250)
hist(simulationOutput)

testDispersion(fittedModel)

testZeroInflation(simulationOutput)

residuals(simulationOutput)

plot(simulationOutput)

plotResiduals(simulationOutput)

testResiduals(simulationOutput)
testDispersion(simulationOutput)
testUniformity(simulationOutput) ## If ks test p value is < 0.5, then the residuals ARE different from the qq plot line, and so, NOT normally distributed. 
testZeroInflation(simulationOutput)

## residuals per variable 
plotResiduals(simulationOutput, mydata$raunk_lf) 
plotResiduals(simulationOutput, mydata$Predominant_habitat) 
plotResiduals(simulationOutput, mydata$map)
plotResiduals(simulationOutput, mydata$mat)
plotResiduals(simulationOutput, mydata$Species_richness)
plotResiduals(simulationOutput, mydata$map_var)
plotResiduals(simulationOutput, mydata$mat_var)




    