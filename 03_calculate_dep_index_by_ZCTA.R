library(tidyverse)

dep_index <- readRDS(gzcon(url('https://github.com/cole-brokamp/dep_index/raw/master/ACS_deprivation_index_by_census_tracts.rds'))) 

ZCTA_data <- read.table("https://www2.census.gov/geo/docs/maps-data/data/rel/zcta_tract_rel_10.txt", header = TRUE,sep = ',',
                       colClasses = c('ZCTA5' = 'character' , 'GEOID' = 'character')) %>%
select(ZCTA5, GEOID)

ZCTA_tract_data <- dplyr::left_join(dep_index, ZCTA_data, by = c('census_tract_fips' = 'GEOID')) %>%
  group_by(ZCTA5) %>%
  summarize_if(is.numeric, mean, na.rm= TRUE)

write.csv(ZCTA_tract_data, file= 'ACS_deprivation_index_by_zipcode.csv', row.names = FALSE)
saveRDS(ZCTA_tract_data, "ACS_deprivation_index_by_zipcode.rds")
