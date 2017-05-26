library(tidyverse)
library(magrittr)
theme_set(theme_bw())

cran <- tools:::CRAN_package_db()
names(cran)[65] <- "MD5sum_rep"

pkg_names <- read_rds("data/pkg_data_data.rds") %>% 
  filter(has_data_dir==TRUE) %>% 
  extract2("pkg_name") 

data_cran <- cran %>%
  as_data_frame() %>% 
  mutate(is_data_package = Package %in% pkg_names) %>% 
  select(Package, Depends, Imports, LinkingTo, Suggests, Enhances, License,
         Author, BugReports,
         Copyright, Description, LazyData, LazyDataCompression, LazyLoad,
         Maintainer, URL, ZipData, Published, `Reverse depends`, `Reverse imports`,
         `Reverse linking to`, `Reverse suggests`, `Reverse enhances`, is_data_package) %>% 
  mutate(BugReports_is_na = is.na(BugReports),
         URL_is_na = is.na(URL)) %>% 
  saveRDS(., "data/description_metadata.rds")
