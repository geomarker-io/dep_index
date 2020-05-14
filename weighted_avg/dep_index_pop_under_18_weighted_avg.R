suppressPackageStartupMessages(library(tidyverse))

states <- tigris::states(cb = TRUE) %>%
  select(NAME) %>%
  sf::st_drop_geometry() %>%
  filter(! NAME %in% c('Guam', 'Commonwealth of the Northern Mariana Islands',
                       'United States Virgin Islands', 'American Samoa', 'Puerto Rico'))

tract_pop_under_18 <- tidycensus::get_acs(geography = 'tract',
                                          variables = c(paste0('B01001_00', 1:6), paste0('B01001_0', 27:30)),
                                          state = states$NAME,
                                          year = 2015) %>%
  group_by(GEOID) %>%
  summarize(pop_under_18 = sum(estimate))

dep_index <- 'https://github.com/cole-brokamp/dep_index/raw/master/ACS_deprivation_index_by_census_tracts.rds' %>%
  url() %>%
  gzcon() %>%
  readRDS() %>%
  as_tibble()

dep_index <- dep_index %>%
  left_join(tract_pop_under_18, by = c('census_tract_fips' = 'GEOID'))

weighted.mean(x = dep_index$dep_index, w = dep_index$pop_under_18, na.rm = TRUE)
## about 1000 tracts are missing deprivation index

diagis::weighted_mean(x = dep_index$dep_index, w = dep_index$pop_under_18, na.rm = TRUE)
diagis::weighted_se(x = dep_index$dep_index, w = dep_index$pop_under_18, na.rm = TRUE)
