library(tidyverse)

dep_index <- 'https://github.com/cole-brokamp/dep_index/raw/master/ACS_deprivation_index_by_census_tracts.rds' %>% 
  url() %>% 
  gzcon() %>% 
  readRDS() %>% 
  as_tibble() %>% 
  select(census_tract_fips, 
         dep_index_2015 = dep_index)

dep_index_2018 <- readRDS('./2018_dep_index/ACS_deprivation_index_by_census_tracts.rds') %>% 
  select(census_tract_fips, 
         dep_index_2018 = dep_index)

compare_dep <- left_join(dep_index, dep_index_2018, by = 'census_tract_fips')

ggplot() + 
  geom_point(aes(x = dep_index_2015, y = dep_index_2018), 
             data = compare_dep) + 
  ggpubr::stat_cor(aes(x = dep_index_2015, y = dep_index_2018), 
                   data = compare_dep)
ggsave('./2018_dep_index/2015_vs_2018.png')

cor.test(x = compare_dep$dep_index_2015, y = compare_dep$dep_index_2018)
