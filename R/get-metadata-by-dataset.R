library(purrr)
library(dplyr)
library(magrittr)
library(assertive.properties)

# setwd("data-packages/")

# vcdExtra::datasets doesn't work from inside lapply/map_df

# dir.create("data/dataset-metadata")

pkg_names <- .packages(TRUE) %>% setdiff(
  c('acc', 'AdapEnetClass', 'adaptsmoFMRI', 'afex', 'alakazam',
    'anesrake', 'angstroms', 'ANLP', 'ANOM', 'anominate',
    'Anthropometry', 'antiword', 'approximator', 'apt', 'ARCensReg',
    'arulesNBMiner', 'arulesViz', 'asbio', 'asht', 'aSPU', 'ASSISTant',
    'AssocTests', 'AssotesteR', 'asymmetry', 'auRoc', 'aVirtualTwins',
    'B2Z', 'BalanceCheck', 'bamdit', 'bamlss', 'BANOVA', 'BayesCR',
    'BayesFactor', 'bayesGARCH', 'bayesLife', 'bayesPop', 'BayesSpec',
    'bayesTFR', 'Bayesthresh', 'BayesVarSel', 'BaySIC', 'BAYSTAR',
    'bdots', 'betas', 'bgmm', 'bgsmtr', 'bifactorial', 'BIFIEsurvey',
    'bartMachine', 'bartMachineJARs', 'BayesMed', 'bigReg',
    'bindata', 'binMto', 'bio3d', 'Biograph', 'BIOMASS', 'biomod2',
    'birdring', 'biwt', 'BNPdensity', 'CNVassocData')
)

dataset_info <- map_df(
  pkg_names, 
  function(pkg_name) {
    
    metadata_file <- paste0("data/dataset-metadata/", pkg_name, ".rds")
    if(file.exists(metadata_file)) {
      return(NULL) # return(readRDS(metadata_file))
    }
    message(pkg_name)
    
    x <- tryCatch(
      suppressPackageStartupMessages(
        library(pkg_name, character.only = TRUE, quietly = TRUE)
      ),
      error = function(e) "failure"
    )
    if(identical(x, "failure")) return(NULL)
    data_env <- new.env()
    data_results <- data(package = pkg_name)$results[, c("Item", "Title"), drop = FALSE]
    if(is_empty(data_results)) {
      return(NULL)
    }  
    data_results <- data_frame(
      data_name = data_results[, "Item"], 
      data_title = data_results[, "Title"]
    )
    data_names <- data_results$data_name
    data(list = data_names, package = pkg_name, envir = data_env) 
    metadata <- if(is_empty(data_env)) {
      data_frame(
        pkg_name = character(),
        data_name = character(), # ls() returns different order
        type    = character(),
        classes = list(),
        length  = integer(),
        n_elts  = integer(),
        nrow    = integer(),
        ncol    = integer(),
        dims    = list(),
        data_title = character()
      )
    } else {
      data_frame(
        pkg_name = pkg_name,
        data_name = names(lapply(data_env, identity)), # ls() returns different order
        type    = vapply(data_env, typeof, character(1), USE.NAMES = FALSE),
        classes = unname(lapply(data_env, class)),
        length  = vapply(data_env, length, integer(1), USE.NAMES = FALSE),
        n_elts  = vapply(data_env, n_elements, integer(1), USE.NAMES = FALSE),
        nrow    = vapply(data_env, NROW, integer(1), USE.NAMES = FALSE),
        ncol    = vapply(data_env, NCOL, integer(1), USE.NAMES = FALSE),
        dims    = unname(lapply(data_env, DIM))
      ) %>% inner_join(data_results, by = "data_name")
    }
    # Save results
    saveRDS(metadata, metadata_file)
    
    search_path_name <- paste0("package:", pkg_name)
    if(search_path_name %in% search()) {
      try(
        detach(search_path_name, character.only = TRUE, unload = TRUE), 
        silent = TRUE
      )
    }
    metadata
  }
)

#   -----------------------------------------------------------------------

rds_files <- dir("data/dataset-metadata", full.names = TRUE)

metadata <- rds_files %>% map(readRDS) %>% bind_rows()

saveRDS(metadata, "data/metadata-for-many-pkgs.rds")

