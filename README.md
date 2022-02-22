landuse_climate_lifeform

This repository is for the code and data files used in the landuse_climate_lifeform project looking at the relationships between plant life form and species occurrence and abundance across human land uses.

Code written by Caroline McKeon funded by Irish Research Council Government of Ireland Postgraduate Scholarship award GOIPG/2018/475, with help from the opensource commmunity at Stack Overflow. 

This workflow is for compiling, cleaning, handling, analysing and visualising land use and Raunkiear life form data and the results of the analysis.
Analysis was carried out on Trinity College Dublin's lonsdale computing cluster, which is funded through grants from Science Foundation Ireland. 

# Data sources:

Land use

PREDICTS - https://www.predicts.org.uk/pages/outputs.html 

Hudson, L. N., Newbold, T., Contu, S., Hill, S. L. L., Lysenko, I., De Palma, A., Phillips, H. R. P., Senior, R. A., Bennett, D. J., Booth, H., Choimes, A., Correia, D. L. P., Day, J., Echeverría-Londoño, S., Garon, M., Harrison, M. L. K., Ingram, D. J., Jung, M., Kemp, V., … Purvis, A. (2016). The PREDICTS database: A global database of how local terrestrial biodiversity responds to human impacts. Ecology and Evolution, 4(24), 4701–4735. https://doi.org/10.1002/ece3.1303![image](https://user-images.githubusercontent.com/44772138/155151408-947a7cbd-7947-4e8f-a0f6-f2ac25c732d7.png)


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


