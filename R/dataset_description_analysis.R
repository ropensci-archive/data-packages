library(forcats)
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

df <- data_cran %>% 
  select(is_data_package, License) %>% 
  group_by(is_data_package, License) %>% 
  summarise(n=n())

df_wide <- df %>% 
  spread(is_data_package, n) %>% 
  mutate(`FALSE` = ifelse(is.na(`FALSE`), 0, `FALSE`),
         `TRUE` = ifelse(is.na(`TRUE`), 0, `TRUE`)) %>% 
  mutate(diff=`TRUE`-`FALSE`)

ggplot(df_wide, aes(fct_reorder(License, diff), diff)) +
  geom_col() + 
  coord_flip() +
  labs(x="License", y="<--- No data folder ----------- Data folder --->")
 
