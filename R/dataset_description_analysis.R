library(tidyverse)

data_cran <- read_rds("data/description_metadata.rds")

ggplot(data_cran, aes(LazyData)) +
  geom_bar() +
  facet_wrap(~is_data_package)

ggplot(data_cran, aes(LazyDataCompression)) +
  geom_bar() +
  facet_wrap(~is_data_package)

ggplot(data_cran, aes(License)) +
  geom_bar() +
  coord_flip() +
  facet_wrap(~is_data_package)

ggplot(data_cran, aes(BugReports_is_na)) +
  geom_bar() +
  facet_wrap(~is_data_package)

ggplot(data_cran, aes(URL_is_na)) +
  geom_bar() +
  facet_wrap(~is_data_package)
