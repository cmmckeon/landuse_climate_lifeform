landuse_climate_lifeform

This repository is for the code and data files used in the landuse_climate_lifeform project looking at the relationships between plant life form and species occurrence and abundance across human land uses.

This workflow is for compiling, cleaning, handling, analysing and visualising land use and Raunkiear life form data and the results of the analysis.
Analysis was carried out on Trinity College Dublin's lonsdale computing cluster, which is funded through grants from Science Foundation Ireland. 

Code written (with help from the open source commmunity at stack overflow) by Caroline McKeon, funded by Irish Research Council Government of Ireland Postgraduate Scholarship award GOIPG/2018/475.

# Data sources:

Land use

PREDICTS - http://www.predicts.org.uk 

Hudson, L. N., Newbold, T., Contu, S., Hill, S. L. L., Lysenko, I., De Palma, A., Phillips, H. R. P., Senior, R. A., Bennett, D. J., Booth, H., Choimes, A., Correia, D. L. P., Day, J., Echeverría-Londoño, S., Garon, M., Harrison, M. L. K., Ingram, D. J., Jung, M., Kemp, V., … Purvis, A. (2016). The PREDICTS database: A global database of how local terrestrial biodiversity responds to human impacts. Ecology and Evolution, 4(24), 4701–4735. https://doi.org/10.1002/ece3.1303 

Life form

TRY (version 5) - https://www.try-db.org/ 

Kattge, J., Díaz, S., Lavorel, S., Prentice, I. C., Leadley, P., Bönisch, G., Garnier, E., Westoby, M., Reich, P. B., Wright, I. J., Cornelissen, J. H., Violle, C., Harrison, S. P., Van Bodegom, P. M., Reichstein, M., Enquist, B. J., Soudzilovskaia, N. A., Ackerly, D. D., Anand, M., … Wirth, C. (2011). TRY – a global database of plant traits. Global Change Biology, 17(9), 2905–2935. https://doi.org/10.1111/j.1365-2486.2011.02451.x


BIEN - https://bien.nceas.ucsb.edu/bien/ 

Maitner, B. S., Boyle, B., Casler, N., Condit, R., II, J. D., Durán, S. M., Guaderrama, D., Hinchliff, C. E., Jørgensen, P. M., Kraft, N. J. B., McGill, B., Merow, C., Morueta‐Holme, N., Peet, R. K., Sandel, B., Schildhauer, M., Smith, S. A., Svenning, J., Thiers, B., … Enquist, B. J. (2018). The bien r package: A tool to access the Botanical Information and Ecology Network (BIEN) database. Methods in Ecology and Evolution, 9(2), 373–379. https://doi.org/10.1111/2041-210X.12861 

Climate

WorldClim (version 1.4) - https://www.worldclim.org/data/v1.4/formats.html  
Fick, S. E., & Hijmans, R. J. (2017). WorldClim 2: New 1‐km spatial resolution climate surfaces for global land areas. International Journal of Climatology, 37(12), 4302–4315


Biomes 

https://ecotope.org/files/anthromes/v2/data/base_data/anthromes_2_base_data_GeoTIFF.zip
Ramankutty, N., & Foley, J. A. (1999). Estimating historical changes in global land cover: Croplands from 1700 to 1992. Global Biogeochemical Cycles, 13(4), 997–1027. https://doi.org/10.1029/1999GB900046

Ecoregions 

https://www.worldwildlife.org/publications/terrestrial-ecoregions-of-the-world 
Olson, D. M., Dinerstein, E., Wikramanayake, E. D., Burgess, N. D., Powell, G. V. N., Underwood, E. C., D’amico, J. A., Itoua, I., Strand, H. E., Morrison, J. C., Loucks, C. J., Allnutt, T. F., Ricketts, T. H., Kura, Y., Lamoreux, J. F., Wettengel, W. W., Hedao, P., & Kassem, K. R. (2001). Terrestrial Ecoregions of the World: A New Map of Life on Earth. BioScience, 51(11), 933. https://doi.org/10.1641/0006-3568(2001)051[0933:TEOTWA]2.0.CO;2

# Scripts should be run in this order:

# On a cluster:

LF_01_data_handling.R (first make sure you have all the datasets detailed at the top of this script)

(there is no LF_02; used to clean phylogeny when I was trying a bayesian version of this analysis - switched back to frequentist as it was way too computationally intensive)

LF_03a_frequentist_percent_cover.R 

LF_03b_frequentist_occurrence.R

LF_04a_NO_RICH_frequentist_percent_cover.R

LF_04b_NO_RICH_frequentist_occurrence.R

LF_12_merged_LU_frequentist_occurrence.R

LF_12_merged_LU_frequentist_percent_cover.R

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

LF_13a_merged_oc_estimates.Rmd

LF_13b_merged_pc_estimates.Rmd

LF_14_merged_figures.Rmd

LF_15_merged_sup_figures.Rmd

LF_16_merged_sup_tables.Rmd






