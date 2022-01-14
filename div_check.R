## LF_02_diversity_check
# diversity check script

## this script is for finding and filtering paper in PREDICTS from which we obtain data, in order to check whether the data is useable for our purposes.

PR <- readRDS("Data_PR_plantDiversityCorr.rds") 
levels(PR$Best_guess_binomial) <- gsub(" ", "_", levels(PR$Best_guess_binomial))
PR <- PR %>% .[.$Diversity_metric == "abundance" | .$Diversity_metric == "percent cover"| .$Diversity_metric == "occurrence",]
P <- PR[PR$Best_guess_binomial %in% ModelDF$Best_guess_binomial,]

# DR <- readRDS("plantDiversity.rds") 
# levels(DR$Best_guess_binomial) <- gsub(" ", "_", levels(DR$Best_guess_binomial))
# D <- DR[DR$Best_guess_binomial %in% ModelDF$Best_guess_binomial,]
# 
# length(unique((D$Source_ID)))
length(unique((P$Source_ID)))

p <- droplevels(unique(P[, which(names(P) %in% c("Source_ID", "Study_name", "Sampling_method", "Sampling_effort_unit", "Sampling_target",
                                      "SS", "Sampling_effort", "Diversity_metric", "Diversity_metric_is_effort_sensitive"))]))


p$Source_ID[p$SS %nin% ModelDF$SS]
setdiff(p$SS,ModelDF$SS)

p <- p[p$SS %in% ModelDF$SS,]

certain_species <- p[p$Sampling_target == "Certain species",]
length(unique(p$Source_ID))
length(unique(p$SS))
length(unique(p$Study_name))

dput(unique(droplevels(certain_species$Source_ID)))
## being very conservative here
issue_papers <- c("SC1_2012__GendreauBerthiaume", "SC1_2010__Baeten","DL1_2009__Barquero",
                  "DL1_2012__Hernandez", "SC1_2004__Kolb", "SC2_2011__LucasBorja")
d <- p[p$Source_ID %in% issue_papers,]

m <- ModelDF[ModelDF$SS %nin% d$SS,] ## 587665 obs (down from 624696) - keeping  94% of data


j <- droplevels(unique(p[, which(names(p) %in% c("SS", "Source_ID", "Study_name"))]))
#write.csv(j, "all_PR_papers.csv")

j <- droplevels(unique(d[, which(names(d) %in% c("SS", "Source_ID", "Study_name"))]))
#write.csv(j, "remaining_PR_papers.csv")





 