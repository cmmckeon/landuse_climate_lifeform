

## notes on using the cluster -----------

# Set up for analysis:
#   Clone git repository and upload onto cluster. 
# You must have all your R packages installed before you try to run the analysis; heavy nodes (where you send jobs) have no internet access. 
# Packages installed from the R console on your head node can be libraries in you Rscript without a problem, as all the files are shared across the cluster


install.packages(c("lme4","optimx", "DHARMa", "glmmTMB", "MuMIn", "effects",
                   "tidyverse", "raster", "rgdal", "RColorBrewer",
                   "MCMCglmm", 'invgamma', "dismo", "wec"),
                 repos="https://cloud.r-project.org/")

## start of cluster setup----------------------------------------------------------------------------------
# bash commands:

## vim mckeonc2_name_of_script.sh
## paste the below

## start of bach script --------------------------

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
## end of bash script --------------------------

## type escape key :wq to save bash script
## end of cluster set up ----------------------------------------------------------------------------------


## then 
sbatch mckeonc2_name_of_script.sh ## to run the bash script that sources your R script

## once your job has been submitted, you will be told 
## "Submitted batch job JOBIDHERE". You can then check if it's in the que
squeue
## check the details of the job (when it will start, how long it is allowed to run, when it will finish)
scontrol show jobid JOBIDHERE
## check the output
vim slurm-JOBIDHERE.out


## if your job was successful, and object where created, download them from the cluster onto your own machine
## cd into the directory where your R script was running 


git pull ## to be sure you are not behind the master branch 
git add name_of_newly_created_object.rds
git commit -m "message detailing how you just added name_of_newly_created_object.rds"
git push



## example bash scripts -----------------------------------

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



