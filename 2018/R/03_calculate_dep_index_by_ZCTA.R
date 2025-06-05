library(tidyverse)

dep_index <- readRDS(gzcon(url('https://github.com/cole-brokamp/dep_index/raw/master/dep_index/ACS_deprivation_index_by_census_tracts.rds')))

ZCTA_tract_crosswalk <-
  read.table("https://www2.census.gov/geo/docs/maps-data/data/rel/zcta_tract_rel_10.txt",
             header = TRUE,
             sep = ',',
             colClasses = c('ZCTA5' = 'character' , 'GEOID' = 'character')) %>%
  select(ZCTA5, GEOID)

dep_index_ZCTA <- left_join(dep_index, ZCTA_tract_crosswalk, by = c('census_tract_fips' = 'GEOID'))

# set ZCTA values as mean of all containing tract values
# make value NA if result is NaN because no non-missing values are available for a ZCTA
ZCTA_data <- dep_index_ZCTA %>%
  group_by(ZCTA5) %>%
  summarize_if(is.numeric, mean, na.rm = TRUE) %>%
  mutate_if(is.numeric, na_if, y = 'NaN')

write_csv(ZCTA_data, './2018_dep_index/ACS_deprivation_index_by_zipcode.csv')
saveRDS(ZCTA_data, "./2018_dep_index/ACS_deprivation_index_by_zipcode.rds")



