landuse_climate_lifeform;
Project looking at the relationships between plant life form and species occurrence and abundance across human land use.
Code written by Caroline McKeon funded by Irish Research Council Government of Ireland Postgraduate Scholarship award GOIPG/2018/475, with help from the opensource commmunity at Stack Overflow. 

This workflow is for compiling, cleaning, handling, analysing and visualising land use and Raunkiear life form data and the results of the analysis.
Analysis was carried out on Trinity College Dublin's lonsdale computing cluster, which is funded through grants from Science Foundation Ireland. 


# Scripts should be run in this order:

# On a cluster:

LF_01_data_handling.R

(there is no LF_02; used to clean phylogeny when I was trying a bayesian version of this analysis - switched back to frequentist as it was way too computationally intensive)

LF_03a_frequentist_percent_cover.R
LF_03b_frequentist_occurrence.R
LF_04a_NO_RICH_frequentist_percent_cover.R
LF_04b_NO_RICH_frequentist_occurrence.R

# On a desktop: 

#LF_05_diagnostics_frequentist.R

LF_06a_pc_estimates.Rmd
LF_06b_oc_estimates.Rmd

LF_07a_NO_RICH_pc_effectsizes.Rmd
LF_07b_NO_RICH_oc_effectsizes.Rmd

LF_08_clim_biome_ecoregion.Rmd

LF_09a_panel_figs.Rmd
LF_09b_sups_panel_figs.Rmd

LF_10_sups_figures.Rmd

LF_11_sups_tables.Rmd


## bash scripts

# mckeonc2_f_pc_script.sh
#!/bin/sh
#SBATCH -n 8           # 8 CPU cores, each lonsdale node has 8 such cores
#SBATCH -t 4-00:00:00   # 4 days
#SBATCH -p compute      # partition name
#SBATCH -J mckeonc_predicts_analysis  # sensible name for the job
pwd
## set up your environment
source ~/git/spack/share/spack/setup-env.sh && spack load r@3.6.3
## launch the code
Rscript ~/PREDICTS/LF_04a_frequentist_percent_cover.R


# mckeonc2_f_oc_script.sh
#!/bin/sh
#SBATCH -n 8           # 8 CPU cores, each lonsdale node has 8 such cores
#SBATCH -t 4-00:00:00   # 4 days
#SBATCH --mem=64000
#SBATCH -p compute      # partition name
#SBATCH -J mckeonc_predicts_analysis  # sensible name for the job
pwd
## set up your environment
source ~/git/spack/share/spack/setup-env.sh && spack load r@3.6.3
## launch the code
Rscript ~/PREDICTS/LF_04b_frequentist_occurrence.R


ect.

## notes on using the cluster 

Set up for analysis:
Clone git repository and upload onto cluster. 
You must have all your R packages installed before you try to run the analysis; heavy nodes (where you send jobs) have no internet access. 
Packages installed from the R console on your head node can be libraries in you Rscript without a problem, as all the files are shared across the cluster

install.packages(c("lme4","optimx", "DHARMa", "glmmTMB", "MuMIn", "effects",
                  "tidyverse", "raster", "rgdal", "RColorBrewer",
                   "MCMCglmm", 'invgamma', "dismo", "wec"),
                 repos="https://cloud.r-project.org/")

#### ----------------------------------------------------------------------------------
# bash commands:

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
pwd

## set up your environment (load the right R version)
source ~/git/spack/share/spack/setup-env.sh && spack load r@3.6.3

## launch the code
Rscript ~/PREDICTS/LF_0which_ever_script_you_need.R
## --------------------------

## type escape key :wq to save bash script
#### ----------------------------------------------------------------------------------


## then 
sbatch mckeonc2_name_of_script.sh ## to run the bash script that sources your R script

## once your job has been submitted, you will be told 
## "Submitted batch job JOBIDHERE". You can then check if it's in the que
# squeue
## check the details of the job (when it will start, how long it is allowed to run, when it will finish)
# scontrol show jobid JOBIDHERE
## check the output
# vim slurm-JOBIDHERE.out


## if your job was successful, and object where created, download them from the cluster onto your own machine
## cd into the directory where your R script was running 

# git pull ## to be sure you are not behind the master branch 
# git add name_of_newly_created_object.rds
# git commit -m "message detailing how you just added name_of_newly_created_object.rds"
# git push

#### ----------------------------------------------------------------------------------
#### ----------------------------------------------------------------------------------
## end of notes on using the cluster 



