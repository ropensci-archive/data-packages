library(tidyverse)

df <- read_csv("data/data_rd_metadata.csv")
# length(unique(df$dataset_alias))

duplicates <- df$dataset_alias[duplicated(df$dataset_alias)]

dup_df <- df %>%
  filter(dataset_alias %in% duplicates)

meta <- read_rds("data/description_metadata.rds") %>% 
  filter(Package %in% dup_df$pkg_name)
meta %>% View

