## LF_05_frequentist_diagnostics

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


## read in models----------------------------------------------------------------------------------------------------
if(!exists("f_mod")) {
  if(file.exists("f_pc_maximal_gauss_logit_nesting.rds")) {
    try(f_mod <- readRDS("f_pc_maximal_gauss_logit_nesting.rds"))
  } else warning("f_pc_maximal_gauss_logit_nesting.rds does not exist in this directory")
} ## 02/07/2020 all data


if(!exists("ModelDF")) {
  if(file.exists("Data_ModelDF.rds")) {
    try(ModelDF <- readRDS("Data_ModelDF.rds"))
    print("Model Dataframe read in")
  } else warning("ModelDF does not exist in this directory")
}

#f_mod <- readRDS("f_oc_maximal_zi_1_nested.rds")

mydata <- ModelDF


## handle model dataframe to get just percent cover data, with species levels in the right format
levels(ModelDF$Best_guess_binomial) <- gsub(" ", "_", levels(ModelDF$Best_guess_binomial))
mydata <- ModelDF[ModelDF$Diversity_metric == "percent cover", ]
mydata <- mydata[mydata$Measurement !=0,]
mydata <- unique(mydata)
mydata$Measurement <- mydata$Measurement/100
mydata$response <- scale(logitTransform(mydata$Measurement))
mydata$animal <- mydata$Best_guess_binomial


## get taxomonic data for all species
if(!exists("PR_oc")) {
  if(file.exists("Data_PR_f_oc.rds")) {
    try(PR_oc <- readRDS("Data_PR_f_oc.rds"))
  } else try(
    {PR <- readRDS("Data_PR_plantDiversityCorr.rds")
    levels(PR$Best_guess_binomial) <- gsub(" ", "_", levels(PR$Best_guess_binomial))
    PR <- PR[PR$Best_guess_binomial %in% mydata$Best_guess_binomial,]
    PR_oc <- unique(PR[, which(names(PR) %in% c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus",
                                                "Best_guess_binomial"))])})
}

mydata <- droplevels(merge(mydata, PR_oc, by = "Best_guess_binomial",all.x = TRUE)) 



summary(f_mod)

plot(f_mod)

## Diagnostics ----------------------------------------------------------

## DHARMa residuals for whole model
set.seed(17)
# save <- simulationOutput
# simulationOutput <- save
simulationOutput <- simulateResiduals(fittedModel = f_mod, n = 250, use.u = T)
simulationOutput <- simulateResiduals(fittedModel = f_mod, n = 250)
hist(simulationOutput)

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


## for the percent cover model, the diagnostics look really good.

## Predict pc------------------------
# direct model predictions (population level, everything else to mean)
new_data <- mydata
new_data <- new_data[, which(names(new_data) %in% c("Best_guess_binomial", "Predominant_habitat", "Measurement", "SS", 
                                                   "raunk_lf", "Species_richness", 
                                                    "map", "mat", "map_var", "mat_var", "pres_abs", 
                                                    "response"))]
cont <- c("Species_richness", 
  "map", "mat", "map_var", "mat_var")
for (i in cont){
  new_data[,i] <-mean(new_data[,i])
}

new_data$x <-predict(f_mod, new_data, newparams = NULL,
        re.form = NULL,
        random.only=FALSE, terms = NULL,
        type = "response", allow.new.levels = TRUE,
        na.action = na.pass)

hist(new_data$response)
hist(new_data$x)

plot(x ~ response, new_data)

# blank theme
set_theme(
  base = theme_classic(),
  axis.title.size = 1,
  axis.textsize = 1,
  legend.size = 1,
  legend.title.size = 1,
  geom.label.size = 3
)

## text editing
get_wraper <- function(width) {
  function(x) {
    lapply(strwrap(x, width = width, simplify = FALSE), paste, collapse="\n")}}
## colour palett
cb_pal <- c("#01665e", "#5ab4ac","#c7eae5", "#d8b365", 
            "#8c510a")

## make plot
pc_pred <- ggpredict(f_mod, terms = c("Predominant_habitat", "raunk_lf"), 
                     back.transform = NULL, type = "fe")

cont <- c("predicted", "std.error", "conf.low", "conf.high")
for (i in cont){
  pc_pred[,i] <-inv.logit(pc_pred[,i]-4.853034) ## "-4.853034" is the mean of the response before scaling
}

ggplot(pc_pred, aes(x, predicted, colour = raunk_lf)) + 
 # geom_point(position = position_dodge(0.5)) +
  geom_pointrange(aes(ymin=conf.low, ymax=conf.high, colour = group), position = position_dodge(0.5)) +
  labs(color = "Raunkiaerian life form", y="Predicted Percent Cover", 
       title = "Predicted values for species Percent Cover", x = "Land use") + 
  scale_colour_manual(values = cb_pal, 
                      limits=c("phanerophyte", "chamaephyte","hemicryptophyte","cryptophyte", "therophyte")) + 
  scale_x_discrete(labels = get_wraper(10)) + 
  theme(plot.title = element_text(size=22), axis.title.x = element_text(size=22)) #+ ylim(0, 1)

## Predict oc------------------------

oc_pred <- ggpredict(f_mod, terms = c("Predominant_habitat", "raunk_lf"), 
                       back.transform = NULL, type = "fe")
cont <- c("predicted", "std.error", "conf.low", "conf.high")
for (i in cont){
  oc_pred[,i] <-inv.logit(oc_pred[,i]) 
}

ggplot(oc_pred, aes(x, predicted)) + 
    geom_pointrange(aes(ymin=conf.low, ymax=conf.high, colour = group), position = position_dodge(0.5)) +
    # geom_point(position = position_dodge(0.5)) +
    labs(color = "Raunkiaerian life form", y="Predicted probability of presense", 
         title = "Predicted values for species probability of presense", x = "Land use") + 
    scale_colour_manual(values = cb_pal, limits=c("phanerophyte", "chamaephyte","hemicryptophyte","cryptophyte", "therophyte")) + 
    scale_x_discrete(labels = get_wraper(10)) + theme(plot.title = element_text(size=22), axis.title.x = element_text(size=22)) #+ ylim(0, 1)  
#saveRDS(oc_pred, "f_oc_pred_binary.rds")  

## check for perfect separation that could be an issue with the zero-inlfation
ggplot(ModelDF, aes(x=pres_abs, y=Predominant_habitat)) + 
  geom_density_ridges2(alpha = .3) + 
  labs(title = "Density of covariate data by Land use and Life Form", y = "Predominant habitat type", x = "", fill = "Raunkiaerian Life form") +
  facet_grid(.~raunk_lf, scales='free')



library(sjPlot)

p <- plot_model(f_mod, transform = NULL, size = 0.01, sort.est = T)



    