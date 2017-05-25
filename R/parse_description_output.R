source("R/parse_description.R")

library(magrittr)

output <- read_rds("data/pkg_data_data.rds") %>% 
              filter(has_data_dir==TRUE) %>% 
              extract2("pkg_name") %>% 
              map(~package_name_to_dsc(.)) %>% 
              map(~read_dcf(.)) %>% 
              map_df(~dsc_to_df(.))
output %>% 
  saveRDS("data/parsed_descriptions.rds")
