# landuse_climate_lifeform
Project looking at the relationships between plant life form and species occurrence and abundance across human land use.

This workflow is for compiling, cleaning, handling, analysing and visualising land use and Raunkiear life form data.
Analysis was carried out on Trinity College Dublin's lonsdale computing cluster.  


Set up for analysis:
Clone git repository and upload onto cluster. 
You must have all your R packages installed before you try to run the analysis; heavy nodes (where you send jobs) have no internet access. 
Packages installed from the R console on your head node can be libraried in you Rscript without a problem,
as all the files are shared across the cluster
# install.packages(c("lme4","optimx", "DHARMa", "glmmTMB", "MuMIn", "effects",
#                    "tidyverse", "raster", "rgdal", "RColorBrewer",
#                    "MCMCglmm", 'invgamma', "mulTree", "ape", 
#                    "phytools", "caper","maps", "dismo", "coda", "hdrcde",
#                    "snow", "corpcor", "curl", "ape", "phytools", "ggtree", "caper"),
#                  repos="https://cloud.r-project.org/")


#### ----------------------------------------------------------------------------------
#### ----------------------------------------------------------------------------------
bash commands:

## vim mckeonc2_name_of_script.sh
## paste the below
## --------------------------
#!/bin/sh
#SBATCH -n 8           # 8 CPU cores, each lonsdale node has 8 such cores
#SBATCH -t 4-00:00:00   # 4 days
#SBATCH --mem=64000 ## this specifies the node that you want. Use mem=32000 for 32GB RAM node, or omitt line to use normal 16GB nodes
#SBATCH -p compute      # partition name
#SBATCH -J mckeonc_predicts_analysis  # sensible name for the job

## check if you're in the right working directory
#pwd

## set up your environment (load the right R version)
#source ~/git/spack/share/spack/setup-env.sh && spack load r@3.6.3

# launch the code
#Rscript ~/PREDICTS/LF_0which_ever_script_you_need.R

## --------------------------
##:wq

## then 
# sbatch mckeonc2_name_of_script.sh

## once your job has been submitted, you will be told 
## "Submitted batch job JOBIDHERE". You can then check if it's in the que
# squeue
## check the details of the job (when it will start, how long it is allowed to run, when it will finish)
# scontrol show jobid JOBIDHERE
## check the output
# vim slurm-JOBIDHERE.out


## if your job was successful, and objectw where created, download them from the cluster onto your own machine
## cd into the directory where your R script was running 

# git pull ## to be sure you are not behind the master branch 
# git add name_of_newly_created_object.rds
# git commit -m "message detailing how you just added name_of_newly_created_object.rds"
# git push

#### ----------------------------------------------------------------------------------
#### ----------------------------------------------------------------------------------

Scripts should be run in this order:

# On a cluster:

LF_01_data_handling.R

LF_02_create_phylogeny.R

LF_03a_frequentist_percent_cover.R
LF_03b_frequentist_occurrence.R
LF_04a_NO_RICH_frequentist_percent_cover.R
LF_04b_NO_RICH_frequentist_occurrence.R

# On a desktop: 

#LF_05_diagnostics_bayesian.R

LF_06a_pc_estimates.Rmd
LF_06b_oc_estimates.Rmd

LF_07b_oc_estimates_and_predicitons.Rmd

LF_08_clim_biome_ecoregion.Rmd


## set up

setwd("~/PREDICTS")

## set up ###################
library(tidyverse)
library(MCMCglmm)
library(lme4)
library(invgamma)
library(glmmTMB)
library(mulTree)
library(phytools)
library(doParallel)
library(optimx) 

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

## get phylogeny set up
if(!exists("clean_tree")) {
  if(file.exists("clean_tree.tre")) {
    try(clean_tree <- read.tree("clean_tree.tre")) } 
    else warning("clean_tree.tre not present in working directory")
} 

if(!exists("clean_tree")) {
  print("trying to source script to create phylogeny")
source("LF_02_create_phylogeny.R")}

## handle model dataframe to get just percent cover data, with species levels in the right format
levels(ModelDF$Best_guess_binomial) <- gsub(" ", "_", levels(ModelDF$Best_guess_binomial))

mcmc_data <- ModelDF[ModelDF$Diversity_metric == "percent cover", ]
mcmc_data <- mcmc_data[mcmc_data$Measurement !=0,]
mcmc_data <- unique(mcmc_data)
mcmc_data$Measurement <- mcmc_data$Measurement/100
mcmc_data$response <- scale(logitTransform(mcmc_data$Measurement))
mcmc_data$animal <- mcmc_data$Best_guess_binomial

## create comparative dataset
comp_data <- clean.data(mcmc_data, clean_tree, data.col = "animal")




## bash scripts

## mckeonc2_f_pc_script.sh
#!/bin/sh
#SBATCH -n 8           # 8 CPU cores, each lonsdale node has 8 such cores
#SBATCH -t 4-00:00:00   # 4 days
#SBATCH -p compute      # partition name
#SBATCH -J mckeonc_predicts_analysis  # sensible name for the job
pwd
# set up your environment
source ~/git/spack/share/spack/setup-env.sh && spack load r@3.6.3
# launch the code
Rscript ~/PREDICTS/LF_04a_frequentist_percent_cover.R


## mckeonc2_f_oc_script.sh
#!/bin/sh
#SBATCH -n 8           # 8 CPU cores, each lonsdale node has 8 such cores
#SBATCH -t 4-00:00:00   # 4 days
#SBATCH --mem=64000
#SBATCH -p compute      # partition name
#SBATCH -J mckeonc_predicts_analysis  # sensible name for the job
pwd
# set up your environment
source ~/git/spack/share/spack/setup-env.sh && spack load r@3.6.3
# launch the code
Rscript ~/PREDICTS/LF_04b_frequentist_occurrence.R

## mckeonc2_b_zi_script.sh
#!/bin/sh
#SBATCH -n 2           # 2 CPU cores, each lonsdale node has 8 such cores
#SBATCH -t 4-00:00:00   # 4 days
#SBATCH --mem=64000
#SBATCH -p compute      # partition name
#SBATCH -J mckeonc_predicts_analysis  # sensible name for the job
pwd
# set up your environment
source ~/git/spack/share/spack/setup-env.sh && spack load r@3.6.3
# launch the code
Rscript ~/PREDICTS/LF_03b_bayesian_zeroinflated_occurrence.R


ect.



