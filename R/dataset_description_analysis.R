library(forcats)
library(tidyverse)
theme_set(theme_bw())

data_cran <- read_rds("data/description_metadata.rds") %>% 
  mutate(is_data_package = factor(is_data_package, levels=c("FALSE", "TRUE"), labels=c("Non-data packages", "Data packages")))

ggplot(data_cran, aes(LazyData)) +
  geom_bar() +
  facet_wrap(~is_data_package)

ggplot(data_cran, aes(License)) +
  geom_bar() +
  coord_flip() +
  facet_wrap(~is_data_package)

ggplot(data_cran, aes(BugReports_is_not_na)) +
  geom_bar() +
  facet_wrap(~is_data_package) +
  labs(x = "Is there an BugReports in the package description?")

ggplot(data_cran, aes(URL_is_not_na)) +
  geom_bar() +
  facet_wrap(~is_data_package) +
  labs(x = "Is there an URL in the package description?")

df <- data_cran %>% 
  select(is_data_package, License) %>% 
  group_by(is_data_package, License) %>% 
  summarise(n=n())

df_wide <- df %>% 
  spread(is_data_package, n) %>% 
  mutate(`Non-data packages` = ifelse(is.na(`Non-data packages`), 0, `Non-data packages`),
         `Data packages` = ifelse(is.na(`Data packages`), 0, `Data packages`)) %>% 
  mutate(diff=`Data packages`-`Non-data packages`)

ggplot(df_wide, aes(fct_reorder(License, diff), diff)) +
  geom_col() + 
  coord_flip() +
  labs(x="License", y="<--- Non-data packages --------- Data packages --->")
 
