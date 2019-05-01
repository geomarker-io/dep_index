library(tidyverse)

# read deprivation index
library(tidyverse)

# Deprivation index
dep_index <- readRDS(gzcon(url('https://github.com/cole-brokamp/dep_index/raw/master/ACS_deprivation_index_by_census_tracts.rds'))) 


# ZCTA data 
ZCTA_data<- read.table("https://www2.census.gov/geo/docs/maps-data/data/rel/zcta_tract_rel_10.txt", header = TRUE,sep = ',',
                       colClasses = c('ZCTA5' = 'character' , 'GEOID' = 'character'))


# combine two data 
ZCTA_data <- dplyr::left_join(dep_index,ZCTA_data, by= c('census_tract_fips' = 'GEOID'))


# Deprivation index by Zip code
ZCTA_data<- ZCTA_data %>%
  group_by(ZCTA5) %>%
  summarize_if(is.numeric, mean, na.rm= TRUE)

write.csv(ZCTA_data, file= 'ACS_deprivation_index_by_zipcode.csv', row.names = FALSE)
saveRDS(ZCTA_data, "ACS_deprivation_index_by_zipcode.rds")
