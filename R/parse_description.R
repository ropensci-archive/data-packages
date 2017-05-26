library(tidyverse)
library(magrittr)
theme_set(theme_bw())

cran <- tools:::CRAN_package_db()
names(cran)[65] <- "MD5sum_rep"

pkg_names <- read_rds("pkg_data_data.rds") %>% 
  filter(has_data_dir==TRUE) %>% 
  extract2("pkg_name") 

data_cran <- cran %>%
  as_data_frame() %>% 
  filter(Package %in% pkg_names) %>% 
  select(Package, Depends, Imports, LinkingTo, Suggests, Enhances, License,
         Author, BugReports,
         Copyright, Description, LazyData, LazyDataCompression, LazyLoad,
         Maintainer, URL, ZipData, Published, `Reverse depends`, `Reverse imports`,
         `Reverse linking to`, `Reverse suggests`, `Reverse enhances`) %>% 
  mutate(BugReports_is_na = is.na(BugReports)) %>% 
  saveRDS(., "data/description_metadata.rds")
# 
# ggplot(data_cran, aes(LazyData)) +
#   geom_bar()
# 
# ggplot(data_cran, aes(LazyDataCompression)) +
#   geom_bar()
# 
# ggplot(data_cran, aes(LazyLoad)) +
#   geom_bar()
# 
# ggplot(data_cran, aes(License)) +
#   geom_bar() +
#   coord_flip()
# 
# ggplot(data_cran, aes(BugReports_is_na)) +
#   geom_bar()
